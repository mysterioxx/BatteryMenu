//
//  ViewController.swift
//  BatteryMenu
//
//  Created by Abhishek Ruhela on 3/11/26.
//
//
//  ViewController.swift
//  BatteryMenu
//

import Cocoa
import IOKit.ps

class ViewController: NSViewController {

    let titleLabel = NSTextField(labelWithString: "Battery")
    let sourceLabel = NSTextField(labelWithString: "")
    let statusLabel = NSTextField(labelWithString: "")
    let chargeLabel = NSTextField(labelWithString: "")
    let remainLabel = NSTextField(labelWithString: "")
    let usageLabel = NSTextField(labelWithString: "")
    let powerLabel = NSTextField(labelWithString: "")

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 230))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let blur = NSVisualEffectView(frame: view.bounds)
        blur.material = .hudWindow
        blur.blendingMode = .behindWindow
        blur.state = .active
        view.addSubview(blur)

        titleLabel.frame = NSRect(x: 18, y: 192, width: 200, height: 24)
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)

        sourceLabel.frame = NSRect(x: 18, y: 162, width: 260, height: 20)
        sourceLabel.font = NSFont.systemFont(ofSize: 13)

        let line1 = separator(y: 150)

        statusLabel.frame = NSRect(x: 18, y: 122, width: 260, height: 20)
        statusLabel.font = NSFont.systemFont(ofSize: 13)

        chargeLabel.frame = NSRect(x: 18, y: 98, width: 260, height: 20)
        chargeLabel.font = NSFont.systemFont(ofSize: 13)

        remainLabel.frame = NSRect(x: 18, y: 74, width: 260, height: 20)
        remainLabel.font = NSFont.systemFont(ofSize: 13)

        usageLabel.frame = NSRect(x: 18, y: 50, width: 260, height: 20)
        usageLabel.font = NSFont.systemFont(ofSize: 13)

        let line2 = separator(y: 40)

        powerLabel.frame = NSRect(x: 18, y: 14, width: 260, height: 20)
        powerLabel.font = NSFont.systemFont(ofSize: 13)

        for label in [titleLabel, sourceLabel, statusLabel, chargeLabel, remainLabel, usageLabel, powerLabel] {
            label.isBordered = false
            label.drawsBackground = false
            label.backgroundColor = .clear
            view.addSubview(label)
        }

        view.addSubview(line1)
        view.addSubview(line2)

        updateBattery()

        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.updateBattery()
        }
    }

    func separator(y: CGFloat) -> NSView {
        let line = NSView(frame: NSRect(x: 18, y: y, width: 264, height: 1))
        line.wantsLayer = true
        line.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.25).cgColor
        return line
    }

    func updateBattery() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any]
        else { return }

        let current = description[kIOPSCurrentCapacityKey as String] as? Int ?? 0
        let max = description[kIOPSMaxCapacityKey as String] as? Int ?? 100
        let percent = current * 100 / max

        let time = description[kIOPSTimeToEmptyKey as String] as? Int ?? -1
        let charging = description[kIOPSIsChargingKey as String] as? Bool ?? false

        titleLabel.stringValue = "Battery"

        sourceLabel.stringValue = charging ? "Power Source: Adapter" : "Power Source: Battery"

        statusLabel.stringValue = charging ? "⚡ Charging" : "🔋 Discharging"

        chargeLabel.stringValue = "Charge Level: \(percent)%"

        if time >= 0 && !charging {
            let hours = time / 60
            let minutes = time % 60
            remainLabel.stringValue = "Remaining: \(hours)h \(minutes)m"
        } else {
            remainLabel.stringValue = charging ? "Remaining: Charging..." : "Remaining: Calculating..."
        }

        let session = ProcessInfo.processInfo.systemUptime
        let usageHours = Int(session) / 3600
        let usageMinutes = (Int(session) % 3600) / 60

        usageLabel.stringValue = "Session Usage: \(usageHours)h \(usageMinutes)m"

        powerLabel.stringValue = "Energy Mode: Low Power"
    }
}
