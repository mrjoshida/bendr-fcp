import Foundation
import FxPlug

struct BENDRFeedbackParams {
    enum ParamID: UInt32 {
        // Feedback Core
        case fbAmount = 3000
        case fbZoom
        case fbRotate
        case fbHue
        case fbShiftX
        case fbShiftY
        case fbMode
        
        // Feedback Shape
        case fbShearX = 3010
        case fbShearY
        case fbWrap
        case fbMirror
        case fbFlip
        case fbBlend
        
        // Feedback Color
        case fbGainR = 3020
        case fbGainG
        case fbGainB
        case fbSat
        case fbVal
        case fbPost
        case fbChromOff
        case fbInvert
        case fbAuto
        
        // Feedback Dynamics
        case fbBlur = 3030
        case fbBlur2
        case fbSharp
        case fbDrive
        case fbPivot
        case fbThresh
        case fbThreshSoft
        case fbNL
        
        // Feedback Noise
        case fbNoise = 3040
        case fbNoiseScale
        case fbRoll
        case fbJitter
        
        // Time Base
        case echo = 3050
        case delayFrames
        case stutter
        case strobe
        case shake
        case shakeRate
        
        // Source Framing
        case srcZoom = 3060
        case srcX
        case srcY
        case srcRot
        case flipMode
        case mirrorMode
        case multiN
        case kaleido
        case kaleidoN
        case kaleidoRot
        case kaleidoX
        case kaleidoY
        case edgeMode
    }
    
