#include <metal_stdlib>
using namespace metal;

struct PhosConstants {
    float phosphor, phosR, phosG, phosB;
};

kernel void FS_PHOS(texture2d<float, access::sample> u_cur [[texture(0)]],
                    texture2d<float, access::sample> u_prev [[texture(1)]],
                    texture2d<float, access::write> outTex [[texture(2)]],
                    constant PhosConstants& u [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
                    
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float2 res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = float2(gid) / res;
    
    float3 c = u_cur.sample(s, uv).rgb;
    float3 p = u_prev.sample(s, uv).rgb;
    
    float3 k = clamp(float3(u.phosR, u.phosG, u.phosB) * u.phosphor, 0.0, 0.995);
    outTex.write(float4(max(c, p * k), 1.0), gid);
}
