import Foundation
import FxPlug
import CoreMedia

@objc(BENDRFeedbackFilter)
class BENDRFeedbackFilter: NSObject, FxTileableEffect {
    
    var apiManager: PROAPIAccessing!
    var renderer: BENDRFeedbackRenderer?
    
    required init?(apiManager: PROAPIAccessing) {
        self.apiManager = apiManager
        super.init()
    }
    
    func properties(_ properties: AutoreleasingUnsafeMutablePointer<NSDictionary>?) throws {
        properties?.pointee = [
            kFxPropertyKey_MayRemapTime: true,
            kFxPropertyKey_PixelTransformSupport: kFxPixelTransform_Supported,
            kFxPropertyKey_NeedsFullBuffer: true
        ] as NSDictionary
    }
    
    func addParameters() throws {
        try BENDRFeedbackParams.addParameters(to: apiManager)
    }
    
    func scheduleInputs(_ request: inout FxScheduleInputsRequest, with pluginState: Data?, at time: CMTime) throws {
        let paramAPI = apiManager.apiForProtocol(FxParameterRetrievalAPI_v6.self) as! FxParameterRetrievalAPI_v6
        
        var fbAmount = 0.0
        paramAPI.getFloatValue(&fbAmount, fromParameter: BENDRFeedbackParams.ParamID.fbAmount.rawValue, at: time)
        
        var delayFrames = 3.0
        paramAPI.getFloatValue(&delayFrames, fromParameter: BENDRFeedbackParams.ParamID.delayFrames.rawValue, at: time)
        
        var hasDelay = false
        var echo = 0.0
        paramAPI.getFloatValue(&echo, fromParameter: BENDRFeedbackParams.ParamID.echo.rawValue, at: time)
        if echo > 0.0 { hasDelay = true }
        
        let frameDuration = request.hostRect.height > 0 ? CMTime(value: 1001, timescale: 30000) : CMTime(value: 1, timescale: 30) // fallback approximation
        
        // Stutter & Strobe logic can be roughly approximated by quantized times.
        // We will just fetch standard historical frames for this stateless feedback approach.
        var historyCount = 0
        if fbAmount > 0.0 {
            if fbAmount > 0.95 { historyCount = 16 }
            else if fbAmount > 0.8 { historyCount = 12 }
            else if fbAmount > 0.5 { historyCount = 8 }
            else { historyCount = 4 }
        }
        
        // Request history frames
        for i in 1...historyCount {
            let histTime = CMTimeSubtract(time, CMTimeMultiply(frameDuration, multiplier: Int32(i)))
            request.addInput(0, with: histTime) // source 0
        }
        
        if hasDelay {
            let delayTime = CMTimeSubtract(time, CMTimeMultiply(frameDuration, multiplier: Int32(delayFrames)))
            request.addInput(0, with: delayTime) // source 0
        }
    }
    
