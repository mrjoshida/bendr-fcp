#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct OpticsParams {
    float lensCA;
    float lensStreak;
    float streakHue;
    float bloom;
    float bloomRad;
    float halation;
    float vignette;
    float lensSmudge;
    float lightLeak;
    float leakHue;
    float gateHair;
    float dust;
    float scratches;
    float grain;
    float lcdGrid;
    float osdShow;
    float osdMode;
    float osdGlow;
    float time;
    float2 res;
};

// 7-segment bitmask table in global constant memory
constant uint segMasks[10] = {
    0x77, // 0: A B C D E F
    0x24, // 1: B C
    0x5D, // 2: A B D E G
    0x6D, // 3: A B C D G
    0x2E, // 4: B C F G
    0x6B, // 5: A C D F G
    0x7B, // 6: A C D E F G
    0x25, // 7: A B C
    0x7F, // 8: A B C D E F G
    0x6F  // 9: A B C D F G
};

// Simple 2D FBM for smudge & leaks
inline float fbmOptics(float2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 3; i++) {
        float2 ip = floor(p), fp = fract(p);
        fp = fp * fp * (3.0 - 2.0 * fp);
        float n = mix(mix(h21(ip), h21(ip + float2(1.0, 0.0)), fp.x),
                      mix(h21(ip + float2(0.0, 1.0)), h21(ip + float2(1.0, 1.0)), fp.x), fp.y);
        v += a * n;
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

// 7-segment digit raster for camcorder OSD
inline float drawDigit(int d, float2 p) {
    if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0) return 0.0;
    uint s = segMasks[clamp(d, 0, 9)];
    float w = 0.18;
    float hit = 0.0;
    if ((s & 0x01u) && p.y > 0.85 && p.x > 0.1 && p.x < 0.9) hit = 1.0;
    if ((s & 0x02u) && p.y > 0.50 && p.y < 0.85 && p.x < w) hit = 1.0;
    if ((s & 0x04u) && p.y > 0.50 && p.y < 0.85 && p.x > 1.0 - w) hit = 1.0;
    if ((s & 0x08u) && p.y > 0.42 && p.y < 0.58 && p.x > 0.1 && p.x < 0.9) hit = 1.0;
    if ((s & 0x10u) && p.y > 0.15 && p.y < 0.50 && p.x < w) hit = 1.0;
    if ((s & 0x20u) && p.y > 0.15 && p.y < 0.50 && p.x > 1.0 - w) hit = 1.0;
    if ((s & 0x40u) && p.y < 0.15 && p.x > 0.1 && p.x < 0.9) hit = 1.0;
    return hit;
}

