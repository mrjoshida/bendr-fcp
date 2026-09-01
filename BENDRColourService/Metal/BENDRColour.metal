#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct ColourParams {
    // Primary Color
    float rGain;
    float gGain;
    float bGain;
    float saturation;
    float hue;
    float brightness;
    float contrast;

    // Color Effects
    float posterize;
    float solarize;
    float negative;
    float negMode;
    float monoCol;
    float monoHue;
    float colorPass;
    float passHue;
    float passWidth;
    float silhouette;
    float silThresh;
    float silHue;
    float glow;

    // Edge & Relief
    float findEdge;
    float edgeHue;
    float emboss;
    float embossDir;
    float diffAmt;
    float diffScale;
    float diffPolar;
    float ampAmt;
    float ampBands;
    float ampPick;
    float ampCol;

    // Function Generator
    float fgPos;
    float fgNeg;
    float fgZero;

    // Bent Enhancer
    float colorize;
    float colorBands;
    float colorSweep;
    float lumaHue;
    float sharpEcho;
    float echoSpace;
    float rgbSep;
    float invFlick;

    // Contour & Dither
    float contour;
    float contourBands;
    float contourWidth;
    float contourHue;
    float contourFill;
    float lumaSteps;
    float stepCount;
    float dither;

    // Modulation Lines
    float mline;
    float mlineScale;
    float mlineGain;
    float mlineBias;
    float mlineFb;
    float mlineWin;
    float mlineTint;
    float mlineCol;
    float mlineSerp;

    // System
    float time;
    float2 res;
};

// Helper functions (adapted from Bendr GLSL)
float lum_local(texture2d<float, access::sample> tex, sampler s, float2 p) {
    float3 c = tex.sample(s, clamp(p, 0.0, 1.0)).rgb;
    return dot(c, float3(0.299, 0.587, 0.114));
}
#include "../../Shared/Metal/BendrCommon.h"

inline float3 hsv2(float h, float sa, float v) {
    float3 k = fract(float3(h) + float3(0.0, 2.0/3.0, 1.0/3.0));
    return v * mix(float3(1.0), clamp(abs(k * 6.0 - 3.0) - 1.0, 0.0, 1.0), sa);
}

