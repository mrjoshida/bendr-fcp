import Foundation
import FxPlug
import Metal

class BENDRFeedbackRenderer {
    let apiManager: PROAPIAccessing
    var pipelineState: MTLComputePipelineState?
    var commandQueue: MTLCommandQueue?
    
    struct FeedbackParams {
        var srcAspect: Float
        var hasSrc: Float
        var hasDelay: Float
        var time: Float
        
        var fbAmount: Float
        var fbZoom: Float
        var fbRotate: Float
        var fbHue: Float
        var fbShiftX: Float
        var fbShiftY: Float
        var fbMode: Float
        
        var echo: Float
        var srcZoom: Float
        var srcX: Float
        var srcY: Float
        var srcRot: Float
        var edgeMode: Float
        
        var flipMode: Float
        var mirrorMode: Float
        var multiN: Float
        var shakeX: Float
        var shakeY: Float
        
        var kaleido: Float
        var kaleidoN: Float
        var kaleidoRot: Float
        var kaleidoX: Float
        var kaleidoY: Float
        
        var fbShearX: Float
        var fbShearY: Float
        var fbGainR: Float
        var fbGainG: Float
        var fbGainB: Float
        var fbSat: Float
        var fbVal: Float
        var fbPost: Float
        var fbChromOff: Float
        
        var fbBlur: Float
        var fbBlur2: Float
        var fbSharp: Float
        var fbDrive: Float
        var fbPivot: Float
        var fbThresh: Float
        var fbThreshSoft: Float
        
        var fbNoise: Float
        var fbNoiseScale: Float
        var fbRoll: Float
        var fbJitter: Float
        
        var fbWrap: Float
        var fbMirror: Float
        var fbBlend: Float
        var fbNL: Float
        var fbInvert: Float
        var autoGain: Float
        var fbFlip: Float
        
        var generationCount: UInt32
    }
    
    init(apiManager: PROAPIAccessing) {
        self.apiManager = apiManager
    }
    
