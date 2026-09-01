#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct SynthParams {
    float shape;
    float wave;
    float colmode;
    float genFreqX;
    float genFreqY;
    float genPhase;
    float genRate;
    float genRot;
    float genSkew;
    float genFM;
    float genPulse;
    float genFold;
    float genComp;
    float genThresh;
    float genSoft;
    float genFoldN;
    float genCX;
    float genCY;
    float genZoom;
    float genWarp;
    float genHue;
    float genSpread;
    float genSat;
    float genBright;
    float genBands;
    float blendWithSource;
    float time;
    float2 res;
};

// Value noise helper
inline float vnSynth(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(h21(i), h21(i + float2(1.0, 0.0)), f.x),
        mix(h21(i + float2(0.0, 1.0)), h21(i + float2(1.0, 1.0)), f.x),
        f.y
    );
}

// Oscillator waveform evaluator
inline float oscWave(float x, float waveMode, float pulseWidth) {
    x = fract(x);
    if (waveMode < 0.5) return 0.5 + 0.5 * sin(x * 2.0 * PI); // Sine
    if (waveMode < 1.5) return abs(x * 2.0 - 1.0);             // Triangle
    if (waveMode < 2.5) return x;                              // Saw
    if (waveMode < 3.5) return step(0.5, x);                   // Square
    if (waveMode < 4.5) return step(1.0 - clamp(pulseWidth, 0.02, 0.98), x); // Variable Pulse
    return h21(float2(floor(x * 48.0), 7.31));                 // S&H Noise
}

