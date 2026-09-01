// BENDRFlowRenderer.swift — Metal Render Pipeline for BENDR Flow

import Foundation
import Metal
import FxPlug

enum BENDRFlowRenderer {

    static func render(destination: FxImageTile, source: FxImageTile, previousFlow: FxImageTile?, previousSource: FxImageTile?, params: FlowParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }

        guard let srcTexture = source.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }

        let flowPrevTexture = previousFlow?.metalTexture(for: context.device) ?? srcTexture
        let srcPrevTexture = previousSource?.metalTexture(for: context.device) ?? srcTexture

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRFlowFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRFlow")
        }

        let pipeline = try context.computePipeline(named: "bendrFlow", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(srcTexture, index: 0)
        encoder.setTexture(flowPrevTexture, index: 1)
        encoder.setTexture(srcPrevTexture, index: 2)
        encoder.setTexture(dstTexture, index: 3)

        var mutableParams = params
        mutableParams.res = SIMD2<Float>(Float(dstTexture.width), Float(dstTexture.height))
        encoder.setBytes(&mutableParams, length: MemoryLayout<FlowParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
