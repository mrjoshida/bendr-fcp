// BendrCommon.h — Shared Metal Shading Language utilities for BENDR FxPlug plugins
// Ported from BENDR's GLSL COMMON block and KEYFN

#ifndef BendrCommon_h
#define BendrCommon_h

#include <metal_stdlib>
using namespace metal;

// --- Constants ---
constant float PI = 3.14159265358979;

// --- Hash function (from BENDR's h21) ---
// Quick pseudo-random from a 2D seed. Used for noise, dropout triggers, etc.
inline float h21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// --- Color space conversions ---

// RGB → YIQ (NTSC luminance / in-phase / quadrature)
inline float3 rgb2yiq(float3 c) {
    return float3(
        dot(c, float3(0.299, 0.587, 0.114)),
        dot(c, float3(0.596, -0.274, -0.322)),
        dot(c, float3(0.211, -0.523, 0.312))
    );
}

// YIQ → RGB
inline float3 yiq2rgb(float3 y) {
    return float3(
        y.x + 0.956 * y.y + 0.621 * y.z,
        y.x - 0.272 * y.y - 0.647 * y.z,
        y.x - 1.106 * y.y + 1.703 * y.z
    );
}

// RGB → HSV
inline float3 rgb2hsv(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// HSV → RGB
inline float3 hsv2rgb(float3 c) {
    float3 p = abs(fract(float3(c.x) + float3(1.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0);
    return c.z * mix(float3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

// Luminance (Rec. 601)
inline float luma(float3 c) {
    return dot(c, float3(0.299, 0.587, 0.114));
}

// Hue rotation in YIQ space (angle in turns, not radians)
inline float3 hueRotate(float3 c, float turns) {
    if (abs(turns) < 0.001) return c;
    float3 yiq = rgb2yiq(c);
    float a = turns * 2.0 * PI;
    float cs = cos(a), sn = sin(a);
    float i = yiq.y * cs - yiq.z * sn;
    float q = yiq.y * sn + yiq.z * cs;
    return yiq2rgb(float3(yiq.x, i, q));
}

// --- Keyer (luma or chroma key with threshold/softness/invert) ---
// Ported from BENDR's KEYFN. On a real keyer the edge is a high-gain amplifier
// driven into its rails, not a smoothstep — so noise in the source becomes noise
// in the edge and grain becomes grain.
inline float keyOf(float3 c, float mode, float hue, float th, float soft, float inv) {
    float v;
    if (mode < 0.5) {
        // Luma key
        v = dot(c, float3(0.299, 0.587, 0.114));
    } else {
        // Chroma key
        float3 yq = rgb2yiq(c);
        float ang = atan2(yq.z, yq.y);
        float target = (hue * 2.0 - 1.0) * PI;
        float d = abs(atan2(sin(ang - target), cos(ang - target))) / PI;
        v = (1.0 - d) * smoothstep(0.02, 0.25, length(yq.yz));
    }
    // High-gain amplifier model: k = clamp(gain*(v - threshold) + 0.5)
    float gain = 1.0 / max(soft, 0.0156);
    float k = clamp((v - th) * gain + 0.5, 0.0, 1.0);
    return mix(k, 1.0 - k, clamp(inv, 0.0, 1.0));
}

// --- UV wrapping modes ---
// 0 = clamp, 1 = repeat, 2 = mirror
inline float2 wrapUV(float2 p, float mode) {
    if (mode > 1.5) {
        // Mirror: triangle wave
        float2 t = fract(p * 0.5) * 2.0;
        return 1.0 - abs(t - 1.0);
    }
    if (mode > 0.5) {
        return fract(p);
    }
    return clamp(p, 0.0, 1.0);
}

// --- Utility: 2D rotation matrix ---
inline float2 rotate2D(float2 p, float angle) {
    float c = cos(angle), s = sin(angle);
    return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

#endif /* BendrCommon_h */
