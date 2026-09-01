import Foundation
import CoreMedia

@objc(BENDRColourFilter)
class BENDRColourFilter: NSObject {
    // Boilerplate for FxPlug
    // Since FxPlug SDK is not strictly required for this build stage, we stub the methods.
    
    var renderer: Any? // Will hold BENDRColourRenderer

    func addParameters(withError error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        // Here we would use FxParameterCreationAPI
        return true
    }
    
    func pluginState(at time: CMTime, quality: UInt, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Data? {
        var params = ColourParams()
        // Extract parameter values via API
        return try? params.encode()
    }
    
    func scheduleInputs(_ inputIDs: [NSNumber], withPluginState pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        return true
    }
    
    func renderDestinationImage(_ destinationImage: Any, sourceImages: [Any], pluginState: Data, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool {
        // Forward to renderer
        return true
    }
    
    func sourceTileRect(_ sourceTileRect: CGRect, sourceImageIndex: UInt, sourceImageRect: CGRect, destinationTileRect: CGRect, destinationImageRect: CGRect, pluginState: Data?, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> CGRect {
        return sourceTileRect
    }
    
    func destinationImageRect(_ sourceImageRects: [NSValue], sourceImages: [Any]?, destinationTileRect: CGRect, pluginState: Data?, at time: CMTime, error: AutoreleasingUnsafeMutablePointer<NSError?>) -> CGRect {
        if let first = sourceImageRects.first {
            return first.cgRectValue
        }
        return CGRect.zero
    }
}
