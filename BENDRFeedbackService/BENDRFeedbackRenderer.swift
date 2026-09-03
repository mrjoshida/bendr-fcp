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

        // Prepare 16 historical frame textures (fallback to srcTexture if unavailable)
        var histTextures: [MTLTexture] = []
        for i in 0..<16 {
            if i < history.count, let tex = history[i].metalTexture(for: context.device) {
                histTextures.append(tex)
            } else {
                histTextures.append(srcTexture)
            }
        }

        let delayTile = history.first ?? current
        let delayTexture = delayTile.metalTexture(for: context.device) ?? srcTexture

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRFeedbackFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRFeedback")
        }

        let pipeline = try context.computePipeline(named: "bendrFeedback", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        if let sampler = BendrRender.makeSampler(device: context.device) {
            encoder.setSamplerState(sampler, index: 0)
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(srcTexture, index: 0)
        encoder.setTextures(histTextures, range: 1..<17)
        encoder.setTexture(delayTexture, index: 17)
        encoder.setTexture(dstTexture, index: 18)

        var mutableParams = params
        mutableParams.srcAspect = Float(dstTexture.width) / Float(dstTexture.height)
        mutableParams.hasSrc = 1.0
        mutableParams.hasDelay = history.isEmpty ? 0.0 : 1.0
        mutableParams.generationCount = 16
        encoder.setBytes(&mutableParams, length: MemoryLayout<FeedbackParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        if let err = commandBuffer.error {
            throw BendrError.renderFailed(err.localizedDescription)
        }
    }
}

