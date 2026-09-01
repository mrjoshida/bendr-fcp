#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct SpatialParams {
    float srcZoom;
    float srcX;
    float srcY;
    float srcRot;
    float flipMode;
    float mirrorMode;
    float multiN;
    float kaleido;
    float kaleidoN;
    float kaleidoRot;
    float kaleidoX;
    float kaleidoY;
    float shake;
    float shakeRate;
    float tdAmt;
    float tdMap;
    float tdSpread;
    float tdSoft;
    float tdWarp;
    float time;
    float2 res;
};

kernel void bendrSpatial(
    texture2d<float, access::sample> inTex   [[texture(0)]],
    texture2d<float, access::sample> prevTex [[texture(1)]],
    texture2d<float, access::write>  outTex  [[texture(2)]],
    constant SpatialParams &p                [[buffer(0)]],
    uint2 gid                                [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float outA = p.res.x / p.res.y;

    // Camera Shake
    float2 sOff = float2(0.0);
    if (p.shake > 0.001) {
        float shT = p.time * (2.0 + p.shakeRate * 20.0);
        float tk = floor(shT);
        float2 n1 = float2(h21(float2(tk, 1.11)), h21(float2(tk, 2.22))) * 2.0 - 1.0;
        float2 n2 = float2(h21(float2(tk + 1.0, 1.11)), h21(float2(tk + 1.0, 2.22))) * 2.0 - 1.0;
        sOff = mix(n1, n2, smoothstep(0.0, 1.0, fract(shT))) * p.shake * 0.04;
    }

    // Centered Geometry Transforms
    float2 pos = (uv - 0.5 - float2(p.srcX, p.srcY) - sOff) * float2(outA, 1.0);
    pos = rotate2D(pos, p.srcRot * PI);
    pos *= exp(-p.srcZoom * 1.5);
    pos.x /= outA;
    pos += 0.5;

    // Flip Mode
    if (p.flipMode > 0.5 && p.flipMode < 1.5) {
        pos.x = 1.0 - pos.x;
    } else if (p.flipMode > 1.5 && p.flipMode < 2.5) {
        pos.y = 1.0 - pos.y;
    } else if (p.flipMode > 2.5) {
        pos = 1.0 - pos;
    }

    // Mirror Mode
    if (p.mirrorMode > 0.5 && p.mirrorMode < 1.5) {
        pos.x = 1.0 - abs(pos.x * 2.0 - 1.0);
    } else if (p.mirrorMode > 1.5 && p.mirrorMode < 2.5) {
        pos.y = 1.0 - abs(pos.y * 2.0 - 1.0);
    } else if (p.mirrorMode > 2.5) {
        pos.x = 1.0 - abs(pos.x * 2.0 - 1.0);
        pos.y = 1.0 - abs(pos.y * 2.0 - 1.0);
    }

    // Multi-Grid Array
    if (p.multiN > 1.01) {
        float n = floor(p.multiN);
        pos = fract(pos * n);
    }

    // Kaleidoscope Symmetry
    if (p.kaleido > 0.003) {
        float2 kpos = (pos - 0.5 - float2(p.kaleidoX, p.kaleidoY) * 0.5) * float2(outA, 1.0);
        float r = length(kpos);
        float ang = atan2(kpos.y, kpos.x) + p.kaleidoRot * PI;
        float seg = (2.0 * PI) / max(2.0, floor(p.kaleidoN));
        ang = abs(fmod(ang, seg) - seg * 0.5);
        float2 folded = float2(cos(ang), sin(ang)) * r;
        folded.x /= outA;
        folded += 0.5 + float2(p.kaleidoX, p.kaleidoY) * 0.5;
        pos = mix(pos, folded, p.kaleido);
    }

    float4 curSample = inTex.sample(smp, clamp(pos, 0.0, 1.0));
    float3 cur = curSample.rgb;
    float alpha = curSample.a;

    // Time Displacement Mapping
    if (p.tdAmt > 0.003) {
        float m = 0.0;
        if (p.tdMap < 0.5) {
            m = 1.0 - pos.y;                                          // Slitscan vertical
        } else if (p.tdMap < 1.5) {
            m = pos.x;                                                // Sweep horizontal
        } else if (p.tdMap < 2.5) {
            m = luma(cur);                                            // Luma lag map
        } else if (p.tdMap < 3.5) {
            m = clamp(length(pos - 0.5) * 1.6, 0.0, 1.0);             // Radial center lag
        } else {
            m = fract(pos.y * p.res.y / 8.0);                         // Failing TBC lines
        }

        m = mix(m, fract(m + p.time * 0.05), p.tdWarp);
        float tdWeight = clamp(m * p.tdSpread, 0.0, 1.0) * p.tdAmt;

        float3 past = prevTex.sample(smp, clamp(pos, 0.0, 1.0)).rgb;
        cur = mix(cur, past, tdWeight);
    }

    outTex.write(float4(cur, alpha), gid);
}
