// BENDRDirtyFilter.swift — FxTileableEffect implementation for BENDR Dirty

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRDirtyFilter)
public class BENDRDirtyFilter: NSObject, FxTileableEffect {

    private let apiManager: PROAPIAccessing

    @objc(initWithAPIManager:)
    public required init(apiManager: PROAPIAccessing) {
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

        // Group 1: Fault Engine
        parmsApi.startParameterSubGroup("Fault Engine", parameterID: DirtyParamID.groupEngine.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dirt Amount", parameterID: DirtyParamID.mixDirt.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Clock Rate", parameterID: DirtyParamID.mixDirtRate.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Fault Manifestation
        parmsApi.startParameterSubGroup("Fault Manifestation", parameterID: DirtyParamID.groupManifestation.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Timebase Knock", parameterID: DirtyParamID.mixDirtKnock.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Line Dropouts", parameterID: DirtyParamID.mixDirtDrop.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Cut / Flash", parameterID: DirtyParamID.mixDirtCut.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Transient Noise", parameterID: DirtyParamID.mixDirtNoise.rawValue, defaultValue: 0.35, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ request: UnsafeMutablePointer<FxScheduleInputsRequest>, with pluginState: Data?, at time: CMTime) throws {
        request.addInput(0, with: time)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData>?, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = DirtyParams()
        var fVal: Double = 0.0

        if parmsApi.getFloatValue(&fVal, fromParameter: DirtyParamID.mixDirt.rawValue, at: renderTime) { p.mixDirt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: DirtyParamID.mixDirtRate.rawValue, at: renderTime) { p.mixDirtRate = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: DirtyParamID.mixDirtKnock.rawValue, at: renderTime) { p.mixDirtKnock = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: DirtyParamID.mixDirtDrop.rawValue, at: renderTime) { p.mixDirtDrop = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: DirtyParamID.mixDirtCut.rawValue, at: renderTime) { p.mixDirtCut = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: DirtyParamID.mixDirtNoise.rawValue, at: renderTime) { p.mixDirtNoise = Float(fVal) }

        p.time = Float(CMTimeGetSeconds(renderTime))
        pluginState?.pointee = try p.encode() as NSData
    }

    public func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImages: [FxImage], destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        destinationImageRect.pointee = FxRect(left: 0, bottom: 0, right: Int32(destinationImage.width), top: Int32(destinationImage.height))
    }

    public func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImages: [FxImage], destinationTileRect: FxRect, destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws {
        sourceTileRect.pointee = destinationTileRect
    }

    public func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws {
        guard let pluginState = pluginState,
              let params = try? DirtyParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        try BENDRDirtyRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}
