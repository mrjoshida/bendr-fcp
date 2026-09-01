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

// 2D Value noise with quintic interpolation
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

// Single-step Lucas-Kanade optical flow estimation between current and previous source frames
inline float2 motionAt(
    float2 uv,
    texture2d<float, access::sample> curTex,
    texture2d<float, access::sample> prevTex,
    sampler smp,
    float2 res
) {
    float2 e = 1.5 / res;
    float c = luma(curTex.sample(smp, uv).rgb);
    float pv = luma(prevTex.sample(smp, uv).rgb);

    float2 g = float2(
        luma(curTex.sample(smp, uv + float2(e.x, 0.0)).rgb) - luma(curTex.sample(smp, uv - float2(e.x, 0.0)).rgb),
        luma(curTex.sample(smp, uv + float2(0.0, e.y)).rgb) - luma(curTex.sample(smp, uv - float2(0.0, e.y)).rgb)
    );

    float d = c - pv;
    float2 mv = -d * g / (dot(g, g) + 0.02);
    return clamp(mv * e * 3.0, float2(-0.06), float2(0.06));
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

    float2 mv = motionAt(uv, inTex, srcPrevTex, smp, p.res);
    float mmag = length(mv) * 26.0;

    // Evaluate driving vector field F
    float2 F = float2(0.0);
    if (p.flowField < 0.5) {
        // 0: MOTION
        F = mv * 18.0;
    } else if (p.flowField < 1.5) {
        // 1: CONTOUR (perpendicular to luminance gradient)
        float2 e = 1.5 / p.res;
        float2 g = float2(
            luma(inTex.sample(smp, uv + float2(e.x, 0.0)).rgb) - luma(inTex.sample(smp, uv - float2(e.x, 0.0)).rgb),
            luma(inTex.sample(smp, uv + float2(0.0, e.y)).rgb) - luma(inTex.sample(smp, uv - float2(0.0, e.y)).rgb)
        );
        F = float2(-g.y, g.x) * 2.2;
    } else if (p.flowField < 2.5) {
        // 2: CURL NOISE
        float e = 0.02;
        float2 np = uv * float2(4.0, 4.0 * ar) + p.time * 0.05;
        F = float2(
             vn(np + float2(0.0, e)) - vn(np - float2(0.0, e)),
            -(vn(np + float2(e, 0.0)) - vn(np - float2(e, 0.0)))
        ) / e * 0.5;
    } else if (p.flowField < 3.5) {
        // 3: RADIAL
        F = normalize(uv - 0.5 + 1e-5) * 0.7;
    } else if (p.flowField < 4.5) {
        // 4: SPIRAL
        float2 c2 = uv - 0.5;
        F = float2(-c2.y, c2.x) * 2.2;
    } else if (p.flowField < 5.5) {
        // 5: CHROMA
        float3 q = rgb2yiq(cur);
        F = q.yz * 3.0;
    } else {
        // 6: WEAVE
        F = float2(sin(uv.y * 22.0 + p.time * 0.7), sin(uv.x * 17.0 - p.time * 0.5)) * 0.8;
    }

    float2 v = F * p.moshVec * 0.006;

    // Melt: gravity along an arbitrary angle, gated on brightness
    if (p.melt > 0.003) {
        float a = p.meltDir * PI;
        float gate = mix(1.0, smoothstep(p.meltGate - 0.18, p.meltGate + 0.18, l), step(0.001, p.meltGate));
        v += float2(sin(a), -cos(a)) * p.melt * (0.15 + 0.85 * l) * gate * 0.006;
    }

    // Swirl turbulence
    if (p.swirl > 0.003) {
        float e = 0.02;
        float sc = 1.0 + p.swirlScale * 11.0;
        float2 np = uv * float2(sc, sc * ar) + p.time * (0.02 + p.swirlSpeed * 0.5);
        float dnx = vn(np + float2(0.0, e)) - vn(np - float2(0.0, e));
        float dny = vn(np + float2(e, 0.0)) - vn(np - float2(e, 0.0));
        v += p.swirl * 0.004 * float2(dnx, -dny) / e;
    }

    // Vector trash: macroblocks shoved by garbage motion vectors
    if (p.moshBlock > 0.003) {
        float bs = mix(46.0, 5.0, p.moshBlockSize);
        float2 cell = floor(uv * float2(bs, bs * ar));
        float tk = floor(p.time * (0.25 + p.moshRate * 11.0));
        float2 bv = float2(h21(cell + tk * 7.0), h21(cell + tk * 13.0)) - 0.5;
        v += p.moshBlock * 0.03 * bv;
    }

    // Stretch: smearing outward from center
    if (abs(p.flowStretch) > 0.003) {
        v += (uv - 0.5) * p.flowStretch * mmag * 0.05;
    }

    // Edge repel: push away from contrast so shapes peel apart
    if (abs(p.flowRepel) > 0.003) {
        float2 e = 1.5 / p.res;
        float2 g = float2(
            luma(inTex.sample(smp, uv + float2(e.x, 0.0)).rgb) - luma(inTex.sample(smp, uv - float2(e.x, 0.0)).rgb),
            luma(inTex.sample(smp, uv + float2(0.0, e.y)).rgb) - luma(inTex.sample(smp, uv - float2(0.0, e.y)).rgb)
        );
        v += g * p.flowRepel * 0.05;
    }

    // Flow Noise
    if (p.flowNoise > 0.003) {
        float2 nseed = float2(
            h21(uv * p.res + fract(p.time) * float2(37.1, 11.7)),
            h21(uv * p.res + fract(p.time) * float2(19.3, 53.9))
        ) - 0.5;
        v += nseed * p.flowNoise * 0.01;
    }

    // Field curl (orbit rotation)
    if (abs(p.flowCurl) > 0.003) {
        float a = p.flowCurl * PI;
        float s = sin(a), k = cos(a);
        v = float2(v.x * k - v.y * s, v.x * s + v.y * k);
    }

    v *= p.flowGain;

    // Sample advected historical frame
    float2 advectUV = fedge(uv + v, p.flowEdge);
    float3 prev = flowPrevTex.sample(smp, advectUV).rgb;

    // Re-sharpening: anti-diffusion
    if (p.flowSharp > 0.003) {
        float2 e = 1.6 / p.res;
        float3 b = (
            flowPrevTex.sample(smp, fedge(uv + v + float2( e.x,  0.0), p.flowEdge)).rgb +
            flowPrevTex.sample(smp, fedge(uv + v + float2(-e.x,  0.0), p.flowEdge)).rgb +
            flowPrevTex.sample(smp, fedge(uv + v + float2( 0.0,  e.y), p.flowEdge)).rgb +
            flowPrevTex.sample(smp, fedge(uv + v + float2( 0.0, -e.y), p.flowEdge)).rgb
        ) * 0.25;
        prev = max(prev + (prev - b) * p.flowSharp * 1.5, float3(0.0));
    }

    // Hue rotation per pass
    if (abs(p.flowHue) > 0.003) {
        prev = max(hueRotate(prev, p.flowHue * 0.06), float3(0.0));
    }

    // Decay per pass
    prev *= 1.0 - p.flowFade * 0.09;

    // Mosh persistence
    float pers = max(p.mosh, clamp((p.melt + p.swirl + p.moshBlock + p.moshVec) * 0.7, 0.0, 0.92));

    // Motion gating
    if (abs(p.moshGate) > 0.003) {
        float mg = smoothstep(0.02, 0.32, mmag);
        pers *= mix(1.0, (p.moshGate > 0.0) ? mg : (1.0 - mg), abs(p.moshGate));
    }

    // Time shear gradient
    float ax = mix(uv.y, uv.x, clamp(p.shearAxis, 0.0, 1.0)) - 0.5;
    pers = clamp(pers + p.timeGrad * ax * 1.4, 0.0, 0.995);

    float3 finalRgb = clamp(mix(cur, prev, pers), -0.2, 2.0);
    outTex.write(float4(finalRgb, alpha), gid);
}
