// BENDRCRTRenderer.swift — Metal Render Pipeline for BENDR CRT

import Foundation
import Metal
import FxPlug

enum BENDRCRTRenderer {

    static func render(destination: FxImageTile, source: FxImageTile, previous: FxImageTile?, params: CRTParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }

        guard let srcTexture = source.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }

        let prevTexture = previous?.metalTexture(for: context.device) ?? srcTexture

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRCRTFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRCRT")
        }

        let pipeline = try context.computePipeline(named: "bendrCRT", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(srcTexture, index: 0)
        encoder.setTexture(prevTexture, index: 1)
        encoder.setTexture(dstTexture, index: 2)

        var mutableParams = params
        mutableParams.procRes = SIMD2<Float>(Float(dstTexture.width), Float(dstTexture.height))
        mutableParams.rows = 480.0
        mutableParams.hasPersist = (previous != nil && mutableParams.phosphor > 0.003) ? 1.0 : 0.0

        encoder.setBytes(&mutableParams, length: MemoryLayout<CRTParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        if let err = commandBuffer.error {
            throw BendrError.renderFailed(err.localizedDescription)
        }
    }
}
