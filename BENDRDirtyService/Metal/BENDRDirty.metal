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

    // Event Clock & Trigger
    float dr = 0.5 + p.mixDirtRate * 15.0;
    float ph = p.time * dr;
    float tk = floor(ph);
    float fr = fract(ph);
    float dirtSeed = tk;

    float fire = step(h21(float2(tk, 7.71)), clamp(p.mixDirt, 0.0, 1.0) * 0.85);
    float dirtE = max(p.mixDirt * 0.35, fire * exp(-fr * mix(11.0, 1.6, p.mixDirt)));

    // Timebase Knock
    float2 duv = uv;
    float kn = dirtE * p.mixDirtKnock;
    if (kn > 0.0005) {
        float rowI = floor(uv.y * p.res.y);
        float shove = (h21(float2(tk, 5.53)) - 0.5) * 0.16 * kn;
        shove *= mix(1.0, 1.0 - uv.y, 0.6);
        shove += (h21(float2(rowI, tk * 0.77)) - 0.5) * 0.05 * kn;
        duv.x += shove;
        duv.y = fract(duv.y + (h21(float2(tk, 2.19)) - 0.5) * 0.06 * kn);
    }

    float4 srcSample = inTex.sample(smp, clamp(duv, 0.0, 1.0));
    float3 src = srcSample.rgb;
    float alpha = srcSample.a;

    if (dirtE > 0.001) {
        // Switching Cut / Momentary Flash & Inversion
        if (p.mixDirtCut > 0.002) {
            float cutSeed = h21(float2(tk, 9.31));
            float3 flashCol = (cutSeed > 0.5) ? float3(0.95) : float3(0.05);
            if (cutSeed > 0.75) {
                flashCol = 1.0 - src;
            }
            src = mix(src, flashCol, clamp(dirtE * p.mixDirtCut * 1.4, 0.0, 0.92));
        }

        // Line Dropouts
        if (p.mixDirtDrop > 0.002) {
            float bandH = 2.0 + 26.0 * h21(float2(dirtSeed, 1.31));
            float rowb = floor(uv.y * p.res.y / bandH);
            float dh = h21(float2(rowb, dirtSeed * 0.77));
            float drop = step(1.0 - clamp(p.mixDirtDrop * dirtE * 1.3, 0.0, 0.95), dh);
            if (drop > 0.5) {
                float sk = (h21(float2(rowb, dirtSeed * 2.3)) - 0.5) * 0.09;
                float dead = step(0.65, h21(float2(rowb * 3.1, dirtSeed)));
                float3 alt = inTex.sample(smp, clamp(float2(uv.x + sk, uv.y), 0.0, 1.0)).rgb;
                float nzVal = h21(float2(floor(uv.x * p.res.x / 2.5), rowb + dirtSeed)) * 0.5;
                alt = mix(alt, float3(nzVal), dead);
                src = mix(src, alt, clamp(p.mixDirtDrop * 1.2, 0.0, 1.0));
            }
        }

        // Switching Transient Noise & Transient Desaturation
        if (p.mixDirtNoise > 0.002) {
            float nx = floor(uv.x * p.res.x / 3.0);
            float ny = floor(uv.y * p.res.y);
            float nz = h21(float2(nx + ny * 13.7, dirtSeed * 7.3)) - 0.5;
            src += nz * p.mixDirtNoise * dirtE * 1.6;
            src = mix(src, float3(luma(src)), p.mixDirtNoise * dirtE * 0.5);
        }
    }

    outTex.write(float4(clamp(src, 0.0, 1.5), alpha), gid);
}
