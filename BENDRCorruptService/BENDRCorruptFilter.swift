import Foundation
import CoreMedia

@objc(BENDRCorruptFilter)
class BENDRCorruptFilter: NSObject /*, FxTileableEffect*/ {
    
    func addParameters(withError error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        return true
    }
    
    func pluginState(at time: CMTime, quality: UInt, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Data? {
        var params = CorruptParams()
        return Data(bytes: &params, count: MemoryLayout<CorruptParams>.size)
    }
    
    func scheduleInputs(_ inputIDs: [NSNumber], withPluginState pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        return true
    }
    
    func renderDestinationImage(_ destinationImage: Any, sourceImages: [Any], pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        return true
    }
    
    func sourceTileRect(_ sourceTileRect: CGRect, sourceImageIndex: UInt, sourceImageRect: CGRect, destinationTileRect: CGRect, destinationImageRect: CGRect, pluginState: Data?, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> CGRect {
        if let state = pluginState, state.count == MemoryLayout<CorruptParams>.size {
            let params = state.withUnsafeBytes { $0.load(as: CorruptParams.self) }
            if params.blockShift > 0.003 {
                return sourceImageRect.insetBy(dx: -100, dy: -100) // Expand ROI
            }
        }
        return destinationTileRect
    }
    
    func destinationImageRect(_ sourceImageRects: [NSValue], sourceImages: [Any], pluginState: Data?, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> CGRect {
        return sourceImageRects.first?.cgRectValue ?? .zero
    }
}
