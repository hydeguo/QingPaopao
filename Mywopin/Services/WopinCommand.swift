//
//  WopinCommand.swift
//  wopinBLEDemo
//
//  Created by Lai kwok tai on 20/6/2018.
//  Copyright © 2018 Lai kwok tai. All rights reserved.
//

import Foundation

struct WopinCommand {
    static let COLOR_LED_ON  = "AABBCC0301CCBBAA"
    static let COLOR_LED_OFF = "AABBCC0302CCBBAA"
    
    static let HYDRO_GEN_ON  = "AABBCC0101CCBBAA"
    static let HYDRO_GEN_OFF = "AABBCC0102CCBBAA"
    
    static let CLEAN_ON      = "AABBCC0103CCBBAA"
    static let CLEAN_OFF     = "AABBCC0104CCBBAA"
}

func hydroGenTimerCommand(min: Int, sec: Int) -> String {
    let minuteStr = String(format:"%02X", min)
    let secondStr = String(format:"%02X", sec)
    return "AABBCC02" + minuteStr + secondStr + "BBAA"
}

func wopinLEDCommand(r: Int, g: Int, b: Int) -> String {
    let red_val = String(format:"%02X", r)
    let green_val  = String(format:"%02X", g)
    let blue_val = String(format:"%02X", b)
    return "AABBDD" + blue_val + green_val + red_val + "DDAA"
}

