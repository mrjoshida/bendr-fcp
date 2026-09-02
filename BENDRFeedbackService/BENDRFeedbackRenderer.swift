import Foundation
import FxPlug
import Metal

enum BENDRFeedbackRenderer {

    static func render(destination: FxImageTile, current: FxImageTile, history: [FxImageTile], params: FeedbackParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }

        guard let srcTexture = current.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }

        // Use the oldest available history frame or fallback to source
        let histTile = history.last ?? current
        let histTexture = histTile.metalTexture(for: context.device) ?? srcTexture

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRFeedbackFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRFeedback")
        }

        let pipeline = try context.computePipeline(named: "bendrFeedback", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(srcTexture, index: 0)
        encoder.setTexture(histTexture, index: 1)
        encoder.setTexture(dstTexture, index: 2)

        var mutableParams = params
        mutableParams.srcAspect = Float(dstTexture.width) / Float(dstTexture.height)
        mutableParams.hasSrc = 1.0
        mutableParams.hasDelay = history.isEmpty ? 0.0 : 1.0
        encoder.setBytes(&mutableParams, length: MemoryLayout<FeedbackParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}

