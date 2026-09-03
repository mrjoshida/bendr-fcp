// BENDRScanFilter.swift — FxTileableEffect implementation for BENDR Scan

import Foundation
import FxPlug
import CoreMedia

@objc(BENDRScanFilter)
public class BENDRScanFilter: NSObject, FxTileableEffect {
    
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
    
    public func scheduleInputs(_ scheduleInputsRequest: UnsafeMutablePointer<FxScheduleInputsRequest>, withPluginState pluginState: Data?, at requestTime: CMTime) throws {
        scheduleInputsRequest.addInput(0, with: requestTime)
    }
    
    public func addParameters() throws {
        guard let parmsApi = apiManager.api(for: FxParameterCreationAPI_v5.self) as? FxParameterCreationAPI_v5 else {
            return
        }
        
        parmsApi.startParameterSubGroup("Deflection & Raster", parameterID: ScanParamID.groupDeflection.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Scan Displace", parameterID: ScanParamID.scanAmt.rawValue, defaultValue: 0.5, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Scan Lines", parameterID: ScanParamID.scanLines.rawValue, defaultValue: 320, parameterMin: 60, parameterMax: 720, sliderMin: 60, sliderMax: 720, delta: 1, parameterFlags: 0)
        parmsApi.addIntSlider(withName: "Scan Detail", parameterID: ScanParamID.scanSamples.rawValue, defaultValue: 256, parameterMin: 64, parameterMax: 640, sliderMin: 64, sliderMax: 640, delta: 1, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Beam Width", parameterID: ScanParamID.scanWidth.rawValue, defaultValue: 0.12, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Velocity Gain", parameterID: ScanParamID.scanVel.rawValue, defaultValue: 0.8, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Scan Level", parameterID: ScanParamID.scanGain.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 3.0, sliderMin: 0.0, sliderMax: 3.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
        
        parmsApi.startParameterSubGroup("3D & Geometry", parameterID: ScanParamID.group3D.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tilt X", parameterID: ScanParamID.scanTiltX.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Tilt Y", parameterID: ScanParamID.scanTiltY.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Perspective", parameterID: ScanParamID.scanPersp.rawValue, defaultValue: 0.3, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "S-Curve", parameterID: ScanParamID.scanCurve.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Raster Skew", parameterID: ScanParamID.scanSkew.rawValue, defaultValue: 0.0, parameterMin: -1.0, parameterMax: 1.0, sliderMin: -1.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Raster Collapse", parameterID: ScanParamID.scanCollapse.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
        
        parmsApi.startParameterSubGroup("Modulation & Sweep", parameterID: ScanParamID.groupModulation.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Wobble", parameterID: ScanParamID.scanWobAmt.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Wobble Freq", parameterID: ScanParamID.scanWobFreq.rawValue, defaultValue: 0.25, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Wobble Lock", parameterID: ScanParamID.scanWobLock.rawValue, defaultValue: 1.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Lissajous", parameterID: ScanParamID.scanLissa.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addToggleButton(withName: "Reverse H Sweep", parameterID: ScanParamID.scanRevH.rawValue, defaultValue: false, parameterFlags: 0)
        parmsApi.addToggleButton(withName: "Reverse V Sweep", parameterID: ScanParamID.scanRevV.rawValue, defaultValue: false, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
        
        parmsApi.startParameterSubGroup("Color Mode", parameterID: ScanParamID.groupColor.rawValue, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Monochrome", parameterID: ScanParamID.scanMono.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.addFloatSlider(withName: "Colorise", parameterID: ScanParamID.scanHue.rawValue, defaultValue: 0.0, parameterMin: 0.0, parameterMax: 1.0, sliderMin: 0.0, sliderMax: 1.0, delta: 0.01, parameterFlags: 0)
        parmsApi.endParameterSubGroup()
    }
    
    public func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData?>, at renderTime: CMTime, quality qualityLevel: UInt) throws {
        guard let parmsApi = apiManager.api(for: FxParameterRetrievalAPI_v6.self) as? FxParameterRetrievalAPI_v6 else {
            return
        }
        
        var p = ScanParams()
        var fVal: Double = 0.0
        var bVal = ObjCBool(false)
        
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanAmt.rawValue, at: renderTime) { p.scanAmt = Float(fVal) }
        var iVal: Int32 = 0
        if parmsApi.getIntValue(&iVal, fromParameter: ScanParamID.scanLines.rawValue, at: renderTime) { p.lines = Float(iVal) }
        if parmsApi.getIntValue(&iVal, fromParameter: ScanParamID.scanSamples.rawValue, at: renderTime) { p.samples = Float(iVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanWidth.rawValue, at: renderTime) { p.scanWidth = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanVel.rawValue, at: renderTime) { p.scanVel = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanGain.rawValue, at: renderTime) { p.scanGain = Float(fVal) }
        
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanTiltX.rawValue, at: renderTime) { p.scanTiltX = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanTiltY.rawValue, at: renderTime) { p.scanTiltY = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanPersp.rawValue, at: renderTime) { p.scanPersp = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanCurve.rawValue, at: renderTime) { p.scanCurve = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanSkew.rawValue, at: renderTime) { p.scanSkew = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanCollapse.rawValue, at: renderTime) { p.scanCollapse = Float(fVal) }
        
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanWobAmt.rawValue, at: renderTime) { p.scanWobAmt = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanWobFreq.rawValue, at: renderTime) { p.scanWobFreq = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanWobLock.rawValue, at: renderTime) { p.scanWobLock = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanLissa.rawValue, at: renderTime) { p.scanLissa = Float(fVal) }
        if parmsApi.getBoolValue(&bVal, fromParameter: ScanParamID.scanRevH.rawValue, at: renderTime) { p.scanRevH = bVal.boolValue ? 1.0 : 0.0 }
        if parmsApi.getBoolValue(&bVal, fromParameter: ScanParamID.scanRevV.rawValue, at: renderTime) { p.scanRevV = bVal.boolValue ? 1.0 : 0.0 }
        
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanMono.rawValue, at: renderTime) { p.scanMono = Float(fVal) }
        if parmsApi.getFloatValue(&fVal, fromParameter: ScanParamID.scanHue.rawValue, at: renderTime) { p.scanHue = Float(fVal) }
        
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
              let params = try? ScanParams.decode(from: pluginState),
              let srcTile = sourceImages.first else {
            return
        }
        
        try BENDRScanRenderer.render(destination: destinationImage, source: srcTile, params: params)
    }
}