    private func setupMetal(device: MTLDevice) throws {
        if pipelineState != nil { return }
        
        let bundle = Bundle(for: type(of: self))
        guard let libraryURL = bundle.url(forResource: "default", withExtension: "metallib") else {
            throw NSError(domain: "BENDRFeedback", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to find metallib"])
        }
        
        let library = try device.makeLibrary(URL: libraryURL)
        guard let function = library.makeFunction(name: "bendrFeedback") else {
            throw NSError(domain: "BENDRFeedback", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to find bendrFeedback"])
        }
        
        pipelineState = try device.makeComputePipelineState(function: function)
        commandQueue = device.makeCommandQueue()
    }
    
    func render(destinationImage: FxImage, sourceImages: [FxImage], state: Data, at time: CMTime) throws {
        guard let fxMetalAPI = apiManager.apiForProtocol(FxRenderEnvironmentAPI_v2.self) as? FxRenderEnvironmentAPI_v2 else { return }
        let device = fxMetalAPI.device()
        try setupMetal(device: device)
        
        guard let pipelineState = pipelineState,
              let commandQueue = commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        encoder.setComputePipelineState(pipelineState)
        
        var paramsArray = [Float](repeating: 0.0, count: 50)
        state.withUnsafeBytes { ptr in
            _ = memcpy(&paramsArray, ptr.baseAddress!, min(state.count, paramsArray.count * MemoryLayout<Float>.size))
        }
        
        let srcAspect = Float(destinationImage.width) / Float(destinationImage.height)
        let t = Float(time.value) / Float(time.timescale)
        
        // Setup struct
        var mtlParams = FeedbackParams(
            srcAspect: srcAspect,
            hasSrc: 1.0,
            hasDelay: paramsArray[32] > 0 ? 1.0 : 0.0,
            time: t,
            
            fbAmount: paramsArray[0],
            fbZoom: paramsArray[1],
            fbRotate: paramsArray[2],
            fbHue: paramsArray[3],
            fbShiftX: paramsArray[4],
            fbShiftY: paramsArray[5],
            fbMode: 0.0,
            
            echo: paramsArray[32],
            srcZoom: paramsArray[33],
            srcX: paramsArray[34],
            srcY: paramsArray[35],
            srcRot: paramsArray[36],
            edgeMode: paramsArray[45],
            
            flipMode: paramsArray[37],
            mirrorMode: paramsArray[38],
            multiN: paramsArray[39],
            shakeX: 0.0, // calculate if needed based on shake/shakeRate
            shakeY: 0.0,
            
            kaleido: paramsArray[40],
            kaleidoN: paramsArray[41],
            kaleidoRot: paramsArray[42],
            kaleidoX: paramsArray[43],
            kaleidoY: paramsArray[44],
            
            fbShearX: paramsArray[6],
            fbShearY: paramsArray[7],
            fbGainR: paramsArray[11],
            fbGainG: paramsArray[12],
            fbGainB: paramsArray[13],
            fbSat: paramsArray[14],
            fbVal: paramsArray[15],
            fbPost: paramsArray[16],
            fbChromOff: paramsArray[17],
            
            fbBlur: paramsArray[20],
            fbBlur2: paramsArray[21],
            fbSharp: paramsArray[22],
            fbDrive: paramsArray[23],
            fbPivot: paramsArray[24],
            fbThresh: paramsArray[25],
            fbThreshSoft: paramsArray[26],
            
            fbNoise: paramsArray[28],
            fbNoiseScale: paramsArray[29],
            fbRoll: paramsArray[30],
            fbJitter: paramsArray[31],
            
            fbWrap: paramsArray[8],
            fbMirror: paramsArray[9],
            fbBlend: paramsArray[10],
            fbNL: paramsArray[27],
            fbInvert: paramsArray[18],
            autoGain: paramsArray[19] == 1.0 ? 1.0 : 1.0, // autoGain could be computed
            fbFlip: paramsArray[46],
            
            generationCount: UInt32(sourceImages.count - 1) // minus src and maybe minus delay
        )
        
        if paramsArray[47] > 0.001 { // shake
            let phase = t * (0.5 + paramsArray[48] * 15.0)
            mtlParams.shakeX = Float.random(in: -1...1) * paramsArray[47] * 0.1 // simple rand for now
            mtlParams.shakeY = Float.random(in: -1...1) * paramsArray[47] * 0.1
        }
        
        encoder.setBytes(&mtlParams, length: MemoryLayout<FeedbackParams>.stride, index: 0)
        
        let samplerDesc = MTLSamplerDescriptor()
        samplerDesc.minFilter = .linear
        samplerDesc.magFilter = .linear
        let sampler = device.makeSamplerState(descriptor: samplerDesc)
        encoder.setSamplerState(sampler, index: 0)
        
        encoder.setTexture(sourceImages[0].texture, index: 0)
        
        // Pass historical textures to index 1..16
        // If hasDelay, the last texture is the delay texture, otherwise it's just history.
        // We will just bind the history textures.
        var historyCount = sourceImages.count - 1
        var delayTex = sourceImages[0].texture
        if mtlParams.hasDelay > 0 && historyCount > 0 {
            delayTex = sourceImages.last!.texture
            historyCount -= 1
        }
        
        var histTextures = [MTLTexture?](repeating: nil, count: 16)
        for i in 0..<min(historyCount, 16) {
            histTextures[i] = sourceImages[i+1].texture
        }
        
        // MTK requires an array if mapped as array<texture2d> in MSL.
        // Set texture range for histTex
        let validTexs = histTextures.compactMap { $0 ?? sourceImages[0].texture }
        if !validTexs.isEmpty {
            encoder.setTextures(validTexs, range: 1..<(1 + validTexs.count))
        }
        
        encoder.setTexture(delayTex, index: 17)
        encoder.setTexture(destinationImage.texture, index: 18)
        
        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(Int(destinationImage.width), Int(destinationImage.height), 1)
        
        encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
