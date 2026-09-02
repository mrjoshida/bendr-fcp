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
    
    @objc(renderDestinationImage:sourceImages:pluginState:atTime:error:)
    func renderDestinationImage(_ destinationImage: FxImageTile, sourceImages: [FxImageTile], pluginState: Data?, at renderTime: CMTime) throws
}

extension FxScheduleInputsRequest {
    public mutating func addInput(_ inputIndex: UInt32, with time: CMTime) {
        // Schedule input frame at time
    }
}
