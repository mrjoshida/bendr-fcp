// BENDRSpatialFilter.swift — FxTileableEffect implementation for BENDR Spatial

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRSpatialFilter)
public class BENDRSpatialFilter: NSObject, FxTileableEffect {

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

        // Group 1: Framing & Geometry
        parmsApi.addFloatSlider(withName: "Zoom", parameterID: SpatialParamID.srcZoom.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pan X", parameterID: SpatialParamID.srcX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pan Y", parameterID: SpatialParamID.srcY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Rotate", parameterID: SpatialParamID.srcRot.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Flip", parameterID: SpatialParamID.flipMode.rawValue, defaultValue: 0, menuEntries: [
            "None", "Flip Horizontal", "Flip Vertical", "Flip Both"
        ], parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Mirror", parameterID: SpatialParamID.mirrorMode.rawValue, defaultValue: 0, menuEntries: [
            "None", "Mirror Horizontal", "Mirror Vertical", "Mirror 4-Way"
        ], parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Multi-Grid", parameterID: SpatialParamID.multiN.rawValue, defaultValue: 1, parameterMin: 1, parameterMax: 8, sliderMin: 1, sliderMax: 8, delta: 1, parameterFlags: 0)

        // Group 2: Kaleidoscope Symmetries
        parmsApi.addFloatSlider(withName: "Kaleidoscope", parameterID: SpatialParamID.kaleido.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Fold Count", parameterID: SpatialParamID.kaleidoN.rawValue, defaultValue: 3, parameterMin: 2, parameterMax: 12, sliderMin: 2, sliderMax: 12, delta: 1, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Fold Spin", parameterID: SpatialParamID.kaleidoRot.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Fold Center X", parameterID: SpatialParamID.kaleidoX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Fold Center Y", parameterID: SpatialParamID.kaleidoY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)

        // Group 3: Camera Shake
        parmsApi.addFloatSlider(withName: "Shake Intensity", parameterID: SpatialParamID.shake.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Shake Rate", parameterID: SpatialParamID.shakeRate.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)

        // Group 4: Time Displacement
        parmsApi.addFloatSlider(withName: "Time Displace", parameterID: SpatialParamID.tdAmt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Displacement Map", parameterID: SpatialParamID.tdMap.rawValue, defaultValue: 0, menuEntries: [
            "Slitscan Vertical", "Sweep Horizontal", "Luminance Lag", "Radial Lag", "Failing TBC Scanlines"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Frame Reach", parameterID: SpatialParamID.tdSpread.rawValue, defaultValue: 0.7, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Interpolation", parameterID: SpatialParamID.tdSoft.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Map Drift", parameterID: SpatialParamID.tdWarp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)

        // Schedule previous frame for time displacement
        let frameDuration = CMTime(value: 1001, timescale: 30000)
        let prevTime = CMTimeSubtract(requestTime, CMTimeMultiply(frameDuration, multiplier: 3))
        scheduleInputsRequest.addInput(0, with: prevTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = SpatialParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.srcZoom.rawValue, at: renderTime) { p.srcZoom = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.srcX.rawValue, at: renderTime) { p.srcX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.srcY.rawValue, at: renderTime) { p.srcY = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.srcRot.rawValue, at: renderTime) { p.srcRot = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SpatialParamID.flipMode.rawValue, at: renderTime) { p.flipMode = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SpatialParamID.mirrorMode.rawValue, at: renderTime) { p.mirrorMode = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SpatialParamID.multiN.rawValue, at: renderTime) { p.multiN = Float(iVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.kaleido.rawValue, at: renderTime) { p.kaleido = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SpatialParamID.kaleidoN.rawValue, at: renderTime) { p.kaleidoN = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.kaleidoRot.rawValue, at: renderTime) { p.kaleidoRot = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.kaleidoX.rawValue, at: renderTime) { p.kaleidoX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.kaleidoY.rawValue, at: renderTime) { p.kaleidoY = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.shake.rawValue, at: renderTime) { p.shake = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.shakeRate.rawValue, at: renderTime) { p.shakeRate = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.tdAmt.rawValue, at: renderTime) { p.tdAmt = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: SpatialParamID.tdMap.rawValue, at: renderTime) { p.tdMap = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.tdSpread.rawValue, at: renderTime) { p.tdSpread = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.tdSoft.rawValue, at: renderTime) { p.tdSoft = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: SpatialParamID.tdWarp.rawValue, at: renderTime) { p.tdWarp = Float(fVal) }

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
              let params = try? SpatialParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        let prevTile = sourceImages.count > 1 ? sourceImages[1] : srcTile
        try BENDRSpatialRenderer.render(destination: destinationImage, source: srcTile, previous: prevTile, params: params)
    }
}