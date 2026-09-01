import Foundation
import FxPlug

autoreleasepool {
    do {
        try FxPlug.FxTileableEffectFactory.register(BENDRFeedbackFilter.self)
        RunLoop.main.run()
    } catch {
        print("Error starting XPC service: \(error)")
    }
}
