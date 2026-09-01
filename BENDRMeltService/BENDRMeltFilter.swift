// BENDRMeltFilter.swift — FxTileableEffect implementation for BENDR Melt

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRMeltFilter)
public class BENDRMeltFilter: NSObject, FxTileableEffect {

    private let apiManager: PROAPIAccessing

    @objc public required init(apiManager: PROAPIAccessing) {
        self.apiManager = apiManager
        super.init()
    }

    public func properties(_ properties: AutoreleasingUnsafeMutablePointer<NSDictionary>?) throws {
        properties?.pointee = [
            kFxPropertyKey_MayRemapTime: true,
            kFxPropertyKey_PixelTransformSupport: kFxPixelTransform_Supported,
            kFxPropertyKey_NeedsFullBuffer: true
        ] as NSDictionary
    }

    public func addParameters() throws {
        guard let parmsApi = apiManager.api(for: FxParameterCreationAPI_v5.self) as? FxParameterCreationAPI_v5 else {
            return
        }

        // Group 1: Dynamics & Mode
        parmsApi.startParameterGroup("Melt Dynamics", parameterID: MeltParamID.groupDynamics.rawValue, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Melt Mode", parameterID: MeltParamID.meltMode.rawValue, defaultValue: 0, menuEntries: [
            "Edge Smear",
            "Spiral Feedback",
            "Motion Driven",
            "Gravity Melt"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Amount", parameterID: MeltParamID.edgeAmt.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 2.0, sliderMin: 0.0, sliderMax: 2.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Hold", parameterID: MeltParamID.edgeHold.rawValue, defaultValue: 0.6, parameterMin: 0.0, parameterMax: 1.5, sliderMin: 0.0, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Width", parameterID: MeltParamID.edgeWidth.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 2.0, sliderMin: 0.0, sliderMax: 2.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Creep", parameterID: MeltParamID.edgeCreep.rawValue, defaultValue: 0.35, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterGroup()

        // Group 2: Spatial & Spiral
        parmsApi.startParameterGroup("Spatial & Spiral", parameterID: MeltParamID.groupSpatial.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Swirl", parameterID: MeltParamID.edgeSwirl.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Zoom", parameterID: MeltParamID.meltZoom.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Angle", parameterID: MeltParamID.meltDir.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Luma Gate", parameterID: MeltParamID.meltGate.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterGroup()

        // Group 3: Color & Diffusion
        parmsApi.startParameterGroup("Color & Diffusion", parameterID: MeltParamID.groupColor.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Soften", parameterID: MeltParamID.meltSoft.rawValue, defaultValue: 0.35, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Chroma Bleed", parameterID: MeltParamID.edgeChroma.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Hue Shift", parameterID: MeltParamID.meltHue.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterGroup()
    }

    public func scheduleInputs(_ request: inout FxScheduleInputsRequest, with pluginState: Data?, at time: CMTime) throws {
        // Schedule current frame
        request.addInput(0, with: time)

        // Schedule previous frame for temporal feedback / motion modes
        let frameDuration = CMTime(value: 1001, timescale: 30000)
        let prevTime = CMTimeSubtract(time, frameDuration)
        request.addInput(0, with: prevTime)
    }

    public func pluginState(at renderTime: CMTime, quality qualityLevel: UInt) throws -> Data {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return Data()
        }

        var p = MeltParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getIntValue(&iVal, fromParameter: MeltParamID.meltMode.rawValue, at: renderTime) { p.meltMode = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.edgeAmt.rawValue, at: renderTime) { p.edgeAmt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.edgeHold.rawValue, at: renderTime) { p.edgeHold = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.edgeWidth.rawValue, at: renderTime) { p.edgeWidth = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.edgeCreep.rawValue, at: renderTime) { p.edgeCreep = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.edgeSwirl.rawValue, at: renderTime) { p.edgeSwirl = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.meltZoom.rawValue, at: renderTime) { p.meltZoom = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.meltDir.rawValue, at: renderTime) { p.meltDir = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.meltGate.rawValue, at: renderTime) { p.meltGate = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.meltSoft.rawValue, at: renderTime) { p.meltSoft = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.edgeChroma.rawValue, at: renderTime) { p.edgeChroma = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: MeltParamID.meltHue.rawValue, at: renderTime) { p.meltHue = Float(fVal) }

        p.time = Float(CMTimeGetSeconds(renderTime))
        return try p.encode()
    }

    public func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImageRects: [NSValue], pluginState: Data?, at renderTime: CMTime) throws {
        guard let sourceRect = sourceImageRects.first?.rectValue else { return }
        destinationImageRect.pointee = sourceRect
    }

    public func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImageRect: FxRect, destinationTileRect: FxRect, destinationImageRect: FxRect, pluginState: Data?, at renderTime: CMTime) throws {
        sourceTileRect.pointee = sourceImageRect
    }

    public func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? MeltParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        let prevTile = sourceImages.count > 1 ? sourceImages[1] : srcTile
        try BENDRMeltRenderer.render(destination: destinationImage, source: srcTile, previous: prevTile, params: params)
    }
}