kernel void bendrSynth(
    texture2d<float, access::sample> inTex  [[texture(0)]],
    texture2d<float, access::write>  outTex [[texture(1)]],
    constant SynthParams &p                 [[buffer(0)]],
    uint2 gid                               [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float t = p.time * p.genRate;
    float ar = p.res.x / p.res.y;

    float2 pos = uv - 0.5 - float2(p.genCX, p.genCY) * 0.5;
    pos.x *= ar;

    float zm = pow(2.0, p.genZoom * 2.0);
    pos *= zm;

    float a0 = p.genRot * PI;
    pos = float2(pos.x * cos(a0) - pos.y * sin(a0), pos.x * sin(a0) + pos.y * cos(a0));
    pos.x += pos.y * p.genSkew * 2.0;

    // Domain warp
    if (p.genWarp > 0.003) {
        pos += (float2(vnSynth(pos * 3.0 + t * 0.2), vnSynth(pos * 3.0 + 17.3 - t * 0.15)) - 0.5) * p.genWarp * 1.2;
    }

    float fx = 0.2 + p.genFreqX * p.genFreqX * 40.0;
    float fy = 0.2 + p.genFreqY * p.genFreqY * 40.0;
    float ph = p.genPhase;
    float nf = max(1.0, floor(p.genFoldN));
    float r = length(pos);
    float ang = atan2(pos.y, pos.x) / (2.0 * PI) + 0.5;

    float f = 0.0;

    if (p.shape < 0.5) {
        // 0: SCAN
        float b = oscWave(pos.y * fy + t * 0.7, p.wave, p.genPulse);
        float a = oscWave(pos.x * fx + ph + t + b * p.genFM * 3.0, p.wave, p.genPulse);
        f = 0.5 * (a + b);
    } else if (p.shape < 1.5) {
        // 1: RADIAL
        f = oscWave(r * fx + ph + t + oscWave(ang * nf, p.wave, p.genPulse) * p.genFM * 2.0, p.wave, p.genPulse);
    } else if (p.shape < 2.5) {
        // 2: SPIRAL
        f = oscWave(r * fx + ang * nf + ph + t, p.wave, p.genPulse);
    } else if (p.shape < 3.5) {
        // 3: PLASMA
        f = 0.25 * (
            oscWave(pos.x * fx * 0.5 + t, p.wave, p.genPulse) +
            oscWave(pos.y * fy * 0.5 - t * 0.8, p.wave, p.genPulse) +
            oscWave((pos.x + pos.y) * fx * 0.35 + t * 1.3, p.wave, p.genPulse) +
            oscWave(r * fy * 0.5 - t * 0.6, p.wave, p.genPulse)
        );
        f = fract(f * (1.0 + p.genFM * 3.0));
    } else if (p.shape < 4.5) {
        // 4: LISSAJOUS
        float lx = sin(pos.x * fx + t);
        float ly = sin(pos.y * fy + t * 1.37 + ph * 2.0 * PI);
        f = oscWave(lx * ly * (0.5 + p.genFM * 3.0) + ph, p.wave, p.genPulse);
    } else if (p.shape < 5.5) {
        // 5: RINGS
        f = oscWave(floor(r * fx * 0.5 + t) / max(1.0, nf) + ph, p.wave, p.genPulse);
    } else if (p.shape < 6.5) {
        // 6: STARBURST
        f = oscWave(ang * nf + ph + t + r * fx * 0.06 * p.genFM * 10.0, p.wave, p.genPulse);
    } else if (p.shape < 7.5) {
        // 7: GRID
        f = max(oscWave(pos.x * fx + ph + t, p.wave, p.genPulse), oscWave(pos.y * fy - t, p.wave, p.genPulse));
    } else if (p.shape < 8.5) {
        // 8: TUNNEL
        float rr = 0.35 / max(r, 0.02);
        f = 0.5 * (oscWave(rr * fx * 0.25 + t, p.wave, p.genPulse) + oscWave(ang * nf + ph, p.wave, p.genPulse));
    } else if (p.shape < 9.5) {
        // 9: CELLS
        float2 g = pos * max(1.0, fx * 0.25);
        float2 gi = floor(g), gf = fract(g);
        float md = 8.0;
        for (int y = -1; y <= 1; y++) {
            for (int x = -1; x <= 1; x++) {
                float2 o = float2(float(x), float(y));
                float2 pt = o + 0.5 + 0.5 * float2(
                    sin(h21(gi + o) * 2.0 * PI + t * 2.0),
                    cos(h21(gi + o + 3.1) * 2.0 * PI + t * 1.7)
                );
                md = min(md, length(pt - gf));
            }
        }
        f = oscWave(md * (0.5 + p.genFM * 3.0) + ph, p.wave, p.genPulse);
    } else if (p.shape < 10.5) {
        // 10: INTERFERENCE
        float d1 = length(pos - float2(0.28, 0.0));
        float d2 = length(pos + float2(0.28, 0.0));
        f = 0.5 * (oscWave(d1 * fx + t, p.wave, p.genPulse) + oscWave(d2 * fy - t, p.wave, p.genPulse));
    } else {
        // 11: POLYGON
        float aa = atan2(pos.y, pos.x);
        float seg = (2.0 * PI) / nf;
        float rp = r * cos(fmod(aa, seg) - seg * 0.5) / max(cos(seg * 0.5), 0.01);
        f = oscWave(rp * fx * 0.5 + ph + t, p.wave, p.genPulse);
    }

    // Wavefolder
    if (p.genFold > 0.003) {
        float k = 1.0 + p.genFold * 7.0;
        f = abs(fract(f * k) * 2.0 - 1.0);
    }

    // Analog Comparator
    if (p.genComp > 0.003) {
        float sf = max(0.001, p.genSoft * 0.5);
        f = mix(f, smoothstep(p.genThresh - sf, p.genThresh + sf, f), p.genComp);
    }
    f = clamp(f, 0.0, 1.0);

    // Color Synthesis
    float3 c = float3(0.0);
    float sp = p.genSpread;

    if (p.colmode < 0.5) {
        // 0: MONO
        c = float3(f);
    } else if (p.colmode < 1.5) {
        // 1: RGB PHASE
        c = float3(
            oscWave(f + p.genHue, p.wave, p.genPulse),
            oscWave(f + p.genHue + sp * 0.33, p.wave, p.genPulse),
            oscWave(f + p.genHue + sp * 0.66, p.wave, p.genPulse)
        );
    } else if (p.colmode < 2.5) {
        // 2: HSV SPECTRUM
        c = hsv2rgb(float3(fract(p.genHue + f * sp), p.genSat, mix(1.0, f, 0.25)));
    } else if (p.colmode < 3.5) {
        // 3: DUOTONE
        float3 c1 = hsv2rgb(float3(fract(p.genHue), p.genSat, 1.0));
        float3 c2 = hsv2rgb(float3(fract(p.genHue + sp * 0.5), p.genSat, 1.0));
        c = mix(c1, c2, f);
    } else {
        // 4: HARMONIC BANDS
        float nb = max(2.0, floor(p.genBands));
        float q = floor(f * nb) / nb;
        c = hsv2rgb(float3(fract(p.genHue + q * sp), p.genSat, 1.0));
    }

    float3 synthRgb = clamp(c * p.genBright, 0.0, 1.0);

    if (p.blendWithSource > 0.003) {
        float4 srcSample = inTex.sample(smp, uv);
        synthRgb = mix(synthRgb, srcSample.rgb + synthRgb, p.blendWithSource);
    }

    outTex.write(float4(synthRgb, 1.0), gid);
}
