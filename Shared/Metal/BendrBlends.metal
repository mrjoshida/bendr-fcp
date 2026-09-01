// BendrBlends.metal — All 24 BENDR blend modes ported to Metal
// Shared by all plugins that need compositing (mixer, feedback, layers)

#include <metal_stdlib>
#include "BendrCommon.h"
using namespace metal;

// --- Individual blend mode functions ---
// Each implements: result = blend(base, layer)

inline float3 blendDissolve(float3 a, float3 b)     { return b; }
inline float3 blendAdditive(float3 a, float3 b)     { return a + b; }
inline float3 blendNonAdditive(float3 a, float3 b)  { return max(a, b); }
inline float3 blendDifference(float3 a, float3 b)   { return abs(a - b); }
inline float3 blendMultiply(float3 a, float3 b)     { return a * b; }
inline float3 blendScreen(float3 a, float3 b)       { return 1.0 - (1.0 - a) * (1.0 - b); }
inline float3 blendDarken(float3 a, float3 b)       { return min(a, b); }
inline float3 blendExclusion(float3 a, float3 b)    { return a + b - 2.0 * a * b; }
inline float3 blendSubtract(float3 a, float3 b)     { return max(a - b, 0.0); }

inline float overlayChannel(float a, float b) {
    return a < 0.5 ? 2.0 * a * b : 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
}
inline float3 blendOverlay(float3 a, float3 b) {
    return float3(overlayChannel(a.r, b.r), overlayChannel(a.g, b.g), overlayChannel(a.b, b.b));
}

inline float hardLightChannel(float a, float b) {
    return b < 0.5 ? 2.0 * a * b : 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
}
inline float3 blendHardLight(float3 a, float3 b) {
    return float3(hardLightChannel(a.r, b.r), hardLightChannel(a.g, b.g), hardLightChannel(a.b, b.b));
}

inline float softLightChannel(float a, float b) {
    return b < 0.5
        ? a - (1.0 - 2.0 * b) * a * (1.0 - a)
        : a + (2.0 * b - 1.0) * (sqrt(a) - a);
}
inline float3 blendSoftLight(float3 a, float3 b) {
    return float3(softLightChannel(a.r, b.r), softLightChannel(a.g, b.g), softLightChannel(a.b, b.b));
}

inline float vividLightChannel(float a, float b) {
    if (b < 0.001) return 0.0;
    if (b > 0.999) return 1.0;
    return b < 0.5
        ? 1.0 - clamp((1.0 - a) / (2.0 * b), 0.0, 1.0)
        : clamp(a / (2.0 * (1.0 - b)), 0.0, 1.0);
}
inline float3 blendVividLight(float3 a, float3 b) {
    return float3(vividLightChannel(a.r, b.r), vividLightChannel(a.g, b.g), vividLightChannel(a.b, b.b));
}

inline float pinLightChannel(float a, float b) {
    return b < 0.5 ? min(a, 2.0 * b) : max(a, 2.0 * b - 1.0);
}
inline float3 blendPinLight(float3 a, float3 b) {
    return float3(pinLightChannel(a.r, b.r), pinLightChannel(a.g, b.g), pinLightChannel(a.b, b.b));
}

inline float3 blendColorDodge(float3 a, float3 b) {
    return clamp(a / max(1.0 - b, 0.001), 0.0, 1.0);
}
inline float3 blendColorBurn(float3 a, float3 b) {
    return 1.0 - clamp((1.0 - a) / max(b, 0.001), 0.0, 1.0);
}
inline float3 blendDivide(float3 a, float3 b) {
    return clamp(a / max(b, 0.001), 0.0, 1.0);
}
inline float3 blendWrapAdd(float3 a, float3 b) {
    return fract(a + b);
}

// Bitwise XOR: quantize to 8-bit, XOR, normalize
inline float3 blendXOR(float3 a, float3 b) {
    uint3 ai = uint3(clamp(a, 0.0, 1.0) * 255.0);
    uint3 bi = uint3(clamp(b, 0.0, 1.0) * 255.0);
    return float3(ai ^ bi) / 255.0;
}

// Bitwise AND
inline float3 blendAND(float3 a, float3 b) {
    uint3 ai = uint3(clamp(a, 0.0, 1.0) * 255.0);
    uint3 bi = uint3(clamp(b, 0.0, 1.0) * 255.0);
    return float3(ai & bi) / 255.0;
}

// HSL blend modes: Hue, Saturation, Color, Luminosity
// These operate in HSV space for simplicity (matching BENDR's implementation)
inline float3 blendHue(float3 a, float3 b) {
    float3 ha = rgb2hsv(a);
    float3 hb = rgb2hsv(b);
    return hsv2rgb(float3(hb.x, ha.y, ha.z));
}

inline float3 blendSaturation(float3 a, float3 b) {
    float3 ha = rgb2hsv(a);
    float3 hb = rgb2hsv(b);
    return hsv2rgb(float3(ha.x, hb.y, ha.z));
}

inline float3 blendColor(float3 a, float3 b) {
    float3 ha = rgb2hsv(a);
    float3 hb = rgb2hsv(b);
    return hsv2rgb(float3(hb.x, hb.y, ha.z));
}

inline float3 blendLuminosity(float3 a, float3 b) {
    float3 ha = rgb2hsv(a);
    float3 hb = rgb2hsv(b);
    return hsv2rgb(float3(ha.x, ha.y, hb.z));
}

// --- Master blend dispatcher ---
// mode 0-23 matching BENDR's blend mode indices
inline float3 bendrBlend(float3 base, float3 layer, int mode) {
    switch (mode) {
        case 0:  return layer;                          // Dissolve (caller handles mix)
        case 1:  return blendAdditive(base, layer);
        case 2:  return blendNonAdditive(base, layer);
        case 3:  return blendDifference(base, layer);
        case 4:  return blendMultiply(base, layer);
        case 5:  return blendScreen(base, layer);
        case 6:  return blendDarken(base, layer);
        case 7:  return blendExclusion(base, layer);
        case 8:  return blendSubtract(base, layer);
        case 9:  return blendOverlay(base, layer);
        case 10: return blendHardLight(base, layer);
        case 11: return blendSoftLight(base, layer);
        case 12: return blendVividLight(base, layer);
        case 13: return blendPinLight(base, layer);
        case 14: return blendColorDodge(base, layer);
        case 15: return blendColorBurn(base, layer);
        case 16: return blendDivide(base, layer);
        case 17: return blendWrapAdd(base, layer);
        case 18: return blendXOR(base, layer);
        case 19: return blendAND(base, layer);
        case 20: return blendHue(base, layer);
        case 21: return blendSaturation(base, layer);
        case 22: return blendColor(base, layer);
        case 23: return blendLuminosity(base, layer);
        default: return layer;
    }
}

// --- Feedback blend modes (subset used by feedback injection) ---
// 0=mix, 1=add, 2=screen, 3=max, 4=min, 5=diff
inline float3 feedbackBlend(float3 src, float3 fb, float amount, int mode) {
    float3 blended;
    switch (mode) {
        case 0:  blended = fb; break;                           // Mix (caller handles lerp)
        case 1:  blended = src + fb; break;                     // Add
        case 2:  blended = 1.0 - (1.0 - src) * (1.0 - fb); break; // Screen
        case 3:  blended = max(src, fb); break;                 // Max
        case 4:  blended = min(src, fb); break;                 // Min
        case 5:  blended = abs(src - fb); break;                // Difference
        default: blended = fb; break;
    }
    return mix(src, blended, amount);
}
