//
//  SetPrefs.swift
//  TimeUp
//
//  Created by 18 Evan I. Trowbridge on 6/5/17.
//  Copyright © 2017 Evan I. Trowbridge. All rights reserved.
//

import Cocoa

class SetPrefs {
    func set(){
        
        //path = "/Library/Preferences/com.jamfsoftware.jamf.plist") {
        
        let selfServiceFileManager = FileManager.default
        let path = "/Users/trowbrev18/Desktop/trowlink.net.pref-test.plist"
        
        if selfServiceFileManager.fileExists(atPath: path) {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                //print(dict)
                //_ = dict["blacklistApps"] as! Array<String>
            print(dict["showOrangeIcon"] as Any)
            }
        }
    }
}
