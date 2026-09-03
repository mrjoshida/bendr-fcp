#include <metal_stdlib>
using namespace metal;

struct Constants {
    float2 procRes;
    float scanlines, beamWidth, beamShape, aperture, maskDark, curvature, cornerRound;
    float vignette, time, outModel, hasPersist;
    float bloom, bloomRad, halation, defocus, grain;
    float outGamma, outBright, outContrast, outSat, outWarmth, blackLevel, whiteClip;
    float phosphor, hvSag;
    float letterbox, pillarbox, bezel, glassRefl, dust, scratches, ovMoire, rollShutter, safeArea;
    float lensDist, lensCA, lensStreak, streakHue, lensSmudge;
    float lightLeak, leakHue, gateWeave, gateHair, stuckPix, lcdGrid;
    float osdShow, osdGlow, probe, rows;
};

#include "../../Shared/Metal/BendrCommon.h"

inline float vnoise(float2 p) {
    float2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = h21(i), b = h21(i + float2(1.0, 0.0));
    float c2 = h21(i + float2(0.0, 1.0)), d2 = h21(i + float2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c2, d2, f.x), f.y);
}

inline float fbm2(float2 p) {
    return vnoise(p) * 0.6 + vnoise(p * 2.1 + 7.3) * 0.3 + vnoise(p * 4.3 + 13.1) * 0.1;
}

inline float lum3(float3 c) { return dot(c, float3(0.299, 0.587, 0.114)); }

