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

float h21(float2 p){ 
    p = fract(p * float2(123.34, 456.21)); 
    p += dot(p, p + 45.32); 
    return fract(p.x * p.y); 
}

float lumAt(float2 p, texture2d<float, access::sample> tex, sampler s){ 
    return dot(tex.sample(s, clamp(p, 0.0, 1.0)).rgb, float3(0.299, 0.587, 0.114)); 
}

kernel void bendrGlitch(
    texture2d<float, access::sample> inTex [[texture(0)]],
    texture2d<float, access::write> outTex [[texture(1)]],
    constant CorruptParams& p [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= outTex.get_width() || gid.y >= outTex.get_height()) return;
    
    float2 res = float2(outTex.get_width(), outTex.get_height());
    float2 uv = float2(gid) / res;
    float2 suv = uv;
    
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    constexpr sampler sWrap(coord::normalized, address::repeat, filter::linear);

    // channel-driven drift warp — pixels pushed by their own colour
    if(p.driftWarp > 0.003) {
        for(int k = 0; k < 3; k++) {
            float2 w = (inTex.sample(sWrap, fract(suv)).rg - 0.5) * p.driftWarp * 0.06;
            suv += w;
        }
    }
    
    // FM warp — scan phase modulated by brightness, contours ripple
    if(p.fmWarp > 0.003) {
        float ph = uv.y * res.y * 0.35 + lumAt(suv, inTex, s) * p.fmWarp * 24.0 + p.time * 2.0;
        suv.x += sin(ph) * p.fmWarp * 0.025;
    }
    
    float3 c = inTex.sample(sWrap, fract(suv)).rgb;
    
    // block trash — databent macroblocks jump and corrupt
    if(p.blockShift > 0.003) {
        float bn = mix(52.0, 7.0, p.blockSize);
        float2 cell = floor(uv * float2(bn, bn * res.y / res.x));
        float tk = floor(p.time * 2.3);
        float r1 = h21(cell * 1.31 + tk * 17.0);
        if(r1 < p.blockShift * 0.4) {
            float2 off = (float2(h21(cell + 31.0 + tk), h21(cell + 57.0 + tk)) - 0.5) * 0.35 * p.blockShift;
            float3 bc = inTex.sample(sWrap, fract(suv + off)).rgb;
            float r2 = h21(cell + 99.0);
            if(r2 < 0.22) bc = bc.gbr;
            else if(r2 < 0.38) bc = 1.0 - bc;
            else if(r2 < 0.5) bc = floor(bc * 3.0 + 0.5) / 3.0;
            c = bc;
        }
    }
    
    // pixel sort — bright runs stretch into streaks
    if(p.pixelSort > 0.003) {
        float th = p.sortThresh;
        float l0 = dot(c, float3(0.299, 0.587, 0.114));
        if(l0 > th) {
            float py = 1.0 / res.y;
            float d = 0.0;
            for(int k = 1; k <= 32; k++) {
                if(lumAt(suv + float2(0.0, float(k) * 2.0 * py), inTex, s) <= th) break;
                d += 2.0 * py;
            }
            float3 sc = inTex.sample(s, clamp(suv + float2(0.0, d), 0.0, 1.0)).rgb;
            c = mix(c, sc, p.pixelSort);
        }
    }
    
    // halftone — everything drops out except dots sized by brightness
    if(p.dotify > 0.003) {
        float cellPx = mix(26.0, 6.0, p.dotSize);
        float2 g = uv * res / cellPx;
        float2 cc = (floor(g) + 0.5) * cellPx / res;
        float3 cs = inTex.sample(s, cc).rgb;
        float lm = dot(cs, float3(0.299, 0.587, 0.114));
        float r = length(fract(g) - 0.5);
        float m = smoothstep(lm * 0.72 + 0.06, lm * 0.72 - 0.06, r);
        c = mix(c, cs * m, p.dotify);
    }
    
    float alpha = inTex.sample(s, uv).a;
    outTex.write(float4(c, alpha), gid);
}
