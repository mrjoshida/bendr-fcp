#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct MeltParams {
    float meltMode;
    float edgeAmt;
    float edgeHold;
    float edgeWidth;
    float edgeCreep;
    float edgeSwirl;
    float meltZoom;
    float meltDir;
    float meltGate;
    float meltSoft;
    float edgeChroma;
    float meltHue;
    float time;
    float2 res;
};

// Helper: 2D Sobel edge detector
inline float4 sampleEdge(texture2d<float, access::sample> tex, sampler smp, float2 uv, float2 res) {
    float2 e = 2.0 / res;
    float3 c00 = tex.sample(smp, clamp(uv + float2(-e.x, -e.y), 0.0, 1.0)).rgb;
    float3 c10 = tex.sample(smp, clamp(uv + float2( 0.0, -e.y), 0.0, 1.0)).rgb;
    float3 c20 = tex.sample(smp, clamp(uv + float2( e.x, -e.y), 0.0, 1.0)).rgb;
    float3 c01 = tex.sample(smp, clamp(uv + float2(-e.x,  0.0), 0.0, 1.0)).rgb;
    float3 c21 = tex.sample(smp, clamp(uv + float2( e.x,  0.0), 0.0, 1.0)).rgb;
    float3 c02 = tex.sample(smp, clamp(uv + float2(-e.x,  e.y), 0.0, 1.0)).rgb;
    float3 c12 = tex.sample(smp, clamp(uv + float2( 0.0,  e.y), 0.0, 1.0)).rgb;
    float3 c22 = tex.sample(smp, clamp(uv + float2( e.x,  e.y), 0.0, 1.0)).rgb;

    float l00 = luma(c00), l10 = luma(c10), l20 = luma(c20);
    float l01 = luma(c01),                 l21 = luma(c21);
    float l02 = luma(c02), l12 = luma(c12), l22 = luma(c22);

    float gx = (l20 + 2.0 * l21 + l22) - (l00 + 2.0 * l01 + l02);
    float gy = (l02 + 2.0 * l12 + l22) - (l00 + 2.0 * l10 + l20);
    float mag = sqrt(gx * gx + gy * gy);
    float2 dir = (mag > 0.001) ? float2(gx, gy) / mag : float2(0.0, 1.0);
    return float4(dir, mag, l10);
}

