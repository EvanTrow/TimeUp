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
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    
    @IBOutlet weak var popoverMsg: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start TimeUp
        uptime()
        start()
        
        popoverMsg.stringValue = UserDefaults.standard.string(forKey: "popoverMessage")!
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // show restart window
    func showRestart(){
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "restartSegue"), sender: self)
    }
    
    // start timers in background task
    func start(){
        DispatchQueue.global(qos: .background).async {
            //print("This is run on the background queue")
            
            DispatchQueue.main.async {
                //print("This is run on the main queue, after the previous code in outer block")
                
                // setup timers in seperate threads
                self.uptime()
                _ = Timer.scheduledTimer(timeInterval: TimeInterval(UserDefaults.standard.integer(forKey: "timerInterval")), target: self, selector: #selector(self.uptime), userInfo: nil, repeats: true)
                
                _ = Timer.scheduledTimer(timeInterval: TimeInterval(UserDefaults.standard.integer(forKey: "timerInterval")), target: self, selector: #selector(self.uptimeSevenDays), userInfo: nil, repeats: true)
                self.uptimeSevenDays()
                
                _ = Timer.scheduledTimer(timeInterval: TimeInterval(UserDefaults.standard.integer(forKey: "timerInterval")), target: self, selector: #selector(self.uptimeTenDays), userInfo: nil, repeats: true)
                self.uptimeTenDays()
                
                _ = Timer.scheduledTimer(timeInterval: TimeInterval(UserDefaults.standard.integer(forKey: "timerInterval")), target: self, selector: #selector(self.uptimeFourteenDays), userInfo: nil, repeats: true)
                self.uptimeFourteenDays()
                
                _ = Timer.scheduledTimer(timeInterval: TimeInterval(UserDefaults.standard.integer(forKey: "timerInterval")), target: self, selector: #selector(self.uptimeTwentyOneDays), userInfo: nil, repeats: true)
                self.uptimeTwentyOneDays()

            }
        }
    }

    // uptime output text
    @IBOutlet weak var timeOut: NSTextField!
    @IBOutlet weak var timeUpProgress: NSLevelIndicator!
    
    // show time up in popover
    @objc func uptime(){
        
        //debug -------------------------------------------------------------------
        //print(Preferences.databaseUploadEnabled)
        //restartProcessCheck(array: Preferences.blacklistApps)
        
        
        let uptime = getUpTime(no1: 0)
        // convert seconds to day, hrs, mins
        let days = String((uptime / 86400)) + " days "
        let hours = String((uptime % 86400) / 3600) + " hrs "
        let minutes = String((uptime % 3600) / 60) + " min"
        
        // show computer uptime and progress bar
        timeOut.stringValue = days + hours + minutes
        timeUpProgress.doubleValue = ((Double(uptime) / 1814400) * 100)
    }
    
    //more than 7 days every 6 hrs
    var lastCheckSevenDays = NSDate() //get time when app started for timer
    var fistRunSevenDays = false
    @objc func uptimeSevenDays() {
        let elapsedTime = NSDate().timeIntervalSince(lastCheckSevenDays as Date)
        
        if (elapsedTime>=Double(UserDefaults.standard.integer(forKey: "firstInterval"))){ // if time is more that 6hrs show notification
            lastCheckSevenDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "firstLow") && UserDefaults.standard.integer(forKey: "firstHigh") < 10){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            print("debug: 7 main")
        }
        if (fistRunSevenDays==false){
            lastCheckSevenDays = NSDate() // record time again
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "firstLow") && UserDefaults.standard.integer(forKey: "firstHigh") < 10){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            fistRunSevenDays = true
            print("debug: 7 first")
        }
    }
    
    //more than 10 days every 3 hrs
    var lastCheckTenDays = NSDate() //get time when app started for timer
    var fistRunTenDays = false
    @objc func uptimeTenDays() {
        let elapsedTime = NSDate().timeIntervalSince(lastCheckTenDays as Date)
        
        if (elapsedTime>=Double(UserDefaults.standard.integer(forKey: "secondInterval"))){ // if time is more that 6hrs show notification
            lastCheckTenDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "secondLow") && daysSeven < UserDefaults.standard.integer(forKey: "secondHigh")){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            print("debug: 10 main")
        }
        if (fistRunTenDays==false){
            lastCheckTenDays = NSDate() // record time again
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "secondLow") && daysSeven < UserDefaults.standard.integer(forKey: "secondHigh")){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            fistRunTenDays = true
            print("debug: 10 first")
        }
    }
    
    //more than 14 days every 1 hr
    var lastCheckFourteenDays = NSDate() //get time when app started for timer
    var fistRunFourteenDays = false
    @objc func uptimeFourteenDays() {
        let elapsedTime = NSDate().timeIntervalSince(lastCheckFourteenDays as Date)
        
        if (elapsedTime>=Double(UserDefaults.standard.integer(forKey: "thirdInterval"))){ // if time is more that 6hrs show notification
            lastCheckFourteenDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "thirdLow") && daysSeven < UserDefaults.standard.integer(forKey: "thirdHigh")){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            print("debug: 14 main")
        }
        if (fistRunFourteenDays==false){
            lastCheckFourteenDays = NSDate() // record time again
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "thirdLow") && daysSeven < UserDefaults.standard.integer(forKey: "thirdHigh")){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            fistRunFourteenDays = true
            print("debug: 14 fisrt")
        }
    }
    
    //more than 21 days every 5 min
    var lastCheckTwentyOneDays = NSDate() //get time when app started for timer
    var fistRunTwentyOneDays = false
    @objc func uptimeTwentyOneDays() {
        let elapsedTime = NSDate().timeIntervalSince(lastCheckTwentyOneDays as Date)
        
        if (elapsedTime>=Double(UserDefaults.standard.integer(forKey: "forthInterval"))){ // if time is more that 6hrs show notification
            lastCheckTwentyOneDays = NSDate() // record time again
            //convert seconds to days
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "forthHigh")){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            print("debug: 21 main")
        }
        if (fistRunTwentyOneDays==false){
            lastCheckTwentyOneDays = NSDate() // record time again
            let daysSeven = getUpTime(no1: 0) / 86400
            // if days over limit show restart
            if (daysSeven >= UserDefaults.standard.integer(forKey: "forthHigh")){
                restartProcessCheck(array: UserDefaults.standard.stringArray(forKey: "blacklistApps") ?? [String]())
            }
            fistRunTwentyOneDays = true
            print("debug: 21 first")
        }
    }
    
    // if blacklist applications are active don't restart
    func restartProcessCheck(array: Array<String>) {
        
        var restartCheck = true
        
        let runningApplications = NSWorkspace.shared.runningApplications
        
        for eachApplication in runningApplications {
            if let applicationName = eachApplication.localizedName {
                
                if array.contains(applicationName) {
                    //print(applicationName+" is open don't restart")
                    restartCheck = false
                }
                //print("application is \(applicationName) & pid is \(eachApplication.processIdentifier)")
            }
        }
        //print(restartCheck)
        
        // show restart dialog
        if(restartCheck){
            showRestart()
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
        //return = 32423423423
    }

}
