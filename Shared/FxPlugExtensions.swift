// FxPlugExtensions.swift — Swift ergonomics and API bridge for FxPlug 4

import Foundation
import FxPlug
import CoreMedia

@objc public protocol FxTileableEffect: NSObjectProtocol {
    @objc(initWithAPIManager:)
    init(apiManager: PROAPIAccessing)
    
    @objc(properties:error:)
    func properties(_ properties: AutoreleasingUnsafeMutablePointer<NSDictionary>?) throws
    
    @objc(addParametersWithError:)
    func addParameters() throws
    
    @objc(scheduleInputs:withPluginState:atTime:error:)
    func scheduleInputs(_ request: UnsafeMutablePointer<FxScheduleInputsRequest>, with pluginState: Data?, at time: CMTime) throws
    
    @objc(pluginState:atTime:quality:error:)
    func pluginState(_ pluginState: AutoreleasingUnsafeMutablePointer<NSData>?, at renderTime: CMTime, quality qualityLevel: UInt) throws
    
    @objc(destinationImageRect:sourceImages:destinationImage:pluginState:atTime:error:)
    func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImages: [FxImage], destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws
    
    @objc(sourceTileRect:sourceImageIndex:sourceImages:destinationTileRect:destinationImage:pluginState:atTime:error:)
    func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImages: [FxImage], destinationTileRect: FxRect, destinationImage: FxImage, pluginState: Data?, at renderTime: CMTime) throws
    
    @objc(renderDestinationImage:sourceImages:pluginState:atTime:error:)
    func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws
}

extension UnsafeMutablePointer where Pointee == FxScheduleInputsRequest {
    public func addInput(_ inputIndex: UInt32, with time: CMTime) {
        // Schedule input frame at time
    }
}
