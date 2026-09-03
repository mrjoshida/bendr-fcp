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

inline float3 nonlin(float3 c, float pivot, float drive, float mode) {
    c = (c - pivot) * drive + pivot;
    if (mode < 0.5) return clamp(c, 0.0, 1.0);
    if (mode < 1.5) return float3(0.5) + tanh((c - 0.5) * 1.9) * 0.5;
    if (mode < 2.5) return fract(max(c, 0.0));
    return abs(fract(max(c, 0.0) * 0.5) * 2.0 - 1.0);
}

kernel void bendrFeedback(
    texture2d<float, access::sample> srcTex   [[texture(0)]],
    array<texture2d<float, access::sample>, 16> histTex [[texture(1)]],
    texture2d<float, access::sample> delayTex [[texture(17)]],
    texture2d<float, access::write>  outTex   [[texture(18)]],
    constant FeedbackParams&         params   [[buffer(0)]],
    sampler                          s        [[sampler(0)]],
    uint2                            gid      [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    
    float2 res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = (float2(gid) + 0.5) / res;
    float outA = res.x / res.y;
    
    // Kaleidoscope transform
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
    
    // Source framing & geometry
    float2 fuv = (kuv - 0.5 - float2(params.srcX, params.srcY)) * float2(outA, 1.0);
    fuv = rotate2D(fuv, params.srcRot * PI);
    fuv *= exp(-params.srcZoom * 1.5);
    fuv.x /= outA;
    fuv += 0.5;
    
    float4 srcSample = srcTex.sample(s, wrapUV(fuv, params.edgeMode));
    float3 col = srcSample.rgb;
    float alpha = srcSample.a;
    
    if (params.fbAmount < 0.003) {
        outTex.write(float4(col, alpha), gid);
        return;
    }
    
    // Recursive compounding optical feedback generator (evaluates up to 16 compounded generations)
    uint maxGens = min(max(params.generationCount, 12u), 16u);
    float3 accumFeedback = float3(0.0);
    float totalFbWeight = 0.0;
    
    for (uint k = 1; k <= maxGens; k++) {
        float fk = float(k);
        float genWeight = pow(params.fbAmount, fk * 0.65);
        if (genWeight < 0.005) break;
        
        // Compounded matrix transform for generation k: T^k
        float2 p = (uv - 0.5) * float2(outA, 1.0);
        
        // 1. Compounded rotation
        float ang = params.fbRotate * fk * 0.45;
        p = rotate2D(p, ang);
        
        // 2. Compounded shear
        p += float2(p.y * params.fbShearX * 0.25 * fk, p.x * params.fbShearY * 0.25 * fk);
        
        // 3. Compounded zoom (tunnel expansion / contraction)
        float zoomFactor = pow(max(0.2, 1.0 - params.fbZoom * 0.22), fk);
        p *= zoomFactor;
        
        // 4. Compounded shift & drift
        p += float2(params.fbShiftX, params.fbShiftY) * 0.2 * fk;
        p.y += params.fbRoll * 0.03 * fk;
        
        p.x /= outA;
        p += 0.5;
        
        // Mirror / Flip modes
        if (params.fbMirror > 0.5) {
            float2 mp = p - 0.5;
            if (params.fbMirror < 1.5) mp.x = abs(mp.x);
            else if (params.fbMirror < 2.5) mp.y = abs(mp.y);
            else mp = abs(mp);
            p = mp + 0.5;
        }
        
        // Sample corresponding history texture (or srcTex fallback)
        uint histIdx = min(k - 1, 15u);
        float3 genSample = histTex[histIdx].sample(s, wrapUV(p, params.fbWrap)).rgb;
        
        // Compounded Color Processing:
        // A. Compounded hue rotation across tunnel generations
        if (abs(params.fbHue) > 0.002) {
            genSample = hueRotate(genSample, params.fbHue * fk * 0.35);
        }
        
        // B. Compounded gain and saturation
        genSample *= float3(pow(params.fbGainR, fk * 0.5), pow(params.fbGainG, fk * 0.5), pow(params.fbGainB, fk * 0.5));
        float l = luma(genSample);
        genSample = mix(float3(l), genSample, max(0.0, 1.0 + (params.fbSat - 1.0) * fk * 0.4));
        
        // C. Nonlinear analog saturation & overdrive
        if (params.fbDrive > 1.01 || params.fbNL > 0.5) {
            genSample = nonlin(genSample, params.fbPivot, pow(params.fbDrive, fk * 0.3), params.fbNL);
        }
        
        // Blend mode into composite
        if (params.fbBlend < 0.5) {
            // Normal alpha mix
            accumFeedback += genSample * genWeight;
            totalFbWeight += genWeight;
        } else if (params.fbBlend < 1.5) {
            // Additive glow
            col += genSample * genWeight * 1.2;
        } else if (params.fbBlend < 2.5) {
            // Screen
            col = 1.0 - (1.0 - col) * (1.0 - clamp(genSample * genWeight, 0.0, 1.0));
        } else if (params.fbBlend < 3.5) {
            // Lighter Color / Max
            col = max(col, genSample * genWeight);
        } else if (params.fbBlend < 4.5) {
            // Darker / Min
            col = mix(col, min(col, genSample), genWeight);
        } else {
            // Difference vortex
            col = abs(col - genSample * genWeight);
        }
    }
    
    if (params.fbBlend < 0.5 && totalFbWeight > 0.001) {
        accumFeedback /= totalFbWeight;
        col = mix(col, accumFeedback, clamp(params.fbAmount * 1.1, 0.0, 0.95));
    }
    
    if (params.hasDelay > 0.5 && params.echo > 0.003) {
        float3 echoSample = delayTex.sample(s, uv).rgb;
        col = mix(col, echoSample, params.echo * 0.5);
    }
    
    outTex.write(float4(clamp(col, 0.0, 2.0), alpha), gid);
}