kernel void bendrOptics(
    texture2d<float, access::sample> inTex  [[texture(0)]],
    texture2d<float, access::write>  outTex [[texture(1)]],
    constant OpticsParams &p                [[buffer(0)]],
    uint2 gid                               [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float ar = p.res.x / p.res.y;

    // Chromatic Aberration
    float3 c = float3(0.0);
    if (p.lensCA > 0.001) {
        float2 caOff = (uv - 0.5) * p.lensCA * 0.035;
        float r = inTex.sample(smp, clamp(uv + caOff, 0.0, 1.0)).r;
        float g = inTex.sample(smp, uv).g;
        float b = inTex.sample(smp, clamp(uv - caOff, 0.0, 1.0)).b;
        c = float3(r, g, b);
    } else {
        c = inTex.sample(smp, uv).rgb;
    }
    float alpha = inTex.sample(smp, uv).a;

    // Anamorphic Lens Flare Streak
    if (p.lensStreak > 0.003) {
        float3 st = float3(0.0);
        float sw = 0.0;
        for (int i = 1; i <= 10; i++) {
            float o = float(i) * (0.006 + p.bloomRad * 0.02);
            float ww = 1.0 / float(i);
            float2 lp = uv + float2(o, 0.0), rp = uv - float2(o, 0.0);
            float li = step(0.0, lp.x) * step(lp.x, 1.0);
            float ri = step(0.0, rp.x) * step(rp.x, 1.0);
            st += max(inTex.sample(smp, clamp(lp, 0.0, 1.0)).rgb - 0.55, 0.0) * ww * li;
            st += max(inTex.sample(smp, clamp(rp, 0.0, 1.0)).rgb - 0.55, 0.0) * ww * ri;
            sw += ww * 2.0;
        }
        st /= max(sw, 0.0001);
        float3 streakTint = mix(float3(1.0), float3(0.3, 0.6, 1.8), p.streakHue);
        c += st * p.lensStreak * 7.0 * streakTint;
    }

    // Optical Highlight Bloom & Film Halation
    if (p.bloom > 0.003 || p.halation > 0.003) {
        float br = (0.004 + p.bloomRad * 0.025);
        float3 b1 = inTex.sample(smp, clamp(uv + float2( br, 0.0), 0.0, 1.0)).rgb;
        float3 b2 = inTex.sample(smp, clamp(uv - float2( br, 0.0), 0.0, 1.0)).rgb;
        float3 b3 = inTex.sample(smp, clamp(uv + float2(0.0,  br), 0.0, 1.0)).rgb;
        float3 b4 = inTex.sample(smp, clamp(uv - float2(0.0,  br), 0.0, 1.0)).rgb;
        float3 bloomCol = max((b1 + b2 + b3 + b4) * 0.25 - 0.4, 0.0);
        
        c += bloomCol * p.bloom * 1.8;
        if (p.halation > 0.003) {
            c += float3(bloomCol.r * 2.2, bloomCol.g * 0.3, bloomCol.b * 0.05) * p.halation * 2.0;
        }
    }

    // Optical Lens Vignette
    if (p.vignette > 0.001) {
        float2 vp = (uv - 0.5) * float2(ar, 1.0);
        c *= 1.0 - p.vignette * 0.9 * pow(length(vp * 0.75), 2.6);
    }

    // Dirty Glass Smudge (gated on highlights)
    if (p.lensSmudge > 0.003) {
        float sm = fbmOptics(uv * float2(5.0, 3.0)) * fbmOptics(uv * float2(11.0, 7.0) + 4.4);
        sm = smoothstep(0.18, 0.62, sm);
        float hl = max(luma(c) - 0.35, 0.0);
        c += sm * hl * p.lensSmudge * 1.6;
        c = mix(c, c * (1.0 - sm * 0.35), p.lensSmudge * 0.4);
    }

    // Film Light Leak / Edge Fogging
    if (p.lightLeak > 0.003) {
        float ang = p.time * 0.043;
        float2 dir = float2(cos(ang), sin(ang));
        float g = clamp(dot(uv - 0.5, dir) * 1.6 + 0.55, 0.0, 1.0);
        g = pow(g, 2.4) * (0.55 + 0.45 * sin(p.time * 0.61) * 0.5 + 0.225);
        g *= 0.75 + 0.25 * fbmOptics(uv * 3.0 + p.time * 0.05);
        float3 leakCol = hsv2rgb(float3(fract(p.leakHue), 0.75, 1.0));
        c += g * p.lightLeak * 1.1 * leakCol;
    }

    // Projector Gate Hair
    if (p.gateHair > 0.003) {
        float sway = (h21(float2(floor(p.time * 1.3 * 24.0), 2.0)) - 0.5) * 0.05;
        float hx = 0.26 + sway + sin(uv.y * 9.0 + p.time * 0.4) * 0.02;
        float hair = 1.0 - smoothstep(0.0008, 0.0026, abs(uv.x - hx));
        hair *= smoothstep(1.0, 0.72, uv.y);
        c = mix(c, c * 0.12, hair * p.gateHair);
    }

    // Film Dust & Lint
    if (p.dust > 0.003) {
        float d = h21(floor(uv * float2(180.0, 140.0)) + floor(p.time * 8.0) * 13.0);
        if (d > 1.0 - p.dust * 0.012) c += 0.7;
        float dk = h21(floor(uv * float2(150.0, 120.0)) + 77.0);
        if (dk > 1.0 - p.dust * 0.008) c *= 0.25;
    }

    // Film Scratches
    if (p.scratches > 0.003) {
        float sx = h21(float2(floor(uv.x * 90.0), floor(p.time * 3.0)));
        if (sx > 1.0 - p.scratches * 0.05) {
            c += float3(0.35) * smoothstep(0.0, 0.3, uv.y);
        }
    }

    // Film Grain (dynamic per frame)
    if (p.grain > 0.003) {
        float gn = h21(float2(gid) + fract(p.time) * float2(37.7, 71.3));
        c += (gn - 0.5) * p.grain * 0.16 * (0.35 + 0.65 * (1.0 - luma(c)));
    }

    // LCD Subpixel Grid
    if (p.lcdGrid > 0.003) {
        float2 lg = fract(float2(gid) / 3.0);
        float gx = smoothstep(0.0, 0.16, lg.x) * smoothstep(1.0, 0.84, lg.x);
        float gy = smoothstep(0.0, 0.22, lg.y) * smoothstep(1.0, 0.78, lg.y);
        c *= mix(1.0, gx * gy * 1.22, p.lcdGrid);
    }

    // Retro Camcorder On-Screen Display (OSD HUD)
    if (p.osdShow > 0.003) {
        // REC indicator top-left (flashing red dot + REC text)
        if (uv.x > 0.05 && uv.x < 0.14 && uv.y > 0.86 && uv.y < 0.94) {
            float dRec = length((uv - float2(0.07, 0.90)) * float2(ar, 1.0));
            if (dRec < 0.014 && fract(p.time * 1.2) > 0.3) {
                c = mix(c, float3(1.0, 0.1, 0.1), p.osdShow);
            }
        }
        // Timecode bottom-right
        if (uv.x > 0.70 && uv.x < 0.95 && uv.y > 0.06 && uv.y < 0.14) {
            float2 tcPos = (uv - float2(0.70, 0.06)) / float2(0.25, 0.08);
            uint totalSec = uint(max(0.0, p.time));
            uint sec = totalSec % 60u;
            uint min = (totalSec / 60u) % 60u;
            int d1 = int(min / 10u), d2 = int(min % 10u);
            int d3 = int(sec / 10u), d4 = int(sec % 10u);
            float charX = tcPos.x * 6.0;
            int digitIdx = int(floor(charX));
            float2 charUV = float2(fract(charX), tcPos.y);
            float dVal = 0.0;
            if (digitIdx == 0) dVal = drawDigit(d1, charUV);
            else if (digitIdx == 1) dVal = drawDigit(d2, charUV);
            else if (digitIdx == 2) dVal = ((charUV.y > 0.3 && charUV.y < 0.45 && abs(charUV.x - 0.5) < 0.12) || (charUV.y > 0.55 && charUV.y < 0.7 && abs(charUV.x - 0.5) < 0.12)) ? 1.0 : 0.0;
            else if (digitIdx == 3) dVal = drawDigit(d3, charUV);
            else if (digitIdx == 4) dVal = drawDigit(d4, charUV);
            
            float3 hudCol = mix(float3(0.95), float3(0.2, 1.0, 0.4), p.osdGlow);
            c = mix(c, hudCol, dVal * p.osdShow);
        }
    }

    outTex.write(float4(clamp(c, 0.0, 2.0), alpha), gid);
}
