#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct FlowParams {
    float flowField;
    float moshVec;
    float flowGain;
    float flowCurl;
    float flowEdge;
    float mosh;
    float moshGate;
    float timeGrad;
    float shearAxis;
    float melt;
    float meltDir;
    float meltGate;
    float swirl;
    float swirlScale;
    float swirlSpeed;
    float moshBlock;
    float moshBlockSize;
    float moshRate;
    float flowStretch;
    float flowRepel;
    float flowNoise;
    float flowSharp;
    float flowHue;
    float flowFade;
    float time;
    float2 res;
};

// 2D Value noise with smooth quintic interpolation
inline float vn(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(h21(i), h21(i + float2(1.0, 0.0)), f.x),
        mix(h21(i + float2(0.0, 1.0)), h21(i + float2(1.0, 1.0)), f.x),
        f.y
    );
}

// Coordinate wrapping according to edge mode
inline float2 fedge(float2 p, float edgeMode) {
    if (edgeMode > 1.5) {
        float2 t = fract(p * 0.5) * 2.0;
        return 1.0 - abs(t - 1.0);
    }
    if (edgeMode > 0.5) {
        return fract(p);
    }
    return clamp(p, 0.0, 1.0);
}

// Single-step Lucas-Kanade optical flow estimation
inline float2 motionAt(
    float2 uv,
    texture2d<float, access::sample> curTex,
    texture2d<float, access::sample> prevTex,
    sampler smp,
    float2 res
) {
    float2 e = 2.0 / res;
    float c = luma(curTex.sample(smp, uv).rgb);
    float pv = luma(prevTex.sample(smp, uv).rgb);

    float2 g = float2(
        luma(curTex.sample(smp, uv + float2(e.x, 0.0)).rgb) - luma(curTex.sample(smp, uv - float2(e.x, 0.0)).rgb),
        luma(curTex.sample(smp, uv + float2(0.0, e.y)).rgb) - luma(curTex.sample(smp, uv - float2(0.0, e.y)).rgb)
    );

    float d = c - pv;
    float2 mv = -d * g / (dot(g, g) + 0.015);
    return clamp(mv * e * 4.0, float2(-0.08), float2(0.08));
}

