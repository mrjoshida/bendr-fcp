#include <metal_stdlib>
#include "../../Shared/Metal/BendrCommon.h"

using namespace metal;

struct VHSParams {
    float chromaBleed;
    float chromaDelay;
    float lumaBleed;
    float bleedDir;
    float vBleed;
    float rainbow;
    float dotCrawl;
    float ringing;
    float signalNoise;
    float chromaNoise;

    float hWobble;
    float wobbleFreq;
    float tear;
    float tearSize;
    float vRoll;
    float jitter;
    float humBar;

    float tapeSpeed;
    float tracking;
    float trackPhase;
    float trackHunt;
    float dropout;
    float dropoutLen;
    float chromaLoss;
    float crease;
    float creasePos;
    float headClog;
    float azimuth;
    float headSwitch;
    float tapeWow;
    float wowRate;
    float flutter;
    float tapeStretch;
    float edgeDmg;
    float printThru;
    float hiss;
    float stillNoise;
    float shuttleNz;
    float genLoss;
    float genCount;

    // hidden/globals
    float time;
    float frame;
    float rows;
    float vrollpos;
    float humpos;
    float rollBar;
};

// rgb2yiq and yiq2rgb
float3 rgb2yiq(float3 c) {
    return float3(
        dot(c, float3(0.299, 0.587, 0.114)),
        dot(c, float3(0.596, -0.274, -0.322)),
        dot(c, float3(0.211, -0.523, 0.312))
    );
}

float3 yiq2rgb(float3 c) {
    return float3(
        dot(c, float3(1.0, 0.956, 0.621)),
        dot(c, float3(1.0, -0.272, -0.647)),
        dot(c, float3(1.0, -1.106, 1.703))
    );
}

float lum(texture2d<float, access::sample> tex, sampler s, float2 p) {
    float3 c = tex.sample(s, p).rgb;
    return dot(c, float3(0.299, 0.587, 0.114));
}

