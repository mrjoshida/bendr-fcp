// BENDRTransitionRenderer.swift — Metal Render Pipeline for BENDR Transition

import Foundation
import Metal
import FxPlug

enum BENDRTransitionRenderer {

    static func render(destination: FxImageTile, sourceA: FxImageTile, sourceB: FxImageTile?, params: TransitionParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }

        guard let texA = sourceA.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }

        let texB = sourceB?.metalTexture(for: context.device) ?? texA

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRTransitionFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRTransition")
        }

        let pipeline = try context.computePipeline(named: "bendrTransition", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(texA, index: 0)
        encoder.setTexture(texB, index: 1)
        encoder.setTexture(dstTexture, index: 2)

        var mutableParams = params
        mutableParams.res = SIMD2<Float>(Float(dstTexture.width), Float(dstTexture.height))
        encoder.setBytes(&mutableParams, length: MemoryLayout<TransitionParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        if let err = commandBuffer.error {
            throw BendrError.renderFailed(err.localizedDescription)
        }
    }
}
