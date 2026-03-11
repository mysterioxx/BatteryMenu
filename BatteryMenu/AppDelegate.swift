//
//  AppDelegate.swift
//  BatteryMenu
//
//  Created by Abhishek Ruhela on 3/11/26.
//

import Cocoa
import IOKit.ps

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = getBatteryPercent()
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover.contentViewController = ViewController()
        popover.behavior = .transient

        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            if let button = self.statusItem.button {
                button.title = self.getBatteryPercent()
            }
        }
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func getBatteryPercent() -> String {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any]
        else {
            return "--%"
        }

        let current = description[kIOPSCurrentCapacityKey as String] as? Int ?? 0
        let max = description[kIOPSMaxCapacityKey as String] as? Int ?? 100
        let percent = current * 100 / max

        return "\(percent)%"
    }
}
