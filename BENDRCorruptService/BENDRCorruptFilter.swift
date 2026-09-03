// BENDRCorruptFilter.swift — FxTileableEffect implementation for BENDR Corrupt

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRCorruptFilter)
public class BENDRCorruptFilter: NSObject, FxTileableEffect {

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

        // Group 1: Glitch & Sorting
        parmsApi.startParameterSubGroup("Glitch & Sorting", parameterID: CorruptParamID.groupGlitch.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pixel Sort", parameterID: CorruptParamID.pixelSort.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Sort Threshold", parameterID: CorruptParamID.sortThresh.rawValue, defaultValue: 0.45, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Block Shift", parameterID: CorruptParamID.blockShift.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Block Size", parameterID: CorruptParamID.blockSize.rawValue, defaultValue: 0.35, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Halftone Dot", parameterID: CorruptParamID.dotify.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dot Size", parameterID: CorruptParamID.dotSize.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Warp & Modulation
        parmsApi.startParameterSubGroup("Warp & Modulation", parameterID: CorruptParamID.groupWarp.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Drift Warp", parameterID: CorruptParamID.driftWarp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "FM Warp", parameterID: CorruptParamID.fmWarp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: DCT Compression
        parmsApi.startParameterSubGroup("DCT Compression", parameterID: CorruptParamID.groupDCT.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "DCT Amount", parameterID: CorruptParamID.dctAmt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Quantization", parameterID: CorruptParamID.dctQ.rawValue, defaultValue: 0.25, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Block Scale", parameterID: CorruptParamID.dctBlock.rawValue, defaultValue: 0.35, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = CorruptParams()
        var fVal: Double = 0.0

        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.pixelSort.rawValue, at: renderTime) { p.pixelSort = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.sortThresh.rawValue, at: renderTime) { p.sortThresh = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.blockShift.rawValue, at: renderTime) { p.blockShift = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.blockSize.rawValue, at: renderTime) { p.blockSize = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.dotify.rawValue, at: renderTime) { p.dotify = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.dotSize.rawValue, at: renderTime) { p.dotSize = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.driftWarp.rawValue, at: renderTime) { p.driftWarp = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.fmWarp.rawValue, at: renderTime) { p.fmWarp = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.dctAmt.rawValue, at: renderTime) { p.dctAmt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.dctQ.rawValue, at: renderTime) { p.dctQ = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CorruptParamID.dctBlock.rawValue, at: renderTime) { p.dctBlock = Float(fVal) }

        p.time = Float(CMTimeGetSeconds(renderTime))
        pluginState.pointee = try p.encode() as NSData
    }

    public func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImages: [Any], destinationImage: Any, pluginState: Data?, at renderTime: CMTime) throws {
        // FCP sends FxImageTile objects at runtime despite the protocol declaring FxImage
        if let tile = sourceImages.first as? FxImageTile {
            destinationImageRect.pointee = tile.imagePixelBounds
        } else if let img = sourceImages.first as? FxImage {
            destinationImageRect.pointee = img.bounds
        } else {
            destinationImageRect.pointee = FxRect(left: 0, bottom: 0, right: 1920, top: 1080)
        }
    }

    public func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImages: [Any], destinationTileRect: FxRect, destinationImage: Any, pluginState: Data?, at renderTime: CMTime) throws {
        sourceTileRect.pointee = destinationTileRect
    }

    public func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? CorruptParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        try BENDRCorruptRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}
