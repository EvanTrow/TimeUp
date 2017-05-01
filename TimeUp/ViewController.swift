//
//  ViewController.swift
//  TimeUp
//
//  Created by Evan Trowbridge on 1/4/17.
//  Copyright © 2017 TrowLink. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSApplicationDelegate {
    
    // setup popover
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var AppDelegate: AppDelegate?
    var RestartViewController: RestartViewController?
    
    // set menu bar text length
    let statusItem = NSStatusBar.system().statusItem(withLength: -1)
    
    @IBOutlet weak var versonLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        uptime()
        start()
        
        //show version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versonLabel.stringValue = "Version " + version + " | TrowLink 2017"
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // show app info in "?" btn click
    @IBAction func showInfo(_ sender: Any) {
        NSSound(named: "Morse")?.play()
        if (versonLabel.isHidden == false){
            versonLabel.isHidden = true
        } else {
            versonLabel.isHidden = false
        }
    }
    
    // show restart window
    func showRestart(){
        self.performSegue(withIdentifier: "restartSegue", sender: self)
    }
    
    // start timers in background task
    func start(){
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                
                self.uptime()
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.uptime), userInfo: nil, repeats: true)
                
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.uptimeSevenDays), userInfo: nil, repeats: true)
                self.uptimeSevenDays()
                
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.uptimeTenDays), userInfo: nil, repeats: true)
                self.uptimeTenDays()
                
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.uptimeFourteenDays), userInfo: nil, repeats: true)
                self.uptimeFourteenDays()
                
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.uptimeTwentyOneDays), userInfo: nil, repeats: true)
                self.uptimeTwentyOneDays()
                
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.databaseUpdate), userInfo: nil, repeats: true)
                self.databaseUpdate()
            }
        }
    }

    // uptime text
    @IBOutlet weak var timeOut: NSTextField!
    
    // show time up in popover
    func uptime(){
        let uptime = getUpTime(no1: 0)
        // convert sec to day, hrs, mins
        let days = String((uptime / 86400)) + " days "
        let hours = String((uptime % 86400) / 3600) + " hrs "
        let minutes = String((uptime % 3600) / 60) + " min"
        
        // show computer uptime
        timeOut.stringValue = days + hours + minutes
    }
    
    
    //more than 7 days every 6 hrs
    static var lastCheckSevenDays = NSDate() //get time when app started for timer
    func uptimeSevenDays() {
        let elapsedTime = NSDate().timeIntervalSince(ViewController.lastCheckSevenDays as Date)
        
        if (elapsedTime>=21600){ // if time is more that 6hrs show notification
            ViewController.lastCheckSevenDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= 7 && daysSeven < 10){
                showRestart()
            }
        }
        
    }
    //more than 10 days every 3 hrs
    static var lastCheckTenDays = NSDate() //get time when app started for timer
    func uptimeTenDays() {
        let elapsedTime = NSDate().timeIntervalSince(ViewController.lastCheckTenDays as Date)
        if (elapsedTime>=10800){ // if time is more that 6hrs show notification
            ViewController.lastCheckTenDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= 10 && daysSeven < 14){
                showRestart()
            }
        }
        
    }
    //more than 14 days every 1 hr
    static var lastCheckFourteenDays = NSDate() //get time when app started for timer
    func uptimeFourteenDays() {
        let elapsedTime = NSDate().timeIntervalSince(ViewController.lastCheckFourteenDays as Date)
        
        if (elapsedTime>=3600){ // if time is more that 6hrs show notification
            ViewController.lastCheckFourteenDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= 14 && daysSeven < 20){
                showRestart()
            }
        }
        
        
    }
    //more than 21 days every 5 min
    static var lastCheckTwentyOneDays = NSDate() //get time when app started for timer
    func uptimeTwentyOneDays() {
        let elapsedTime = NSDate().timeIntervalSince(ViewController.lastCheckTwentyOneDays as Date)
        if (elapsedTime>=300){ // if time is more that 6hrs show notification
            ViewController.lastCheckTwentyOneDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            print(daysSeven)
            // if days over limit show restart
            if (daysSeven >= 21){
                showRestart()
            }
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
    
    // sends computer timeup to firebase realtime database for analitics/tracking - https://firebase.google.com
    static var lastCheckDatabaseUpdate = NSDate() //get time when app started for timer
    func databaseUpdate(){
        let elapsedTime = NSDate().timeIntervalSince(ViewController.lastCheckDatabaseUpdate as Date)
        if (elapsedTime>=7200){ // if time is more that 2hrs update database days
            ViewController.lastCheckTwentyOneDays = NSDate() // record time again
            let currentHost = Host.current().localizedName ?? ""
            let timeNow = String(Date().timeIntervalSince1970)
            let data = "{\"timeup\": \""+String(getUpTime(no1: 0))+"\",\"lastUpdate\": \""+timeNow+"\"}"
            _ = shell(launchPath: "/usr/bin/curl", arguments: ["curl", "-X", "PUT" ,"-d" ,data , "https://timeup-9ddea.firebaseio.com/computers/"+currentHost+".json"]) // runs a curl put command to update database
            //print(output)
        }
    }
    
    // runs terminal commands to send curl put request
    func shell(launchPath: String, arguments: [String]) -> String {
        
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let output_from_command = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
        
        // remove the trailing new-line char
        if output_from_command.characters.count > 0 {
            let lastIndex = output_from_command.index(before: output_from_command.endIndex)
            return output_from_command[output_from_command.startIndex ..< lastIndex]
        }
        return output_from_command
    }
}