float h21(float2 p) {
    // Basic PRNG for shaders
    float3 p3  = fract(float3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

kernel void bendrVHS(
    texture2d<float, access::sample> inTex [[texture(0)]],
    texture2d<float, access::write> outTex [[texture(1)]],
    texture2d<float, access::sample> dispTex [[texture(2)]],
    constant VHSParams& u [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;

    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    constexpr sampler point_s(coord::pixel, address::clamp_to_edge, filter::nearest);

    float2 u_res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = float2(gid) / u_res;
    uv.y = 1.0 - uv.y; // flipped Y if needed, assuming standard fcp UVs

    float t = u.time;
    float row = uv.y * u.rows;
    int i0 = clamp(int(row), 0, int(u.rows) - 1);
    int i1 = min(i0 + 1, int(u.rows) - 1);
    
    float4 d0 = dispTex.read(uint2(0, i0));
    float4 d1 = dispTex.read(uint2(0, i1));
    float4 D = mix(d0, d1, fract(row));

    float dx = D.x, rowGain = D.y, noiseG = D.z, hfl = clamp(D.w, 0.0, 1.0);
    
    float gEff = 1.0 - pow(1.0 - clamp(u.genLoss, 0.0, 0.98) * 0.5, max(u.genCount, 1.0));
    float sp = u.tapeSpeed;
    float rowI = floor(uv.y * u_res.y);
    
    dx += (h21(float2(rowI, floor(t * 479.0))) - 0.5) * 0.0018 * u.jitter;
    
    float dy = u.vrollpos + ((fmod(u.frame, 2.0) < 1.0) ? 0.5 : -0.5) * (0.25 + 0.75 * u.jitter) / u_res.y;
    float2 suv = float2(uv.x + dx, fract(uv.y + dy));
    
    float px = 1.0 / u_res.x;
    float3 c0 = rgb2yiq(inTex.sample(s, fract(suv)).rgb);
    float y = c0.x;
    
    float yl = lum(inTex, s, suv - float2(2.0 * px, 0.0));
    float yr = lum(inTex, s, suv + float2(2.0 * px, 0.0));
    y += u.ringing * 1.4 * (y - 0.5 * (yl + yr));
    
    float2 iq = float2(0.0);
    float spread = mix(0.6, 11.0, u.chromaBleed) * (1.0 + sp * 1.7 + gEff * 1.1 + hfl * 2.2);
    float cdel = u.chromaDelay * 10.0 * px;
    
    float iqw = 0.0;
    for (int i = 0; i < 9; i++) {
        float fi = float(i) - 4.0;
        float2 tp = suv + float2(fi * spread * px - cdel, 0.0);
        float inb = step(0.0, tp.x) * step(tp.x, 1.0);
        iq += rgb2yiq(inTex.sample(s, clamp(tp, 0.0, 1.0)).rgb).yz * inb;
        iqw += inb;
    }
    iq /= max(iqw, 1.0);
    
    float edge = lum(inTex, s, suv + float2(px, 0.0)) - lum(inTex, s, suv - float2(px, 0.0));
    float ph = suv.x * u_res.x * 1.85 + rowI * 2.3 + t * 10.0;
    iq += u.rainbow * edge * 2.6 * float2(sin(ph), cos(ph * 0.93));
    
    float crawl = sin(suv.x * u_res.x * 3.14159 + rowI * 3.14159 + t * 7.0);
    y += u.dotCrawl * length(iq) * crawl * 0.35;
    
    float ys = 0.25 * (
        lum(inTex, s, suv - float2(3.0 * px, 0.0)) + 
        lum(inTex, s, suv + float2(3.0 * px, 0.0)) + 
        lum(inTex, s, suv - float2(6.0 * px, 0.0)) + 
        lum(inTex, s, suv + float2(6.0 * px, 0.0))
    );
    y = mix(y, ys, clamp(gEff * 0.7 + sp * 0.35 + hfl * 0.9, 0.0, 1.0));
    iq *= 1.0 - clamp(gEff * 0.45 + sp * 0.25 + hfl * 0.7, 0.0, 1.0);
    
    if (u.chromaLoss > 0.003) {
        float cs = h21(float2(rowI * 0.37, floor(t * 3.0)));
        float band = smoothstep(1.0 - u.chromaLoss, 1.02 - u.chromaLoss, cs);
        iq *= 1.0 - u.chromaLoss * (0.45 + 0.55 * band);
    }
    
    if (u.printThru > 0.003) {
        float3 gh = rgb2yiq(inTex.sample(s, fract(suv + float2(0.004 * u.printThru, 0.055 * u.printThru))).rgb);
        y += (gh.x - 0.5) * u.printThru * 0.22;
    }
    
    if (u.lumaBleed > 0.003) {
        float bdir = (u.bleedDir >= 0.0) ? 1.0 : -1.0;
        float bstep = (2.0 + 9.0 * abs(u.bleedDir)) * px * bdir;
        float fall = 0.22 * (1.05 - u.lumaBleed);
        float acc = y;
        for (int k = 1; k <= 6; k++) {
            float sx = suv.x - float(k) * bstep;
            if (sx < 0.0 || sx > 1.0) continue;
            acc = max(acc, lum(inTex, s, float2(sx, suv.y)) - float(k) * fall);
        }
        y = mix(y, acc, min(1.0, u.lumaBleed * 1.4));
    }
    
    if (u.vBleed > 0.003) {
        float pyx = 1.0 / u_res.y;
        float2 iqv = float2(0.0);
        float wsum = 0.0;
        for (int k = 1; k <= 4; k++) {
            float w = 1.0 / float(k);
            float2 tp = suv + float2(0.0, float(k) * (1.0 + u.vBleed * 5.0) * pyx);
            float inb = step(0.0, tp.y) * step(tp.y, 1.0);
            iqv += w * inb * rgb2yiq(inTex.sample(s, clamp(tp, 0.0, 1.0)).rgb).yz;
            wsum += w * inb;
        }
        iq = mix(iq, iqv / max(wsum, 0.0001), u.vBleed * 0.75 * step(0.0001, wsum));
    }
    
    float nx = suv.x * u_res.x / 3.5;
    float nseed = rowI * 7.13 + floor(t * 61.0) * 13.7;
    float nb = mix(h21(float2(floor(nx), nseed)), h21(float2(floor(nx) + 1.0, nseed)), smoothstep(0.0, 1.0, fract(nx)));
    float streak = smoothstep(0.55, 0.95, h21(float2(rowI, floor(t * 61.0) + 3.0)));
    y += (nb - 0.5) * (u.signalNoise * (0.22 + 0.85 * streak) + noiseG * 0.55 + gEff * 0.14 + sp * 0.05);
    
    if (u.hiss > 0.003) y += (h21(uv * u_res * 1.7 + fract(t) * float2(91.3, 57.1)) - 0.5) * u.hiss * 0.28;
    y += (h21(suv * u_res + fract(t) * float2(31.7, 17.3)) - 0.5) * u.signalNoise * 0.1;
    iq += (float2(h21(float2(floor(nx) * 1.7, nseed + 31.0)), h21(float2(floor(nx) * 2.3, nseed + 57.0))) - 0.5) * u.chromaNoise * 0.55;
    iq *= 1.0 / (1.0 + noiseG * 2.5);
    
    float dr = h21(float2(rowI * 1.31, floor(t * 24.0)));
    if (dr < u.dropout * 0.05 * (1.0 + sp * 1.5)) {
        float xs = h21(float2(rowI, floor(t * 24.0) + 7.0));
        float len = (0.06 + h21(float2(rowI, 99.0)) * 0.5) * (0.25 + u.dropoutLen * 2.4);
        float f = (suv.x - xs) / len;
        if (f > 0.0 && f < 1.0) { 
            float k = pow(1.0 - f, 1.8) * 0.95; 
            y = mix(y, 1.05, k); 
            iq *= 1.0 - k; 
        }
    }
    
    if (u.edgeDmg > 0.003) {
        float ed = smoothstep(0.10 * u.edgeDmg + 0.02, 0.0, min(uv.y, 1.0 - uv.y));
        float en = h21(float2(floor(suv.x * u_res.x / 2.0), rowI + floor(t * 50.0) * 3.0));
        y = mix(y, en * 0.9, ed * u.edgeDmg);
        iq *= 1.0 - ed * u.edgeDmg;
    }
    
    float stAmt = max(u.stillNoise, 0.0); // assuming u_tpStill maps to stillNoise for now
    if (stAmt > 0.003) {
        float bp = fract(0.5 + t * 0.03);
        float bd = abs(fract(uv.y - bp + 0.5) - 0.5);
        float bm = smoothstep(0.045 * stAmt + 0.004, 0.0, bd);
        float bn = h21(float2(floor(suv.x * u_res.x / 2.5), rowI * 1.7 + floor(t * 50.0) * 11.0));
        y = mix(y, bn, bm * 0.95); 
        iq *= 1.0 - bm * 0.9;
    }
    
    float shA = max(u.shuttleNz, 0.0);
    if (shA > 0.003) {
        float dir = 1.0;
        float nb2 = 3.0 + floor(shA * 7.0);
        float ph2 = fract(uv.y * nb2 - t * dir * 1.6);
        float bm2 = smoothstep(0.55, 0.98, ph2) * shA;
        float sn = h21(float2(floor(suv.x * u_res.x / 2.0), rowI + floor(t * 50.0) * 7.0));
        y = mix(y, sn * 0.85, bm2 * 0.9); 
        iq *= 1.0 - bm2 * 0.85;
    }
    
    float hb = smoothstep(0.18, 0.0, abs(fract(uv.y - u.humpos) - 0.5)) * u.humBar;
    y -= hb * 0.25;
    
    float bw2 = min(suv.y, 1.0 - suv.y);
    float bar = smoothstep(0.05, 0.018, bw2) * u.rollBar;
    if (bar > 0.001) { 
        float syncp = 0.03 + 0.2 * h21(float2(floor(suv.x * 32.0), rowI)); 
        y = mix(y, syncp, bar * 0.92); 
        iq *= 1.0 - bar * 0.9; 
    }
    
    y = (y - 0.02) * rowGain + 0.02 - (1.0 - rowGain) * 0.06;
    float3 wet = yiq2rgb(float3(y, iq));
    
    outTex.write(float4(wet, inTex.sample(s, uv).a), gid);
}
