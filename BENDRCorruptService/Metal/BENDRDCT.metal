#include <metal_stdlib>
using namespace metal;

struct CorruptParams {
    float pixelSort;
    float sortThresh;
    float blockShift;
    float blockSize;
    float dotify;
    float dotSize;
    float driftWarp;
    float fmWarp;
    float dctAmt;
    float dctQ;
    float dctTilt;
    float dctChroma;
    float dctBlock;
    float time;
};

constant float PI = 3.14159265;

kernel void bendrDCT(
    texture2d<float, access::sample> inTex [[texture(0)]],
    texture2d<float, access::write> outTex [[texture(1)]],
    constant CorruptParams& p [[buffer(0)]],
    constant float& u_axis [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    
    float2 res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = float2(gid) / res;
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    
    float3 src = inTex.sample(s, uv).rgb;
    if(p.dctAmt < 0.003) {
        outTex.write(float4(src, inTex.sample(s, uv).a), gid);
        return;
    }
    
    float N = floor(4.0 + p.dctBlock * 12.0); // block size, 4 to 16
    float2 px = 1.0 / res;
    float pos = (u_axis < 0.5) ? (float)gid.x : (float)gid.y;
    float base = floor(pos / N) * N;
    float k = pos - base;
    float3 out3 = float3(0.0);
    
    // forward transform, quantise, inverse - all in one pass along this axis
    for(int u = 0; u < 16; u++) {
        if(float(u) >= N) break;
        float fu = float(u);
        float3 co = float3(0.0);
        for(int x = 0; x < 16; x++) {
            if(float(x) >= N) break;
            float2 sp = ((u_axis < 0.5) ? float2(base + float(x) + 0.5, (float)gid.y)
                                        : float2((float)gid.x, base + float(x) + 0.5)) * px;
            co += inTex.sample(s, clamp(sp, 0.0, 1.0)).rgb * cos((2.0 * float(x) + 1.0) * fu * PI / (2.0 * N));
        }
        co *= (u == 0 ? sqrt(1.0 / N) : sqrt(2.0 / N));
        
        // quantiser gets coarser for higher frequencies
        float step = (0.004 + p.dctQ * 0.5) * (1.0 + fu * p.dctTilt * 2.0);
        
        // chroma is quantised harder than luma
        float y = dot(co, float3(0.299, 0.587, 0.114));
        float3 chroma = co - y;
        co = y + chroma * (1.0 - p.dctChroma * 0.85);
        
        co = floor(co / step + 0.5) * step;
        out3 += co * (u == 0 ? sqrt(1.0 / N) : sqrt(2.0 / N)) * cos((2.0 * k + 1.0) * fu * PI / (2.0 * N));
    }
    
    outTex.write(float4(mix(src, out3, p.dctAmt), inTex.sample(s, uv).a), gid);
}
