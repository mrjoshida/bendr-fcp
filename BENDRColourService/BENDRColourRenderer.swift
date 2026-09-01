import Foundation
import Metal

class BENDRColourRenderer {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLComputePipelineState
    
    init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        
        do {
            let library = try device.makeDefaultLibrary(bundle: Bundle(for: BENDRColourRenderer.self))
            guard let function = library.makeFunction(name: "bendrColour") else { return nil }
            self.pipelineState = try device.makeComputePipelineState(function: function)
        } catch {
            print("Failed to create pipeline state: \(error)")
            return nil
        }
    }
    
    func render(inTex: MTLTexture, outTex: MTLTexture, params: ColourParams) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(inTex, index: 0)
        encoder.setTexture(outTex, index: 1)
        
        var p = params
        p.res = SIMD2<Float>(Float(outTex.width), Float(outTex.height))
        encoder.setBytes(&p, length: MemoryLayout<ColourParams>.stride, index: 0)
        
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1)
        let threadsPerGrid = MTLSize(width: outTex.width, height: outTex.height, depth: 1)
        
        encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
        
        commandBuffer.commit()
    }
}
