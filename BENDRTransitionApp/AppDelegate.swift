import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Wrapper application registers the XPC service with PlugInKit
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
