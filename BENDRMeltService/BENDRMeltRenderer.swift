// BENDRMeltRenderer.swift — Metal Render Pipeline for BENDR Melt

import Foundation
import Metal
import FxPlug

enum BENDRMeltRenderer {

    static func render(destination: FxImageTile, source: FxImageTile, previous: FxImageTile?, params: MeltParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }

        guard let srcTexture = source.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }

        let prevTexture = previous?.metalTexture(for: context.device) ?? srcTexture

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRMeltFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRMelt")
        }

        let pipeline = try context.computePipeline(named: "bendrMelt", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(srcTexture, index: 0)
        encoder.setTexture(prevTexture, index: 1)
        encoder.setTexture(dstTexture, index: 2)

        var mutableParams = params
        mutableParams.res = SIMD2<Float>(Float(dstTexture.width), Float(dstTexture.height))
        encoder.setBytes(&mutableParams, length: MemoryLayout<MeltParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
