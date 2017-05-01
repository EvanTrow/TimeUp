//
//  RestartViewController.swift
//  TimeUp
//
//  Created by 18 Evan I. Trowbridge on 3/28/17.
//  Copyright © 2017 Evan I. Trowbridge. All rights reserved.
//

import Cocoa

class RestartViewController: NSViewController, NSApplicationDelegate {
    
    var AppDelegate: AppDelegate?
    
    // starts timer and sets delay to 2:30mins
    var timer = Timer()
    var counter = 149
    
    // cancel restart btn
    @IBOutlet weak var restartCancelButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //play sound when window opens
        NSSound(named: "Funk")?.play()
        
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
        if(daysUp>=21){
            restartCancelButton.isEnabled = false
        }
    }
    
    // btn to restart now
    @IBAction func restartButton(_ sender: Any) {
        let source = "tell application \"System Events\" to restart"
        let script = NSAppleScript(source: source)
        script?.executeAndReturnError(nil)
    }
    
    // cancel btn and reset timer
    @IBAction func closeRestart(_ sender: NSButton) {
        timer.invalidate()
        counter = 149
        self.view.window?.close()
        
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBOutlet weak var timerString: NSTextField!
    
    // shows and counts timer.
    func timerUpdate(){
        self.view.window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        
        // convert sec to mins
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60
        
        let timer = String(format: "%2i:%02i",minutes,seconds)
        
        // set timer text if time is more that -1
        if(counter > -1){
            timerString.stringValue = "If you do nothing, the computer will restart automatically in" + timer
        }
        
        // counts down
        counter = counter - 1
        
        // auto restart at end of timer.
        if(counter == -2){
            let source = "tell application \"System Events\" to restart"
            let script = NSAppleScript(source: source)
            script?.executeAndReturnError(nil)
        }
    }
    func process() {
        let runningApplications = NSWorkspace.shared().runningApplications
        
        for eachApplication in runningApplications {
            if let applicationName = eachApplication.localizedName {
                if(applicationName=="DRCInsight" || applicationName=="LockDown Browser"){
                    print("Don't retart black is running")
                }
                //print("application is \(applicationName) & pid is \(eachApplication.processIdentifier)")
            }
        }
    }
}
