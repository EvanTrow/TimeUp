//
//  ShutdownViewController.swift
//  TimeUp
//
//  Created by Evan Trowbridge on 1/4/17.
//  Copyright © 2017 TrowLink. All rights reserved.
//

import Cocoa

class ShutdownViewController: NSViewController, NSApplicationDelegate {
    
    var AppDelegate: AppDelegate?
    
    
    // starts timer and sets delay to 2:30mins
    var timer = Timer()
    var counter = UserDefaults.standard.integer(forKey: "shutdownTimer") - 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // play sound when window opens
        NSSound(named: NSSound.Name("Funk"))?.play()
        
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RestartViewController.timerUpdate), userInfo: nil, repeats: true)
        
    }
    
    // btn to shutdown now
    @IBAction func shutdownButton(_ sender: NSButton) {
        let source = "tell application \"System Events\" to shut down"
        let script = NSAppleScript(source: source)
        script?.executeAndReturnError(nil)
    }
    
    // cancel btn and reset timer
    @IBAction func closeShutdown(_ sender: Any) {
        timer.invalidate()
        counter = UserDefaults.standard.integer(forKey: "shutdownTimer") - 1
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
        self.view.window?.level = NSWindow.Level(Int(CGWindowLevelForKey(.floatingWindow)))
        
        // convert sec to mins
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60
        
        let timer = String(format: "%2i:%02i",minutes,seconds)
        
        // set timer text if time is more that -1
        if(counter > -1){
            timerString.stringValue = UserDefaults.standard.string(forKey: "shutdownMsg")! + timer
        }
        
        // counts down
        counter = counter - 1
        
        // auto shutdown at end of timer.
        if(counter == -2){
            let source = "tell application \"System Events\" to shut down"
            let script = NSAppleScript(source: source)
            script?.executeAndReturnError(nil)
        }
        
    }
}
