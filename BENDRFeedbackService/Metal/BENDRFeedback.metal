#include <metal_stdlib>
using namespace metal;

struct FeedbackParams {
    float srcAspect;
    float hasSrc;
    float hasDelay;
    float time;
    
    float fbAmount;
    float fbZoom;
    float fbRotate;
    float fbHue;
    float fbShiftX;
    float fbShiftY;
    float fbMode;
    
    float echo;
    float srcZoom;
    float srcX;
    float srcY;
    float srcRot;
    float edgeMode;
    
    float flipMode;
    float mirrorMode;
    float multiN;
    float shakeX;
    float shakeY;
    
    float kaleido;
    float kaleidoN;
    float kaleidoRot;
    float kaleidoX;
    float kaleidoY;
    
    float fbShearX;
    float fbShearY;
    float fbGainR;
    float fbGainG;
    float fbGainB;
    float fbSat;
    float fbVal;
    float fbPost;
    float fbChromOff;
    
    float fbBlur;
    float fbBlur2;
    float fbSharp;
    float fbDrive;
    float fbPivot;
    float fbThresh;
    float fbThreshSoft;
    
    float fbNoise;
    float fbNoiseScale;
    float fbRoll;
    float fbJitter;
    
    float fbWrap;
    float fbMirror;
    float fbBlend;
    float fbNL;
    float fbInvert;
    float autoGain;
    float fbFlip;
    
    uint generationCount;
};

#include "../../Shared/Metal/BendrCommon.h"

inline float3 tapTex(texture2d<float, access::sample> tex, sampler s, float2 p, float mode) {
    return tex.sample(s, wrapUV(p, mode)).rgb;
}

float3 blurTex(texture2d<float, access::sample> tex, sampler s, float2 p, float r, float2 res, float mode) {
    if (r < 0.002) return tapTex(tex, s, p, mode);
    float2 px = r * 9.0 / res;
    float3 a = tapTex(tex, s, p, mode) * 0.28;
    a += tapTex(tex, s, p + float2(px.x, 0), mode) * 0.12 + tapTex(tex, s, p - float2(px.x, 0), mode) * 0.12;
    a += tapTex(tex, s, p + float2(0, px.y), mode) * 0.12 + tapTex(tex, s, p - float2(0, px.y), mode) * 0.12;
    a += tapTex(tex, s, p + px * 0.7, mode) * 0.06 + tapTex(tex, s, p - px * 0.7, mode) * 0.06;
    a += tapTex(tex, s, p + float2(px.x, -px.y) * 0.7, mode) * 0.06 + tapTex(tex, s, p + float2(-px.x, px.y) * 0.7, mode) * 0.06;
    return a;
}

float3 nonlin(float3 c, float pivot, float drive, float mode) {
    c = (c - pivot) * drive + pivot;
    if (mode < 0.5) return clamp(c, 0.0, 1.0);
    if (mode < 1.5) return float3(0.5) + tanh((c - 0.5) * 1.9) * 0.5;
    if (mode < 2.5) return fract(max(c, 0.0));
    return abs(fract(max(c, 0.0) * 0.5) * 2.0 - 1.0);
}

float2 frameXf(float2 uv, float rot, float zoom, float px, float py) {
    float2 q = uv - 0.5;
    float a = rot * 3.14159;
    float c = cos(a), s = sin(a);
    float2x2 m = float2x2(c, -s, s, c);
    q = m * q;
    q /= pow(8.0, zoom);
    return q + 0.5 - float2(px, py) * 1.5;
}

