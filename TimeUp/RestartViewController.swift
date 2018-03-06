//
//  RestartViewController.swift
//  TimeUp
//
//  Created by Evan Trowbridge on 1/4/17.
//  Copyright © 2017 TrowLink. All rights reserved.
//

import Cocoa

class RestartViewController: NSViewController, NSApplicationDelegate {
    
    var AppDelegate: AppDelegate?
    
    // starts timer and sets delay to 2:30mins
    var timer = Timer()
    var counter = UserDefaults.standard.integer(forKey: "restartTimer") - 1
    
    // cancel restart btn
    @IBOutlet weak var restartCancelButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //play sound when window opens
        NSSound(named: NSSound.Name(rawValue: "Funk"))?.play()
        
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RestartViewController.timerUpdate), userInfo: nil, repeats: true)
        
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
        
        // convert seconds to days
        let daysUp = uptime / 86400
        
        // disables cancel btn if days are more than or equal to 21 days
        if(daysUp>=UserDefaults.standard.integer(forKey: "restartCancelLimit")){
            restartCancelButton.isEnabled = false
        }
    }
    
    // btn to restart now
    @IBAction func restartButton(_ sender: Any) {
        restartNow()
    }
    
    // cancel btn and reset timer
    @IBAction func closeRestart(_ sender: NSButton) {
        timer.invalidate()
        counter = UserDefaults.standard.integer(forKey: "restartTimer") - 1
        self.view.window?.close()
        
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBOutlet weak var timerString: NSTextField!
    
    // shows and counts timer.
    @objc func timerUpdate(){
        self.view.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        
        // convert sec to mins
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60
        
        let timer = String(format: "%2i:%02i",minutes,seconds)
        
        // set timer text if time is more that -1
        if(counter > -1){
            timerString.stringValue = UserDefaults.standard.string(forKey: "restartMsg")! + timer
        }
        
        // counts down
        counter = counter - 1
        
        // auto restart at end of timer.
        if(counter == -2){
            restartNow()
        }
    }
    func restartNow(){
        let source = "tell application \"Google Chrome\" to quit saving no \n tell application \"Microsoft Word\" to quit saving no \n tell application \"Microsoft Excel\" to quit saving no \n tell application \"Microsoft PowerPoint\" to quit saving no \n tell application \"SketchUp\" to quit saving no \n tell application \"System Events\" to restart"
        // \n tell application \"System Events\" to restart
        let script = NSAppleScript(source: source)
        script?.executeAndReturnError(nil)
    }
}
