import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // App wrapper does not do much for FxPlug except register
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
