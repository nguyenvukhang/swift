//
//  AppDelegate.swift
//  Battery
//
//  Created by khang on 27/2/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let bar = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    private var battery = Battery()
    let runLoop = RunLoop()
    
    
    @objc func updateStatus() {
        bar.button?.attributedTitle = NSAttributedString(string: String(battery.charge()), attributes: [ .font: NSFont.systemFont(ofSize: 12.0, weight: .regular) ])
        bar.button?.image = battery.isCharging() || battery.isACPowered() ? .init(systemSymbolName: "chevron.up", accessibilityDescription: "charging") : nil
        bar.button?.imagePosition = .imageRight
    }
    
    
    private func initBar() {
        bar.menu = NSMenu()
        bar.menu?.addItem(NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q"))
        bar.button?.imagePosition = .imageRight
    }

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        initBar()
        if battery.open() == kIOReturnSuccess {
            
            updateStatus()
            
            let interval = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
            runLoop.add(interval, forMode: .common)
            
        } else {
            
            exit(0)
            
        }
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        let _ = battery.close()
    }

    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
         true
    }
    
    
    @objc func quit() {
        let _ = battery.close()
        exit(0)
    }
}


