// BENDRSignalLabFilter.swift — FxTileableEffect implementation for BENDR Signal Lab

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRSignalLabFilter)
public class BENDRSignalLabFilter: NSObject, FxTileableEffect {

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

        // Group 1: Raster Glitch & Displacement
        parmsApi.startParameterSubGroup("Raster Glitch & Displacement", parameterID: SignalLabParamID.groupRaster.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Sparse Jitter", parameterID: SignalLabParamID.sparseJit.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Jitter Gate", parameterID: SignalLabParamID.jitThresh.rawValue, defaultValue: 0.7, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "FM Wobble", parameterID: SignalLabParamID.fmAmt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "FM Carrier", parameterID: SignalLabParamID.fmCarrier.rawValue, defaultValue: 0.35, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Slitscan", parameterID: SignalLabParamID.slitscan.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Slitscan Axis", parameterID: SignalLabParamID.slitDir.rawValue, defaultValue: 0, menuEntries: [
            "Horizontal",
            "Vertical"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Row Smear", parameterID: SignalLabParamID.rowSmear.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Codec & Signal Breakdown
        parmsApi.startParameterSubGroup("Codec & Signal Breakdown", parameterID: SignalLabParamID.groupSignal.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Filter Avalanche", parameterID: SignalLabParamID.pngAmt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Avalanche Axis", parameterID: SignalLabParamID.pngDir.rawValue, defaultValue: 0, menuEntries: [
            "Sub (Horizontal)",
            "Up (Vertical)",
            "Average (Diagonal)"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Avalanche Run", parameterID: SignalLabParamID.pngRun.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "NTSC Artifacts", parameterID: SignalLabParamID.ntscArt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "NTSC Fringing", parameterID: SignalLabParamID.ntscFringe.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "CRT Snow", parameterID: SignalLabParamID.snow.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Snow Clumping", parameterID: SignalLabParamID.snowAniso.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Moire", parameterID: SignalLabParamID.moire.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Moire Frequency", parameterID: SignalLabParamID.moireFreq.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: Quantization & Field Mod
        parmsApi.startParameterSubGroup("Quantization & Field Mod", parameterID: SignalLabParamID.groupQuant.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "1-Bit Crush", parameterID: SignalLabParamID.bitCrush.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Crush Scale", parameterID: SignalLabParamID.bitScale.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Band Keyer", parameterID: SignalLabParamID.bandKey.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Band Count", parameterID: SignalLabParamID.bandN.rawValue, defaultValue: 5, parameterMin: 2, parameterMax: 12, sliderMin: 2, sliderMax: 12, delta: 1, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Band Hue", parameterID: SignalLabParamID.bandHue.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Field Mod Amount", parameterID: SignalLabParamID.fieldMod.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Field Source", parameterID: SignalLabParamID.fieldSrc.rawValue, defaultValue: 0, menuEntries: [
            "H-Ramp",
            "V-Ramp",
            "Radial",
            "Sine Wave",
            "Noise Field"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Field > Warp", parameterID: SignalLabParamID.fieldWarp.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Field > Hue", parameterID: SignalLabParamID.fieldHue.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = SignalLabParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.sparseJit.rawValue, at: renderTime) { p.sparseJit = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.jitThresh.rawValue, at: renderTime) { p.jitThresh = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.fmAmt.rawValue, at: renderTime) { p.fmAmt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.fmCarrier.rawValue, at: renderTime) { p.fmCarrier = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.slitscan.rawValue, at: renderTime) { p.slitscan = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SignalLabParamID.slitDir.rawValue, at: renderTime) { p.slitDir = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.rowSmear.rawValue, at: renderTime) { p.rowSmear = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.pngAmt.rawValue, at: renderTime) { p.pngAmt = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SignalLabParamID.pngDir.rawValue, at: renderTime) { p.pngDir = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.pngRun.rawValue, at: renderTime) { p.pngRun = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.ntscArt.rawValue, at: renderTime) { p.ntscArt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.ntscFringe.rawValue, at: renderTime) { p.ntscFringe = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.snow.rawValue, at: renderTime) { p.snow = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.snowAniso.rawValue, at: renderTime) { p.snowAniso = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.moire.rawValue, at: renderTime) { p.moire = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.moireFreq.rawValue, at: renderTime) { p.moireFreq = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.bitCrush.rawValue, at: renderTime) { p.bitCrush = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.bitScale.rawValue, at: renderTime) { p.bitScale = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.bandKey.rawValue, at: renderTime) { p.bandKey = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SignalLabParamID.bandN.rawValue, at: renderTime) { p.bandN = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.bandHue.rawValue, at: renderTime) { p.bandHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.fieldMod.rawValue, at: renderTime) { p.fieldMod = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SignalLabParamID.fieldSrc.rawValue, at: renderTime) { p.fieldSrc = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.fieldWarp.rawValue, at: renderTime) { p.fieldWarp = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SignalLabParamID.fieldHue.rawValue, at: renderTime) { p.fieldHue = Float(fVal) }

        p.time = Float(CMTimeGetSeconds(renderTime))
        pluginState.pointee = try p.encode() as NSData
    }

    public func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImages: [FxImage], destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        destinationImageRect.pointee = FxRect(left: 0, bottom: 0, right: Int32(destinationImage.width), top: Int32(destinationImage.height))
    }

    public func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImages: [FxImage], destinationTileRect: FxRect, destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        sourceTileRect.pointee = destinationTileRect
    }

    public func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? SignalLabParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        try BENDRSignalLabRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}