inline float3 hsvOut(float3 c) {
    float3 q = abs(fract(c.xxx + float3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0);
    return c.z * mix(float3(1.0), clamp(q - 1.0, 0.0, 1.0), c.y);
}

float3 maskAt(float2 fc, float model, float maskDark) {
    float dark = 1.0 - maskDark * 0.55;
    if(model < 1.5) { 
        float m = fmod(fc.x, 3.0);
        return float3(m < 1.0 ? 1.0 : dark, (m >= 1.0 && m < 2.0) ? 1.0 : dark, m >= 2.0 ? 1.0 : dark); 
    }
    if(model < 2.5) { 
        float2 g = floor(fc / float2(3.0, 6.0));
        float off = fmod(g.y, 2.0) * 1.5;
        float m = fmod(fc.x + off, 3.0);
        float v = fmod(fc.y, 6.0) < 5.0 ? 1.0 : dark;
        return float3(m < 1.0 ? 1.0 : dark, (m >= 1.0 && m < 2.0) ? 1.0 : dark, m >= 2.0 ? 1.0 : dark) * v; 
    }
    if(model < 3.5) { 
        float2 q = fc / float2(6.0, 6.0);
        float2 f = fract(q) - 0.5;
        float r = length(f);
        float tri = fmod(floor(q.x) + floor(q.y) * 2.0, 3.0);
        float3 t = float3(tri < 0.5 ? 1.0 : dark, (tri >= 0.5 && tri < 1.5) ? 1.0 : dark, tri >= 1.5 ? 1.0 : dark);
        return t * (1.0 - smoothstep(0.28, 0.5, r) * maskDark); 
    }
    if(model < 4.5) { 
        float m = fmod(fc.x, 2.0);
        return mix(float3(1.0), float3(m < 1.0 ? 1.06 : dark), 0.85); 
    }
    return float3(1.0);
}

// Compute kernel
kernel void bendrCRT(texture2d<float, access::sample> u_tex [[texture(0)]],
                   texture2d<float, access::sample> u_persist [[texture(1)]],
                   texture2d<float, access::write> outTex [[texture(2)]],
                   constant Constants& u [[buffer(0)]],
                   uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    float2 res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = float2(gid) / res;
    
    float2 p = uv * 2.0 - 1.0;
    
    float sag = 0.0;
    if(u.hvSag > 0.003) { 
        sag = u.hvSag * 0.035 * (lum3(u_tex.sample(s, float2(0.5)).rgb) + 0.35); 
    }
    
    p *= 1.0 + u.curvature * 0.09 * dot(p, p) - sag;
    float2 cuv = p * 0.5 + 0.5;
    
    if(abs(u.lensDist) > 0.003) {
        float2 dl = cuv - 0.5; 
        float r2 = dot(dl, dl);
        cuv = 0.5 + dl * (1.0 + u.lensDist * 0.9 * r2);
    }
    
    if(u.gateWeave > 0.003) {
        float tw = u.time * 1.7;
        float2 wv = float2(vnoise(float2(tw, 3.1)) - 0.5, vnoise(float2(tw * 0.8 + 11.0, 7.9)) - 0.5);
        wv += float2(0.0, (h21(float2(floor(u.time * 24.0), 5.0)) - 0.5) * 0.35);
        cuv += wv * u.gateWeave * 0.03;
    }
    
    float2 ab = abs(p) - float2(1.0 - u.cornerRound * 0.18);
    float corner = length(max(ab, 0.0)) - u.cornerRound * 0.18;
    
    float caa = 1.0 / res.x * 0.75 + 1e-6; // approx fwidth
    float tube = 1.0 - smoothstep(-caa, caa, corner);
    
    float2 ed = min(cuv, 1.0 - cuv);
    float2 ew = float2(1.0) / res * 0.75 + float2(1e-6);
    tube *= smoothstep(0.0, ew.x, ed.x) * smoothstep(0.0, ew.y, ed.y);
    
    if(tube <= 0.0) { outTex.write(float4(0.0, 0.0, 0.0, 1.0), gid); return; }
    
    if(u.rollShutter > 0.003) { cuv.y += sin((uv.y * 3.0 + u.time * 0.7) * 3.14159) * u.rollShutter * 0.004; }
    
    float3 c = u_tex.sample(s, clamp(cuv, 0.0, 1.0)).rgb;
    
    if(u.lensCA > 0.003) {
        float2 dc = cuv - 0.5;
        float kr = 1.0 + u.lensCA * 0.012, kb = 1.0 - u.lensCA * 0.012;
        c.r = u_tex.sample(s, clamp(0.5 + dc * kr, 0.0, 1.0)).r;
        c.b = u_tex.sample(s, clamp(0.5 + dc * kb, 0.0, 1.0)).b;
    }
    
    if(u.phosphor > 0.003 && u.hasPersist > 0.5) {
        c = max(c, u_persist.sample(s, clamp(cuv, 0.0, 1.0)).rgb);
    }
    
    if(u.defocus > 0.003 || u.bloom > 0.003) {
        float2 px = 1.0 / res;
        float3 blur = float3(0.0); float wsum = 0.0;
        float rad = (1.5 + u.bloomRad * 16.0);
        for(int i = 0; i < 12; i++) {
            float a = float(i) * 0.5236;
            float r = (1.0 + fmod(float(i), 3.0)) * 0.45;
            float2 off = float2(cos(a), sin(a)) * rad * r * px;
            float2 tp = cuv + off;
            float inb = step(0.0, tp.x) * step(tp.x, 1.0) * step(0.0, tp.y) * step(tp.y, 1.0);
            float w = inb / (1.0 + r * 1.4);
            blur += u_tex.sample(s, clamp(tp, 0.0, 1.0)).rgb * w; wsum += w;
        }
        blur = (wsum > 0.0001) ? blur / wsum : c;
        c = mix(c, blur, u.defocus * 0.85);
        if(u.bloom > 0.003) {
            float3 hot = max(blur - 0.42, 0.0) * 1.9;
            float3 tint = mix(float3(1.0), float3(1.25, 0.62, 0.42), u.halation);
            c += hot * u.bloom * 1.5 * tint;
        }
    }
    
    float model = u.outModel;
    if(model > 0.5) {
        float lines = (u.rows > 0.0 && u.rows <= 720.0) ? u.rows : 480.0;
        float fy = fract(cuv.y * lines) - 0.5;
        float bright = lum3(c);
        float w = u.beamWidth * (0.35 + 0.65 * mix(1.0, bright, u.beamShape));
        float beam = exp(-(fy * fy) / max(0.008, w * w * 0.22));
        c *= mix(1.0, beam * 1.35, u.scanlines);
        c *= mix(float3(1.0), maskAt(float2(gid), model, u.maskDark), u.aperture);
        if(model > 4.5) c = mix(c, float3(lum3(c)), 0.85);
        if(model > 5.5) c *= float3(0.75, 1.0, 0.8);
    }
    
    c = max(c - u.blackLevel, 0.0);
    c = pow(max(c, 0.0), float3(1.0 / max(0.05, u.outGamma)));
    c = (c - 0.5) * u.outContrast + 0.5 + u.outBright;
    float L = lum3(c);
    c = mix(float3(L), c, u.outSat);
    c *= mix(float3(1.0), float3(1.12, 1.0, 0.86), max(u.outWarmth, 0.0)) * mix(float3(1.0), float3(0.86, 1.0, 1.14), max(-u.outWarmth, 0.0));
    c = min(c, float3(u.whiteClip));
    
    c *= 1.0 - u.vignette * 0.9 * pow(length(p * 0.75), 2.6);
    
    if(u.glassRefl > 0.003) {
        float g = smoothstep(0.75, 0.0, length(uv - float2(0.28, 0.78)));
        c += g * u.glassRefl * 0.16;
        c += smoothstep(0.5, 0.0, abs(uv.x - uv.y * 0.4 - 0.15)) * u.glassRefl * 0.05;
    }
    if(u.bezel > 0.003) {
        float edge = smoothstep(0.0, 0.06, min(min(cuv.x, 1.0 - cuv.x), min(cuv.y, 1.0 - cuv.y)));
        c = mix(c * 0.15, c, mix(1.0, edge, u.bezel));
    }
    if(u.ovMoire > 0.003) {
        float mo = sin(float(gid.x) * 2.399) * sin(float(gid.y) * 2.017);
        c *= 1.0 + mo * u.ovMoire * 0.18;
    }
    if(u.dust > 0.003) {
        float d = h21(floor(uv * float2(180.0, 140.0)) + floor(u.time * 8.0) * 13.0);
        if(d > 1.0 - u.dust * 0.012) c += 0.7;
        float dk = h21(floor(uv * float2(150.0, 120.0)) + 77.0);
        if(dk > 1.0 - u.dust * 0.008) c *= 0.25;
    }
    if(u.scratches > 0.003) {
        float sx = h21(float2(floor(uv.x * 90.0), floor(u.time * 3.0)));
        if(sx > 1.0 - u.scratches * 0.05) c += float3(0.35) * smoothstep(0.0, 0.3, uv.y);
    }
    if(u.grain > 0.003) {
        float gn = h21(float2(gid) + fract(u.time) * float2(37.7, 71.3));
        c += (gn - 0.5) * u.grain * 0.16 * (0.35 + 0.65 * (1.0 - lum3(c)));
    }
    
    if(u.lensStreak > 0.003) {
        float3 st = float3(0.0); float sw = 0.0;
        for(int i = 1; i <= 10; i++) {
            float o = float(i) * (0.006 + u.bloomRad * 0.02);
            float ww = 1.0 / float(i);
            float2 lp = cuv + float2(o, 0.0), rp = cuv - float2(o, 0.0);
            float li = step(0.0, lp.x) * step(lp.x, 1.0), ri = step(0.0, rp.x) * step(rp.x, 1.0);
            st += max(u_tex.sample(s, clamp(lp, 0.0, 1.0)).rgb - 0.62, 0.0) * ww * li;
            st += max(u_tex.sample(s, clamp(rp, 0.0, 1.0)).rgb - 0.62, 0.0) * ww * ri;
            sw += ww * 2.0;
        }
        st /= max(sw, 0.0001);
        c += st * u.lensStreak * 6.0 * mix(float3(1.0), float3(0.3, 0.55, 1.7), u.streakHue);
    }
    if(u.lensSmudge > 0.003) {
        float sm = fbm2(uv * float2(5.0, 3.0)) * fbm2(uv * float2(11.0, 7.0) + 4.4);
        sm = smoothstep(0.18, 0.62, sm);
        float hl = max(lum3(c) - 0.35, 0.0);
        c += sm * hl * u.lensSmudge * 1.6;
        c = mix(c, c * (1.0 - sm * 0.35), u.lensSmudge * 0.4);
    }
    if(u.lightLeak > 0.003) {
        float ang = u.time * 0.043;
        float2 dir = float2(cos(ang), sin(ang));
        float g = clamp(dot(uv - 0.5, dir) * 1.6 + 0.55, 0.0, 1.0);
        g = pow(g, 2.4) * (0.55 + 0.45 * sin(u.time * 0.61) * 0.5 + 0.225);
        g *= 0.75 + 0.25 * fbm2(uv * 3.0 + u.time * 0.05);
        c += g * u.lightLeak * 1.1 * hsvOut(float3(fract(u.leakHue), 0.75, 1.0));
    }
    if(u.gateHair > 0.003) {
        float sway = (vnoise(float2(u.time * 1.3, 2.0)) - 0.5) * 0.05;
        float hx = 0.26 + sway + sin(uv.y * 9.0 + u.time * 0.4) * 0.02;
        float hair = 1.0 - smoothstep(0.0008, 0.0026, abs(uv.x - hx));
        hair *= smoothstep(1.0, 0.72, uv.y);
        c = mix(c, c * 0.12, hair * u.gateHair);
    }
    if(u.lcdGrid > 0.003) {
        float2 g = fract(float2(gid) / 3.0);
        float gx = smoothstep(0.0, 0.16, g.x) * smoothstep(1.0, 0.84, g.x);
        float gy = smoothstep(0.0, 0.22, g.y) * smoothstep(1.0, 0.78, g.y);
        c *= mix(1.0, gx * gy * 1.22, u.lcdGrid);
    }
    if(u.stuckPix > 0.003) {
        float2 pc = floor(float2(gid));
        float r = h21(pc * 0.371 + 3.7);
        if(r > 1.0 - u.stuckPix * 0.0035) {
            float kind = h21(pc * 1.73 + 9.1);
            if(kind < 0.42) c = float3(0.0);
            else if(kind < 0.66) c = float3(1.0);
            else if(kind < 0.78) c = float3(1.0, 0.0, 0.0);
            else if(kind < 0.9) c = float3(0.0, 1.0, 0.0);
            else c = float3(0.0, 0.0, 1.0);
        }
    }
    
    if(u.letterbox > 0.001 && (uv.y < u.letterbox || uv.y > 1.0 - u.letterbox)) c = float3(0.0);
    if(u.pillarbox > 0.001 && (uv.x < u.pillarbox || uv.x > 1.0 - u.pillarbox)) c = float3(0.0);
    if(u.safeArea > 0.003) {
        float2 d90 = abs(uv - 0.5) - float2(0.45, 0.45);
        float2 d80 = abs(uv - 0.5) - float2(0.40, 0.40);
        float g1 = step(-0.002, max(d90.x, d90.y)) * step(max(d90.x, d90.y), 0.002);
        float g2 = step(-0.002, max(d80.x, d80.y)) * step(max(d80.x, d80.y), 0.002);
        c = mix(c, float3(0.2, 1.0, 0.9), (g1 + g2) * u.safeArea * 0.8);
    }
    
    outTex.write(float4(max(c, 0.0) * tube * u_tex.sample(s, clamp(cuv, 0.0, 1.0)).a, 1.0), gid);
}
