// FxPlugExtensions.swift — Swift ergonomics and API bridge for FxPlug 4

import Foundation
import FxPlug
import CoreMedia

public protocol FxTileableEffect: NSObjectProtocol {
    init(apiManager: PROAPIAccessing)
    func properties(_ properties: AutoreleasingUnsafeMutablePointer<NSDictionary>?) throws
    func addParameters() throws
    func pluginState(at renderTime: CMTime, quality qualityLevel: UInt) throws -> Data
    func scheduleInputs(_ request: inout FxScheduleInputsRequest, with pluginState: Data?, at time: CMTime) throws
    func destinationImageRect(_ destinationImageRect: UnsafeMutablePointer<FxRect>, sourceImageRects: [NSValue], pluginState: Data?, at renderTime: CMTime) throws
    func sourceTileRect(_ sourceTileRect: UnsafeMutablePointer<FxRect>, sourceImageIndex: UInt, sourceImageRect: FxRect, destinationTileRect: FxRect, destinationImageRect: FxRect, pluginState: Data?, at renderTime: CMTime) throws
    func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws
}

extension FxScheduleInputsRequest {
    public mutating func addInput(_ inputIndex: UInt32, with time: CMTime) {
        // Schedule input frame at time
    }
}
