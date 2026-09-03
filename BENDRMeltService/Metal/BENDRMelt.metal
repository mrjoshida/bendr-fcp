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

// 2D Perlin / Value Noise for organic fluid turbulence
inline float meltNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = h21(i);
    float b = h21(i + float2(1.0, 0.0));
    float c = h21(i + float2(0.0, 1.0));
    float d = h21(i + float2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

inline float2 meltCurl(float2 p) {
    float eps = 0.08;
    float n1 = meltNoise(p + float2(0.0, eps));
    float n2 = meltNoise(p - float2(0.0, eps));
    float n3 = meltNoise(p + float2(eps, 0.0));
    float n4 = meltNoise(p - float2(eps, 0.0));
    float dx = (n3 - n4) / (2.0 * eps);
    float dy = (n1 - n2) / (2.0 * eps);
    return float2(dy, -dx); // Curl perpendicular to gradient
}

// 2D Sobel edge detector
inline float4 sampleEdge(texture2d<float, access::sample> tex, sampler smp, float2 uv, float2 res) {
    float2 e = 3.0 / res;
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

    // Dynamic fluid turbulence field
    float2 fluidCoord = uv * float2(5.0 * outA, 5.0) + float2(0.0, p.time * 0.4);
    float2 curl = meltCurl(fluidCoord);
    float2 curl2 = meltCurl(fluidCoord * 2.2 + float2(3.1, 7.7));

    // Directional Melt Vector calculation with bold displacement scale
    float2 meltVec = float2(0.0);
    float meltWeight = 0.0;
    float meltMagnitude = p.edgeAmt * 0.35 + 0.05; // Significant visible displacement

    if (p.meltMode > 2.5) {
        // Mode 3: Gravity / Thermal Luma Melt (hot bright pixels liquefy and drip down)
        float a = p.meltDir * PI;
        float2 gdir = float2(sin(a), -cos(a)); // Downward gravity
        float gate = mix(1.0, smoothstep(p.meltGate - 0.25, p.meltGate + 0.25, l), step(0.001, p.meltGate));
        
        // Fluid drip paths modulated by luma, curl noise & edge contours
        float drip = (0.3 + 0.7 * l) * (1.0 + 0.5 * curl.x) * gate;
        meltVec = (gdir * drip + curl2 * 0.25 * drip) * meltMagnitude;
        meltWeight = gate * clamp(p.edgeHold * (0.6 + 0.6 * l), 0.0, 1.0);
        
    } else if (p.meltMode > 1.5) {
        // Mode 2: Motion Driven Dynamic Liquid Warp
        float3 prevSample = prevTex.sample(smp, uv).rgb;
        float motionDiff = abs(l - luma(prevSample));
        float motionGate = smoothstep(0.02, 0.25 / (1.0 + p.edgeWidth * 3.0), motionDiff);
        
        // Liquid swirl at motion boundaries
        float2 c = (uv - 0.5) * float2(outA, 1.0);
        float ro = p.edgeSwirl * 0.6 + curl.x * 0.3;
        float cs = cos(ro), sn = sin(ro);
        float2 rotC = float2(cs * c.x - sn * c.y, sn * c.x + cs * c.y) * (1.0 - p.meltZoom * 0.25);
        float2 targetUV = rotC / float2(outA, 1.0) + 0.5;
        
        meltVec = ((targetUV - uv) + curl * 0.15) * (0.6 + p.edgeAmt * 1.2);
        meltWeight = clamp(p.edgeHold * (0.3 + motionGate * 1.5), 0.0, 1.0);
        
    } else if (p.meltMode > 0.5) {
        // Mode 1: Spiral Feedback Vortex
        float2 c = (uv - 0.5) * float2(outA, 1.0);
        float r = length(c);
        float ro = p.edgeSwirl * 1.2 * (1.0 - smoothstep(0.0, 0.8, r)) + p.time * 0.3;
        float cs = cos(ro), sn = sin(ro);
        float2 rotC = float2(cs * c.x - sn * c.y, sn * c.x + cs * c.y) * (1.0 - p.meltZoom * 0.3);
        float2 targetUV = rotC / float2(outA, 1.0) + 0.5;
        
        meltVec = (targetUV - uv + curl * 0.08) * (0.7 + p.edgeAmt);
        meltWeight = clamp(p.edgeHold * 1.1, 0.0, 1.0);
        
    } else {
        // Mode 0: Viscous Edge Bleed & Liquid Boundary Smear
        float creepSign = mix(1.0, -1.0, p.edgeCreep);
        float edgeBand = smoothstep(0.005, 0.45 / (1.0 + p.edgeWidth * 4.0), edgeMag);
        
        // Follow edge normal with fluid curl deflection
        float2 fluidNormal = normalize(en + curl * 0.6);
        meltVec = fluidNormal * creepSign * meltMagnitude * (0.4 + 0.6 * edgeBand);
        meltWeight = clamp(edgeBand * p.edgeHold * 1.4 + 0.2 * p.edgeHold, 0.0, 1.0);
    }

    // 12-Tap Viscous Fluid Accumulation along stream lines
    float3 meltedRgb = float3(0.0);
    float totalW = 0.0;
    
    for (int i = 1; i <= 12; i++) {
        float fi = float(i) / 12.0;
        // Non-linear fluid viscosity weighting
        float tapW = exp(-fi * (1.8 - p.edgeHold * 0.9));
        float2 tapUV = clamp(uv + meltVec * fi, 0.0, 1.0);
        
        // Chromatic dispersion along fluid stream
        if (p.edgeChroma > 0.002) {
            float2 cOff = meltVec * fi * p.edgeChroma * 0.6;
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

    // Surface tension softening & diffusion blur
    if (p.meltSoft > 0.002) {
        float sr = p.meltSoft * 0.015;
        float3 s1 = inTex.sample(smp, clamp(uv + float2(sr / outA, 0.0), 0.0, 1.0)).rgb;
        float3 s2 = inTex.sample(smp, clamp(uv - float2(sr / outA, 0.0), 0.0, 1.0)).rgb;
        float3 s3 = inTex.sample(smp, clamp(uv + float2(0.0, sr), 0.0, 1.0)).rgb;
        float3 s4 = inTex.sample(smp, clamp(uv - float2(0.0, sr), 0.0, 1.0)).rgb;
        float3 blurred = (s1 + s2 + s3 + s4) * 0.25;
        meltedRgb = mix(meltedRgb, blurred, p.meltSoft * 0.7);
    }

    // Color cycling / thermal hue shift
    if (abs(p.meltHue) > 0.002) {
        meltedRgb = hueRotate(meltedRgb, p.meltHue * 0.5);
    }

    // Blend source with liquefied fluid
    float3 finalRgb = mix(src, meltedRgb, meltWeight);
    outTex.write(float4(clamp(finalRgb, 0.0, 1.5), srcAlpha), gid);
}
