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
    
    // setup popover
    let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var ViewController: ViewController?
    
    // setup icon on launch
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // setup menu icon
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImageGreen")
            button.imagePosition = .imageLeft
            button.title = "0d"
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        let mainViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ViewControllerId") as! ViewController
        
        // setup popover
        popover.contentViewController = mainViewController
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(event)
            }
        }
        // start all processes
        eventMonitor?.start()
        ViewController?.start()
        togglePopover(nil)
        
        // timer for icon and notifications
        uptimeIcon()
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(AppDelegate.uptimeIcon), userInfo: nil, repeats: true)
    }
    
    // toggles popver open/close
    func togglePopover(_ sender: AnyObject?) {
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
    func uptimeIcon(){
        
        // get computer uptime
        let uptime = getUpTime(no1: 0)
        
        // convert sec to days
        let days = String(uptime / 86400) + "d"
        let daysIcon = uptime / 86400
        
        // set menu icon text
        statusItem.title = days
        
        // set menu icon picture by amount of days
        if (daysIcon >= 5) {
            statusItem.image = NSImage(named: "StatusBarButtonImageOrange")
        }
        if (daysIcon >= 10) {
            statusItem.image = NSImage(named: "StatusBarButtonImageRed")
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
}