float3 fitSample(texture2d<float, access::sample> tx, sampler s, float2 uv, float srcA, float outA, constant FeedbackParams& params, thread float& g_cover) {
    float2 p = uv - 0.5;
    
    if (params.flipMode > 0.5) {
        if (params.flipMode < 1.5) p.x = -p.x;
        else if (params.flipMode < 2.5) p.y = -p.y;
        else p = -p;
    }
    
    if (params.multiN > 1.5) {
        float n = floor(params.multiN);
        float2 g = fract((p + 0.5) * n);
        float2 cell = floor((p + 0.5) * n);
        if (fmod(cell.x, 2.0) > 0.5) g.x = 1.0 - g.x;
        if (fmod(cell.y, 2.0) > 0.5) g.y = 1.0 - g.y;
        p = g - 0.5;
    }
    
    if (params.mirrorMode > 0.5) {
        if (params.mirrorMode < 1.5) p.x = abs(p.x) - 0.25;
        else if (params.mirrorMode < 2.5) p.y = abs(p.y) - 0.25;
        else p = abs(p) - 0.25;
    }
    
    p += float2(params.shakeX, params.shakeY);
    if (srcA > outA) { p.y *= srcA / outA; } else { p.x *= outA / srcA; }
    p += 0.5;
    
    if (params.edgeMode > 1.5) {
        float2 t = fract(p * 0.5) * 2.0;
        p = 1.0 - abs(t - 1.0);
    } else if (params.edgeMode > 0.5) {
        p = fract(p);
    } else if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0) {
        g_cover = 0.0;
        return float3(0.0);
    }
    
    return tx.sample(s, p).rgb;
}

// Applies one generation of feedback processing (spatial + color transforms)
float3 applyFeedbackGen(float3 prev, float2 uv, float2 res, constant FeedbackParams& params, texture2d<float, access::sample> tx, sampler s) {
    float2 p = uv - 0.5;
    
    if (params.fbMirror > 0.5) {
        if (params.fbMirror < 1.5) p.x = abs(p.x);
        else if (params.fbMirror < 2.5) p.y = abs(p.y);
        else p = abs(p);
    }
    
    if (params.fbFlip > 0.5) {
        if (params.fbFlip < 1.5) p.x = -p.x;
        else if (params.fbFlip < 2.5) p.y = -p.y;
        else p = -p;
    }
    
    float ang = params.fbRotate * 1.0;
    float ca = cos(ang), sa = sin(ang);
    p = float2x2(ca, -sa, sa, ca) * p;
    p += float2(p.y * params.fbShearX * 0.4, p.x * params.fbShearY * 0.4);
    p *= (1.0 - params.fbZoom * 0.3);
    p += float2(params.fbShiftX, params.fbShiftY) * 0.3;
    p.y += params.fbRoll * 0.05;
    
    if (params.fbJitter > 0.003 && h21(float2(floor(params.time * 60.0), 7.0)) < params.fbJitter * 0.4) p.y += 0.01;
    p += 0.5;
    
    float3 t_prev = blurTex(tx, s, p, params.fbBlur, res, params.fbWrap);
    if (params.fbSharp > 0.003 || params.fbBlur2 > 0.003) {
        float3 wide = blurTex(tx, s, p, max(params.fbBlur2, params.fbBlur * 3.0 + 0.05), res, params.fbWrap);
        t_prev += (t_prev - wide) * params.fbSharp;
    }
    
    if (abs(params.fbChromOff) > 0.003) {
        float co = params.fbChromOff * 6.0 / res.x;
        t_prev.r = tapTex(tx, s, p + float2(co, 0.0), params.fbWrap).r;
        t_prev.b = tapTex(tx, s, p - float2(co, 0.0), params.fbWrap).b;
    }
    
    float ha = params.fbHue * 1.2;
    float3 py = rgb2yiq(t_prev);
    float hc = cos(ha), hs = sin(ha);
    py.yz = float2x2(hc, -hs, hs, hc) * py.yz;
    py.yz *= params.fbSat;
    py.x *= params.fbVal;
    t_prev = yiq2rgb(py);
    t_prev *= float3(params.fbGainR, params.fbGainG, params.fbGainB) * params.autoGain;
    
    if (params.fbInvert > 0.5) t_prev = 1.0 - t_prev;
    if (params.fbPost > 0.003) {
        float L = 2.0 + (1.0 - params.fbPost) * 14.0;
        t_prev = mix(t_prev, floor(t_prev * L + 0.5) / L, min(params.fbPost * 2.0, 1.0));
    }
    if (params.fbThresh > 0.003) {
        float lv = dot(t_prev, float3(0.299, 0.587, 0.114));
        float k = smoothstep(params.fbThresh - params.fbThreshSoft, params.fbThresh + params.fbThreshSoft, lv);
        t_prev = mix(t_prev * 0.15, t_prev, k);
    }
    if (params.fbNoise > 0.003) {
        float ns = mix(120.0, 6.0, params.fbNoiseScale);
        float3 n3 = float3(
            h21(floor(uv * ns) + fract(params.time) * 17.0),
            h21(floor(uv * ns) + fract(params.time) * 31.0 + 5.0),
            h21(floor(uv * ns) + fract(params.time) * 43.0 + 9.0)
        ) - 0.5;
        t_prev += n3 * params.fbNoise * 0.06;
    }
    
    t_prev = nonlin(t_prev, params.fbPivot, params.fbDrive, params.fbNL);
    return t_prev;
}

