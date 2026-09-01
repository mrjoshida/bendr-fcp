#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct SignalLabParams {
    float sparseJit;
    float jitThresh;
    float fmAmt;
    float fmCarrier;
    float slitscan;
    float slitDir;
    float rowSmear;
    float pngAmt;
    float pngDir;
    float pngRun;
    float ntscArt;
    float ntscFringe;
    float snow;
    float snowAniso;
    float moire;
    float moireFreq;
    float bitCrush;
    float bitScale;
    float bandKey;
    float bandN;
    float bandHue;
    float fieldMod;
    float fieldSrc;
    float fieldWarp;
    float fieldHue;
    float time;
    float2 res;
};

// Generates video-rate modulation field
inline float fieldAt(float2 uv, float fieldSrc, float time) {
    if (fieldSrc < 0.5) return uv.x;
    if (fieldSrc < 1.5) return 1.0 - uv.y;
    if (fieldSrc < 2.5) return clamp(length(uv - 0.5) * 1.9, 0.0, 1.0);
    if (fieldSrc < 3.5) return 0.5 + 0.5 * sin(uv.x * 20.0 + time);
    return h21(floor(uv * 40.0));
}

kernel void bendrSignalLab(
    texture2d<float, access::sample> inTex  [[texture(0)]],
    texture2d<float, access::write>  outTex [[texture(1)]],
    constant SignalLabParams &p             [[buffer(0)]],
    uint2 gid                               [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float2 suv = uv;
    float fld = fieldAt(uv, p.fieldSrc, p.time);

    // Field modulation warps space per-pixel
    if (p.fieldMod > 0.003 && abs(p.fieldWarp) > 0.003) {
        suv.x += (fld - 0.5) * p.fieldWarp * p.fieldMod * 0.15;
    }

    // Sparse line jitter
    if (p.sparseJit > 0.003) {
        float row = floor(uv.y * p.res.y / 2.0);
        float j = h21(float2(row, floor(p.time * 24.0))) * 2.0 - 1.0;
        j *= step(p.jitThresh, abs(j));
        suv.x += j * p.sparseJit * 0.25;
    }

    // FM carrier wobble
    if (p.fmAmt > 0.003) {
        float car = mix(2.0, 60.0, p.fmCarrier);
        float m = luma(inTex.sample(smp, fract(suv)).rgb);
        suv.x += sin((uv.y * car + m * 8.0 + p.time) * PI) * p.fmAmt * 0.03;
    }

    // Slitscan
    if (p.slitscan > 0.003) {
        float axis = mix(uv.y, uv.x, step(0.5, p.slitDir));
        float sh = (axis - 0.5) * p.slitscan * 0.35;
        suv += mix(float2(sh, 0.0), float2(0.0, sh), step(0.5, p.slitDir));
    }

    // Row smear
    if (p.rowSmear > 0.003) {
        float amt = p.rowSmear * 0.35;
        suv.x -= amt * fract(uv.y * p.res.y * 0.5) * 0.4;
        suv.y -= amt * 0.02;
    }

    float4 baseSample = inTex.sample(smp, fract(suv));
    float3 c = baseSample.rgb;
    float alpha = baseSample.a;

    // PNG reconstruction filter avalanche
    if (p.pngAmt > 0.003) {
        float2 stepv = (p.pngDir < 0.5) ? float2(1.0 / p.res.x, 0.0)
                     : (p.pngDir < 1.5) ? float2(0.0, 1.0 / p.res.y)
                     : float2(1.0 / p.res.x, 1.0 / p.res.y) * 0.7071;
        float lane = (p.pngDir < 0.5) ? floor(suv.y * p.res.y) : floor(suv.x * p.res.x);
        float hit = h21(float2(lane, floor(p.time * 3.0)));
        if (hit < p.pngAmt * 0.5) {
            float3 acc = float3(0.0);
            float span = 2.0 + p.pngRun * 40.0;
            for (int i = 1; i <= 32; i++) {
                float fi = float(i);
                if (fi > span) break;
                float2 tp = suv - stepv * fi;
                float inb = step(0.0, tp.x) * step(tp.x, 1.0) * step(0.0, tp.y) * step(tp.y, 1.0);
                float3 a1 = inTex.sample(smp, clamp(tp, 0.0, 1.0)).rgb;
                float3 a2 = inTex.sample(smp, clamp(tp - stepv, 0.0, 1.0)).rgb;
                acc += (a1 - a2) * inb;
            }
            float seed = h21(float2(lane * 1.7, 11.0)) * 2.0 - 1.0;
            c = fract(c + acc * p.pngAmt * 1.6 + seed * p.pngAmt * 0.25);
        }
    }

    // NTSC composite crosstalk & chroma fringing
    if (p.ntscArt > 0.003 || p.ntscFringe > 0.003) {
        float px = 1.0 / p.res.x;
        float3 yq = rgb2yiq(c);
        float3 l = rgb2yiq(inTex.sample(smp, float2(clamp(suv.x - px * 2.0, 0.0, 1.0), fract(suv.y))).rgb);
        float3 r = rgb2yiq(inTex.sample(smp, float2(clamp(suv.x + px * 2.0, 0.0, 1.0), fract(suv.y))).rgb);
        float carrier = sin(suv.x * p.res.x * 1.8 + floor(suv.y * p.res.y) * 2.4 + p.time * 9.0);
        yq.yz += (yq.x - 0.5 * (l.x + r.x)) * p.ntscArt * 2.2 * float2(carrier, carrier * 0.87);
        yq.x += (length(yq.yz)) * p.ntscFringe * carrier * 0.5;
        c = yiq2rgb(yq);
    }

    // Anisotropic CRT snow
    if (p.snow > 0.003) {
        float row = floor(uv.y * p.res.y);
        float lineGate = mix(1.0, step(0.82, h21(float2(row, floor(p.time * 30.0)))), p.snowAniso);
        float seed = h21(floor(uv * float2(p.res.x / 3.0, p.res.y)) + fract(p.time) * 91.0);
        float hit = step(1.0 - p.snow * 0.06 * lineGate * 3.0, seed);
        if (hit > 0.5) {
            float tail = fract(uv.x * p.res.x / 3.0);
            c += float3(1.0 - tail) * p.snow * 1.2;
        }
    }

    // Moire grid interference
    if (p.moire > 0.003) {
        float f = mix(40.0, 400.0, p.moireFreq);
        float m = sin(uv.x * f) * sin(uv.y * f * 1.03 + p.time * 0.4);
        c *= 1.0 + m * p.moire * 0.5;
    }

    // 1-Bit Bayer dither crush
    if (p.bitCrush > 0.003) {
        float cell = mix(1.5, 14.0, p.bitScale);
        float2 cuv = (floor(uv * p.res / cell) + 0.5) * cell / p.res;
        float3 sm = (
            inTex.sample(smp, cuv).rgb +
            inTex.sample(smp, cuv + float2(cell, 0.0) / p.res).rgb +
            inTex.sample(smp, cuv - float2(cell, 0.0) / p.res).rgb +
            inTex.sample(smp, cuv + float2(0.0, cell) / p.res).rgb +
            inTex.sample(smp, cuv - float2(0.0, cell) / p.res).rgb
        ) * 0.2;
        float L = luma(sm);
        int2 bp = int2(fmod(float2(gid) / cell, 4.0));
        constant float bayer[16] = {
            0.0, 8.0, 2.0, 10.0,
            12.0, 4.0, 14.0, 6.0,
            3.0, 11.0, 1.0, 9.0,
            15.0, 7.0, 13.0, 5.0
        };
        float th = bayer[clamp(bp.y * 4 + bp.x, 0, 15)] / 16.0;
        c = mix(c, float3(step(th, L)), p.bitCrush);
    }

    // Multi-band sequential keyer
    if (p.bandKey > 0.003) {
        float L = luma(c);
        float N = max(2.0, floor(p.bandN));
        float band = floor(L * N);
        float3 bc = 0.5 + 0.5 * cos(6.2831853 * (band / N + p.bandHue + float3(0.0, 0.333, 0.667)));
        c = mix(c, bc * (0.35 + 0.75 * band / N), p.bandKey);
    }

    // Field modulation into hue
    if (p.fieldMod > 0.003 && abs(p.fieldHue) > 0.003) {
        float3 yq = rgb2yiq(c);
        float a = fld * p.fieldHue * p.fieldMod * 6.2831853;
        float cc = cos(a), ss = sin(a);
        yq.yz = float2(cc * yq.y - ss * yq.z, ss * yq.y + cc * yq.z);
        c = yiq2rgb(yq);
    }

    outTex.write(float4(clamp(c, 0.0, 2.0), alpha), gid);
}
