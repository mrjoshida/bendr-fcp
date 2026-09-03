// BENDRColourFilter.swift — FxTileableEffect implementation for BENDR Colour

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRColourFilter)
public class BENDRColourFilter: NSObject, FxTileableEffect {

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

        // Group 1: Primary Color
        parmsApi.startParameterSubGroup("Primary Color", parameterID: ColourParamID.groupPrimary.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Red Gain", parameterID: ColourParamID.rGain.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 3.0, sliderMin: 0.0, sliderMax: 3.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Green Gain", parameterID: ColourParamID.gGain.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 3.0, sliderMin: 0.0, sliderMax: 3.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Blue Gain", parameterID: ColourParamID.bGain.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 3.0, sliderMin: 0.0, sliderMax: 3.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Saturation", parameterID: ColourParamID.saturation.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 3.0, sliderMin: 0.0, sliderMax: 3.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Hue Shift", parameterID: ColourParamID.hue.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Brightness", parameterID: ColourParamID.brightness.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Contrast", parameterID: ColourParamID.contrast.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 3.0, sliderMin: 0.0, sliderMax: 3.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 2: Color Effects
        parmsApi.startParameterSubGroup("Color Effects", parameterID: ColourParamID.groupEffects.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Posterize", parameterID: ColourParamID.posterize.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Solarize", parameterID: ColourParamID.solarize.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Negative", parameterID: ColourParamID.negative.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addPopupMenu(withName: "Negative Mode", parameterID: ColourParamID.negMode.rawValue, defaultValue: 0, menuEntries: [
            "RGB Invert", "Luma Only", "Chroma (IQ) Invert"
        ], parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Monochrome Tint", parameterID: ColourParamID.monoCol.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Mono Hue", parameterID: ColourParamID.monoHue.rawValue, defaultValue: 0.55, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Color Pass", parameterID: ColourParamID.colorPass.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pass Hue", parameterID: ColourParamID.passHue.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Pass Width", parameterID: ColourParamID.passWidth.rawValue, defaultValue: 0.25, parameterMin: 0.01, parameterMax: 1.0, sliderMin: 0.01, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Silhouette", parameterID: ColourParamID.silhouette.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Silhouette Threshold", parameterID: ColourParamID.silThresh.rawValue, defaultValue: 0.45, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Silhouette Hue", parameterID: ColourParamID.silHue.rawValue, defaultValue: 0.08, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Glow", parameterID: ColourParamID.glow.rawValue, defaultValue: 0.15, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 3: Edge & Relief
        parmsApi.startParameterSubGroup("Edge & Relief", parameterID: ColourParamID.groupEdge.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Find Edges", parameterID: ColourParamID.findEdge.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Edge Hue", parameterID: ColourParamID.edgeHue.rawValue, defaultValue: 0.45, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Emboss", parameterID: ColourParamID.emboss.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Emboss Direction", parameterID: ColourParamID.embossDir.rawValue, defaultValue: 0.12, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Differentiator", parameterID: ColourParamID.diffAmt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Diff Scale", parameterID: ColourParamID.diffScale.rawValue, defaultValue: 0.2, parameterMin: 0.01, parameterMax: 1.0, sliderMin: 0.01, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Amp Slicer", parameterID: ColourParamID.ampAmt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Amp Bands", parameterID: ColourParamID.ampBands.rawValue, defaultValue: 0.5, parameterMin: 0.1, parameterMax: 2.0, sliderMin: 0.1, sliderMax: 2.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 4: Bent Enhancer
        parmsApi.startParameterSubGroup("Bent Enhancer", parameterID: ColourParamID.groupEnhancer.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Colorize", parameterID: ColourParamID.colorize.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Color Bands", parameterID: ColourParamID.colorBands.rawValue, defaultValue: 1.5, parameterMin: 0.5, parameterMax: 10.0, sliderMin: 0.5, sliderMax: 10.0, delta: 0.1, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Color Sweep", parameterID: ColourParamID.colorSweep.rawValue, defaultValue: 0.15, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "RGB Separation", parameterID: ColourParamID.rgbSep.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Invert Flicker", parameterID: ColourParamID.invFlick.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 5: Contour & Dither
        parmsApi.startParameterSubGroup("Contour & Dither", parameterID: ColourParamID.groupContour.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Contour", parameterID: ColourParamID.contour.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Contour Bands", parameterID: ColourParamID.contourBands.rawValue, defaultValue: 10.0, parameterMin: 1.0, parameterMax: 32.0, sliderMin: 1.0, sliderMax: 32.0, delta: 1.0, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Contour Width", parameterID: ColourParamID.contourWidth.rawValue, defaultValue: 1.2, parameterMin: 0.5, parameterMax: 5.0, sliderMin: 0.5, sliderMax: 5.0, delta: 0.1, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Contour Hue", parameterID: ColourParamID.contourHue.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Contour Fill", parameterID: ColourParamID.contourFill.rawValue, defaultValue: 0.25, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Luma Quantize", parameterID: ColourParamID.lumaSteps.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Luma Step Count", parameterID: ColourParamID.stepCount.rawValue, defaultValue: 5.0, parameterMin: 2.0, parameterMax: 16.0, sliderMin: 2.0, sliderMax: 16.0, delta: 1.0, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dither", parameterID: ColourParamID.dither.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()

        // Group 6: Modulation Lines
        parmsApi.startParameterSubGroup("Modulation Lines", parameterID: ColourParamID.groupModulation.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Modulation", parameterID: ColourParamID.mline.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Line Scale", parameterID: ColourParamID.mlineScale.rawValue, defaultValue: 1.0, parameterMin: 0.2, parameterMax: 5.0, sliderMin: 0.2, sliderMax: 5.0, delta: 0.05, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Line Gain", parameterID: ColourParamID.mlineGain.rawValue, defaultValue: 1.15, parameterMin: 0.5, parameterMax: 3.0, sliderMin: 0.5, sliderMax: 3.0, delta: 0.05, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Line Feedback", parameterID: ColourParamID.mlineFb.rawValue, defaultValue: 0.92, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Line Window", parameterID: ColourParamID.mlineWin.rawValue, defaultValue: 32.0, parameterMin: 4.0, parameterMax: 128.0, sliderMin: 4.0, sliderMax: 128.0, delta: 1.0, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Line Color", parameterID: ColourParamID.mlineCol.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = ColourParams()
        var fVal: Double = 0.0
        var iVal: Int32 = 0

        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.rGain.rawValue, at: renderTime) { p.rGain = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.gGain.rawValue, at: renderTime) { p.gGain = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.bGain.rawValue, at: renderTime) { p.bGain = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.saturation.rawValue, at: renderTime) { p.saturation = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.hue.rawValue, at: renderTime) { p.hue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.brightness.rawValue, at: renderTime) { p.brightness = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.contrast.rawValue, at: renderTime) { p.contrast = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.posterize.rawValue, at: renderTime) { p.posterize = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.solarize.rawValue, at: renderTime) { p.solarize = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.negative.rawValue, at: renderTime) { p.negative = Float(fVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: ColourParamID.negMode.rawValue, at: renderTime) { p.negMode = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.monoCol.rawValue, at: renderTime) { p.monoCol = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.monoHue.rawValue, at: renderTime) { p.monoHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.colorPass.rawValue, at: renderTime) { p.colorPass = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.passHue.rawValue, at: renderTime) { p.passHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.passWidth.rawValue, at: renderTime) { p.passWidth = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.silhouette.rawValue, at: renderTime) { p.silhouette = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.silThresh.rawValue, at: renderTime) { p.silThresh = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.silHue.rawValue, at: renderTime) { p.silHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.glow.rawValue, at: renderTime) { p.glow = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.findEdge.rawValue, at: renderTime) { p.findEdge = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.edgeHue.rawValue, at: renderTime) { p.edgeHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.emboss.rawValue, at: renderTime) { p.emboss = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.embossDir.rawValue, at: renderTime) { p.embossDir = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.diffAmt.rawValue, at: renderTime) { p.diffAmt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.diffScale.rawValue, at: renderTime) { p.diffScale = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.ampAmt.rawValue, at: renderTime) { p.ampAmt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.ampBands.rawValue, at: renderTime) { p.ampBands = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.colorize.rawValue, at: renderTime) { p.colorize = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.colorBands.rawValue, at: renderTime) { p.colorBands = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.colorSweep.rawValue, at: renderTime) { p.colorSweep = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.rgbSep.rawValue, at: renderTime) { p.rgbSep = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.invFlick.rawValue, at: renderTime) { p.invFlick = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.contour.rawValue, at: renderTime) { p.contour = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.contourBands.rawValue, at: renderTime) { p.contourBands = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.contourWidth.rawValue, at: renderTime) { p.contourWidth = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.contourHue.rawValue, at: renderTime) { p.contourHue = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.contourFill.rawValue, at: renderTime) { p.contourFill = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.lumaSteps.rawValue, at: renderTime) { p.lumaSteps = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.stepCount.rawValue, at: renderTime) { p.stepCount = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.dither.rawValue, at: renderTime) { p.dither = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.mline.rawValue, at: renderTime) { p.mline = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.mlineScale.rawValue, at: renderTime) { p.mlineScale = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.mlineGain.rawValue, at: renderTime) { p.mlineGain = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.mlineFb.rawValue, at: renderTime) { p.mlineFb = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.mlineWin.rawValue, at: renderTime) { p.mlineWin = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ColourParamID.mlineCol.rawValue, at: renderTime) { p.mlineCol = Float(fVal) }

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
              let params = try? ColourParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        try BENDRColourRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}
