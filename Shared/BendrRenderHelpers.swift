// BendrRenderHelpers.swift — Shared rendering utilities for FxPlug Metal pipelines

import Metal
import Foundation

/// Helpers for dispatching Metal compute shaders in FxPlug render callbacks
enum BendrRender {

    /// Calculate optimal threadgroup size for a compute pipeline on the given texture dimensions.
    static func threadgroupSize(for pipeline: MTLComputePipelineState,
                                width: Int, height: Int) -> (threadgroupSize: MTLSize, threadgroupCount: MTLSize) {
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadgroupSize = MTLSize(width: w, height: h, depth: 1)
        let threadgroupCount = MTLSize(
            width:  (width  + threadgroupSize.width  - 1) / threadgroupSize.width,
            height: (height + threadgroupSize.height - 1) / threadgroupSize.height,
            depth: 1
        )
        return (threadgroupSize, threadgroupCount)
    }

    /// Dispatch a compute shader over a 2D grid matching the output texture dimensions.
    static func dispatch(encoder: MTLComputeCommandEncoder,
                         pipeline: MTLComputePipelineState,
                         width: Int, height: Int) {
        encoder.setComputePipelineState(pipeline)
        let (tgSize, tgCount) = threadgroupSize(for: pipeline, width: width, height: height)
        encoder.dispatchThreadgroups(tgCount, threadsPerThreadgroup: tgSize)
    }

    /// Create a sampler state with the given address mode.
    /// Cached per device via the metal context.
    static func makeSampler(device: MTLDevice,
                            addressMode: MTLSamplerAddressMode = .clampToEdge,
                            filter: MTLSamplerMinMagFilter = .linear) -> MTLSamplerState? {
        let desc = MTLSamplerDescriptor()
        desc.minFilter = filter
        desc.magFilter = filter
        desc.sAddressMode = addressMode
        desc.tAddressMode = addressMode
        return device.makeSamplerState(descriptor: desc)
    }
}

/// Resolution info passed to shaders
struct BendrResolution {
    let width: Float
    let height: Float

    init(_ w: Int, _ h: Int) {
        self.width = Float(w)
        self.height = Float(h)
    }

    var simd: SIMD2<Float> {
        return SIMD2<Float>(width, height)
    }
}
