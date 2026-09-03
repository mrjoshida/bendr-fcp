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

// Continuous 1D band-limited analog RF noise along scanline carrier
inline float analogCarrierNoise(float2 uv, float frameSeed, float resX) {
    float row = floor(uv.y * 480.0);
    float scanPos = uv.x * resX * 0.95 + row * 19.37;
    float s0 = floor(scanPos);
    float sf = fract(scanPos);
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

    // 60Hz analog field timing
    float frameSeed = floor(p.time * 60.0);
    float scanlines = 480.0;
    float row = uv.y * scanlines;
    float rowI = floor(row);
    
    // Dynamic periodic desk knock / circuit fault oscillation
    float faultRate = 1.0 + p.mixDirtRate * 4.5;
    float faultPhase = p.time * faultRate;
    float faultBlock = floor(faultPhase);
    float faultFrac = fract(faultPhase);
    
    float hitRand = h21(float2(faultBlock, 7.31));
    float isHit = step(0.30, hitRand);
    float hitDecay = exp(-faultFrac * mix(6.5, 2.2, p.mixDirt));
    float hitPower = isHit * hitDecay * p.mixDirt;

    // 1. ANALOG TIMEBASE & SYNC DEVIATION (TBC Jitter, Tearing & Head Switching)
    float2 duv = uv;
    float totalKnock = p.mixDirtKnock * (p.mixDirt * 0.75 + hitPower * 1.4);
    
    if (totalKnock > 0.002) {
        // A. Horizontal TBC loss bands (jagged analog scanline tearing across 12-36 lines)
        float bandSize = 18.0 + 24.0 * h21(float2(faultBlock, 11.3));
        float bandID = floor((row + frameSeed * 2.3) / bandSize);
        float bandRand = h21(float2(bandID, frameSeed * 0.13));
        
        if (bandRand > 0.50) {
            float tearStrength = (h21(float2(bandID, frameSeed * 0.37)) - 0.5) * 0.06 * totalKnock;
            duv.x += tearStrength;
        }
        
        // B. Fast analog line-by-line sync jitter
        float lineJitter = (h21(float2(rowI * 1.33, frameSeed * 4.91)) - 0.5) * 0.012 * totalKnock;
        duv.x += lineJitter;
        
        // C. Bottom head-switching glitch band (nonlinear phase shear)
        float headZone = smoothstep(0.90, 0.99, uv.y);
        float headShear = headZone * sin(uv.y * 110.0 + frameSeed * 0.7) * 0.035 * totalKnock;
        duv.x += headShear;
        
        // D. Top tape tension skew (flag waving falloff)
        float flagWave = exp(-uv.y * 5.5) * sin(p.time * 24.0 + rowI * 0.05) * 0.022 * totalKnock;
        duv.x += flagWave;
        
        // E. Vertical field rolling on hard knock
        if (hitPower > 0.15) {
            float vRoll = sin(p.time * 38.0) * 0.05 * hitPower;
            duv.y = fract(duv.y + vRoll);
        }
    }

    // 2. Base Video Sample in YIQ Analog Domain with Chromatic Dispersion
    float4 baseSample = inTex.sample(smp, clamp(duv, 0.0, 1.0));
    float3 yiq = rgb2yiq(baseSample.rgb);
    float alpha = baseSample.a;

    // 3. ANALOG PREAMP SLEW-RATE LIMITING & EDGE RINGING
    float2 dX = float2(2.5 / p.res.x, 0.0);
    float3 leftSample = inTex.sample(smp, clamp(duv - dX, 0.0, 1.0)).rgb;
    float edgeLuma = luma(baseSample.rgb) - luma(leftSample);
    yiq.x += edgeLuma * 0.5 * p.mixDirt;

    // 4. AUTHENTIC MULTI-SCALE ANALOG TAPE OXIDE DROPOUTS
    if (p.mixDirtDrop > 0.003) {
        float dropDensity = p.mixDirtDrop * (0.35 + p.mixDirt * 0.55 + hitPower * 0.7);
        
        // Evaluate 6 distinct analog dropout events across the field
        for (int k = 0; k < 6; k++) {
            float fk = float(k);
            float bandCenter = h21(float2(fk * 17.7, frameSeed * 5.31 + fk * 11.9)) * scanlines;
            float rowDist = abs(row - bandCenter);
            
            // Soft vertical profile across 2-4 scanlines
            if (rowDist < 4.0) {
                float vertEnvelope = exp(-rowDist * rowDist * 0.28);
                float dropTrigger = h21(float2(bandCenter, frameSeed * 13.7 + fk * 29.3));
                
                if (dropTrigger > 1.0 - dropDensity * 0.35) {
                    float startX = h21(float2(bandCenter, frameSeed * 2.91 + fk * 13.7));
                    float lenX = 0.06 + 0.60 * h21(float2(bandCenter, frameSeed * 8.17 + fk * 37.1));
                    
                    if (uv.x >= startX && uv.x <= startX + lenX) {
                        float progress = (uv.x - startX) / lenX;
                        // Organic attack and exponential RC decay tail
                        float attack = smoothstep(0.0, 0.06, progress);
                        float decay = exp(-progress * 3.0);
                        float env = attack * decay * vertEnvelope;
                        
                        float dropMode = h21(float2(bandCenter, frameSeed * 37.9 + fk * 9.1));
                        
                        if (dropMode < 0.42) {
                            // Demodulator saturation surge (luminous white RF burst with cyan glow)
                            yiq.x = mix(yiq.x, 1.15, env * 0.90);
                            yiq.yz *= (1.0 - env * 0.92);
                        } else if (dropMode < 0.75) {
                            // Oxide gap loss (luma signal droop + analog carrier hiss)
                            float hiss = (h21(float2(gid.x, gid.y + frameSeed * 7.0)) - 0.5) * 0.4;
                            yiq.x = mix(yiq.x, 0.06 + hiss, env * 0.85);
                            yiq.yz *= (1.0 - env * 0.80);
                        } else {
                            // Demodulator PLL unlock chromatic burst (phase swing in I/Q subcarrier)
                            float phaseAngle = progress * 18.0 + frameSeed * 1.5;
                            float2 chromBurst = float2(cos(phaseAngle), sin(phaseAngle)) * 0.4;
                            yiq.yz = mix(yiq.yz, chromBurst, env * 0.85);
                        }
                    }
                }
            }
        }
    }

    // 5. TAPE CREASE & TRANSVERSE WRINKLE TRACK (Diagonal physical tape crease)
    if (p.mixDirt > 0.15) {
        float creasePos = fract(p.time * 0.12 + 0.4);
        float creaseDist = abs(uv.y - creasePos + (uv.x - 0.5) * 0.15);
        if (creaseDist < 0.025) {
            float cEnv = smoothstep(0.025, 0.002, creaseDist) * p.mixDirt * 0.6;
            // Crease luma shift and phase distortion
            yiq.x = mix(yiq.x, yiq.x * 0.5 + 0.35, cEnv * 0.5);
            yiq.y += sin(uv.x * 40.0 + frameSeed) * 0.15 * cEnv;
            yiq.z += cos(uv.x * 40.0 + frameSeed) * 0.15 * cEnv;
        }
    }

    // 6. 60Hz & 120Hz ROLLING GROUND LOOP HUM BARS
    float hum = sin(uv.y * 6.28318 * 2.0 - p.time * 3.5) * 0.05 * p.mixDirt
              + sin(uv.y * 6.28318 * 4.0 - p.time * 7.0) * 0.025 * p.mixDirt;
    yiq.x += hum;

    // 7. CONTINUOUS ANALOG BAND-LIMITED SCANLINE RF NOISE
    if (p.mixDirtNoise > 0.003) {
        float rfLuma = analogCarrierNoise(uv, frameSeed, p.res.x);
        float rfChrom = analogCarrierNoise(uv + float2(0.015, 0.0), frameSeed + 17.0, p.res.x * 0.6);
        float noiseGain = p.mixDirtNoise * (0.06 + p.mixDirt * 0.14 + hitPower * 0.20);
        
        yiq.x += rfLuma * noiseGain;
        yiq.yz += float2(rfChrom) * noiseGain * 0.5;
    }

    // 8. INTERMITTENT DESK VOLTAGE BROWNOUT SAG & FLASH CUTS
    if (p.mixDirtCut > 0.003 && hitPower > 0.12) {
        float cutTrigger = h21(float2(faultBlock, 71.3));
        if (cutTrigger > 0.65) {
            float sagAmount = hitPower * p.mixDirtCut;
            yiq.x = pow(max(yiq.x, 0.0), 1.0 + sagAmount * 1.8) * (1.0 - sagAmount * 0.45);
            yiq.yz *= (1.0 - sagAmount * 0.65);
        }
    }

    // Convert back from YIQ to RGB with analog clamping
    float3 finalRGB = yiq2rgb(yiq);
    outTex.write(float4(clamp(finalRGB, 0.0, 1.2), alpha), gid);
}
