//
//  Prefs.swift
//  TimeUp
//
//  Created by 18 Evan I. Trowbridge on 6/5/17.
//  Copyright © 2017 Evan I. Trowbridge. All rights reserved.
//

enum Preferences {

    //notification 1
    static var firstLow = 7
    static var firstHigh = 10
    static var firstInterval = 21600
    
    //notification 2
    static var secondLow = 10
    static var secondHigh = 14
    static var secondInterval = 10800
    
    //notification 3
    static var thirdLow = 14
    static var thirdHigh = 21
    static var thirdInterval = 3600
    
    //notification 4
    static var forthHigh = 21
    static var forthInterval = 300
    
    //other Prefs
    static var timerInterval = 5
    static var databaseUploadInterval = 7200
    static var databaseUploadEnabled = true
    static var restartTimer = 150
    static var shutdownTimer = 150
    static var orangeIconDays = 5
    static var redIconDays = 10
    static var daysUnit = "d"
    static var restartCancelLimit = 21
    static var restartMsg = "If you do nothing, the computer will restart automatically in"
    static var shutdownMsg = "If you do nothing, the computer will shutdown automatically in"
    static var popoverMessage = "Restarting your computer regularly keeps your applications up to date and your computer running smoothly."
    static var blacklistApps: Array<String> = []
    
}