/*
 * BENDRFeedback: Approximates recursive feedback by compounding transformations
 * over a series of historical source frames.
 */
kernel void bendrFeedback(
    texture2d<float, access::sample> srcTex [[texture(0)]],
    array<texture2d<float, access::sample>, 16> histTex [[texture(1)]],
    texture2d<float, access::sample> delayTex [[texture(17)]],
    texture2d<float, access::write> outTex [[texture(18)]],
    constant FeedbackParams& params [[buffer(0)]],
    sampler s [[sampler(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    
    float2 res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = (float2(gid) + 0.5) / res;
    float outA = res.x / res.y;
    
    float2 kuv = uv;
    if (params.kaleido > 0.003) {
        float2 ctr = float2(0.5) + float2(params.kaleidoX, params.kaleidoY) * 0.5;
        float2 q = (uv - ctr) * float2(outA, 1.0);
        float ang = atan2(q.y, q.x) + params.kaleidoRot * 3.14159;
        float rad = length(q);
        float seg = 6.28318 / max(2.0, floor(params.kaleidoN));
        ang = fmod(ang, seg);
        ang = abs(ang - seg * 0.5);
        float2 f = ctr + float2(cos(ang), sin(ang)) * rad / float2(outA, 1.0);
        kuv = mix(uv, f, clamp(params.kaleido, 0.0, 1.0));
    }
    
    float2 fuv = frameXf(kuv, params.srcRot, params.srcZoom, params.srcX, params.srcY);
    
    float g_cover = 1.0;
    float3 src = (params.hasSrc > 0.5) ? fitSample(srcTex, s, fuv, params.srcAspect, outA, params, g_cover) : float3(0.0);
    
    // Instead of sampling u_prev and blending, we evaluate the compound feedback over generationCount frames
    // This provides the approximate recursive look. We sample from historical source frames.
    float3 col = src;
    uint genCount = min(params.generationCount, 16u);
    if (genCount > 0 && params.fbAmount > 0.003) {
        float3 accumPrev = float3(0.0);
        float weight = 1.0;
        
        // Loop backwards from oldest to newest to build up the effect
        for (int i = int(genCount) - 1; i >= 0; i--) {
            // Apply cumulative transforms conceptually (in MSL we just apply one pass to each historical frame,
            // since chaining UV transforms and sampling historically is complex, we just sample the 
            // historical frame as if it were the previous output).
            // A closer approximation: each hist frame gets processed with the transform stack.
            float3 genCol = fitSample(histTex[i], s, fuv, params.srcAspect, outA, params, g_cover);
            
            // To properly compound, we'd ideally run `applyFeedbackGen` recursively. Since we can't write to 
            // textures in a loop, we approximate by applying the transform iteratively.
            // (For simplicity in this approximation, we just process the historical frame through one pass of feedback)
            float3 proc = applyFeedbackGen(genCol, uv, res, params, histTex[i], s);
            
            float fbA = params.fbAmount * weight; // Apply decay
            
            if (params.fbBlend < 0.5) col = mix(col, proc, fbA);
            else if (params.fbBlend < 1.5) col = col + proc * fbA;
            else if (params.fbBlend < 2.5) col = 1.0 - (1.0 - col) * (1.0 - proc * fbA);
            else if (params.fbBlend < 3.5) col = max(col, proc * fbA);
            else if (params.fbBlend < 4.5) col = mix(col, min(col, proc), fbA);
            else col = mix(col, abs(col - proc), fbA);
            
            weight *= params.fbAmount; // decay weight for next oldest frame
        }
    }
    
    if (params.hasDelay > 0.5) {
        float2 dUV = uv;
        col = mix(col, delayTex.sample(s, dUV).rgb, params.echo);
    }
    
    float cover = (params.hasSrc > 0.5) ? g_cover : 0.0;
    
    // Write back with flipped Y
    outTex.write(float4(clamp(col, -0.5, 2.0), cover), gid);
}
