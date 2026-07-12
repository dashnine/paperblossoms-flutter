import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    // Default to a desktop-sized window; the xib's contentRect is tiny.
    let windowFrame = NSRect(origin: self.frame.origin,
                             size: NSSize(width: 1360, height: 900))
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
