// BENDRSynthFilter.swift — FxTileableEffect implementation for BENDR Synth

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRSynthFilter)
public class BENDRSynthFilter: NSObject, FxTileableEffect {

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

        // Group 1: Geometry & Oscillators
        parmsApi.startParameterSubGroup("Geometry & Oscillators", parameterID: SynthParamID.groupGeometry.rawValue, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Pattern Shape", parameterID: SynthParamID.shape.rawValue, defaultValue: 0, menuEntries: [
            "Scan (Dual Ramp)",
            "Radial",
            "Spiral",
            "Plasma",
            "Lissajous",
            "Rings",
            "Starburst",
            "Grid",
            "Tunnel",
            "Cells (Voronoi)",
            "Interference",
            "Polygon"
        ], parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Oscillator Waveform", parameterID: SynthParamID.wave.rawValue, defaultValue: 0, menuEntries: [
            "Sine",
            "Triangle",
            "Saw",
            "Square",
            "Variable Pulse",
            "Sample & Hold Noise"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Frequency X", parameterID: SynthParamID.genFreqX.rawValue, defaultValue: 0.18, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Frequency Y", parameterID: SynthParamID.genFreqY.rawValue, defaultValue: 0.12, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Phase", parameterID: SynthParamID.genPhase.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Animation Rate", parameterID: SynthParamID.genRate.rawValue, defaultValue: 0.08, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Rotation", parameterID: SynthParamID.genRot.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Raster Skew", parameterID: SynthParamID.genSkew.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Center X", parameterID: SynthParamID.genCX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Center Y", parameterID: SynthParamID.genCY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Zoom / Scale", parameterID: SynthParamID.genZoom.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Symmetry Folds", parameterID: SynthParamID.genFoldN.rawValue, defaultValue: 4, parameterMin: 1, parameterMax: 16, sliderMin: 1, sliderMax: 16, delta: 1, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Synthesis & Modulation
        parmsApi.startParameterSubGroup("Synthesis & Modulation", parameterID: SynthParamID.groupModulation.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Cross-FM Depth", parameterID: SynthParamID.genFM.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Wavefolder", parameterID: SynthParamID.genFold.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pulse Width", parameterID: SynthParamID.genPulse.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Comparator", parameterID: SynthParamID.genComp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Comparator Thresh", parameterID: SynthParamID.genThresh.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Comparator Soft", parameterID: SynthParamID.genSoft.rawValue, defaultValue: 0.12, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Domain Warp", parameterID: SynthParamID.genWarp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: Color & Output
        parmsApi.startParameterSubGroup("Color & Output", parameterID: SynthParamID.groupColor.rawValue, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Color Mode", parameterID: SynthParamID.colmode.rawValue, defaultValue: 2, menuEntries: [
            "Monochrome",
            "RGB Phase Shift",
            "HSV Spectrum",
            "Duotone",
            "Harmonic Bands"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Base Hue", parameterID: SynthParamID.genHue.rawValue, defaultValue: 0.55, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Color Spread", parameterID: SynthParamID.genSpread.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 2.0, sliderMin: 0.0, sliderMax: 2.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Saturation", parameterID: SynthParamID.genSat.rawValue, defaultValue: 0.9, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Brightness", parameterID: SynthParamID.genBright.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Color Bands", parameterID: SynthParamID.genBands.rawValue, defaultValue: 6, parameterMin: 2, parameterMax: 16, sliderMin: 2, sliderMax: 16, delta: 1, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Overlay Source", parameterID: SynthParamID.blendWithSource.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = SynthParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getIntValue(&iVal, fromParameter: SynthParamID.shape.rawValue, at: renderTime) { p.shape = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SynthParamID.wave.rawValue, at: renderTime) { p.wave = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genFreqX.rawValue, at: renderTime) { p.genFreqX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genFreqY.rawValue, at: renderTime) { p.genFreqY = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genPhase.rawValue, at: renderTime) { p.genPhase = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genRate.rawValue, at: renderTime) { p.genRate = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genRot.rawValue, at: renderTime) { p.genRot = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genSkew.rawValue, at: renderTime) { p.genSkew = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genCX.rawValue, at: renderTime) { p.genCX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genCY.rawValue, at: renderTime) { p.genCY = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genZoom.rawValue, at: renderTime) { p.genZoom = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SynthParamID.genFoldN.rawValue, at: renderTime) { p.genFoldN = Float(iVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genFM.rawValue, at: renderTime) { p.genFM = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genFold.rawValue, at: renderTime) { p.genFold = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genPulse.rawValue, at: renderTime) { p.genPulse = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genComp.rawValue, at: renderTime) { p.genComp = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genThresh.rawValue, at: renderTime) { p.genThresh = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genSoft.rawValue, at: renderTime) { p.genSoft = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genWarp.rawValue, at: renderTime) { p.genWarp = Float(fVal) }

        if parmsApi.getIntValue(&iVal, fromParameter: SynthParamID.colmode.rawValue, at: renderTime) { p.colmode = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genHue.rawValue, at: renderTime) { p.genHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genSpread.rawValue, at: renderTime) { p.genSpread = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genSat.rawValue, at: renderTime) { p.genSat = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.genBright.rawValue, at: renderTime) { p.genBright = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SynthParamID.genBands.rawValue, at: renderTime) { p.genBands = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SynthParamID.blendWithSource.rawValue, at: renderTime) { p.blendWithSource = Float(fVal) }

        p.time = Float(CMTimeGetSeconds(renderTime))
        pluginState.pointee = try p.encode() as NSData
    }

    public func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImages: [FxImage], destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        if let src = sourceImages.first, src.responds(to: #selector(getter: FxImage.width)), src.responds(to: #selector(getter: FxImage.height)) {
            let w = Int32(src.width)
            let h = Int32(src.height)
            destinationImageRect.pointee = FxRect(left: 0, bottom: 0, right: w > 0 ? w : 1920, top: h > 0 ? h : 1080)
        } else {
            destinationImageRect.pointee = FxRect(left: 0, bottom: 0, right: 1920, top: 1080)
        }
    }

    public func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImages: [FxImage], destinationTileRect: FxRect, destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        sourceTileRect.pointee = destinationTileRect
    }

    public func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? SynthParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        try BENDRSynthRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}
