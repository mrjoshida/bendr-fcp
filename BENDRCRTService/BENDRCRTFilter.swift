import Foundation
// import FxPlug
// import Metal

@objc(BENDRCRTFilter)
class BENDRCRTFilter: NSObject /*, FxTileableEffect*/ {
    
    // FxTileableEffect API stubs
    func addParameters(withError error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        // Register parameters
        return true
    }
    
    func pluginState(at time: CMTime, quality: UInt, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Data? {
        var params = BENDRCRTParams()
        // Extract parameters from API
        return Data(bytes: &params, count: MemoryLayout<BENDRCRTParams>.size)
    }
    
    func scheduleInputs(_ inputIDs: [NSNumber], withPluginState pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        // Interlace needs 1 previous frame
        // Phosphor needs up to 8
        return true
    }
    
    func renderDestinationImage(_ destinationImage: Any, sourceImages: [Any], pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        return true
    }
    
    // ROI and DOD
    func sourceTileRect(_ sourceTileRect: CGRect, sourceImageIndex: UInt, sourceImageRect: CGRect, destinationTileRect: CGRect, destinationImageRect: CGRect, pluginState: Data?, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> CGRect {
        var params = BENDRCRTParams()
        if let state = pluginState {
            state.withUnsafeBytes { ptr in
                params = ptr.load(as: BENDRCRTParams.self)
            }
        }
        let expand = CGFloat(params.curvature * 0.15 + params.bloomRad * 0.1)
        return sourceTileRect.insetBy(dx: -expand * sourceTileRect.width, dy: -expand * sourceTileRect.height)
    }
}
