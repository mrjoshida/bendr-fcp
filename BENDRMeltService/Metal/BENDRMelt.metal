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

// Helper: 2D Sobel edge detector to find seam direction and intensity
inline float4 sampleEdge(texture2d<float, access::sample> tex, sampler smp, float2 uv, float2 res) {
    float2 e = 1.5 / res;
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
    float band = clamp(edgeInfo.z * (1.0 + p.edgeWidth * 4.0), 0.0, 1.0);
    float l = luma(src);

    float2 puv = uv;
    float w = band;

    if (p.meltMode > 2.5) {
        // Mode 3: Gravity / Directional Luma Melt
        float a = p.meltDir * PI;
        float gate = mix(1.0, smoothstep(p.meltGate - 0.18, p.meltGate + 0.18, l), step(0.001, p.meltGate));
        float2 gdir = float2(sin(a), -cos(a));
        puv = uv + gdir * p.edgeAmt * (0.002 + 0.038 * l) * gate;
        w = gate * (0.2 + 0.8 * l);
    } else if (p.meltMode > 1.5) {
        // Mode 2: Motion / Dynamic Change Driven
        float2 c = (uv - 0.5) * float2(outA, 1.0);
        float ro = p.edgeSwirl * 0.10;
        float zo = 1.0 - p.meltZoom * 0.05;
        float cs = cos(ro), sn = sin(ro);
        c = float2(cs * c.x - sn * c.y, sn * c.x + cs * c.y) * zo;
        puv = c / float2(outA, 1.0) + 0.5;
        
        float3 prevSample = prevTex.sample(smp, uv).rgb;
        float d = abs(luma(src) - luma(prevSample));
        w = clamp(d * (3.0 + p.edgeWidth * 14.0), 0.0, 1.0);
    } else if (p.meltMode > 0.5) {
        // Mode 1: Frame Spiral Feedback
        float2 c = (uv - 0.5) * float2(outA, 1.0);
        float ro = p.edgeSwirl * 0.10;
        float zo = 1.0 - p.meltZoom * 0.05;
        float cs = cos(ro), sn = sin(ro);
        c = float2(cs * c.x - sn * c.y, sn * c.x + cs * c.y) * zo;
        puv = c / float2(outA, 1.0) + 0.5;
        w = 1.0;
    } else {
        // Mode 0: Edge Smear / Boundary Bleed
        float creepSign = mix(1.0, -1.0, p.edgeCreep);
        puv = uv + en * creepSign * (0.0015 + p.edgeAmt * 0.04);
        w = band;
    }

    puv = clamp(puv, 0.0, 1.0);
    float3 pv = prevTex.sample(smp, puv).rgb;

    // Soften / multi-tap diffusion per pass
    if (p.meltSoft > 0.002) {
        float sr = p.meltSoft * 0.006;
        float3 s1 = prevTex.sample(smp, clamp(puv + float2(sr / outA, 0.0), 0.0, 1.0)).rgb;
        float3 s2 = prevTex.sample(smp, clamp(puv - float2(sr / outA, 0.0), 0.0, 1.0)).rgb;
        float3 s3 = prevTex.sample(smp, clamp(puv + float2(0.0, sr), 0.0, 1.0)).rgb;
        float3 s4 = prevTex.sample(smp, clamp(puv - float2(0.0, sr), 0.0, 1.0)).rgb;
        pv = (pv + s1 + s2 + s3 + s4) * 0.2;
    }

    // Chromatic dispersion per pass
    if (p.edgeChroma > 0.002) {
        float2 co = (p.meltMode > 0.5) ? (puv - uv) : (en * (0.0015 + p.edgeAmt * 0.04));
        float3 pc = prevTex.sample(smp, clamp(puv + co * 3.0 * p.edgeChroma, 0.0, 1.0)).rgb;
        float3 y1 = rgb2yiq(pv);
        float3 y2 = rgb2yiq(pc);
        pv = yiq2rgb(float3(y1.x, mix(y1.yz, y2.yz, p.edgeChroma)));
    }

    // Hue rotation per pass
    if (abs(p.meltHue) > 0.002) {
        float3 yy = rgb2yiq(pv);
        float ha = p.meltHue * 0.22;
        float hc = cos(ha), hs = sin(ha);
        pv = yiq2rgb(float3(yy.x, hc * yy.y - hs * yy.z, hs * yy.y + hc * yy.z));
    }

    // Persistence calculation and ceiling
    float hcap = min(0.90 + max(p.edgeAmt - 1.0, 0.0) * 0.055 + max(p.edgeHold - 1.0, 0.0) * 0.055, 0.998);
    float mixAmt = (p.meltMode < 0.5) ? (w * p.edgeHold)
                 : (p.meltMode > 2.5) ? (w * p.edgeHold * p.edgeAmt)
                                      : (w * p.edgeHold * p.edgeAmt);

    float3 finalRgb = mix(src, pv, clamp(mixAmt, 0.0, hcap));
    outTex.write(float4(finalRgb, srcAlpha), gid);
}
