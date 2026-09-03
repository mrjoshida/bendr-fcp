// BENDRCRTFilter.swift — FxTileableEffect implementation for BENDR CRT

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRCRTFilter)
public class BENDRCRTFilter: NSObject, FxTileableEffect {

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

        // Group 1: Monitor & Geometry
        parmsApi.startParameterSubGroup("Monitor & Geometry", parameterID: CRTParamID.groupMonitor.rawValue, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Display Type", parameterID: CRTParamID.outModel.rawValue, defaultValue: 1, menuEntries: [
            "None",
            "Aperture Grille (Trinitron)",
            "Slot Mask",
            "Dot Triad",
            "Monochrome / B&W"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Scanlines", parameterID: CRTParamID.scanlines.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Mask Darkness", parameterID: CRTParamID.maskDark.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Screen Curvature", parameterID: CRTParamID.curvature.rawValue, defaultValue: 0.15, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Corner Rounding", parameterID: CRTParamID.cornerRound.rawValue, defaultValue: 0.1, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Vignette", parameterID: CRTParamID.vignette.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Phosphor & Optics
        parmsApi.startParameterSubGroup("Phosphor & Optics", parameterID: CRTParamID.groupPhosphor.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Phosphor Trail", parameterID: CRTParamID.phosphor.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Beam Bloom", parameterID: CRTParamID.bloom.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Bloom Radius", parameterID: CRTParamID.bloomRad.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Halation", parameterID: CRTParamID.halation.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: Color & Picture
        parmsApi.startParameterSubGroup("Color & Picture", parameterID: CRTParamID.groupPicture.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gamma", parameterID: CRTParamID.outGamma.rawValue, defaultValue: 1.0, parameterMin: 0.2, parameterMax: 2.5, sliderMin: 0.2, sliderMax: 2.5, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Brightness", parameterID: CRTParamID.outBright.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Contrast", parameterID: CRTParamID.outContrast.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 2.0, sliderMin: 0.0, sliderMax: 2.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Saturation", parameterID: CRTParamID.outSat.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 2.0, sliderMin: 0.0, sliderMax: 2.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Color Warmth", parameterID: CRTParamID.outWarmth.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "White Clip", parameterID: CRTParamID.whiteClip.rawValue, defaultValue: 1.0, parameterMin: 0.5, parameterMax: 1.5, sliderMin: 0.5, sliderMax: 1.5, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 4: Glass & Overlays
        parmsApi.startParameterSubGroup("Glass & Overlays", parameterID: CRTParamID.groupOverlays.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Bezel Frame", parameterID: CRTParamID.bezel.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Glass Reflection", parameterID: CRTParamID.glassRefl.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dust Particles", parameterID: CRTParamID.dust.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Surface Scratches", parameterID: CRTParamID.scratches.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Phosphor Grain", parameterID: CRTParamID.grain.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "OSD Channel", parameterID: CRTParamID.osdShow.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)

        // Previous frame for phosphor decay / interlace
        let frameDuration = CMTime(value: 1001, timescale: 30000)
        let prevTime = CMTimeSubtract(requestTime, frameDuration)
        scheduleInputsRequest.addInput(0, with: prevTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = CRTParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getIntValue(&iVal, fromParameter: CRTParamID.outModel.rawValue, at: renderTime) { p.outModel = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.scanlines.rawValue, at: renderTime) { p.scanlines = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.maskDark.rawValue, at: renderTime) { p.maskDark = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.curvature.rawValue, at: renderTime) { p.curvature = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.cornerRound.rawValue, at: renderTime) { p.cornerRound = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.vignette.rawValue, at: renderTime) { p.vignette = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.phosphor.rawValue, at: renderTime) { p.phosphor = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.bloom.rawValue, at: renderTime) { p.bloom = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.bloomRad.rawValue, at: renderTime) { p.bloomRad = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.halation.rawValue, at: renderTime) { p.halation = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.outGamma.rawValue, at: renderTime) { p.outGamma = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.outBright.rawValue, at: renderTime) { p.outBright = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.outContrast.rawValue, at: renderTime) { p.outContrast = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.outSat.rawValue, at: renderTime) { p.outSat = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.outWarmth.rawValue, at: renderTime) { p.outWarmth = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.whiteClip.rawValue, at: renderTime) { p.whiteClip = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.bezel.rawValue, at: renderTime) { p.bezel = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.glassRefl.rawValue, at: renderTime) { p.glassRefl = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.dust.rawValue, at: renderTime) { p.dust = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.scratches.rawValue, at: renderTime) { p.scratches = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.grain.rawValue, at: renderTime) { p.grain = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: CRTParamID.osdShow.rawValue, at: renderTime) { p.osdShow = Float(fVal) }

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
              let params = try? CRTParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        let prevTile = sourceImages.count > 1 ? sourceImages[1] : srcTile
        try BENDRCRTRenderer.render(destination: destinationImage, source: srcTile, previous: prevTile, params: params)
    }
}
