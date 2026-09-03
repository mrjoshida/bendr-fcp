// BENDRTransitionFilter.swift — FxTileableEffect implementation for BENDR Transition

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRTransitionFilter)
public class BENDRTransitionFilter: NSObject, FxTileableEffect {

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

        // Group 1: Transition & Blend
        parmsApi.addFloatSlider(withName: "Transition Progress", parameterID: TransitionParamID.abMix.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Transition Type", parameterID: TransitionParamID.mixMode.rawValue, defaultValue: 0, menuEntries: [
            "Cross Dissolve",
            "Horizontal Wipe",
            "Vertical Wipe",
            "Diagonal Wipe",
            "Box / Rectangle Wipe",
            "Circle Wipe",
            "Horizontal Split",
            "Vertical Split",
            "Venetian Blinds H",
            "Venetian Blinds V",
            "Clock Wipe",
            "Checker Wipe",
            "Noise Wipe",
            "Slide Left",
            "Slide Right",
            "Slide Up",
            "Slide Down",
            "Stretch Horizontal",
            "Stretch Vertical"
        ], parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Blend Mode", parameterID: TransitionParamID.mixBlend.rawValue, defaultValue: 0, menuEntries: [
            "Normal / Mix", "Additive", "Non-Additive", "Difference", "Multiply", "Screen",
            "Darken", "Exclusion", "Subtract", "Overlay", "Hard Light", "Soft Light",
            "Vivid Light", "Pin Light", "Color Dodge", "Color Burn", "Divide", "Wrap Add",
            "XOR Logic", "AND Logic", "Hue", "Saturation", "Color", "Luminosity"
        ], parameterFlags: 0)

        // Group 2: Wipe Geometry
        parmsApi.addFloatSlider(withName: "Wipe Softness", parameterID: TransitionParamID.wipeSoft.rawValue, defaultValue: 0.03, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Wipe Frequency", parameterID: TransitionParamID.wipeDetail.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Center X", parameterID: TransitionParamID.wipeX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Center Y", parameterID: TransitionParamID.wipeY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addToggleButton(withName: "Invert Wipe", parameterID: TransitionParamID.wipeInv.rawValue, defaultValue: false, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Border Wipe", parameterID: TransitionParamID.wipeBord.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Border Color", parameterID: TransitionParamID.wipeBordCol.rawValue, defaultValue: 0, menuEntries: [
            "White", "Yellow", "Cyan", "Green", "Magenta", "Red", "Blue", "Black"
        ], parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Multi-Tiling", parameterID: TransitionParamID.wipeRep.rawValue, defaultValue: 1, parameterMin: 1, parameterMax: 4, sliderMin: 1, sliderMax: 4, delta: 1, parameterFlags: 0)

        // Group 3: Keyer & Matte
        parmsApi.addPopupMenu(withName: "Key Mode", parameterID: TransitionParamID.mixKey.rawValue, defaultValue: 0, menuEntries: [
            "Off", "Luma White", "Luma Black", "Chroma Key"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Threshold", parameterID: TransitionParamID.mixKeyThresh.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Softness", parameterID: TransitionParamID.mixKeySoft.rawValue, defaultValue: 0.2, parameterMin: 0.01, parameterMax: 1.0, sliderMin: 0.01, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Chroma Hue", parameterID: TransitionParamID.mixKeyHue.rawValue, defaultValue: 0.33, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addToggleButton(withName: "Invert Key", parameterID: TransitionParamID.mixKeyInv.rawValue, defaultValue: false, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Key Density", parameterID: TransitionParamID.mixKeyDens.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Key Gain", parameterID: TransitionParamID.mixKeyGain.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Key Border", parameterID: TransitionParamID.mixKeyEdge.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Key Border Color", parameterID: TransitionParamID.mixKeyEdgeCol.rawValue, defaultValue: 0, menuEntries: [
            "White", "Yellow", "Cyan", "Green", "Magenta", "Red", "Blue", "Black"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Key Shadow", parameterID: TransitionParamID.mixKeyShadow.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)
        scheduleInputsRequest.addInput(1, with: requestTime) // Second input clip if in a transition/composite
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = TransitionParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0
        var bVal = ObjCBool(false)

        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.abMix.rawValue, at: renderTime) { p.abMix = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: TransitionParamID.mixMode.rawValue, at: renderTime) { p.mixMode = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: TransitionParamID.mixBlend.rawValue, at: renderTime) { p.mixBlend = Float(iVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.wipeSoft.rawValue, at: renderTime) { p.wipeSoft = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.wipeDetail.rawValue, at: renderTime) { p.wipeDetail = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.wipeX.rawValue, at: renderTime) { p.wipeX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.wipeY.rawValue, at: renderTime) { p.wipeY = Float(fVal) }
        if parmsApi.getBoolValue(&bVal, fromParameter: TransitionParamID.wipeInv.rawValue, at: renderTime) { p.wipeInv = bVal.boolValue ? 1.0 : 0.0 }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.wipeBord.rawValue, at: renderTime) { p.wipeBord = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: TransitionParamID.wipeBordCol.rawValue, at: renderTime) { p.wipeBordCol = Float(iVal) / 7.0 }
        if parmsApi.getIntValue(&iVal, fromParameter: TransitionParamID.wipeRep.rawValue, at: renderTime) { p.wipeRep = Float(iVal) }

        if parmsApi.getIntValue(&iVal, fromParameter: TransitionParamID.mixKey.rawValue, at: renderTime) { p.mixKey = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.mixKeyThresh.rawValue, at: renderTime) { p.mixKeyThresh = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.mixKeySoft.rawValue, at: renderTime) { p.mixKeySoft = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.mixKeyHue.rawValue, at: renderTime) { p.mixKeyHue = Float(fVal) }
        if parmsApi.getBoolValue(&bVal, fromParameter: TransitionParamID.mixKeyInv.rawValue, at: renderTime) { p.mixKeyInv = bVal.boolValue ? 1.0 : 0.0 }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.mixKeyGain.rawValue, at: renderTime) { p.mixKeyGain = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.mixKeyDens.rawValue, at: renderTime) { p.mixKeyDens = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.mixKeyEdge.rawValue, at: renderTime) { p.mixKeyEdge = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: TransitionParamID.mixKeyEdgeCol.rawValue, at: renderTime) { p.mixKeyEdgeCol = Float(iVal) / 7.0 }
        if parmsApi.getFloatValue(&fVal, fromParameter: TransitionParamID.mixKeyShadow.rawValue, at: renderTime) { p.mixKeyShadow = Float(fVal) }

        p.time = Float(CMTimeGetSeconds(renderTime))
        pluginState.pointee = try p.encode() as NSData
    }

        public func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImages: [FxImageTile], destinationImage: FxImageTile, pluginState: Data?, at renderTime: CMTime) throws {
        destinationImageRect.pointee = sourceImages.first?.imagePixelBounds ?? destinationImage.imagePixelBounds
    }

        public func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImages: [FxImageTile], destinationTileRect: FxRect, destinationImage: FxImageTile, pluginState: Data?, at renderTime: CMTime) throws {
        sourceTileRect.pointee = destinationTileRect
    }

    public func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? TransitionParams.decode(from: pluginState),
              let srcA = sourceImages.first else {
            return
        }

        let srcB = sourceImages.count > 1 ? sourceImages[1] : srcA
        try BENDRTransitionRenderer.render(destination: destinationImage, sourceA: srcA, sourceB: srcB, params: params)
    }
}