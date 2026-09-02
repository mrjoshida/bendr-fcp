// BENDROpticsFilter.swift — FxTileableEffect implementation for BENDR Optics

import Foundation
import FxPlug
import CoreMedia

@objc(BENDROpticsFilter)
public class BENDROpticsFilter: NSObject, FxTileableEffect {

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

        // Group 1: Lens & Optics
        parmsApi.startParameterSubGroup("Lens & Optics", parameterID: OpticsParamID.groupLens.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Chromatic Aberration", parameterID: OpticsParamID.lensCA.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Anamorphic Streak", parameterID: OpticsParamID.lensStreak.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Streak Coating Tint", parameterID: OpticsParamID.streakHue.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Highlight Bloom", parameterID: OpticsParamID.bloom.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Bloom Radius", parameterID: OpticsParamID.bloomRad.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Film Halation", parameterID: OpticsParamID.halation.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Lens Vignette", parameterID: OpticsParamID.vignette.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Film & Glass Texture
        parmsApi.startParameterSubGroup("Film & Glass Texture", parameterID: OpticsParamID.groupTexture.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dirty Glass Smudge", parameterID: OpticsParamID.lensSmudge.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Film Light Leak", parameterID: OpticsParamID.lightLeak.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Leak Color", parameterID: OpticsParamID.leakHue.rawValue, defaultValue: 0.08, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gate Hair", parameterID: OpticsParamID.gateHair.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dust & Lint", parameterID: OpticsParamID.dust.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Film Scratches", parameterID: OpticsParamID.scratches.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Film Grain", parameterID: OpticsParamID.grain.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: Display & Retro HUD
        parmsApi.startParameterSubGroup("Display & Retro HUD", parameterID: OpticsParamID.groupDisplay.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "LCD Subpixel Grid", parameterID: OpticsParamID.lcdGrid.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Camcorder OSD", parameterID: OpticsParamID.osdShow.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "OSD Mode", parameterID: OpticsParamID.osdMode.rawValue, defaultValue: 0, menuEntries: [
            "REC + Timecode",
            "Playback HUD",
            "Tape Counter"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "OSD Glow", parameterID: OpticsParamID.osdGlow.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ request: inout FxScheduleInputsRequest, with pluginState: Data?, at time: CMTime) throws {
        request.addInput(0, with: time)
    }

    public func pluginState(at renderTime: CMTime, quality qualityLevel: UInt) throws -> Data {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return Data()
        }

        var p = OpticsParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.lensCA.rawValue, at: renderTime) { p.lensCA = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.lensStreak.rawValue, at: renderTime) { p.lensStreak = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.streakHue.rawValue, at: renderTime) { p.streakHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.bloom.rawValue, at: renderTime) { p.bloom = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.bloomRad.rawValue, at: renderTime) { p.bloomRad = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.halation.rawValue, at: renderTime) { p.halation = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.vignette.rawValue, at: renderTime) { p.vignette = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.lensSmudge.rawValue, at: renderTime) { p.lensSmudge = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.lightLeak.rawValue, at: renderTime) { p.lightLeak = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.leakHue.rawValue, at: renderTime) { p.leakHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.gateHair.rawValue, at: renderTime) { p.gateHair = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.dust.rawValue, at: renderTime) { p.dust = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.scratches.rawValue, at: renderTime) { p.scratches = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.grain.rawValue, at: renderTime) { p.grain = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.lcdGrid.rawValue, at: renderTime) { p.lcdGrid = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.osdShow.rawValue, at: renderTime) { p.osdShow = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: OpticsParamID.osdMode.rawValue, at: renderTime) { p.osdMode = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: OpticsParamID.osdGlow.rawValue, at: renderTime) { p.osdGlow = Float(fVal) }

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
              let params = try? OpticsParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        try BENDROpticsRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}
