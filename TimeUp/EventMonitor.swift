//
//  EventMonitor.swift
//  TimeUp
//
//  Created by Evan Trowbridge on 1/4/17.
//  Copyright © 2017 TrowLink. All rights reserved.
//

import Cocoa

open class EventMonitor {
    
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEvent.EventTypeMask
    fileprivate let handler: (NSEvent?) -> ()
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    // starts popover
    open func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
    }
    
    // stops popover
    open func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