kernel void bendrMelt(
    texture2d<float, access::sample> inTex   [[texture(0)]],
    texture2d<float, access::sample> prevTex [[texture(1)]],
    texture2d<float, access::write>  outTex  [[texture(2)]],
    constant MeltParams &p                   [[buffer(0)]],
    uint2 gid                                [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float outA = p.res.x / p.res.y;

    float4 srcSample = inTex.sample(smp, uv);
    float3 src = srcSample.rgb;
    float srcAlpha = srcSample.a;

    if (p.edgeAmt < 0.001 && p.edgeHold < 0.001) {
        outTex.write(float4(src, srcAlpha), gid);
        return;
    }

    float4 edgeInfo = sampleEdge(inTex, smp, uv, p.res);
    float2 en = edgeInfo.xy;
    float edgeMag = edgeInfo.z;
    float l = luma(src);

    // Multi-tap directional melt vector calculation
    float2 meltVec = float2(0.0);
    float meltWeight = 0.0;

    if (p.meltMode > 2.5) {
        // Mode 3: Gravity / Directional Luma Melt (viscous dripping)
        float a = p.meltDir * PI;
        float gate = mix(1.0, smoothstep(p.meltGate - 0.2, p.meltGate + 0.2, l), step(0.001, p.meltGate));
        float2 gdir = float2(sin(a), -cos(a));
        float dripScale = (0.01 + p.edgeAmt * 0.12) * (0.2 + 0.8 * l) * gate;
        meltVec = gdir * dripScale;
        meltWeight = gate * clamp(p.edgeHold * 1.2, 0.0, 1.0);
    } else if (p.meltMode > 1.5) {
        // Mode 2: Motion Driven Dynamic Warp
        float2 c = (uv - 0.5) * float2(outA, 1.0);
        float ro = p.edgeSwirl * 0.35;
        float zo = 1.0 - p.meltZoom * 0.18;
        float cs = cos(ro), sn = sin(ro);
        float2 rotC = float2(cs * c.x - sn * c.y, sn * c.x + cs * c.y) * zo;
        float2 targetUV = rotC / float2(outA, 1.0) + 0.5;
        meltVec = (targetUV - uv) * (0.5 + p.edgeAmt);
        
        float3 prevSample = prevTex.sample(smp, uv).rgb;
        float motionDiff = abs(l - luma(prevSample));
        meltWeight = clamp(p.edgeHold * (0.4 + motionDiff * 8.0 * (1.0 + p.edgeWidth * 3.0)), 0.0, 1.0);
    } else if (p.meltMode > 0.5) {
        // Mode 1: Spiral Feedback Vortex
        float2 c = (uv - 0.5) * float2(outA, 1.0);
        float ro = p.edgeSwirl * 0.35 + sin(p.time * 0.5) * 0.05;
        float zo = 1.0 - p.meltZoom * 0.18;
        float cs = cos(ro), sn = sin(ro);
        float2 rotC = float2(cs * c.x - sn * c.y, sn * c.x + cs * c.y) * zo;
        float2 targetUV = rotC / float2(outA, 1.0) + 0.5;
        meltVec = (targetUV - uv) * (0.4 + p.edgeAmt * 0.8);
        meltWeight = clamp(p.edgeHold * 1.0, 0.0, 1.0);
    } else {
        // Mode 0: Edge Smear / Boundary Bleed
        float creepSign = mix(1.0, -1.0, p.edgeCreep);
        float smearDist = (0.01 + p.edgeAmt * 0.09);
        meltVec = en * creepSign * smearDist;
        float edgeBand = smoothstep(0.01, 0.35 / (1.0 + p.edgeWidth * 4.0), edgeMag);
        meltWeight = clamp(edgeBand * p.edgeHold * 1.3, 0.0, 1.0);
    }

    // Multi-tap viscous accumulation along melt vector (8 taps)
    float3 meltedRgb = float3(0.0);
    float totalW = 0.0;
    for (int i = 1; i <= 8; i++) {
        float fi = float(i) / 8.0;
        float tapW = exp(-fi * (1.5 - p.edgeHold * 0.8));
        float2 tapUV = clamp(uv + meltVec * fi, 0.0, 1.0);
        
        // Chromatic dispersion per tap
        if (p.edgeChroma > 0.002) {
            float2 cOff = meltVec * fi * p.edgeChroma * 0.5;
            float r = inTex.sample(smp, clamp(tapUV + cOff, 0.0, 1.0)).r;
            float g = inTex.sample(smp, tapUV).g;
            float b = inTex.sample(smp, clamp(tapUV - cOff, 0.0, 1.0)).b;
            meltedRgb += float3(r, g, b) * tapW;
        } else {
            meltedRgb += inTex.sample(smp, tapUV).rgb * tapW;
        }
        totalW += tapW;
    }
    meltedRgb /= max(totalW, 0.0001);

    // Soften / blur radius
    if (p.meltSoft > 0.002) {
        float sr = p.meltSoft * 0.008;
        float3 s1 = inTex.sample(smp, clamp(uv + float2(sr / outA, 0.0), 0.0, 1.0)).rgb;
        float3 s2 = inTex.sample(smp, clamp(uv - float2(sr / outA, 0.0), 0.0, 1.0)).rgb;
        float3 s3 = inTex.sample(smp, clamp(uv + float2(0.0, sr), 0.0, 1.0)).rgb;
        float3 s4 = inTex.sample(smp, clamp(uv - float2(0.0, sr), 0.0, 1.0)).rgb;
        float3 blurred = (s1 + s2 + s3 + s4) * 0.25;
        meltedRgb = mix(meltedRgb, blurred, p.meltSoft * 0.6);
    }

    // Hue shift
    if (abs(p.meltHue) > 0.002) {
        meltedRgb = hueRotate(meltedRgb, p.meltHue * 0.35);
    }

    // Blend original with multi-tap melted fluid
    float3 finalRgb = mix(src, meltedRgb, meltWeight);
    outTex.write(float4(clamp(finalRgb, 0.0, 1.5), srcAlpha), gid);
}
