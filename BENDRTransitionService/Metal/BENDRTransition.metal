#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"
#include "../../Shared/Metal/BendrBlends.metal"

struct TransitionParams {
    float abMix;
    float mixMode;
    float mixBlend;
    float wipeSoft;
    float wipeDetail;
    float wipeX;
    float wipeY;
    float wipeInv;
    float wipeBord;
    float wipeBordCol;
    float wipeRep;
    float mixKey;
    float mixKeyThresh;
    float mixKeySoft;
    float mixKeyHue;
    float mixKeyInv;
    float mixKeyGain;
    float mixKeyDens;
    float mixKeyEdge;
    float mixKeyEdgeCol;
    float mixKeyShadow;
    float time;
    float2 res;
};

// 8 classic video-mixer test/border colors
inline float3 backCol(float i) {
    int k = int(clamp(floor(i * 7.999), 0.0, 7.0));
    if (k == 0) return float3(1.0);
    if (k == 1) return float3(1.0, 1.0, 0.0);
    if (k == 2) return float3(0.0, 1.0, 1.0);
    if (k == 3) return float3(0.0, 1.0, 0.0);
    if (k == 4) return float3(1.0, 0.0, 1.0);
    if (k == 5) return float3(1.0, 0.0, 0.0);
    if (k == 6) return float3(0.0, 0.0, 1.0);
    return float3(0.0);
}

inline float wipeField(float2 uv, float mode, float outA, float repIn, float wx, float wy, float detail) {
    float rep = max(1.0, floor(repIn + 0.5));
    float2 tu = (rep > 1.5) ? fract(uv * rep) : uv;
    float2 off = float2(wx, wy) * 0.5;
    float2 c = tu - 0.5 - off;
    float2 far = abs(off) + 0.5;
    float n = 2.0 + floor(detail * 14.0);

    if (mode < 1.5) return tu.x;                                                        // Horizontal wipe
    if (mode < 2.5) return 1.0 - tu.y;                                                  // Vertical wipe
    if (mode < 3.5) return (tu.x + (1.0 - tu.y)) * 0.5;                                 // Diagonal wipe
    if (mode < 4.5) return max(abs(c.x) / far.x, abs(c.y) / far.y);                     // Box / Rectangle wipe
    if (mode < 5.5) return length(c * float2(outA, 1.0)) / max(length(far * float2(outA, 1.0)), 0.0001); // Circle wipe
    if (mode < 6.5) return abs(c.x) / far.x;                                            // Horizontal split
    if (mode < 7.5) return abs(c.y) / far.y;                                            // Vertical split
    if (mode < 8.5) return fract(tu.x * n);                                             // Venetian blinds H
    if (mode < 9.5) return fract(tu.y * n);                                             // Venetian blinds V
    if (mode < 10.5) { float a = atan2(c.y, c.x) / (2.0 * PI) + 0.5; return fract(a); } // Clock wipe
    if (mode < 11.5) return fract((tu.x + tu.y) * n * 0.5);                              // Checker wipe
    return h21(floor(tu * float2(n * 2.0, n)));                                         // Noise wipe
}

inline float2 slideUV(float2 uv, float dir, float t, thread float &inside) {
    float2 d = dir < 0.5 ? float2(1.0, 0.0) : dir < 1.5 ? float2(-1.0, 0.0) : dir < 2.5 ? float2(0.0, 1.0) : float2(0.0, -1.0);
    float2 p = uv + d * (1.0 - t);
    inside = step(0.0, p.x) * step(p.x, 1.0) * step(0.0, p.y) * step(p.y, 1.0);
    return p;
}

inline float2 stretchUV(float2 uv, float dir, float t, thread float &inside) {
    float k = max(t, 0.0001);
    float2 p = uv;
    if (dir < 0.5) { p.x = uv.x / k; }
    else if (dir < 1.5) { p.x = 1.0 - (1.0 - uv.x) / k; }
    else if (dir < 2.5) { p.y = uv.y / k; }
    else { p.y = 1.0 - (1.0 - uv.y) / k; }
    inside = step(0.0, p.x) * step(p.x, 1.0) * step(0.0, p.y) * step(p.y, 1.0);
    return p;
}

