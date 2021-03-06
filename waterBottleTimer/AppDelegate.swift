//
//  AppDelegate.swift
//  waterBottleTimer
//
//  Created by George Hajjar on 2018-06-13.
//  Copyright © 2018 George Hajjar. All rights reserved.
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var startPause: NSMenuItem!
    @IBOutlet weak var reset: NSMenuItem!
    @IBOutlet weak var window: NSPanel!
    @IBOutlet weak var reminderFrequency: NSPopUpButton!
    @IBOutlet weak var waterBottleCapacity: NSTextField!
    
    var frequency:String?
    var capacity:Int = 0
    var timer = Timer()
    
    var isStart:Bool = true
    var bottleFills = 1
    
//    var ones_sec = 2
//    var tens_sec = 0
//    var ones_min = 0
//    var tens_min = 0

    var ones_sec = 9
    var tens_sec = 5
    var ones_min = 9
    var tens_min = 5


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.menu = mainMenu
        self.mainMenu.autoenablesItems = false
        
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        icon?.isTemplate = true
        statusItem.image = icon
        
        NSUserNotificationCenter.default.delegate = self
        
        reminderFrequency.removeAllItems()
        reminderFrequency.addItems(withTitles: ["10 minutes", "15 minutes", "20 minutes", "30 minutes"])
    }

    
    @IBAction func startPressed(_ sender: Any) {
        self.reset.isEnabled = true
        if isStart {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.tick), userInfo: nil, repeats: true)
            isStart = false
            startPause.title = "Pause"
        }
        else {
            timer.invalidate()
            isStart = true
            startPause.title = "Start"
        }
    }
    
    @objc func tick() {
        ones_sec -= 1
        
        if (ones_sec < 0) {
            tens_sec -= 1
            ones_sec = 9
        }
        if (tens_sec < 0) {
            ones_min -= 1
            tens_sec = 5
        }
        if (ones_min < 0) {
            tens_min -= 1
            ones_min = 9
        }
        if (tens_min < 0) {
            ones_sec = 9
            tens_sec = 5
            ones_min = 9
            tens_min = 5
            showFillNotification()
        }
        
        statusItem.title = String(tens_min) + String(ones_min) + ":" + String(tens_sec) + String(ones_sec)
        
        if frequency == "10 minutes" {
            if ones_min == 0 && tens_sec == 0 && ones_sec == 0 && tens_min > 0 {
                showDrinkNotification()
            }
        }
        
        if frequency == "15 minutes" {
            if ((tens_min * 10) + ones_min) % 15 == 0 && tens_sec == 0 && ones_sec == 0 && tens_min > 0 {
                showDrinkNotification()
            }
        }
        
        if frequency == "20 minutes" {
            if tens_min % 2 == 0 && ones_min == 0 && tens_sec == 0 && ones_sec == 0 && tens_min > 0 {
                showDrinkNotification()
            }
        }
        
        if frequency == "30 minutes" {
            if tens_min % 3 == 0 && ones_min == 0 && tens_sec == 0 && ones_sec == 0 && tens_min > 0 {
                showDrinkNotification()
            }
        }
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        timer.invalidate()
        ones_sec = 9
        tens_sec = 5
        ones_min = 9
        tens_min = 5
        startPause.title = "Start"
        isStart = true
        self.reset.isEnabled = false
        bottleFills = 1
        statusItem.title = String(tens_min) + String(ones_min) + ":" + String(tens_sec) + String(ones_sec)
    }
    
    func showFillNotification() -> Void {
        let notification = NSUserNotification()
        notification.title = "Fill Up Your Waterbottle!"
        notification.informativeText = String(format: "You've drank %dml of water today.", (bottleFills*capacity))
        notification.soundName = "Glass"
        NSUserNotificationCenter.default.deliver(notification)
        bottleFills += 1
    }
    
    func showDrinkNotification() -> Void {
        let notification = NSUserNotification()
        notification.title = "Reminder to drink"
        notification.soundName = "Submarine"
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    @IBAction func openSettings(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        window.orderFront(self)
        window.setFrameOrigin(NSPoint(x: (NSScreen.main?.frame.width)!/2, y: (NSScreen.main?.frame.height)!/2))
    }
    
    @IBAction func quitPressed(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func reminderFrequency(_ sender: NSPopUpButton) {
        frequency = sender.selectedItem?.title
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        capacity = waterBottleCapacity.integerValue
        window.close()
    }
}
