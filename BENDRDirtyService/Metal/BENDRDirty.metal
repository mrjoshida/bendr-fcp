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

// Continuous 1D band-limited analog RF noise along the raster scanline
inline float analogScanlineNoise(float2 uv, float frameSeed, float resX) {
    float row = floor(uv.y * 480.0);
    float scanPos = uv.x * resX * 0.25;
    float s0 = floor(scanPos);
    float sf = fract(scanPos);
    // Smooth cubic hermite interpolation along the scanline RF carrier
    float sf2 = sf * sf * (3.0 - 2.0 * sf);
    float n0 = h21(float2(s0, row * 1.37 + frameSeed * 31.7));
    float n1 = h21(float2(s0 + 1.0, row * 1.37 + frameSeed * 31.7));
    return mix(n0, n1, sf2) * 2.0 - 1.0;
}

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

    // Dynamic per-frame seed (30 fps frame counter)
    float frameSeed = floor(p.time * 30.0);
    
    // Macro fault events (periodic tape damage / tracking loss burst)
    float dr = 1.0 + p.mixDirtRate * 8.0;
    float ph = p.time * dr;
    float tk = floor(ph);
    float fr = fract(ph);
    float eventTrigger = step(0.38, h21(float2(tk, 11.71) + p.mixDirt * 9.0));
    float burstIntensity = eventTrigger * exp(-fr * mix(10.0, 2.5, p.mixDirt));
    float totalDirt = clamp(p.mixDirt * 0.45 + burstIntensity * 0.75, 0.0, 1.5);

    // 1. Timebase jitter & head switching flag waving
    float2 duv = uv;
    if (p.mixDirtKnock > 0.003) {
        float rowI = floor(uv.y * 480.0);
        
        // Analog horizontal line-to-line sync jitter
        float lineNoise = (h21(float2(rowI * 0.23, frameSeed * 7.19)) - 0.5) * 0.015 * p.mixDirtKnock * totalDirt;
        
        // CRT / VCR bottom head-switching glitch bar
        float headSwitchZone = smoothstep(0.92, 1.0, uv.y);
        float headSwitchShear = headSwitchZone * sin(uv.y * 80.0 + frameSeed) * 0.035 * p.mixDirtKnock * totalDirt;
        
        // Top flag-waving skew
        float flagWave = exp(-uv.y * 6.0) * sin(p.time * 25.0) * 0.02 * p.mixDirtKnock * totalDirt;
        
        // Macro horizontal jump on tracking hit
        float macroJump = (h21(float2(tk, 3.41)) - 0.5) * 0.08 * p.mixDirtKnock * burstIntensity;
        
        duv.x += lineNoise + headSwitchShear + flagWave + macroJump;
        duv.y = clamp(duv.y + (h21(float2(tk, 8.81)) - 0.5) * 0.025 * burstIntensity * p.mixDirtKnock, 0.0, 1.0);
    }

    // 2. Base video sampling with Y/C separation
    float4 srcSample = inTex.sample(smp, clamp(duv, 0.0, 1.0));
    float3 src = srcSample.rgb;
    float alpha = srcSample.a;

    // 3. Realistic Analog Tape Oxide Dropouts (horizontal streaking with exponential RC recovery)
    if (p.mixDirtDrop > 0.003 && totalDirt > 0.01) {
        float rowI = floor(uv.y * 480.0);
        float lineRand = h21(float2(rowI, frameSeed * 13.37));
        
        float dropThresh = 1.0 - (p.mixDirtDrop * totalDirt * 0.07);
        if (lineRand > dropThresh) {
            float streakStart = h21(float2(rowI, frameSeed * 5.11));
            float streakLen = 0.05 + 0.55 * h21(float2(rowI, frameSeed * 19.33));
            
            if (uv.x >= streakStart && uv.x <= streakStart + streakLen) {
                float progress = (uv.x - streakStart) / streakLen;
                // Exponential decay tail at the end of the dropout (head amplifier recovery)
                float tailDecay = exp(-progress * 2.5);
                float flakeType = h21(float2(rowI, frameSeed * 29.7));
                
                if (flakeType < 0.4) {
                    // Bright white RF streak (demodulator saturated peak) with soft edges
                    src = mix(src, float3(0.92, 0.94, 0.98), tailDecay * 0.9);
                } else if (flakeType < 0.7) {
                    // Signal black loss
                    src = mix(src, float3(0.04), tailDecay * 0.85);
                } else {
                    // Y/C delay chromatic smear (red/cyan fringe)
                    float2 cOffset = float2(-0.03 * tailDecay, 0.0);
                    float3 smearedChroma = inTex.sample(smp, clamp(duv + cOffset, 0.0, 1.0)).rgb;
                    src = mix(src, smearedChroma.brg, 0.75 * tailDecay);
                }
            }
        }
    }

    // 4. Analog Magnetic Tape Oxide Spots / Clumps (spanning 2-4 lines with soft organic contours)
    float2 clumpGrid = uv * float2(16.0, 12.0);
    float2 clumpID = floor(clumpGrid);
    float clumpRand = h21(clumpID + float2(frameSeed * 3.3, frameSeed * 7.7));
    if (clumpRand > 1.0 - p.mixDirt * 0.08) {
        float2 clumpCenter = clumpID + float2(h21(clumpID + 1.1), h21(clumpID + 2.2));
        float dist = length((clumpGrid - clumpCenter) * float2(0.5, 2.5)); // Horizontally stretched magnetic smear
        if (dist < 0.45) {
            float clumpMask = smoothstep(0.45, 0.1, dist);
            src = mix(src, float3(0.05), clumpMask * 0.7 * p.mixDirt);
        }
    }

    // 5. 60Hz Ground Loop Hum Bar (soft rolling luma shading)
    float humPos = fract(uv.y * 1.5 - p.time * 0.4);
    float humBar = sin(humPos * 2.0 * PI) * 0.045 * p.mixDirt;
    src = clamp(src + float3(humBar), 0.0, 1.0);

    // 6. Analog RF demodulation noise (continuous scanline carrier, not digital pixels)
    if (p.mixDirtNoise > 0.003) {
        float rfNoise = analogScanlineNoise(uv, frameSeed, p.res.x);
        float noiseGain = p.mixDirtNoise * (0.08 + totalDirt * 0.18);
        src += float3(rfNoise * noiseGain);
        // Slight chromatic noise dispersion
        float rfChroma = analogScanlineNoise(uv + float2(0.01, 0.0), frameSeed + 1.0, p.res.x);
        src.rb += float2(rfChroma * noiseGain * 0.4, -rfChroma * noiseGain * 0.4);
    }

    // 7. Momentary signal solarization / flash on tracking burst
    if (p.mixDirtCut > 0.003 && burstIntensity > 0.08) {
        float cutSeed = h21(float2(tk, 13.9));
        float flashAmt = burstIntensity * p.mixDirtCut;
        if (cutSeed > 0.7) {
            src = mix(src, 1.0 - src, clamp(flashAmt * 1.2, 0.0, 0.9));
        } else if (cutSeed > 0.4) {
            src = mix(src, float3(1.15, 1.1, 0.95), clamp(flashAmt * 1.1, 0.0, 0.85));
        }
    }

    outTex.write(float4(clamp(src, 0.0, 1.5), alpha), gid);
}
