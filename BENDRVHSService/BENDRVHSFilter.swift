// BENDRVHSFilter.swift — FxTileableEffect implementation for BENDR VHS

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRVHSFilter)
public class BENDRVHSFilter: NSObject, FxTileableEffect {

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

        // Group 1: Tape & Transport
        parmsApi.addFloatSlider(withName: "Tape Speed", parameterID: VHSParamID.tapeSpeed.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tracking Error", parameterID: VHSParamID.tracking.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tracking Phase", parameterID: VHSParamID.trackPhase.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tracking Hunt", parameterID: VHSParamID.trackHunt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Head Switch", parameterID: VHSParamID.headSwitch.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tape Wow", parameterID: VHSParamID.tapeWow.rawValue, defaultValue: 0.15, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Wow Rate", parameterID: VHSParamID.wowRate.rawValue, defaultValue: 0.25, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Flutter", parameterID: VHSParamID.flutter.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tape Stretch", parameterID: VHSParamID.tapeStretch.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Edge Damage", parameterID: VHSParamID.edgeDmg.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dropout Level", parameterID: VHSParamID.dropout.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dropout Length", parameterID: VHSParamID.dropoutLen.rawValue, defaultValue: 0.35, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tape Crease", parameterID: VHSParamID.crease.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Crease Position", parameterID: VHSParamID.creasePos.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Head Clog", parameterID: VHSParamID.headClog.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Azimuth Error", parameterID: VHSParamID.azimuth.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gen Loss", parameterID: VHSParamID.genLoss.rawValue, defaultValue: 0.1, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Gen Count", parameterID: VHSParamID.genCount.rawValue, defaultValue: 1.0, parameterMin: 1.0, parameterMax: 10.0, sliderMin: 1.0, sliderMax: 10.0, delta: 1.0, parameterFlags: 0)

        // Group 2: RF & Signal Noise
        parmsApi.addFloatSlider(withName: "Chroma Bleed", parameterID: VHSParamID.chromaBleed.rawValue, defaultValue: 0.25, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Chroma Delay", parameterID: VHSParamID.chromaDelay.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Luma Bleed", parameterID: VHSParamID.lumaBleed.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Bleed Direction", parameterID: VHSParamID.bleedDir.rawValue, defaultValue: 0.5, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Vertical Bleed", parameterID: VHSParamID.vBleed.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Rainbowing", parameterID: VHSParamID.rainbow.rawValue, defaultValue: 0.1, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Dot Crawl", parameterID: VHSParamID.dotCrawl.rawValue, defaultValue: 0.1, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Ringing", parameterID: VHSParamID.ringing.rawValue, defaultValue: 0.15, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Signal Noise", parameterID: VHSParamID.signalNoise.rawValue, defaultValue: 0.05, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Chroma Noise", parameterID: VHSParamID.chromaNoise.rawValue, defaultValue: 0.05, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Chroma Loss", parameterID: VHSParamID.chromaLoss.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Print-Through", parameterID: VHSParamID.printThru.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tape Hiss", parameterID: VHSParamID.hiss.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)

        // Group 3: Sync & Timebase
        parmsApi.addFloatSlider(withName: "H-Wobble", parameterID: VHSParamID.hWobble.rawValue, defaultValue: 0.05, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Wobble Freq", parameterID: VHSParamID.wobbleFreq.rawValue, defaultValue: 0.2, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Sync Tear", parameterID: VHSParamID.tear.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tear Size", parameterID: VHSParamID.tearSize.rawValue, defaultValue: 0.4, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "V-Roll", parameterID: VHSParamID.vRoll.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Sync Jitter", parameterID: VHSParamID.jitter.rawValue, defaultValue: 0.1, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Hum Bar", parameterID: VHSParamID.humBar.rawValue, defaultValue: 0.1, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
    }

    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)
    }

    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }

        var p = VHSParams()
        var fVal: Double = 0.0

        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.tapeSpeed.rawValue, at: renderTime) { p.tapeSpeed = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.tracking.rawValue, at: renderTime) { p.tracking = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.trackPhase.rawValue, at: renderTime) { p.trackPhase = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.trackHunt.rawValue, at: renderTime) { p.trackHunt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.headSwitch.rawValue, at: renderTime) { p.headSwitch = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.tapeWow.rawValue, at: renderTime) { p.tapeWow = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.wowRate.rawValue, at: renderTime) { p.wowRate = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.flutter.rawValue, at: renderTime) { p.flutter = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.tapeStretch.rawValue, at: renderTime) { p.tapeStretch = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.edgeDmg.rawValue, at: renderTime) { p.edgeDmg = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.dropout.rawValue, at: renderTime) { p.dropout = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.dropoutLen.rawValue, at: renderTime) { p.dropoutLen = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.crease.rawValue, at: renderTime) { p.crease = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.creasePos.rawValue, at: renderTime) { p.creasePos = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.headClog.rawValue, at: renderTime) { p.headClog = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.azimuth.rawValue, at: renderTime) { p.azimuth = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.genLoss.rawValue, at: renderTime) { p.genLoss = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.genCount.rawValue, at: renderTime) { p.genCount = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.chromaBleed.rawValue, at: renderTime) { p.chromaBleed = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.chromaDelay.rawValue, at: renderTime) { p.chromaDelay = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.lumaBleed.rawValue, at: renderTime) { p.lumaBleed = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.bleedDir.rawValue, at: renderTime) { p.bleedDir = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.vBleed.rawValue, at: renderTime) { p.vBleed = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.rainbow.rawValue, at: renderTime) { p.rainbow = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.dotCrawl.rawValue, at: renderTime) { p.dotCrawl = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.ringing.rawValue, at: renderTime) { p.ringing = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.signalNoise.rawValue, at: renderTime) { p.signalNoise = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.chromaNoise.rawValue, at: renderTime) { p.chromaNoise = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.chromaLoss.rawValue, at: renderTime) { p.chromaLoss = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.printThru.rawValue, at: renderTime) { p.printThru = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.hiss.rawValue, at: renderTime) { p.hiss = Float(fVal) }

        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.hWobble.rawValue, at: renderTime) { p.hWobble = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.wobbleFreq.rawValue, at: renderTime) { p.wobbleFreq = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.tear.rawValue, at: renderTime) { p.tear = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.tearSize.rawValue, at: renderTime) { p.tearSize = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.vRoll.rawValue, at: renderTime) { p.vRoll = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.jitter.rawValue, at: renderTime) { p.jitter = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: VHSParamID.humBar.rawValue, at: renderTime) { p.humBar = Float(fVal) }

        let t = Float(CMTimeGetSeconds(renderTime))
        p.time = t
        p.frame = t * 30.0
        p.humpos = Float(fmod(Double(t) * 0.25, 1.0))
        p.vrollpos = Float(fmod(Double(p.vRoll) * Double(t) * 0.5, 1.0))
        
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
              let params = try? VHSParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }

        try BENDRVHSRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}