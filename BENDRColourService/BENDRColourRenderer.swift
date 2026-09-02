// BENDRColourRenderer.swift — Metal Render Pipeline for BENDR Colour

import Foundation
import Metal
import FxPlug

enum BENDRColourRenderer {

    static func render(destination: FxImageTile, source: FxImageTile, params: ColourParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }

        guard let srcTexture = source.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRColourFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRColour")
        }

        let pipeline = try context.computePipeline(named: "bendrColour", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(srcTexture, index: 0)
        encoder.setTexture(dstTexture, index: 1)

        var mutableParams = params
        mutableParams.res = SIMD2<Float>(Float(dstTexture.width), Float(dstTexture.height))
        encoder.setBytes(&mutableParams, length: MemoryLayout<ColourParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
