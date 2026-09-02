// BENDRVHSRenderer.swift — Metal Render Pipeline for BENDR VHS

import Foundation
import Metal
import FxPlug

enum BENDRVHSRenderer {

    static func render(destination: FxImageTile, source: FxImageTile, params: VHSParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }

        guard let srcTexture = source.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }

        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRVHSFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library for BENDRVHS")
        }

        let pipeline = try context.computePipeline(named: "bendrVHS", from: library)

        guard let commandBuffer = context.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BendrError.commandBufferFailed
        }

        var mutableParams = params
        let rows = dstTexture.height
        mutableParams.rows = Float(rows)

        // Evaluate PLL sync model and generate 1xRows displacement texture
        let syncTuples = BENDRVHSPLL.updateSyncModel(t: mutableParams.time, params: mutableParams)
        
        let dispDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba32Float, width: 1, height: rows, mipmapped: false)
        dispDesc.usage = [.shaderRead]
        guard let dispTexture = context.device.makeTexture(descriptor: dispDesc) else {
            throw BendrError.textureCreationFailed
        }
        
        dispTexture.replace(
            region: MTLRegionMake2D(0, 0, 1, rows),
            mipmapLevel: 0,
            withBytes: syncTuples,
            bytesPerRow: MemoryLayout<SyncTuple>.stride
        )

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(srcTexture, index: 0)
        encoder.setTexture(dstTexture, index: 1)
        encoder.setTexture(dispTexture, index: 2)
        encoder.setBytes(&mutableParams, length: MemoryLayout<VHSParams>.stride, index: 0)

        BendrRender.dispatch(encoder: encoder, pipeline: pipeline, width: dstTexture.width, height: dstTexture.height)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        if let err = commandBuffer.error {
            throw BendrError.renderFailed(err.localizedDescription)
        }
    }
}
