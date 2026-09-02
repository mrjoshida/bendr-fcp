import Foundation
import CoreMedia
import Metal
import FxPlug

// Mock PROAPIAccessing
class MockAPIManager: NSObject, PROAPIAccessing {
    func api(for protocol: Protocol) -> Any? {
        return nil
    }
}

print("==================================================")
print("🧪 BENDR In-Process FxPlug Lifecycle Test")
print("==================================================")

let bundlePaths = [
    "BENDRColourApp.app/Contents/PlugIns/BENDRColourService.xpc",
    "BENDRCRTApp.app/Contents/PlugIns/BENDRCRTService.xpc",
    "BENDRCorruptApp.app/Contents/PlugIns/BENDRCorruptService.xpc",
    "BENDRDirtyApp.app/Contents/PlugIns/BENDRDirtyService.xpc",
    "BENDRFeedbackApp.app/Contents/PlugIns/BENDRFeedbackService.xpc",
    "BENDRFlowApp.app/Contents/PlugIns/BENDRFlowService.xpc",
    "BENDRMeltApp.app/Contents/PlugIns/BENDRMeltService.xpc",
    "BENDROpticsApp.app/Contents/PlugIns/BENDROpticsService.xpc",
    "BENDRScanApp.app/Contents/PlugIns/BENDRScanService.xpc",
    "BENDRSignalLabApp.app/Contents/PlugIns/BENDRSignalLabService.xpc",
    "BENDRSpatialApp.app/Contents/PlugIns/BENDRSpatialService.xpc",
    "BENDRSynthApp.app/Contents/PlugIns/BENDRSynthService.xpc",
    "BENDRTransitionApp.app/Contents/PlugIns/BENDRTransitionService.xpc",
    "BENDRVHSApp.app/Contents/PlugIns/BENDRVHSService.xpc"
]

let baseDir = "\(NSHomeDirectory())/Applications/BENDR"
let mockAPI = MockAPIManager()

var passCount = 0
var failCount = 0

for relPath in bundlePaths {
    let fullPath = "\(baseDir)/\(relPath)"
    guard let bundle = Bundle(path: fullPath) else {
        print("❌ Could not load bundle: \(fullPath)")
        failCount += 1
        continue
    }
    
    guard bundle.load() else {
        print("❌ Bundle load() failed: \(fullPath)")
        failCount += 1
        continue
    }
    
    guard let principalClass = bundle.principalClass as? NSObject.Type else {
        print("❌ Principal class not found for \(bundle.bundleURL.lastPathComponent)")
        failCount += 1
        continue
    }
    
    print("Testing \(principalClass)...")
    
    // Test instantiating the filter
    let filterName = principalClass.description()
    guard let filterClass = NSClassFromString(filterName) as? NSObject.Type else {
        print("  ❌ Filter class not found: \(filterName)")
        failCount += 1
        continue
    }
    
    // Check respondsToSelector initWithAPIManager:
    let selInit = NSSelectorFromString("initWithAPIManager:")
    guard filterClass.instancesRespond(to: selInit) else {
        print("  ❌ Does not respond to initWithAPIManager:")
        failCount += 1
        continue
    }
    
    // Allocate and init
    let filter = (filterClass as! NSObject.Type).init()
    _ = filter.perform(selInit, with: mockAPI)
    
    // Test properties:
    let selProperties = NSSelectorFromString("properties:error:")
    if filter.responds(to: selProperties) {
        print("  ✅ Responds to properties:error:")
    } else {
        print("  ⚠️ Does not respond to properties:error:")
    }
    
    // Test addParametersWithError:
    let selAddParams = NSSelectorFromString("addParametersWithError:")
    if filter.responds(to: selAddParams) {
        print("  ✅ Responds to addParametersWithError:")
    } else {
        print("  ⚠️ Does not respond to addParametersWithError:")
    }
    
    // Test destinationImageRect:sourceImages:destinationImage:pluginState:atTime:error:
    let selDOD = NSSelectorFromString("destinationImageRect:sourceImages:destinationImage:pluginState:atTime:error:")
    if filter.responds(to: selDOD) {
        print("  ✅ Responds to destinationImageRect:sourceImages:destinationImage:pluginState:atTime:error:")
    } else {
        print("  ❌ Does NOT respond to destinationImageRect:sourceImages:destinationImage:pluginState:atTime:error:")
        failCount += 1
        continue
    }
    
    // Test sourceTileRect:sourceImageIndex:sourceImages:destinationTileRect:destinationImage:pluginState:atTime:error:
    let selROI = NSSelectorFromString("sourceTileRect:sourceImageIndex:sourceImages:destinationTileRect:destinationImage:pluginState:atTime:error:")
    if filter.responds(to: selROI) {
        print("  ✅ Responds to sourceTileRect:sourceImageIndex:sourceImages:destinationTileRect:destinationImage:pluginState:atTime:error:")
    } else {
        print("  ❌ Does NOT respond to sourceTileRect:sourceImageIndex:sourceImages:destinationTileRect:destinationImage:pluginState:atTime:error:")
        failCount += 1
        continue
    }
    
    // Test renderDestinationImage:sourceImages:pluginState:atTime:error:
    let selRender = NSSelectorFromString("renderDestinationImage:sourceImages:pluginState:atTime:error:")
    if filter.responds(to: selRender) {
        print("  ✅ Responds to renderDestinationImage:sourceImages:pluginState:atTime:error:")
    } else {
        print("  ❌ Does NOT respond to renderDestinationImage:sourceImages:pluginState:atTime:error:")
        failCount += 1
        continue
    }
    
    passCount += 1
}

print("==================================================")
print("Result: \(passCount) passed, \(failCount) failed")
print("==================================================")
