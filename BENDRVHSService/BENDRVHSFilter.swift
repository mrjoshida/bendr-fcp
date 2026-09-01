import Foundation
// import FxPlug
// import Metal

@objc(BENDRVHSFilter)
class BENDRVHSFilter: NSObject /*, FxTileableEffect*/ {
    
    // FxTileableEffect API stubs
    func addParameters(withError error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        // Register parameters
        return true
    }
    
    func pluginState(at time: CMTime, quality: UInt, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Data? {
        var params = BENDRVHSParams()
        // Extract parameters from API
        return Data(bytes: &params, count: MemoryLayout<BENDRVHSParams>.size)
    }
    
    func scheduleInputs(_ inputIDs: [NSNumber], withPluginState pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        return true
    }
    
    func renderDestinationImage(_ destinationImage: Any, sourceImages: [Any], pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        return true
    }
    
    func sourceTileRect(_ sourceTileRect: CGRect, sourceImageIndex: UInt, sourceImageRect: CGRect, destinationTileRect: CGRect, destinationImageRect: CGRect, pluginState: Data?, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> CGRect {
        // VHS is 1:1 mapping
        return destinationTileRect
    }
    
    func destinationImageRect(_ sourceImageRects: [NSValue], sourceImages: [Any], pluginState: Data?, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> CGRect {
        // No spatial expansion
        return sourceImageRects.first?.cgRectValue ?? .zero
    }
}
