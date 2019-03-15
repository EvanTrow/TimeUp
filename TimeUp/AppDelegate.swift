//
//  AppDelegate.swift
//  TimeUp
//
//  Created by Evan Trowbridge on 1/4/17.
//  Copyright © 2017 TrowLink. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // setup popover / view
    let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var ViewController: ViewController?
    
    // setup
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // sets defualt prefences
        SetPrefs()
    }
    
    func afterSetPrefs() {
        
        // setup menu icon
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarButtonImageGreen"))
            button.imagePosition = .imageLeft
            button.title = "0" + UserDefaults.standard.string(forKey: "daysUnit")!
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        // setup view controller
        let mainViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ViewControllerId")) as! ViewController
        
        // setup popover
        popover.contentViewController = mainViewController
        eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(event)
            }
        }
        // start all processes
        eventMonitor?.start()
        ViewController?.start()
        togglePopover(nil)
        togglePopover(nil)
        
        // timer for icon and notifications
        uptimeIcon()
        _ = Timer.scheduledTimer(timeInterval: TimeInterval(UserDefaults.standard.integer(forKey: "timerInterval")), target: self, selector: #selector(AppDelegate.uptimeIcon), userInfo: nil, repeats: true)
    }
    
    // toggles popver open/close
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    // show popover on icon click
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    // closes popover
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    // set uptime icon number of days
    @objc func uptimeIcon(){
        
        // get computer uptime
        let uptime = getUpTime(no1: 0)
        
        // convert sec to days
        let days = String(uptime / 86400) + UserDefaults.standard.string(forKey: "daysUnit")!
        let daysIcon = uptime / 86400
        
        // set menu icon text
        statusItem.title = days
        
        // set menu icon color by amount of days
        if (daysIcon >= UserDefaults.standard.integer(forKey: "orangeIconDays")) {
            statusItem.image = NSImage(named: NSImage.Name("StatusBarButtonImageOrange"))
        }
        if (daysIcon >= UserDefaults.standard.integer(forKey: "redIconDays")) {
            statusItem.image = NSImage(named: NSImage.Name("StatusBarButtonImageRed"))
        }
    }
    
    func getUpTime(no1: Int) -> Int {
        // get computer uptime
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride
        var now = time_t()
        var uptime: time_t = -1
        time(&now)
        if (sysctl(&mib, 2, &boottime, &size, nil, 0) != -1 && boottime.tv_sec != 0) {
            uptime = now - boottime.tv_sec
        }
        return uptime
    }
    
    // set defualt prefs
    func SetPrefs(){
        
        // reset prefs
        resetDefaults()
        
        // file path for plist
        let path = Bundle.main.paths(forResourcesOfType: "plist", inDirectory: nil)[0]
        //let path = "/Users/superx/Desktop/com.trowlink.TimeUp.plist"
        
        let selfServiceFileManager = FileManager.default
        if !selfServiceFileManager.fileExists(atPath: path) {
            
            UserDefaults.standard.set(5, forKey: "timerInterval")
            
            UserDefaults.standard.set(7, forKey: "firstLow")
            UserDefaults.standard.set(10, forKey: "firstHigh")
            UserDefaults.standard.set(21600, forKey: "firstInterval")
            
            UserDefaults.standard.set(10, forKey: "secondLow")
            UserDefaults.standard.set(14, forKey: "secondHigh")
            UserDefaults.standard.set(10800, forKey: "secondInterval")
            
            UserDefaults.standard.set(14, forKey: "thirdLow")
            UserDefaults.standard.set(21, forKey: "thirdHigh")
            UserDefaults.standard.set(3600, forKey: "thirdInterval")
            
            UserDefaults.standard.set(21, forKey: "forthHigh")
            UserDefaults.standard.set(300, forKey: "forthInterval")
            
            UserDefaults.standard.set(150, forKey: "restartTimer")
            UserDefaults.standard.set(150, forKey: "shutdownTimer")
            UserDefaults.standard.set(21, forKey: "restartCancelLimit")
            UserDefaults.standard.set(true, forKey: "enableInactivityDetection")
            UserDefaults.standard.set(30, forKey: "inactiveTime")
            UserDefaults.standard.set(true, forKey: "enableNotifications")

            
            UserDefaults.standard.set(5, forKey: "orangeIconDays")
            UserDefaults.standard.set(10, forKey: "redIconDays")
            UserDefaults.standard.set("d", forKey: "daysUnit")
            
            UserDefaults.standard.set("If you do nothing, the computer will restart automatically in", forKey: "restartMsg")
            UserDefaults.standard.set("If you do nothing, the computer will shutdown automatically in", forKey: "shutdownMsg")
            UserDefaults.standard.set("Restarting your computer regularly keeps your applications up to date and your computer running smoothly.", forKey: "popoverMessage")
            
            UserDefaults.standard.set([String](), forKey: "blacklistApps")
            
            // show error message if no plist found in path specified above
            print("debug: plist error - "+String(UserDefaults.standard.bool(forKey: "dontShowNotFoundError")))
            if(UserDefaults.standard.bool(forKey: "dontShowNotFoundError") == false) {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "TimeUp configuration not found at: " + path + " TimeUp will use default configuration."
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "Don't show this message again.")
                let result = alert.runModal()
                switch(result) {
                case NSAlertFirstButtonReturn: NSApplication.ModalResponse.self;
                    print("OK")
                case NSAlertSecondButtonReturn: NSApplication.ModalResponse.self;
                    UserDefaults.standard.set(true, forKey: "dontShowNotFoundError")
                    print("don't show again")
                default:
                    break
                }
            }
        } else {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                //print(dict)
                UserDefaults.standard.set(dict["timerInterval"] as! Int, forKey: "timerInterval")
                
                UserDefaults.standard.set(dict["firstLow"] as! Int, forKey: "firstLow")
                UserDefaults.standard.set(dict["firstHigh"] as! Int, forKey: "firstHigh")
                UserDefaults.standard.set(dict["firstInterval"] as! Int, forKey: "firstInterval")
                
                UserDefaults.standard.set(dict["secondLow"] as! Int, forKey: "secondLow")
                UserDefaults.standard.set(dict["secondHigh"] as! Int, forKey: "secondHigh")
                UserDefaults.standard.set(dict["secondInterval"] as! Int, forKey: "secondInterval")
                
                UserDefaults.standard.set(dict["thirdLow"] as! Int, forKey: "thirdLow")
                UserDefaults.standard.set(dict["thirdHigh"] as! Int, forKey: "thirdHigh")
                UserDefaults.standard.set(dict["thirdInterval"] as! Int, forKey: "thirdInterval")
                
                UserDefaults.standard.set(dict["forthHigh"] as! Int, forKey: "forthHigh")
                UserDefaults.standard.set(dict["forthInterval"] as! Int, forKey: "forthInterval")
                
                UserDefaults.standard.set(dict["restartTimer"] as! Int, forKey: "restartTimer")
                UserDefaults.standard.set(dict["shutdownTimer"] as! Int, forKey: "shutdownTimer")
                UserDefaults.standard.set(dict["enableInactivityDetection"] as! Bool, forKey: "enableInactivityDetection")
                UserDefaults.standard.set(dict["inactiveTime"] as! Int, forKey: "inactiveTime")
                UserDefaults.standard.set(dict["enableNotifications"] as! Bool, forKey: "enableNotifications")

                UserDefaults.standard.set(dict["orangeIconDays"] as! Int, forKey: "orangeIconDays")
                UserDefaults.standard.set(dict["redIconDays"] as! Int, forKey: "redIconDays")
                UserDefaults.standard.set(dict["daysUnit"] as! String, forKey: "daysUnit")

                UserDefaults.standard.set(dict["restartMsg"] as! String, forKey: "restartMsg")
                UserDefaults.standard.set(dict["shutdownMsg"] as! String, forKey: "shutdownMsg")
                UserDefaults.standard.set(dict["popoverMsg"] as! String, forKey: "popoverMsg")
                
                UserDefaults.standard.set(dict["blacklistApps"] as! Array<String>, forKey: "blacklistApps")
            }
        }
        afterSetPrefs()
    }
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }

}

