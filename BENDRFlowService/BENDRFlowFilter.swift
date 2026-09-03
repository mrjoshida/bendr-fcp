// BENDRFlowFilter.swift — FxTileableEffect implementation for BENDR Flow

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRFlowFilter)
public class BENDRFlowFilter: NSObject, FxTileableEffect {

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

        // Group 1: Vector Field & Advection
        parmsApi.startParameterSubGroup("Vector Field & Advection", parameterID: FlowParamID.groupField.rawValue, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Vector Field", parameterID: FlowParamID.flowField.rawValue, defaultValue: 0, menuEntries: [
            "Motion (Optical Flow)",
            "Contour Gradient",
            "Curl Noise",
            "Radial",
            "Spiral",
            "Chroma Drift",
            "Weave"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "P-Frame Push", parameterID: FlowParamID.moshVec.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Field Velocity", parameterID: FlowParamID.flowGain.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 3.0, sliderMin: 0.0, sliderMax: 3.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Field Curl (Orbit)", parameterID: FlowParamID.flowCurl.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Edge Wrap Mode", parameterID: FlowParamID.flowEdge.rawValue, defaultValue: 0, menuEntries: [
            "Clamp",
            "Wrap / Repeat",
            "Mirror"
        ], parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Mosh & Persistence
        parmsApi.startParameterSubGroup("Mosh & Persistence", parameterID: FlowParamID.groupPersistence.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Mosh Hold", parameterID: FlowParamID.mosh.rawValue, defaultValue: 0.7, parameterMin: 0.0, parameterMax: 0.99, sliderMin: 0.0, sliderMax: 0.99, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Mosh Gate", parameterID: FlowParamID.moshGate.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Time Shear", parameterID: FlowParamID.timeGrad.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Shear Axis", parameterID: FlowParamID.shearAxis.rawValue, defaultValue: 0, menuEntries: [
            "Vertical",
            "Horizontal"
        ], parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: Melt & Swirl Dynamics
        parmsApi.startParameterSubGroup("Melt & Swirl Dynamics", parameterID: FlowParamID.groupDynamics.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gravity Melt", parameterID: FlowParamID.melt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Angle", parameterID: FlowParamID.meltDir.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Melt Gate", parameterID: FlowParamID.meltGate.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Swirl Turbulence", parameterID: FlowParamID.swirl.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Swirl Scale", parameterID: FlowParamID.swirlScale.rawValue, defaultValue: 0.18, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Swirl Speed", parameterID: FlowParamID.swirlSpeed.rawValue, defaultValue: 0.08, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 4: Glitch & Texture
        parmsApi.startParameterSubGroup("Glitch & Texture", parameterID: FlowParamID.groupGlitch.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Vector Trash", parameterID: FlowParamID.moshBlock.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Trash Block Size", parameterID: FlowParamID.moshBlockSize.rawValue, defaultValue: 0.68, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Trash Rate", parameterID: FlowParamID.moshRate.rawValue, defaultValue: 0.13, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Center Stretch", parameterID: FlowParamID.flowStretch.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Edge Repel", parameterID: FlowParamID.flowRepel.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Flow Noise", parameterID: FlowParamID.flowNoise.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Re-Sharpen", parameterID: FlowParamID.flowSharp.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Hue Shift / Pass", parameterID: FlowParamID.flowHue.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Decay / Pass", parameterID: FlowParamID.flowFade.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        // Schedule current frame
        scheduleInputsRequest.addInput(0, with: requestTime)

        // Schedule previous frame for motion estimation and advection history
        let frameDuration = CMTime(value: 1001, timescale: 30000)
        let prevTime = CMTimeSubtract(requestTime, frameDuration)
        scheduleInputsRequest.addInput(0, with: prevTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = FlowParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getIntValue(&iVal, fromParameter: FlowParamID.flowField.rawValue, at: renderTime) { p.flowField = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.moshVec.rawValue, at: renderTime) { p.moshVec = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowGain.rawValue, at: renderTime) { p.flowGain = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowCurl.rawValue, at: renderTime) { p.flowCurl = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FlowParamID.flowEdge.rawValue, at: renderTime) { p.flowEdge = Float(iVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.mosh.rawValue, at: renderTime) { p.mosh = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.moshGate.rawValue, at: renderTime) { p.moshGate = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.timeGrad.rawValue, at: renderTime) { p.timeGrad = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: FlowParamID.shearAxis.rawValue, at: renderTime) { p.shearAxis = Float(iVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.melt.rawValue, at: renderTime) { p.melt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.meltDir.rawValue, at: renderTime) { p.meltDir = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.meltGate.rawValue, at: renderTime) { p.meltGate = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.swirl.rawValue, at: renderTime) { p.swirl = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.swirlScale.rawValue, at: renderTime) { p.swirlScale = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.swirlSpeed.rawValue, at: renderTime) { p.swirlSpeed = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.moshBlock.rawValue, at: renderTime) { p.moshBlock = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.moshBlockSize.rawValue, at: renderTime) { p.moshBlockSize = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.moshRate.rawValue, at: renderTime) { p.moshRate = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowStretch.rawValue, at: renderTime) { p.flowStretch = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowRepel.rawValue, at: renderTime) { p.flowRepel = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowNoise.rawValue, at: renderTime) { p.flowNoise = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowSharp.rawValue, at: renderTime) { p.flowSharp = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowHue.rawValue, at: renderTime) { p.flowHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: FlowParamID.flowFade.rawValue, at: renderTime) { p.flowFade = Float(fVal) }

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
              let params = try? FlowParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        let prevFlowTile = sourceImages.count > 1 ? sourceImages[1] : srcTile
        let prevSrcTile = sourceImages.count > 1 ? sourceImages[1] : srcTile
        try BENDRFlowRenderer.render(destination: destinationImage, source: srcTile, previousFlow: prevFlowTile, previousSource: prevSrcTile, params: params)
    }
}
