#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct CorruptParams {
    float pixelSort;
    float sortThresh;
    float blockShift;
    float blockSize;
    float dotify;
    float dotSize;
    float driftWarp;
    float fmWarp;
    float dctAmt;
    float dctQ;
    float dctTilt;
    float dctChroma;
    float dctBlock;
    float time;
    float2 res;
};

kernel void bendrCorrupt(
    texture2d<float, access::sample> inTex  [[texture(0)]],
    texture2d<float, access::write>  outTex [[texture(1)]],
    constant CorruptParams &p               [[buffer(0)]],
    uint2 gid                               [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float2 suv = uv;

    // Channel-driven drift warp (clamped to edge, no wrapping loops)
    if (p.driftWarp > 0.003) {
        for (int k = 0; k < 3; k++) {
            float2 w = (inTex.sample(smp, clamp(suv, 0.0, 1.0)).rg - 0.5) * p.driftWarp * 0.04;
            suv += w;
        }
    }

    // FM warp — scan phase modulated by brightness (smooth timebase wobble)
    if (p.fmWarp > 0.003) {
        float lumaVal = luma(inTex.sample(smp, clamp(suv, 0.0, 1.0)).rgb);
        float ph = uv.y * 32.0 + lumaVal * p.fmWarp * 6.28318 + p.time * 3.0;
        suv.x += sin(ph) * p.fmWarp * 0.015;
    }

    float3 c = inTex.sample(smp, clamp(suv, 0.0, 1.0)).rgb;

    // Databent macroblock shift
    if (p.blockShift > 0.003) {
        float bn = mix(52.0, 7.0, p.blockSize);
        float2 cell = floor(uv * float2(bn, bn * p.res.y / p.res.x));
        float tk = floor(p.time * 2.3);
        float r1 = h21(cell * 1.31 + tk * 17.0);
        if (r1 < p.blockShift * 0.4) {
            float2 off = (float2(h21(cell + 31.0 + tk), h21(cell + 57.0 + tk)) - 0.5) * 0.35 * p.blockShift;
            float3 bc = inTex.sample(smp, clamp(suv + off, 0.0, 1.0)).rgb;
            float r2 = h21(cell + 99.0);
            if (r2 < 0.22) bc = bc.gbr;
            else if (r2 < 0.38) bc = 1.0 - bc;
            else if (r2 < 0.5) bc = floor(bc * 3.0 + 0.5) / 3.0;
            c = bc;
        }
    }

    // Directional pixel sorting
    if (p.pixelSort > 0.003) {
        float th = p.sortThresh;
        float l0 = luma(c);
        if (l0 > th) {
            float py = 1.0 / p.res.y;
            float d = 0.0;
            for (int k = 1; k <= 32; k++) {
                if (luma(inTex.sample(smp, clamp(suv + float2(0.0, float(k) * 2.0 * py), 0.0, 1.0)).rgb) <= th) break;
                d += 2.0 * py;
            }
            float3 sc = inTex.sample(smp, clamp(suv + float2(0.0, d), 0.0, 1.0)).rgb;
            c = mix(c, sc, p.pixelSort);
        }
    }

    // Halftone dotting
    if (p.dotify > 0.003) {
        float cellPx = mix(26.0, 6.0, p.dotSize);
        float2 g = uv * p.res / cellPx;
        float2 cc = (floor(g) + 0.5) * cellPx / p.res;
        float3 cs = inTex.sample(smp, clamp(cc, 0.0, 1.0)).rgb;
        float lm = luma(cs);
        float r = length(fract(g) - 0.5);
        float m = smoothstep(lm * 0.72 + 0.06, lm * 0.72 - 0.06, r);
        c = mix(c, cs * m, p.dotify);
    }

    // DCT block quantization simulation
    if (p.dctAmt > 0.003) {
        float bs = mix(8.0, 32.0, p.dctBlock);
        float2 bCoord = floor(uv * p.res / bs) * bs / p.res;
        float3 bSample = inTex.sample(smp, clamp(bCoord, 0.0, 1.0)).rgb;
        float qStep = mix(0.02, 0.4, p.dctQ);
        float3 qCol = floor(bSample / qStep + 0.5) * qStep;
        c = mix(c, qCol, p.dctAmt);
    }

    float alpha = inTex.sample(smp, uv).a;
    outTex.write(float4(clamp(c, 0.0, 1.5), alpha), gid);
}
