// BENDRScanRenderer.swift — Metal Render Pipeline for BENDR Scan

import Foundation
import Metal
import FxPlug

enum BENDRScanRenderer {
    
    static func render(destination: FxImageTile, source: FxImageTile, params: ScanParams) throws {
        guard let context = BendrMetalContext.context(for: destination.deviceRegistryID) else {
            throw BendrError.renderFailed("Unable to obtain Metal context")
        }
        
        guard let srcTexture = source.metalTexture(for: context.device),
              let dstTexture = destination.metalTexture(for: context.device) else {
            throw BendrError.textureCreationFailed
        }
        
        let desc = MTLRenderPipelineDescriptor()
        desc.label = "BENDRScanRenderPipeline"
        
        guard let library = try? context.device.makeDefaultLibrary(bundle: Bundle(for: BENDRScanFilter.self)) ?? context.device.makeDefaultLibrary() else {
            throw BendrError.shaderNotFound("Default library")
        }
        
        guard let vertFunc = library.makeFunction(name: "scanVertex"),
              let fragFunc = library.makeFunction(name: "scanFragment") else {
            throw BendrError.shaderNotFound("scanVertex or scanFragment")
        }
        
        desc.vertexFunction = vertFunc
        desc.fragmentFunction = fragFunc
        desc.colorAttachments[0].pixelFormat = dstTexture.pixelFormat
        desc.colorAttachments[0].isBlendingEnabled = true
        desc.colorAttachments[0].rgbBlendOperation = .add
        desc.colorAttachments[0].alphaBlendOperation = .add
        desc.colorAttachments[0].sourceRGBBlendFactor = .one
        desc.colorAttachments[0].sourceAlphaBlendFactor = .one
        desc.colorAttachments[0].destinationRGBBlendFactor = .one
        desc.colorAttachments[0].destinationAlphaBlendFactor = .one
        
        let pipelineState = try context.renderPipeline(key: "scanPipeline_\(dstTexture.pixelFormat.rawValue)", descriptor: desc)
        
        guard let commandBuffer = context.makeCommandBuffer() else {
            throw BendrError.commandBufferFailed
        }
        
        let passDesc = MTLRenderPassDescriptor()
        passDesc.colorAttachments[0].texture = dstTexture
        passDesc.colorAttachments[0].loadAction = .clear
        passDesc.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        passDesc.colorAttachments[0].storeAction = .store
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDesc) else {
            throw BendrError.renderFailed("Could not create render command encoder")
        }
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexTexture(srcTexture, index: 0)
        
        var mutableParams = params
        encoder.setVertexBytes(&mutableParams, length: MemoryLayout<ScanParams>.stride, index: 0)
        encoder.setFragmentBytes(&mutableParams, length: MemoryLayout<ScanParams>.stride, index: 0)
        
        let vertexCount = max(Int(params.samples) * 2, 2)
        let instanceCount = max(Int(params.lines), 1)
        
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexCount, instanceCount: instanceCount)
        encoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
