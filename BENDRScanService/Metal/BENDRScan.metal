// BENDRScan.metal — Rutt-Etra / Paik-Abe Analog Cathode Ray Scan Processor
// Instanced geometry ribbons deflected by video luminance with dwell-time velocity modulation

#include <metal_stdlib>
using namespace metal;

#include "../../Shared/Metal/BendrCommon.h"

struct ScanParams {
    float lines;
    float samples;
    float scanAmt;
    float scanWidth;
    float scanVel;
    float scanTiltX;
    float scanTiltY;
    float scanPersp;
    float scanCurve;
    float scanCollapse;
    float scanRevH;
    float scanRevV;
    float scanWobAmt;
    float scanWobFreq;
    float scanWobLock;
    float scanLissa;
    float scanSkew;
    float scanGain;
    float scanMono;
    float scanHue;
    float time;
};

struct ScanVertexOut {
    float4 position [[position]];
    float3 col;
    float gain;
};

inline float lum3v(float3 c) {
    return dot(c, float3(0.299, 0.587, 0.114));
}

inline float2 beamAt(float sx, float line, thread float3& col, texture2d<float> tex, constant ScanParams& params, sampler s) {
    float u = sx;
    float v = line;
    if (params.scanRevH > 0.5) u = 1.0 - u;
    if (params.scanRevV > 0.5) v = 1.0 - v;
    
    col = tex.sample(s, float2(u, v)).rgb;
    float y = lum3v(col);
    
    float2 p = float2(sx * 2.0 - 1.0, (1.0 - line) * 2.0 - 1.0);
    
    p.x += sin(p.y * 3.14159) * params.scanCurve * 0.4;
    p.x += p.y * params.scanSkew * 0.5;
    
    if (params.scanWobAmt > 0.0005) {
        float f = floor(params.scanWobFreq * 12.0 + 0.5) + (1.0 - params.scanWobLock) * fract(params.scanWobFreq * 12.0);
        float ph = p.y * f * 3.14159 + params.time * (1.0 - params.scanWobLock) * 2.0;
        p.x += sin(ph) * params.scanWobAmt * 0.5;
        if (params.scanLissa > 0.0005) {
            p.y += sin(p.x * f * 1.61803 * 3.14159 + params.time * (1.0 - params.scanWobLock) * 1.7) * params.scanWobAmt * params.scanLissa * 0.5;
        }
    }
    
    p.y *= 1.0 - clamp(params.scanCollapse, 0.0, 1.0);
    p.y += (y - 0.35) * params.scanAmt * 1.6;
    
    float cx = cos(params.scanTiltX), sx2 = sin(params.scanTiltX);
    float cy = cos(params.scanTiltY), sy = sin(params.scanTiltY);
    float dz = (y - 0.35) * params.scanAmt * 1.6;
    
    float3 q = float3(p.x, p.y, dz);
    q = float3(q.x * cy + q.z * sy, q.y, -q.x * sy + q.z * cy);
    q = float3(q.x, q.y * cx - q.z * sx2, q.y * sx2 + q.z * cx);
    
    float w = 1.0 + q.z * params.scanPersp * 0.6;
    return float2(q.x, q.y) / max(w, 0.15);
}

vertex ScanVertexOut scanVertex(
    uint vid [[vertex_id]],
    uint iid [[instance_id]],
    texture2d<float> tex [[texture(0)]],
    constant ScanParams& params [[buffer(0)]]
) {
    ScanVertexOut out;
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    
    float line = (float(iid) + 0.5) / max(params.lines, 1.0);
    float si = float(vid >> 1);
    float side = (vid & 1) == 0 ? -1.0 : 1.0;
    float sx = si / max(params.samples - 1.0, 1.0);
    
    float3 col;
    float2 here = beamAt(sx, line, col, tex, params, s);
    
    float d = 1.0 / max(params.samples - 1.0, 1.0);
    float3 tc;
    float2 ahead = beamAt(min(sx + d, 1.0), line, tc, tex, params, s);
    float2 back = beamAt(max(sx - d, 0.0), line, tc, tex, params, s);
    float2 tang = ahead - back;
    
    float speed = max(length(tang) / (2.0 * d), 0.02);
    
    float resX = float(tex.get_width());
    float resY = float(tex.get_height());
    float2 nrm = normalize(float2(-tang.y, tang.x * resX / resY));
    
    float wpx = (0.7 + params.scanWidth * 7.0) / max(resY, 1.0) * 2.0;
    
    out.position = float4(here + nrm * side * wpx, 0.0, 1.0);
    out.col = col;
    out.gain = mix(1.0, clamp(2.0 / speed, 0.05, 8.0), params.scanVel);
    
    return out;
}

inline float3 hsv2s(float3 c) {
    float3 p = abs(fract(c.xxx + float3(0.0, 2.0/3.0, 1.0/3.0)) * 6.0 - 3.0);
    return c.z * mix(float3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

fragment float4 scanFragment(
    ScanVertexOut in [[stage_in]],
    constant ScanParams& params [[buffer(0)]]
) {
    float3 c = in.col;
    float y = dot(c, float3(0.299, 0.587, 0.114));
    c = mix(c, float3(y), params.scanMono);
    
    if (params.scanHue > 0.002) {
        c = mix(c, hsv2s(float3(fract(params.scanHue + y * 0.35), 0.85, 1.0)) * y, params.scanHue);
    }
    
    return float4(c * in.gain * params.scanGain, 1.0);
}
