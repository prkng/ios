//
//  NSself.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-26.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

extension NSTimeInterval {
    
    func toString() -> String {
        
        let testFormat = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: NSLocale.currentLocale())
        let is24Hour = testFormat?.rangeOfString("a") == nil
        
        if is24Hour {
            var hours = Int((self / 3600))
            let minutes  = Int((self / 60) % 60)
            
            if (minutes != 0) {
                return String(format: "%ldh%ld", hours, minutes)
            } else {
                return String(format: "%ldh", hours)
            }
            
        } else {
            var amPm: String
            
            if(self >= 12.0 * 3600.0) {
                amPm = "PM"
            } else {
                amPm = "AM"
            }
            
            var hours = Int((self / 3600))
            hours = hours >= 13 ? hours - 12 : hours
            let minutes  = Int((self / 60) % 60)
            
            if (minutes != 0) {
                return String(format: "%ld:%ld%@", hours, minutes, amPm)
            } else {
                return String(format: "%ld%@", hours, amPm)
            }
        }
        
    }

}
