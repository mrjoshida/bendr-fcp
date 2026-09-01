#include <metal_stdlib>
using namespace metal;

struct FieldConstants {
    float ilAmt, ilMode, ilOrder, ilTwitter, ilJudder, parity, time;
};

kernel void FS_FIELD(texture2d<float, access::sample> u_tex [[texture(0)]],
                     texture2d<float, access::sample> u_prevField [[texture(1)]],
                     texture2d<float, access::write> outTex [[texture(2)]],
                     constant FieldConstants& u [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
                     
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float2 res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = float2(gid) / res;
    
    float3 cur = u_tex.sample(s, uv).rgb;
    if(u.ilAmt < 0.003) { outTex.write(float4(cur, 1.0), gid); return; }
    
    float line = floor(float(gid.y));
    float lineParity = fmod(line, 2.0);
    float now = u.ilOrder > 0.5 ? 1.0 - u.parity : u.parity;
    bool thisField = abs(lineParity - now) < 0.5;
    
    float3 prev = u_prevField.sample(s, uv).rgb;
    float3 outc;
    
    if(u.ilMode < 0.5) {
        outc = thisField ? cur : prev;
    } else if(u.ilMode < 1.5) {
        float py = 1.0 / res.y;
        float3 a = u_tex.sample(s, float2(uv.x, uv.y + (thisField ? 0.0 : (now > 0.5 ? py : -py)))).rgb;
        outc = a;
    } else {
        outc = mix(cur, prev, 0.5);
    }
    
    if(u.ilTwitter > 0.003) {
        float py = 1.0 / res.y;
        float3 up = u_tex.sample(s, float2(uv.x, uv.y + py)).rgb;
        float3 dn = u_tex.sample(s, float2(uv.x, uv.y - py)).rgb;
        float3 hf = cur - (up + dn) * 0.5;
        float onThis = thisField ? 1.0 : -1.0;
        outc += hf * onThis * u.ilTwitter * 1.6;
    }
    
    if(u.ilJudder > 0.003) {
        float ph = fmod(floor(u.time * 24.0), 5.0);
        float held = (ph < 2.0) ? 1.0 : 0.0;
        outc = mix(outc, prev, held * u.ilJudder * 0.85);
    }
    
    outTex.write(float4(mix(cur, outc, u.ilAmt), u_tex.sample(s, uv).a), gid);
}
