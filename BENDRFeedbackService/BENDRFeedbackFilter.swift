import Foundation
import FxPlug
import CoreMedia

@objc(BENDRFeedbackFilter)
public class BENDRFeedbackFilter: NSObject, FxTileableEffect {

    private let apiManager: PROAPIAccessing

    @objc(initWithAPIManager:)
    public required init(apiManager: PROAPIAccessing) {
        self.apiManager = apiManager
        super.init()
    }

    public func properties(_ properties: AutoreleasingUnsafeMutablePointer<NSDictionary?>) throws {
        properties.pointee = [
            kFxPropertyKey_MayRemapTime: true,
            kFxPropertyKey_PixelTransformSupport: kFxPixelTransform_Supported,
            kFxPropertyKey_NeedsFullBuffer: true
        ] as NSDictionary
    }

    public func addParameters() throws {
        guard let parmsApi = apiManager.api(for: FxParameterCreationAPI_v5.self) as? FxParameterCreationAPI_v5 else {
            return
        }

        // Group 1: Source Framing
        parmsApi.startParameterSubGroup("Source Framing", parameterID: FeedbackParamID.groupSource.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Zoom", parameterID: FeedbackParamID.srcZoom.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pos X", parameterID: FeedbackParamID.srcX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pos Y", parameterID: FeedbackParamID.srcY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Rotate", parameterID: FeedbackParamID.srcRot.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Flip", parameterID: FeedbackParamID.flipMode.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Mirror", parameterID: FeedbackParamID.mirrorMode.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Multi Grid", parameterID: FeedbackParamID.multiN.rawValue, defaultValue: 1.0, parameterMin: 1.0, parameterMax: 8.0, sliderMin: 1.0, sliderMax: 8.0, delta: 1.0, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Edge Mode", parameterID: FeedbackParamID.edgeMode.rawValue, defaultValue: 0, menuEntries: ["Black", "Tile", "Mirror"], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Kaleido", parameterID: FeedbackParamID.kaleido.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Fold N", parameterID: FeedbackParamID.kaleidoN.rawValue, defaultValue: 3.0, parameterMin: 2.0, parameterMax: 12.0, sliderMin: 2.0, sliderMax: 12.0, delta: 1.0, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Fold Spin", parameterID: FeedbackParamID.kaleidoRot.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Fold Ctr X", parameterID: FeedbackParamID.kaleidoX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Fold Ctr Y", parameterID: FeedbackParamID.kaleidoY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Feedback Core
        parmsApi.startParameterSubGroup("Feedback Core", parameterID: FeedbackParamID.groupCore.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Amount", parameterID: FeedbackParamID.fbAmount.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 0.99, sliderMin: 0.0, sliderMax: 0.97, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Zoom", parameterID: FeedbackParamID.fbZoom.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Rotate", parameterID: FeedbackParamID.fbRotate.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Hue Spin", parameterID: FeedbackParamID.fbHue.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Shift X", parameterID: FeedbackParamID.fbShiftX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Shift Y", parameterID: FeedbackParamID.fbShiftY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Shear X", parameterID: FeedbackParamID.fbShearX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Shear Y", parameterID: FeedbackParamID.fbShearY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Wrap", parameterID: FeedbackParamID.fbWrap.rawValue, defaultValue: 0, menuEntries: ["Clamp", "Repeat", "Mirror"], parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Mirror", parameterID: FeedbackParamID.fbMirror.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Flip", parameterID: FeedbackParamID.fbFlip.rawValue, defaultValue: 0, menuEntries: ["Off", "Horizontal", "Vertical", "Both"], parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Blend", parameterID: FeedbackParamID.fbBlend.rawValue, defaultValue: 0, menuEntries: ["Mix", "Add", "Screen", "Max", "Min", "Difference"], parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: Feedback Color
        parmsApi.startParameterSubGroup("Feedback Color", parameterID: FeedbackParamID.groupColor.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gain R", parameterID: FeedbackParamID.fbGainR.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gain G", parameterID: FeedbackParamID.fbGainG.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gain B", parameterID: FeedbackParamID.fbGainB.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Sat / Pass", parameterID: FeedbackParamID.fbSat.rawValue, defaultValue: 1.0, parameterMin: 0.5, parameterMax: 1.5, sliderMin: 0.5, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Val / Pass", parameterID: FeedbackParamID.fbVal.rawValue, defaultValue: 1.0, parameterMin: 0.5, parameterMax: 1.5, sliderMin: 0.5, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Posterize", parameterID: FeedbackParamID.fbPost.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Chroma Off", parameterID: FeedbackParamID.fbChromOff.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addToggleButton(withName: "Invert", parameterID: FeedbackParamID.fbInvert.rawValue, defaultValue: false, parameterFlags: 0)
        parmsApi.addToggleButton(withName: "Auto Level", parameterID: FeedbackParamID.fbAuto.rawValue, defaultValue: false, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 4: Feedback Dynamics
        parmsApi.startParameterSubGroup("Feedback Dynamics", parameterID: FeedbackParamID.groupDynamics.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Blur", parameterID: FeedbackParamID.fbBlur.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Blur 2 (DoG)", parameterID: FeedbackParamID.fbBlur2.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Sharpen", parameterID: FeedbackParamID.fbSharp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 2.0, sliderMin: 0.0, sliderMax: 2.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Drive", parameterID: FeedbackParamID.fbDrive.rawValue, defaultValue: 1.0, parameterMin: 0.2, parameterMax: 4.0, sliderMin: 0.2, sliderMax: 4.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pivot", parameterID: FeedbackParamID.fbPivot.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Threshold", parameterID: FeedbackParamID.fbThresh.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Thresh Soft", parameterID: FeedbackParamID.fbThreshSoft.rawValue, defaultValue: 0.05, parameterMin: 0.005, parameterMax: 0.5, sliderMin: 0.005, sliderMax: 0.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Curve", parameterID: FeedbackParamID.fbNL.rawValue, defaultValue: 0, menuEntries: ["Clamp", "Tanh", "Wrap", "Fold"], parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 5: Feedback Noise
        parmsApi.startParameterSubGroup("Feedback Noise", parameterID: FeedbackParamID.groupNoise.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Loop Noise", parameterID: FeedbackParamID.fbNoise.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Noise Scale", parameterID: FeedbackParamID.fbNoiseScale.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "V Roll / Pass", parameterID: FeedbackParamID.fbRoll.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Sync Jitter", parameterID: FeedbackParamID.fbJitter.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 6: Time Base
        parmsApi.startParameterSubGroup("Time Base", parameterID: FeedbackParamID.groupTime.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Echo", parameterID: FeedbackParamID.echo.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Delay Frm", parameterID: FeedbackParamID.delayFrames.rawValue, defaultValue: 3.0, parameterMin: 1.0, parameterMax: 29.0, sliderMin: 1.0, sliderMax: 29.0, delta: 1.0, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Stutter", parameterID: FeedbackParamID.stutter.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Strobe", parameterID: FeedbackParamID.strobe.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Shake", parameterID: FeedbackParamID.shake.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Shake Rate", parameterID: FeedbackParamID.shakeRate.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? FeedbackParams.decode(from: pluginState) else {
            scheduleInputsRequest.addInput(0, with: requestTime)
            return
        }

        scheduleInputsRequest.addInput(0, with: requestTime)
        let frameDuration = CMTime(value: 1001, timescale: 30000)

        if params.fbAmount > 0.01 {
            let histTime = CMTimeSubtract(requestTime, frameDuration)
            scheduleInputsRequest.addInput(0, with: histTime)
        }
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = FeedbackParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.srcZoom.rawValue, at: renderTime) { p.srcZoom = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.srcX.rawValue, at: renderTime) { p.srcX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.srcY.rawValue, at: renderTime) { p.srcY = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.srcRot.rawValue, at: renderTime) { p.srcRot = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.flipMode.rawValue, at: renderTime) { p.flipMode = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.mirrorMode.rawValue, at: renderTime) { p.mirrorMode = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.multiN.rawValue, at: renderTime) { p.multiN = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.edgeMode.rawValue, at: renderTime) { p.edgeMode = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.kaleido.rawValue, at: renderTime) { p.kaleido = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.kaleidoN.rawValue, at: renderTime) { p.kaleidoN = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.kaleidoRot.rawValue, at: renderTime) { p.kaleidoRot = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.kaleidoX.rawValue, at: renderTime) { p.kaleidoX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.kaleidoY.rawValue, at: renderTime) { p.kaleidoY = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbAmount.rawValue, at: renderTime) { p.fbAmount = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbZoom.rawValue, at: renderTime) { p.fbZoom = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbRotate.rawValue, at: renderTime) { p.fbRotate = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbHue.rawValue, at: renderTime) { p.fbHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbShiftX.rawValue, at: renderTime) { p.fbShiftX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbShiftY.rawValue, at: renderTime) { p.fbShiftY = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbShearX.rawValue, at: renderTime) { p.fbShearX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbShearY.rawValue, at: renderTime) { p.fbShearY = Float(fVal) }
        var bVal = ObjCBool(false)
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.fbWrap.rawValue, at: renderTime) { p.fbWrap = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.fbMirror.rawValue, at: renderTime) { p.fbMirror = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.fbFlip.rawValue, at: renderTime) { p.fbFlip = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.fbBlend.rawValue, at: renderTime) { p.fbBlend = Float(iVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbGainR.rawValue, at: renderTime) { p.fbGainR = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbGainG.rawValue, at: renderTime) { p.fbGainG = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbGainB.rawValue, at: renderTime) { p.fbGainB = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbSat.rawValue, at: renderTime) { p.fbSat = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbVal.rawValue, at: renderTime) { p.fbVal = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbPost.rawValue, at: renderTime) { p.fbPost = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbChromOff.rawValue, at: renderTime) { p.fbChromOff = Float(fVal) }
        if parmsApi.getBoolValue(&bVal, fromParameter: FeedbackParamID.fbInvert.rawValue, at: renderTime) { p.fbInvert = bVal.boolValue ? 1.0 : 0.0 }
        if parmsApi.getBoolValue(&bVal, fromParameter: FeedbackParamID.fbAuto.rawValue, at: renderTime) { p.autoGain = bVal.boolValue ? 1.0 : 0.0 }

        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbBlur.rawValue, at: renderTime) { p.fbBlur = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbBlur2.rawValue, at: renderTime) { p.fbBlur2 = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbSharp.rawValue, at: renderTime) { p.fbSharp = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbDrive.rawValue, at: renderTime) { p.fbDrive = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbPivot.rawValue, at: renderTime) { p.fbPivot = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbThresh.rawValue, at: renderTime) { p.fbThresh = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbThreshSoft.rawValue, at: renderTime) { p.fbThreshSoft = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FeedbackParamID.fbNL.rawValue, at: renderTime) { p.fbNL = Float(iVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbNoise.rawValue, at: renderTime) { p.fbNoise = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbNoiseScale.rawValue, at: renderTime) { p.fbNoiseScale = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbRoll.rawValue, at: renderTime) { p.fbRoll = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.fbJitter.rawValue, at: renderTime) { p.fbJitter = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.echo.rawValue, at: renderTime) { p.echo = Float(fVal) }

        var shake: Float = 0.0
        var shakeRate: Float = 0.5
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.shake.rawValue, at: renderTime) { shake = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FeedbackParamID.shakeRate.rawValue, at: renderTime) { shakeRate = Float(fVal) }

        let t = Float(CMTimeGetSeconds(renderTime))
        p.time = t

        if shake > 0.001 {
            let phase = t * (1.0 + shakeRate * 20.0)
            p.shakeX = sin(phase * 13.7) * cos(phase * 7.3) * shake * 0.1
            p.shakeY = cos(phase * 11.3) * sin(phase * 5.7) * shake * 0.1
        }

        pluginState.pointee = try p.encode() as NSData
    }

    public func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImages: [FxImage], destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        destinationImageRect.pointee = FxRect(left: -100000, bottom: -100000, right: 100000, top: 100000)
    }

    public func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImages: [FxImage], destinationTileRect: FxRect, destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        sourceTileRect.pointee = destinationTileRect
    }

    public func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? FeedbackParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        let historyTiles = sourceImages.count > 1 ? Array(sourceImages.dropFirst()) : []
        try BENDRFeedbackRenderer.render(destination: destinationImage, current: srcTile, history: historyTiles, params: params)
    }
}