kernel void bendrFlow(
    texture2d<float, access::sample> inTex       [[texture(0)]],
    texture2d<float, access::sample> flowPrevTex [[texture(1)]],
    texture2d<float, access::sample> srcPrevTex  [[texture(2)]],
    texture2d<float, access::write>  outTex      [[texture(3)]],
    constant FlowParams &p                       [[buffer(0)]],
    uint2 gid                                    [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float ar = p.res.y / p.res.x;

    float4 curSample = inTex.sample(smp, uv);
    float3 cur = curSample.rgb;
    float alpha = curSample.a;
    float l = luma(cur);

    // Optical flow estimation
    float2 mv = motionAt(uv, inTex, srcPrevTex, smp, p.res);
    float rawMotionMag = length(mv);

    // Evaluate driving vector field F
    float2 F = float2(0.0);
    if (p.flowField < 0.5) {
        // 0: MOTION (Optical flow with organic fluid fallback if clip is static/paused)
        float2 fluidFallback = float2(
            vn(uv * float2(3.5, 3.5 * ar) + p.time * 0.35) - 0.5,
            vn(uv * float2(3.5, 3.5 * ar) + float2(11.3, 7.1) + p.time * 0.35) - 0.5
        ) * 0.06;
        float hasRealMotion = smoothstep(0.0005, 0.006, rawMotionMag);
        float2 activeMotion = mix(fluidFallback, mv, hasRealMotion);
        F = activeMotion * 18.0;
    } else if (p.flowField < 1.5) {
        // 1: CONTOUR (perpendicular to luminance gradient)
        float2 e = 2.0 / p.res;
        float2 g = float2(
            luma(inTex.sample(smp, uv + float2(e.x, 0.0)).rgb) - luma(inTex.sample(smp, uv - float2(e.x, 0.0)).rgb),
            luma(inTex.sample(smp, uv + float2(0.0, e.y)).rgb) - luma(inTex.sample(smp, uv - float2(0.0, e.y)).rgb)
        );
        F = float2(-g.y, g.x) * 3.5;
    } else if (p.flowField < 2.5) {
        // 2: CURL NOISE (turbulent vortices)
        float e = 0.02;
        float2 np = uv * float2(4.0, 4.0 * ar) + p.time * 0.15;
        F = float2(
             vn(np + float2(0.0, e)) - vn(np - float2(0.0, e)),
            -(vn(np + float2(e, 0.0)) - vn(np - float2(e, 0.0)))
        ) / e * 0.8;
    } else if (p.flowField < 3.5) {
        // 3: RADIAL
        F = normalize(uv - 0.5 + 1e-5) * 1.0;
    } else if (p.flowField < 4.5) {
        // 4: SPIRAL VORTEX
        float2 c2 = uv - 0.5;
        F = float2(-c2.y, c2.x) * 3.0;
    } else if (p.flowField < 5.5) {
        // 5: CHROMA DRIFT
        float3 q = rgb2yiq(cur);
        F = q.yz * 4.0;
    } else {
        // 6: HARMONIC WEAVE
        F = float2(sin(uv.y * 18.0 + p.time * 1.5), sin(uv.x * 14.0 - p.time * 1.2)) * 1.2;
    }

    // Base force displacement
    float2 v = F * (p.moshVec * 0.045) * p.flowGain;

    // Gravity Melt
    if (p.melt > 0.003) {
        float a = p.meltDir * PI;
        float gate = mix(1.0, smoothstep(p.meltGate - 0.18, p.meltGate + 0.18, l), step(0.001, p.meltGate));
        v += float2(sin(a), -cos(a)) * p.melt * (0.2 + 0.8 * l) * gate * 0.08;
    }

    // Swirl Turbulence
    if (p.swirl > 0.003) {
        float e = 0.02;
        float sc = 1.0 + p.swirlScale * 10.0;
        float2 np = uv * float2(sc, sc * ar) + p.time * (0.05 + p.swirlSpeed * 0.8);
        float dnx = vn(np + float2(0.0, e)) - vn(np - float2(0.0, e));
        float dny = vn(np + float2(e, 0.0)) - vn(np - float2(e, 0.0));
        v += p.swirl * 0.05 * float2(dnx, -dny) / e;
    }

    // Vector Trash (Datamosh macroblocks)
    if (p.moshBlock > 0.003) {
        float bs = mix(36.0, 4.0, p.moshBlockSize);
        float2 cell = floor(uv * float2(bs, bs * ar));
        float tk = floor(p.time * (1.0 + p.moshRate * 15.0));
        float2 bv = float2(h21(cell + tk * 7.0), h21(cell + tk * 13.0)) - 0.5;
        v += p.moshBlock * 0.06 * bv;
    }

    // Center Stretch
    if (abs(p.flowStretch) > 0.003) {
        v += (uv - 0.5) * p.flowStretch * 0.12;
    }

    // Edge Repel
    if (abs(p.flowRepel) > 0.003) {
        float2 e = 2.0 / p.res;
        float2 g = float2(
            luma(inTex.sample(smp, uv + float2(e.x, 0.0)).rgb) - luma(inTex.sample(smp, uv - float2(e.x, 0.0)).rgb),
            luma(inTex.sample(smp, uv + float2(0.0, e.y)).rgb) - luma(inTex.sample(smp, uv - float2(0.0, e.y)).rgb)
        );
        v += g * p.flowRepel * 0.08;
    }

    // Flow Noise
    if (p.flowNoise > 0.003) {
        float2 nseed = float2(
            h21(uv * p.res + fract(p.time) * float2(37.1, 11.7)),
            h21(uv * p.res + fract(p.time) * float2(19.3, 53.9))
        ) - 0.5;
        v += nseed * p.flowNoise * 0.03;
    }

    // Field curl (orbit rotation)
    if (abs(p.flowCurl) > 0.003) {
        float a = p.flowCurl * PI;
        float s = sin(a), k = cos(a);
        v = float2(v.x * k - v.y * s, v.x * s + v.y * k);
    }

    // Sample advected coordinate
    float2 advectUV = fedge(uv + v, p.flowEdge);
    
    // Sample warped current and historical frame
    float3 advectedCur = inTex.sample(smp, advectUV).rgb;
    float3 prev = flowPrevTex.sample(smp, advectUV).rgb;

    // Re-sharpening
    if (p.flowSharp > 0.003) {
        float2 e = 2.0 / p.res;
        float3 b = (
            flowPrevTex.sample(smp, fedge(uv + v + float2( e.x,  0.0), p.flowEdge)).rgb +
            flowPrevTex.sample(smp, fedge(uv + v + float2(-e.x,  0.0), p.flowEdge)).rgb +
            flowPrevTex.sample(smp, fedge(uv + v + float2( 0.0,  e.y), p.flowEdge)).rgb +
            flowPrevTex.sample(smp, fedge(uv + v + float2( 0.0, -e.y), p.flowEdge)).rgb
        ) * 0.25;
        prev = max(prev + (prev - b) * p.flowSharp * 1.5, float3(0.0));
    }

    // Hue rotation
    if (abs(p.flowHue) > 0.003) {
        prev = max(hueRotate(prev, p.flowHue * 0.15), float3(0.0));
    }

    // Decay
    prev *= 1.0 - p.flowFade * 0.15;

    // Mosh persistence blend
    float pers = clamp(p.mosh, 0.0, 0.98);
    float motionStrength = clamp(length(v) * 15.0, 0.0, 1.0);
    
    // Output blends warped frame boldly
    float3 warpedBlend = mix(advectedCur, prev, pers * 0.7);
    float3 finalRgb = mix(cur, warpedBlend, clamp(0.35 + motionStrength * 0.65, 0.0, 1.0));

    outTex.write(float4(clamp(finalRgb, 0.0, 1.5), alpha), gid);
}
