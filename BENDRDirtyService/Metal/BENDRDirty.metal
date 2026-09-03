#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct DirtyParams {
    float mixDirt;
    float mixDirtRate;
    float mixDirtKnock;
    float mixDirtDrop;
    float mixDirtCut;
    float mixDirtNoise;
    float time;
    float2 res;
};

kernel void bendrDirty(
    texture2d<float, access::sample> inTex  [[texture(0)]],
    texture2d<float, access::write>  outTex [[texture(1)]],
    constant DirtyParams &p                 [[buffer(0)]],
    uint2 gid                               [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;

    if (p.mixDirt < 0.001) {
        float4 direct = inTex.sample(smp, uv);
        outTex.write(direct, gid);
        return;
    }

    // --- Dynamic Per-Frame Time & Event Clock ---
    // Frame-level seed updates on every single frame (at 30/60 fps)
    float frameSeed = floor(p.time * 30.0);
    
    // Periodic macro fault events (desk failures, sync pops)
    float dr = 1.0 + p.mixDirtRate * 12.0;
    float ph = p.time * dr;
    float tk = floor(ph);
    float fr = fract(ph);
    
    // Event trigger envelope with organic exponential decay
    float eventTrigger = step(0.35, h21(float2(tk, 7.71) + p.mixDirt * 13.0));
    float burstIntensity = eventTrigger * exp(-fr * mix(12.0, 3.0, p.mixDirt));
    float totalDirt = clamp(p.mixDirt * 0.4 + burstIntensity * 0.8, 0.0, 1.5);

    // --- Timebase Knock, Jitter & Head-Switching Shear ---
    float2 duv = uv;
    if (p.mixDirtKnock > 0.003) {
        float rowI = floor(uv.y * p.res.y);
        
        // 1. High-frequency line-by-line sync jitter (changes EVERY frame)
        float lineNoise = (h21(float2(rowI * 0.17, frameSeed * 3.19)) - 0.5) * 0.012 * p.mixDirtKnock * totalDirt;
        
        // 2. Top-of-frame flag waving / head-switching distortion
        float flagWave = exp(-uv.y * 7.0) * sin(uv.y * 24.0 + p.time * 45.0) * 0.04 * p.mixDirtKnock * totalDirt;
        
        // 3. Macro horizontal frame shear during burst events
        float macroShear = (h21(float2(tk, 5.53)) - 0.5) * 0.12 * p.mixDirtKnock * burstIntensity;
        
        // 4. Vertical sync bounce
        float vBounce = (h21(float2(tk, 2.19)) - 0.5) * 0.04 * p.mixDirtKnock * burstIntensity;
        
        duv.x += lineNoise + flagWave + macroShear;
        duv.y = clamp(duv.y + vBounce, 0.0, 1.0);
    }

    // Source Sample (clamped, no wrapping)
    float4 srcSample = inTex.sample(smp, clamp(duv, 0.0, 1.0));
    float3 src = srcSample.rgb;
    float alpha = srcSample.a;

    // --- Dynamic Line Dropouts & Tape Oxide Streaks ---
    if (p.mixDirtDrop > 0.003 && totalDirt > 0.01) {
        // Individual scanline dropouts (calculated per frame)
        float rowI = floor(uv.y * p.res.y);
        float lineRand = h21(float2(rowI, frameSeed * 7.13));
        
        // Drop threshold dynamically driven by mixDirtDrop
        float dropThresh = 1.0 - (p.mixDirtDrop * totalDirt * 0.06);
        if (lineRand > dropThresh) {
            // Horizontal dropout streak position and length
            float streakStart = h21(float2(rowI, frameSeed * 11.3));
            float streakLen = 0.08 + 0.6 * h21(float2(rowI, frameSeed * 17.9));
            if (uv.x >= streakStart && uv.x <= streakStart + streakLen) {
                // Oxide flake type: white flash, dark loss, or chromatic shear
                float flakeType = h21(float2(rowI, frameSeed * 23.1));
                if (flakeType < 0.35) {
                    src = float3(0.95, 0.95, 1.0); // Bright RF drop
                } else if (flakeType < 0.65) {
                    src *= 0.1; // Total signal loss / black streak
                } else {
                    // Y/C delay chromatic smear
                    float2 chromaUV = clamp(float2(duv.x - 0.04, duv.y), 0.0, 1.0);
                    src = mix(src, inTex.sample(smp, chromaUV).bgr, 0.85);
                }
            }
        }
    }

    // --- Switching Cut / Momentary Flash & Solarization ---
    if (p.mixDirtCut > 0.003 && burstIntensity > 0.05) {
        float cutSeed = h21(float2(tk, 9.31));
        if (cutSeed > 0.45) {
            float flashAmt = burstIntensity * p.mixDirtCut;
            if (cutSeed > 0.75) {
                // Color inversion / solarization
                src = mix(src, 1.0 - src, clamp(flashAmt * 1.5, 0.0, 0.95));
            } else if (cutSeed > 0.55) {
                // Luma flash
                src = mix(src, float3(1.1, 1.05, 0.95), clamp(flashAmt * 1.3, 0.0, 0.9));
            } else {
                // Sync black cut
                src = mix(src, float3(0.02), clamp(flashAmt * 1.4, 0.0, 0.95));
            }
        }
    }

    // --- Transient RF Noise & Analog Grain (Per-Pixel, Per-Frame) ---
    if (p.mixDirtNoise > 0.003) {
        // High-frequency per-pixel noise that changes EVERY single frame
        float2 px = float2(gid);
        float noiseVal = h21(px + float2(frameSeed * 37.71, frameSeed * 91.13)) - 0.5;
        
        // Analog luma noise + chroma sparkles
        float noiseAmt = p.mixDirtNoise * (0.15 + totalDirt * 0.35);
        src += float3(noiseVal * noiseAmt);
        
        // Random magnetic oxide speckles
        float speckleRand = h21(px * 0.5 + float2(frameSeed * 13.9, frameSeed * 47.1));
        if (speckleRand > 1.0 - (p.mixDirtNoise * totalDirt * 0.004)) {
            src = (speckleRand > 1.0 - p.mixDirtNoise * totalDirt * 0.002) ? float3(1.0) : float3(0.0);
        }
    }

    outTex.write(float4(clamp(src, 0.0, 1.5), alpha), gid);
}
