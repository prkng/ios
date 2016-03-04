//
//  NSDate.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-20.
//  Copyright © 2016 PRKNG. All rights reserved.
//

extension NSDate {

    func skipToNextEvenMinuteInterval(interval: Int) -> NSDate {
        let componentMask: NSCalendarUnit = ([NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day , NSCalendarUnit.Hour ,NSCalendarUnit.Minute])
        let components = NSCalendar.currentCalendar().components(componentMask, fromDate: self)
        
        components.minute += interval - components.minute % interval
        components.second = 0
        if (components.minute == 0) {
            components.hour += 1
        }
        
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    //1 pm = 13 instead of 1. Note: uses local timezone.
    func hour24Format() -> Int {
        let componentMask: NSCalendarUnit = ([NSCalendarUnit.Hour])
        let components = NSCalendar.currentCalendar().components(componentMask, fromDate: self)
        components.timeZone = NSTimeZone.localTimeZone()
        let hour = components.hour
        return hour
    }


}
