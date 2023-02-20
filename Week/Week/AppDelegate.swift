//
//  AppDelegate.swift
//  Week
//
//  Created by khang on 27/2/23.
//

import Cocoa

extension URLSession {
    static func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let dataTask = self.shared.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return (data, response, error)
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let bar = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        bar.menu = NSMenu()
        bar.menu?.addItem(NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q"))
        bar.button?.imagePosition = .imageRight
        
        bar.button?.attributedTitle = NSAttributedString(string: String("NUS Week"), attributes: [ .font: NSFont.systemFont(ofSize: 12.0, weight: .regular) ])
        
        let url = URL(string: "https://www.nguyenvukhang.com/api/nus")!
        let (raw, _, _) = URLSession.synchronousDataTask(with: url)
        let str = String(data: raw!, encoding: .utf8)!
        let week = str.split(separator: "  ").last!.trimmingPrefix { char in
            char.isWhitespace
        }

        self.bar.button?.attributedTitle = NSAttributedString(string: String(week), attributes: [ .font: NSFont.systemFont(ofSize: 12.0, weight: .regular) ])
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {}

    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
         true
    }
    
    
    @objc func quit() {
        exit(0)
    }
}


