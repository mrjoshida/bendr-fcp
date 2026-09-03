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

// Phosphor aperture grille / slot mask / triad patterns
float3 maskAt(float2 fc, float model, float maskDark) {
    float dark = 1.0 - maskDark * 0.55;
    if(model < 1.5) { 
        // Trinitron Aperture Grille
        float m = fmod(fc.x, 3.0);
        return float3(m < 1.0 ? 1.0 : dark, (m >= 1.0 && m < 2.0) ? 1.0 : dark, m >= 2.0 ? 1.0 : dark); 
    }
    if(model < 2.5) { 
        // Slot Mask
        float2 g = floor(fc / float2(3.0, 6.0));
        float off = fmod(g.y, 2.0) * 1.5;
        float m = fmod(fc.x + off, 3.0);
        float v = fmod(fc.y, 6.0) < 5.0 ? 1.0 : dark;
        return float3(m < 1.0 ? 1.0 : dark, (m >= 1.0 && m < 2.0) ? 1.0 : dark, m >= 2.0 ? 1.0 : dark) * v; 
    }
    if(model < 3.5) { 
        // Dot Triad
        float2 q = fc / float2(6.0, 6.0);
        float2 f = fract(q) - 0.5;
        float r = length(f);
        float tri = fmod(floor(q.x) + floor(q.y) * 2.0, 3.0);
        float3 t = float3(tri < 0.5 ? 1.0 : dark, (tri >= 0.5 && tri < 1.5) ? 1.0 : dark, tri >= 1.5 ? 1.0 : dark);
        return t * (1.0 - smoothstep(0.28, 0.5, r) * maskDark); 
    }
    if(model < 4.5) { 
        // Monochrome B&W Phosphor
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
    float2 uv = (float2(gid) + 0.5) / res;
    
    // --- Authentic CRT Balloon Curvature ---
    float2 origP = (uv - 0.5) * 2.0; // [-1, 1] screen space
    float2 p = origP;
    
    float sag = 0.0;
    if(u.hvSag > 0.003) { 
        sag = u.hvSag * 0.02 * (lum3(u_tex.sample(s, float2(0.5)).rgb) + 0.35); 
    }
    
    if (u.curvature > 0.001) {
        float k = u.curvature * 0.20;
        float r2 = p.x * p.x + p.y * p.y;
        p = p * (1.0 + r2 * k);
        p.y -= sag;
    }
    
    float2 cuv = p * 0.5 + 0.5;
    
    if(abs(u.lensDist) > 0.003) {
        float2 dl = cuv - 0.5; 
        float r2 = dot(dl, dl);
        cuv = 0.5 + dl * (1.0 + u.lensDist * 0.2 * r2);
    }
    
    if(u.gateWeave > 0.003) {
        float tw = u.time * 1.7;
        float2 wv = float2(vnoise(float2(tw, 3.1)) - 0.5, vnoise(float2(tw * 0.8 + 11.0, 7.9)) - 0.5);
        wv += float2(0.0, (h21(float2(floor(u.time * 24.0), 5.0)) - 0.5) * 0.35);
        cuv += wv * u.gateWeave * 0.015;
    }
    
    if(u.rollShutter > 0.003) { 
        cuv.y += sin((uv.y * 3.0 + u.time * 0.7) * 3.14159) * u.rollShutter * 0.004; 
    }
    
    // --- Tube Mask / Rounded CRT Glass Bezel (SDF) ---
    float tube = 1.0;
    if (cuv.x < 0.0 || cuv.x > 1.0 || cuv.y < 0.0 || cuv.y > 1.0) {
        tube = 0.0;
    } else if (u.cornerRound > 0.001) {
        float r = clamp(u.cornerRound * 0.12, 0.002, 0.25);
        float2 q = abs(cuv - 0.5) * 2.0; // [0, 1]
        float2 b = float2(1.0) - float2(r * 2.0);
        float2 cornerDist = max(q - b, float2(0.0));
        float corner = length(cornerDist) - r * 2.0;
        float aa = 2.0 / min(res.x, res.y);
        tube = 1.0 - smoothstep(-aa, aa, corner);
    }
    
    if (tube <= 0.0) { 
        outTex.write(float4(0.0, 0.0, 0.0, 1.0), gid); 
        return; 
    }
    
    // --- Source Sampling ---
    float3 c = u_tex.sample(s, clamp(cuv, 0.0, 1.0)).rgb;
    
    // Lens Chromatic Aberration
    if(u.lensCA > 0.003) {
        float2 dc = cuv - 0.5;
        float kr = 1.0 + u.lensCA * 0.012, kb = 1.0 - u.lensCA * 0.012;
        c.r = u_tex.sample(s, clamp(0.5 + dc * kr, 0.0, 1.0)).r;
        c.b = u_tex.sample(s, clamp(0.5 + dc * kb, 0.0, 1.0)).b;
    }
    
    // Phosphor Persistence
    if(u.phosphor > 0.003 && u.hasPersist > 0.5) {
        c = max(c, u_persist.sample(s, clamp(cuv, 0.0, 1.0)).rgb);
    }
    
    // --- Bloom, Defocus & Halation (Golden Angle Spiral) ---
    if(u.defocus > 0.003 || u.bloom > 0.003) {
        float2 px = 1.0 / res;
        float maxRad = 2.0 + u.bloomRad * 16.0;
        float3 blur = float3(0.0); 
        float wsum = 0.0;
        for(int i = 0; i < 16; i++) {
            float fi = float(i);
            float ang = fi * 2.39996323; // Golden angle
            float r = sqrt((fi + 0.5) / 16.0) * maxRad;
            float2 off = float2(cos(ang), sin(ang)) * r * px;
            float2 tp = cuv + off;
            if (tp.x >= 0.0 && tp.x <= 1.0 && tp.y >= 0.0 && tp.y <= 1.0) {
                float w = 1.0 - (r / (maxRad + 1.0)) * 0.4;
                blur += u_tex.sample(s, tp).rgb * w; 
                wsum += w;
            }
        }
        blur = (wsum > 0.0001) ? blur / wsum : c;
        c = mix(c, blur, u.defocus * 0.75);
        if(u.bloom > 0.003) {
            float3 hot = max(blur - 0.35, 0.0) * 1.5;
            float3 tint = mix(float3(1.0), float3(1.25, 0.72, 0.48), u.halation);
            c += hot * u.bloom * 1.2 * tint;
        }
    }
    
    // --- Graduated CRT Raster Scanlines ---
    if (u.scanlines > 0.001) {
        float lines = (u.rows > 0.0 && u.rows <= 720.0) ? u.rows : 240.0;
        // True graduated balloon curvature: scanlines arch upwards at top (dome), curve downwards at bottom, perfectly flat at equator
        float edgeCurve = u.curvature * 0.20;
        float scanY = origP.y * (1.0 + (1.0 - origP.x * origP.x) * edgeCurve);
        float scanNorm = scanY * 0.5 + 0.5;
        
        float phase = scanNorm * lines * 6.2831853;
        float beam = 0.5 + 0.5 * cos(phase);
        float bright = lum3(c);
        beam = pow(beam, mix(0.5, 0.85, bright));
        c *= mix(1.0, beam * 1.25, u.scanlines);
    }
    
    // Phosphor Mask / Aperture Grille
    float model = u.outModel;
    if (model > 0.5 && u.aperture > 0.001) {
        c *= mix(float3(1.0), maskAt(float2(gid), model, u.maskDark), u.aperture);
        if(model > 4.5) c = mix(c, float3(lum3(c)), 0.85);
        if(model > 5.5) c *= float3(0.75, 1.0, 0.8);
    }
    
    // --- Color & Picture Adjustment ---
    if (abs(u.outGamma - 1.0) > 0.001) {
        c = pow(max(c, 0.0), float3(1.0 / max(0.15, u.outGamma)));
    }
    if (abs(u.outContrast - 1.0) > 0.001 || abs(u.outBright) > 0.001) {
        c = (c - 0.5) * u.outContrast + 0.5 + u.outBright;
    }
    if (abs(u.outSat - 1.0) > 0.001) {
        float L = lum3(c);
        c = mix(float3(L), c, u.outSat);
    }
    if (abs(u.outWarmth) > 0.001) {
        c *= mix(float3(1.0), float3(1.12, 1.0, 0.86), max(u.outWarmth, 0.0)) * 
             mix(float3(1.0), float3(0.86, 1.0, 1.14), max(-u.outWarmth, 0.0));
    }
    c = max(c - u.blackLevel, 0.0);
    c = min(c, float3(u.whiteClip));
    
    // Vignette
    if (u.vignette > 0.001) {
        float2 vp = (uv - 0.5) * float2(res.x / res.y, 1.0);
        float vig = 1.0 - smoothstep(0.4, 1.2, length(vp)) * u.vignette * 0.75;
        c *= clamp(vig, 0.0, 1.0);
    }
    
    // Glass reflection
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