    static func addParameters(to api: PROAPIAccessing) throws {
        guard let paramAPI = api.apiForProtocol(FxParameterCreationAPI_v5.self) as? FxParameterCreationAPI_v5 else {
            throw NSError(domain: "BENDRFeedback", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get FxParameterCreationAPI_v5"])
        }
        
        paramAPI.addParameterGroup(withName: "Source Framing", parameterID: 3900, flags: 0)
        paramAPI.addFloatSlider(withName: "Zoom", parameterID: ParamID.srcZoom.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Pos X", parameterID: ParamID.srcX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Pos Y", parameterID: ParamID.srcY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Rotate", parameterID: ParamID.srcRot.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addPopupMenu(withName: "Flip", parameterID: ParamID.flipMode.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], flags: 0)
        paramAPI.addPopupMenu(withName: "Mirror", parameterID: ParamID.mirrorMode.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], flags: 0)
        paramAPI.addFloatSlider(withName: "Multi Grid", parameterID: ParamID.multiN.rawValue, defaultValue: 1.0, parameterMin: 1.0, parameterMax: 8.0, sliderMin: 1.0, sliderMax: 8.0, delta: 1.0, flags: 0)
        paramAPI.addPopupMenu(withName: "Edge Mode", parameterID: ParamID.edgeMode.rawValue, defaultValue: 0, menuEntries: ["Black", "Tile", "Mirror"], flags: 0)
        
        paramAPI.addFloatSlider(withName: "Kaleido", parameterID: ParamID.kaleido.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Fold N", parameterID: ParamID.kaleidoN.rawValue, defaultValue: 3.0, parameterMin: 2.0, parameterMax: 12.0, sliderMin: 2.0, sliderMax: 12.0, delta: 1.0, flags: 0)
        paramAPI.addFloatSlider(withName: "Fold Spin", parameterID: ParamID.kaleidoRot.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Fold Ctr X", parameterID: ParamID.kaleidoX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Fold Ctr Y", parameterID: ParamID.kaleidoY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.endParameterGroup()
        
        paramAPI.addParameterGroup(withName: "Feedback Core", parameterID: 3901, flags: 0)
        paramAPI.addFloatSlider(withName: "Amount", parameterID: ParamID.fbAmount.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 0.99, sliderMin: 0.0, sliderMax: 0.97, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Zoom", parameterID: ParamID.fbZoom.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Rotate", parameterID: ParamID.fbRotate.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Hue Spin", parameterID: ParamID.fbHue.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Shift X", parameterID: ParamID.fbShiftX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Shift Y", parameterID: ParamID.fbShiftY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Shear X", parameterID: ParamID.fbShearX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Shear Y", parameterID: ParamID.fbShearY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addPopupMenu(withName: "Wrap", parameterID: ParamID.fbWrap.rawValue, defaultValue: 0, menuEntries: ["Clamp", "Repeat", "Mirror"], flags: 0)
        paramAPI.addPopupMenu(withName: "Mirror", parameterID: ParamID.fbMirror.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], flags: 0)
        paramAPI.addPopupMenu(withName: "Flip", parameterID: ParamID.fbFlip.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], flags: 0)
        paramAPI.addPopupMenu(withName: "Blend", parameterID: ParamID.fbBlend.rawValue, defaultValue: 0, menuEntries: ["Mix", "Add", "Screen", "Max", "Min", "Difference"], flags: 0)
        paramAPI.endParameterGroup()
        
        paramAPI.addParameterGroup(withName: "Feedback Color", parameterID: 3902, flags: 0)
        paramAPI.addFloatSlider(withName: "Gain R", parameterID: ParamID.fbGainR.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Gain G", parameterID: ParamID.fbGainG.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Gain B", parameterID: ParamID.fbGainB.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Sat / Pass", parameterID: ParamID.fbSat.rawValue, defaultValue: 1.0, parameterMin: 0.5, parameterMax: 1.5, sliderMin: 0.5, sliderMax: 1.5, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Val / Pass", parameterID: ParamID.fbVal.rawValue, defaultValue: 1.0, parameterMin: 0.5, parameterMax: 1.5, sliderMin: 0.5, sliderMax: 1.5, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Posterize", parameterID: ParamID.fbPost.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Chroma Off", parameterID: ParamID.fbChromOff.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addToggleButton(withName: "Invert", parameterID: ParamID.fbInvert.rawValue, defaultValue: false, flags: 0)
        paramAPI.addToggleButton(withName: "Auto Level", parameterID: ParamID.fbAuto.rawValue, defaultValue: false, flags: 0)
        paramAPI.endParameterGroup()
        
        paramAPI.addParameterGroup(withName: "Feedback Dynamics", parameterID: 3903, flags: 0)
        paramAPI.addFloatSlider(withName: "Blur", parameterID: ParamID.fbBlur.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Blur 2 (DoG)", parameterID: ParamID.fbBlur2.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Sharpen", parameterID: ParamID.fbSharp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 2.0, sliderMin: 0.0, sliderMax: 2.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Drive", parameterID: ParamID.fbDrive.rawValue, defaultValue: 1.0, parameterMin: 0.2, parameterMax: 4.0, sliderMin: 0.2, sliderMax: 4.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Pivot", parameterID: ParamID.fbPivot.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Threshold", parameterID: ParamID.fbThresh.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Thresh Soft", parameterID: ParamID.fbThreshSoft.rawValue, defaultValue: 0.05, parameterMin: 0.005, parameterMax: 0.5, sliderMin: 0.005, sliderMax: 0.5, delta: 0.01, flags: 0)
        paramAPI.addPopupMenu(withName: "Curve", parameterID: ParamID.fbNL.rawValue, defaultValue: 0, menuEntries: ["Clamp", "Tanh", "Wrap", "Fold"], flags: 0)
        paramAPI.endParameterGroup()
        
        paramAPI.addParameterGroup(withName: "Feedback Noise", parameterID: 3904, flags: 0)
        paramAPI.addFloatSlider(withName: "Loop Noise", parameterID: ParamID.fbNoise.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Noise Scale", parameterID: ParamID.fbNoiseScale.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "V Roll / Pass", parameterID: ParamID.fbRoll.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Sync Jitter", parameterID: ParamID.fbJitter.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.endParameterGroup()
        
        paramAPI.addParameterGroup(withName: "Time Base", parameterID: 3905, flags: 0)
        paramAPI.addFloatSlider(withName: "Echo", parameterID: ParamID.echo.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Delay Frm", parameterID: ParamID.delayFrames.rawValue, defaultValue: 3.0, parameterMin: 1.0, parameterMax: 29.0, sliderMin: 1.0, sliderMax: 29.0, delta: 1.0, flags: 0)
        paramAPI.addFloatSlider(withName: "Stutter", parameterID: ParamID.stutter.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Strobe", parameterID: ParamID.strobe.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Shake", parameterID: ParamID.shake.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.addFloatSlider(withName: "Shake Rate", parameterID: ParamID.shakeRate.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, flags: 0)
        paramAPI.endParameterGroup()
    }
}