    func pluginState(at time: CMTime, quality: UInt, error: NSErrorPointer) -> Data? {
        guard let paramAPI = apiManager.apiForProtocol(FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else { return nil }
        
        var params = [Float](repeating: 0.0, count: 50)
        
        paramAPI.getFloatValue(&params[0], fromParameter: BENDRFeedbackParams.ParamID.fbAmount.rawValue, at: time)
        paramAPI.getFloatValue(&params[1], fromParameter: BENDRFeedbackParams.ParamID.fbZoom.rawValue, at: time)
        paramAPI.getFloatValue(&params[2], fromParameter: BENDRFeedbackParams.ParamID.fbRotate.rawValue, at: time)
        paramAPI.getFloatValue(&params[3], fromParameter: BENDRFeedbackParams.ParamID.fbHue.rawValue, at: time)
        paramAPI.getFloatValue(&params[4], fromParameter: BENDRFeedbackParams.ParamID.fbShiftX.rawValue, at: time)
        paramAPI.getFloatValue(&params[5], fromParameter: BENDRFeedbackParams.ParamID.fbShiftY.rawValue, at: time)
        
        paramAPI.getFloatValue(&params[6], fromParameter: BENDRFeedbackParams.ParamID.fbShearX.rawValue, at: time)
        paramAPI.getFloatValue(&params[7], fromParameter: BENDRFeedbackParams.ParamID.fbShearY.rawValue, at: time)
        
        var wrap: Int32 = 0
        paramAPI.getIntValue(&wrap, fromParameter: BENDRFeedbackParams.ParamID.fbWrap.rawValue, at: time)
        params[8] = Float(wrap)
        
        var mirror: Int32 = 0
        paramAPI.getIntValue(&mirror, fromParameter: BENDRFeedbackParams.ParamID.fbMirror.rawValue, at: time)
        params[9] = Float(mirror)
        
        var blend: Int32 = 0
        paramAPI.getIntValue(&blend, fromParameter: BENDRFeedbackParams.ParamID.fbBlend.rawValue, at: time)
        params[10] = Float(blend)
        
        paramAPI.getFloatValue(&params[11], fromParameter: BENDRFeedbackParams.ParamID.fbGainR.rawValue, at: time)
        paramAPI.getFloatValue(&params[12], fromParameter: BENDRFeedbackParams.ParamID.fbGainG.rawValue, at: time)
        paramAPI.getFloatValue(&params[13], fromParameter: BENDRFeedbackParams.ParamID.fbGainB.rawValue, at: time)
        paramAPI.getFloatValue(&params[14], fromParameter: BENDRFeedbackParams.ParamID.fbSat.rawValue, at: time)
        paramAPI.getFloatValue(&params[15], fromParameter: BENDRFeedbackParams.ParamID.fbVal.rawValue, at: time)
        paramAPI.getFloatValue(&params[16], fromParameter: BENDRFeedbackParams.ParamID.fbPost.rawValue, at: time)
        paramAPI.getFloatValue(&params[17], fromParameter: BENDRFeedbackParams.ParamID.fbChromOff.rawValue, at: time)
        
        var invert = false
        paramAPI.getBoolValue(&invert, fromParameter: BENDRFeedbackParams.ParamID.fbInvert.rawValue, at: time)
        params[18] = invert ? 1.0 : 0.0
        
        var autoLevel = false
        paramAPI.getBoolValue(&autoLevel, fromParameter: BENDRFeedbackParams.ParamID.fbAuto.rawValue, at: time)
        params[19] = autoLevel ? 1.0 : 0.0
        
        paramAPI.getFloatValue(&params[20], fromParameter: BENDRFeedbackParams.ParamID.fbBlur.rawValue, at: time)
        paramAPI.getFloatValue(&params[21], fromParameter: BENDRFeedbackParams.ParamID.fbBlur2.rawValue, at: time)
        paramAPI.getFloatValue(&params[22], fromParameter: BENDRFeedbackParams.ParamID.fbSharp.rawValue, at: time)
        paramAPI.getFloatValue(&params[23], fromParameter: BENDRFeedbackParams.ParamID.fbDrive.rawValue, at: time)
        paramAPI.getFloatValue(&params[24], fromParameter: BENDRFeedbackParams.ParamID.fbPivot.rawValue, at: time)
        paramAPI.getFloatValue(&params[25], fromParameter: BENDRFeedbackParams.ParamID.fbThresh.rawValue, at: time)
        paramAPI.getFloatValue(&params[26], fromParameter: BENDRFeedbackParams.ParamID.fbThreshSoft.rawValue, at: time)
        
        var nl: Int32 = 0
        paramAPI.getIntValue(&nl, fromParameter: BENDRFeedbackParams.ParamID.fbNL.rawValue, at: time)
        params[27] = Float(nl)
        
        paramAPI.getFloatValue(&params[28], fromParameter: BENDRFeedbackParams.ParamID.fbNoise.rawValue, at: time)
        paramAPI.getFloatValue(&params[29], fromParameter: BENDRFeedbackParams.ParamID.fbNoiseScale.rawValue, at: time)
        paramAPI.getFloatValue(&params[30], fromParameter: BENDRFeedbackParams.ParamID.fbRoll.rawValue, at: time)
        paramAPI.getFloatValue(&params[31], fromParameter: BENDRFeedbackParams.ParamID.fbJitter.rawValue, at: time)
        
        paramAPI.getFloatValue(&params[32], fromParameter: BENDRFeedbackParams.ParamID.echo.rawValue, at: time)
        
        paramAPI.getFloatValue(&params[33], fromParameter: BENDRFeedbackParams.ParamID.srcZoom.rawValue, at: time)
        paramAPI.getFloatValue(&params[34], fromParameter: BENDRFeedbackParams.ParamID.srcX.rawValue, at: time)
        paramAPI.getFloatValue(&params[35], fromParameter: BENDRFeedbackParams.ParamID.srcY.rawValue, at: time)
        paramAPI.getFloatValue(&params[36], fromParameter: BENDRFeedbackParams.ParamID.srcRot.rawValue, at: time)
        
        var flip: Int32 = 0
        paramAPI.getIntValue(&flip, fromParameter: BENDRFeedbackParams.ParamID.flipMode.rawValue, at: time)
        params[37] = Float(flip)
        
        var smirror: Int32 = 0
        paramAPI.getIntValue(&smirror, fromParameter: BENDRFeedbackParams.ParamID.mirrorMode.rawValue, at: time)
        params[38] = Float(smirror)
        
        paramAPI.getFloatValue(&params[39], fromParameter: BENDRFeedbackParams.ParamID.multiN.rawValue, at: time)
        
        paramAPI.getFloatValue(&params[40], fromParameter: BENDRFeedbackParams.ParamID.kaleido.rawValue, at: time)
        paramAPI.getFloatValue(&params[41], fromParameter: BENDRFeedbackParams.ParamID.kaleidoN.rawValue, at: time)
        paramAPI.getFloatValue(&params[42], fromParameter: BENDRFeedbackParams.ParamID.kaleidoRot.rawValue, at: time)
        paramAPI.getFloatValue(&params[43], fromParameter: BENDRFeedbackParams.ParamID.kaleidoX.rawValue, at: time)
        paramAPI.getFloatValue(&params[44], fromParameter: BENDRFeedbackParams.ParamID.kaleidoY.rawValue, at: time)
        
        var edgem: Int32 = 0
        paramAPI.getIntValue(&edgem, fromParameter: BENDRFeedbackParams.ParamID.edgeMode.rawValue, at: time)
        params[45] = Float(edgem)
        
        var fbflip: Int32 = 0
        paramAPI.getIntValue(&fbflip, fromParameter: BENDRFeedbackParams.ParamID.fbFlip.rawValue, at: time)
        params[46] = Float(fbflip)
        
        paramAPI.getFloatValue(&params[47], fromParameter: BENDRFeedbackParams.ParamID.shake.rawValue, at: time)
        paramAPI.getFloatValue(&params[48], fromParameter: BENDRFeedbackParams.ParamID.shakeRate.rawValue, at: time)
        
        return Data(bytes: params, count: params.count * MemoryLayout<Float>.size)
    }
    
    func renderDestinationImage(_ destinationImage: FxImage, sourceImages: [FxImage]?, pluginState: Data?, at time: CMTime, error: NSErrorPointer) throws {
        guard let sourceImages = sourceImages, !sourceImages.isEmpty else { return }
        let currentSrc = sourceImages[0]
        
        guard let state = pluginState else { return }
        
        if renderer == nil {
            renderer = BENDRFeedbackRenderer(apiManager: apiManager)
        }
        
        try renderer?.render(destinationImage: destinationImage, sourceImages: sourceImages, state: state, at: time)
    }
    
    func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImageRect: FxRect, destinationTileRect: FxRect, destinationImageRect: FxRect, pluginState: Data?, at time: CMTime, error: NSErrorPointer) throws {
        sourceTileRect.pointee = destinationTileRect
    }
    
    func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImageRects: [NSValue]?, pluginState: Data?, at time: CMTime, error: NSErrorPointer) throws {
        if let first = sourceImageRects?.first {
            destinationImageRect.pointee = first.fxRectValue
        }
    }
}