kernel void bendrTransition(
    texture2d<float, access::sample> texA   [[texture(0)]],
    texture2d<float, access::sample> texB   [[texture(1)]],
    texture2d<float, access::write>  outTex [[texture(2)]],
    constant TransitionParams &p            [[buffer(0)]],
    uint2 gid                               [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) {
        return;
    }

    constexpr sampler smp(address::clamp_to_edge, filter::linear);
    float2 uv = (float2(gid) + 0.5) / p.res;
    float outA = p.res.x / p.res.y;
    float t = clamp(p.abMix, 0.0, 1.0);

    float m = t;
    float ins = 1.0;
    float2 buv = uv;

    // Evaluate transition geometry / wipe matte
    if (p.mixMode > 0.5 && p.mixMode < 12.5) {
        float d = wipeField(uv, p.mixMode, outA, p.wipeRep, p.wipeX, p.wipeY, p.wipeDetail);
        if (p.wipeInv > 0.5) d = 1.0 - d;
        float sw = max(p.wipeSoft * 0.5, 0.002);
        m = smoothstep(d - sw, d + sw, t * (1.0 + 2.0 * sw) - sw);
    } else if (p.mixMode > 12.5 && p.mixMode < 16.5) {
        buv = slideUV(uv, p.mixMode - 13.0, t, ins);
        m = ins;
    } else if (p.mixMode > 16.5 && p.mixMode < 20.5) {
        buv = stretchUV(uv, p.mixMode - 17.0, t, ins);
        m = ins;
    }

    float4 sampleA = texA.sample(smp, uv);
    float4 sampleB = texB.sample(smp, clamp(buv, 0.0, 1.0));
    float3 a = sampleA.rgb;
    float3 b = sampleB.rgb;

    // Keyer on B
    if (p.mixKey > 0.5) {
        float km = keyOf(
            b,
            p.mixKey > 2.5 ? 1.0 : 0.0,
            p.mixKeyHue,
            p.mixKeyThresh,
            p.mixKeySoft,
            (p.mixKey < 1.5) ? 1.0 - p.mixKeyInv : p.mixKeyInv
        );
        km = pow(clamp(km, 0.0, 1.0), mix(3.2, 0.3, clamp(p.mixKeyGain, 0.0, 1.0)));
        m *= km * clamp(p.mixKeyDens, 0.0, 1.0);
    }

    m = clamp(m, 0.0, 1.0);

    // Apply selected hardware blend mode
    float3 blended = bendrBlend(a, b, int(p.mixBlend));
    float3 src = mix(a, blended, m);

    // Wipe border line
    if (p.wipeBord > 0.001 && p.mixMode > 0.5 && p.mixMode < 12.5) {
        float sw = max(p.wipeSoft * 0.5, 0.002);
        float d = wipeField(uv, p.mixMode, outA, p.wipeRep, p.wipeX, p.wipeY, p.wipeDetail);
        if (p.wipeInv > 0.5) d = 1.0 - d;
        float borderW = p.wipeBord * 0.05;
        float bMatte = smoothstep(0.0, sw, borderW - abs(d - t));
        src = mix(src, backCol(p.wipeBordCol), bMatte * clamp(p.wipeBord * 2.5, 0.0, 1.0));
    }

    // Key border & shadow
    if (p.mixKey > 0.5) {
        if (p.mixKeyShadow > 0.001) {
            float sMatte = max(0.0, m - 0.5);
            src = mix(src, src * (1.0 - 0.8 * p.mixKeyShadow), sMatte);
        }
        if (p.mixKeyEdge > 0.001) {
            float edgeLine = smoothstep(0.0, 0.2, m) * (1.0 - smoothstep(0.8, 1.0, m));
            src = mix(src, backCol(p.mixKeyEdgeCol), edgeLine * clamp(p.mixKeyEdge * 2.0, 0.0, 1.0));
        }
    }

    float finalAlpha = mix(sampleA.a, sampleB.a, m);
    outTex.write(float4(clamp(src, 0.0, 1.5), finalAlpha), gid);
}
