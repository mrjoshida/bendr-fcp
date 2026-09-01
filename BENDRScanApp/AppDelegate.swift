import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let alert = NSAlert()
        alert.messageText = "BENDR Scan Plug-in Installed"
        alert.informativeText = "BENDR Scan has been registered with Final Cut Pro. You can now use it in Final Cut Pro and Apple Motion."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
        NSApplication.shared.terminate(nil)
    }
}