[[kernel]]
void bendrColour(texture2d<float, access::sample> inTex [[texture(0)]],
                 texture2d<float, access::write> outTex [[texture(1)]],
                 constant ColourParams& params [[buffer(0)]],
                 uint2 gid [[thread_position_in_grid]])
{
    float2 res = float2(outTex.get_width(), outTex.get_height());
    if (gid.x >= uint(res.x) || gid.y >= uint(res.y)) {
        return;
    }
    float2 uv = float2(gid) / res;
    
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    
    float px = 1.0 / res.x;
    
    // bent enhancer: RGB channel split
    float sep = params.rgbSep * 20.0 * px;
    float3 c;
    c.r = inTex.sample(s, uv + float2(sep, 0.0)).r;
    c.g = inTex.sample(s, uv).g;
    c.b = inTex.sample(s, uv - float2(sep, 0.0)).b;
    
    // enhancer front panel: per-channel gain knobs
    c *= float3(params.rGain, params.gGain, params.bGain);
    
    // bent enhancer: sharpness circuit driven into oscillation — repeated edge ghosts
    if (params.sharpEcho > 0.001) {
        float y0 = dot(c, float3(0.299, 0.587, 0.114));
        float sp = (2.0 + params.echoSpace * 22.0) * px;
        float e = 0.0;
        float w = 1.0;
        for (int k = 1; k <= 5; k++) {
            w *= 0.72;
            e += w * (y0 - lum_local(inTex, s, uv - float2(float(k) * sp, 0.0)));
        }
        c += params.sharpEcho * 2.2 * e * float3(1.25, 1.0, 1.45);
    }
    
    float3 y = rgb2yiq(c);
    // luma-driven hue slew (colours chase brightness)
    float ha = params.hue * 6.2832 + clamp(y.x, 0.0, 1.0) * params.lumaHue * 6.2832;
    float hc = cos(ha);
    float hs = sin(ha);
    float2x2 rot = float2x2(hc, hs, -hs, hc); // Column-major MSL
    y.yz = rot * y.yz;
    y.yz *= params.saturation;
    y.x = (y.x - 0.5) * params.contrast + 0.5 + params.brightness * 0.5;
    c = yiq2rgb(y);
    
    // bent enhancer: luma-keyed rainbow colorizer
    if (params.colorize > 0.001) {
        float hph = clamp(y.x, 0.0, 1.2) * params.colorBands + params.time * params.colorSweep * 0.55;
        float3 pal = 0.5 + 0.5 * cos(6.2832 * (hph + float3(0.0, 0.33, 0.67)));
        pal *= 0.3 + 1.0 * smoothstep(0.02, 0.85, y.x);
        c = mix(c, pal, params.colorize);
    }
    
    if (params.solarize > 0.001) {
        c = mix(c, abs(1.0 - abs(1.0 - 2.0 * c)), params.solarize);
    }
    
    // bent enhancer: flickering luma-keyed inversion
    if (params.invFlick > 0.001) {
        float gate = step(0.5, fract(params.time * (1.5 + 13.0 * params.invFlick)));
        float thr = 0.45 + 0.3 * sin(params.time * 0.9);
        float m = gate * step(thr, dot(c, float3(0.333)));
        c = mix(c, 1.0 - c, m * min(1.0, params.invFlick * 1.6));
    }
    
    if (params.posterize > 0.001) {
        float L = 2.0 + (1.0 - params.posterize) * 14.0;
        c = mix(c, floor(c * L + 0.5) / L, min(params.posterize * 2.0, 1.0));
    }
    
    // flatten: quantise luma into hard steps for solid colour fields
    if (params.lumaSteps > 0.003) {
        float L0 = dot(c, float3(0.299, 0.587, 0.114));
        float N = max(2.0, floor(params.stepCount));
        float dth = 0.0;
        if (params.dither > 0.003) {
            int2 bp = int2(gid.x % 4, gid.y % 4);
            float bayer[16] = {0.0,8.0,2.0,10.0, 12.0,4.0,14.0,6.0, 3.0,11.0,1.0,9.0, 15.0,7.0,13.0,5.0};
            dth = (bayer[bp.y * 4 + bp.x] / 16.0 - 0.5) * params.dither / N;
        }
        float Lq = floor((L0 + dth) * N + 0.5) / N;
        float3 flat_ = (L0 > 0.001) ? c * (Lq / max(L0, 0.001)) : float3(Lq);
        c = mix(c, clamp(flat_, 0.0, 1.6), params.lumaSteps);
    }
    
    // One-bit modulation lines
    if (params.mline > 0.003) {
        float stp = (1.0 / res.x) * params.mlineScale;
        int W = int(clamp(params.mlineWin, 4.0, 64.0));
        float dir = (params.mlineSerp > 0.5 && (gid.y % 2) != 0) ? -1.0 : 1.0;
        float3 q = float3(0.0);
        float3 err = float3(0.0);
        for (int i = 0; i < 64; i++) {
            if (i > W) break;
            float2 su = clamp(float2(uv.x - dir * float(W - i) * stp, uv.y), 0.0, 1.0);
            float3 sc = inTex.sample(s, su).rgb;
            if (params.mlineCol < 0.5) sc = float3(dot(sc, float3(0.299, 0.587, 0.114)));
            float3 v = sc * params.mlineGain + params.mlineBias + err;
            q = step(float3(0.5), v);
            err = (v - q) * params.mlineFb;
        }
        c = mix(c, q * mix(float3(1.0), c, params.mlineTint), params.mline);
    }
    
    // contour: draw the isolines between luma bands
    if (params.contour > 0.003) {
        float2 sp = 1.4 / res;
        float L1 = dot(c, float3(0.299, 0.587, 0.114)) * 0.36;
        L1 += dot(inTex.sample(s, uv + float2(sp.x, 0.0)).rgb, float3(0.299, 0.587, 0.114)) * 0.16;
        L1 += dot(inTex.sample(s, uv + float2(-sp.x, 0.0)).rgb, float3(0.299, 0.587, 0.114)) * 0.16;
        L1 += dot(inTex.sample(s, uv + float2(0.0, sp.y)).rgb, float3(0.299, 0.587, 0.114)) * 0.16;
        L1 += dot(inTex.sample(s, uv + float2(0.0, -sp.y)).rgb, float3(0.299, 0.587, 0.114)) * 0.16;
        float b = L1 * params.contourBands;
        
        // Finite differences for dFdx and dFdy (since fragment derivatives are not available in compute)
        float L_x = dot(inTex.sample(s, uv + float2(px, 0.0)).rgb, float3(0.299, 0.587, 0.114)) * params.contourBands;
        float L_y = dot(inTex.sample(s, uv + float2(0.0, 1.0/res.y)).rgb, float3(0.299, 0.587, 0.114)) * params.contourBands;
        float dbdx = L_x - b;
        float dbdy = L_y - b;
        
        float g = length(float2(dbdx, dbdy)) + 1e-4;
        float f = fract(b);
        float dist = min(f, 1.0 - f) / g;
        float line = 1.0 - smoothstep(params.contourWidth * 0.5, params.contourWidth * 0.5 + 1.0, dist);
        float band = floor(b);
        float3 lc = 0.5 + 0.5 * cos(6.2832 * (band / params.contourBands * 1.5 + params.contourHue + float3(0.0, 0.33, 0.67)));
        lc = mix(float3(1.0), lc, smoothstep(0.0, 0.15, params.contourHue));
        float3 bg = c * params.contourFill;
        c = mix(c, mix(bg, lc, line), params.contour);
    }
    
    // the video-mixer effect family
    float lm2 = dot(c, float3(0.299, 0.587, 0.114));
    
    // NEGATIVE
    if (params.negative > 0.003) {
        float3 nb = float3(1.0) - c;
        float3 nv;
        if (params.negMode < 0.5) nv = nb;
        else if (params.negMode < 1.5) nv = clamp(float3(lm2) + (float3(lm2) - (c - float3(lm2))) - float3(lm2), 0.0, 1.0);
        else nv = clamp(c + float3(1.0 - 2.0 * lm2), 0.0, 1.0);
        c = mix(c, nv, params.negative);
    }
    
    // COLORPASS
    if (params.colorPass > 0.003) {
        float3 q = rgb2yiq(c);
        float ang = atan2(q.z, q.y) / 6.2832 + 0.5;
        float d = abs(fract(ang - params.passHue + 0.5) - 0.5) * 2.0;
        float keep = 1.0 - smoothstep(params.passWidth * 0.5, params.passWidth * 0.5 + 0.12, d);
        keep *= smoothstep(0.02, 0.16, length(q.yz));
        c = mix(mix(float3(lm2), c, keep), c, 1.0 - params.colorPass);
    }
    
    // MONOCOLOR
    if (params.monoCol > 0.003) {
        c = mix(c, hsv2(params.monoHue, 1.0, 1.0) * (0.15 + lm2 * 1.15), params.monoCol);
    }
    
    // SILHOUETTE
    if (params.silhouette > 0.003) {
        float sm = smoothstep(params.silThresh - 0.06, params.silThresh + 0.06, lm2);
        c = mix(c, hsv2(params.silHue, 1.0, 1.0) * sm, params.silhouette);
    }
    
    // FINDEDGE
    if (params.findEdge > 0.003) {
        float2 e = 1.0 / res;
        float gx = lum_local(inTex, s, uv + float2(e.x, 0.0)) - lum_local(inTex, s, uv - float2(e.x, 0.0));
        float gy = lum_local(inTex, s, uv + float2(0.0, e.y)) - lum_local(inTex, s, uv - float2(0.0, e.y));
        float g = clamp(length(float2(gx, gy)) * 4.5, 0.0, 1.0);
        c = mix(c, hsv2(params.edgeHue + g * 0.25, 0.9, 1.0) * g, params.findEdge);
    }
    
    // EMBOSS
    if (params.emboss > 0.003) {
        float a2 = params.embossDir * 6.2832;
        float2 d2 = float2(cos(a2), sin(a2)) * 1.6 / res;
        float em = (lum_local(inTex, s, uv + d2) - lum_local(inTex, s, uv - d2)) * 3.0 + 0.5;
        c = mix(c, float3(em) * mix(float3(1.0), c * 1.6, 0.35), params.emboss);
    }
    
    // amplitude classifier
    if (params.ampAmt > 0.003) {
        float n = floor(2.0 + params.ampBands * 6.0);
        float y_local = dot(c, float3(0.299, 0.587, 0.114));
        float bi = floor(clamp(y_local, 0.0, 0.999) * n);
        float3 banded;
        if (params.ampPick > 0.003) {
            float want = floor(clamp(params.ampPick, 0.0, 0.999) * n);
            float on = abs(bi - want) < 0.5 ? 1.0 : 0.0;
            banded = mix(float3(on), c * on, 1.0 - params.ampCol);
        } else {
            float lev = (bi + 0.5) / n;
            banded = mix(float3(lev), hsv2(fract(bi / n + params.ampCol), 0.9, lev * 1.15), params.ampCol);
        }
        c = mix(c, banded, params.ampAmt);
    }
    
    // differentiator bank
    if (params.diffAmt > 0.003) {
        float r = pow(2.0, floor(params.diffScale * 5.999)) / res.y;
        float cx = lum_local(inTex, s, uv + float2(r, 0.0)) - lum_local(inTex, s, uv - float2(r, 0.0));
        float cy = lum_local(inTex, s, uv + float2(0.0, r)) - lum_local(inTex, s, uv - float2(0.0, r));
        float mag = length(float2(cx, cy));
        float3 dv = (params.diffPolar > 0.5)
            ? hsv2(fract(atan2(cy, cx) / 6.2832 + 0.5), 0.9, clamp(mag * 4.0, 0.0, 1.0))
            : float3(clamp(mag * 4.0, 0.0, 1.0));
        c = mix(c, dv, params.diffAmt);
    }
    
    // function generator
    if (abs(params.fgPos) > 0.003 || abs(params.fgNeg) > 0.003 || params.fgZero > 0.003) {
        float3 d = c - 0.5;
        float3 dz = max(abs(d) - params.fgZero * 0.5, 0.0) * sign(d);
        float3 pos = pow(clamp(dz * 2.0, 0.0, 1.0), float3(exp(-params.fgPos * 2.0))) * 0.5;
        float3 neg = pow(clamp(-dz * 2.0, 0.0, 1.0), float3(exp(-params.fgNeg * 2.0))) * 0.5;
        c = 0.5 + pos - neg;
    }
    
    c += c * c * params.glow * 0.8;
    
    float4 finalColor = float4(clamp(c, 0.0, 1.4), inTex.sample(s, uv).a);
    outTex.write(finalColor, gid);
}
