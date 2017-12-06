//
//  NSDate.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-20.
//  Copyright © 2016 PRKNG. All rights reserved.
//

extension Date {

    func skipToNextEvenMinuteInterval(_ interval: Int) -> Date {
        let componentMask: NSCalendar.Unit = ([NSCalendar.Unit.year , NSCalendar.Unit.month , NSCalendar.Unit.day , NSCalendar.Unit.hour ,NSCalendar.Unit.minute])
        var components = (Calendar.current as NSCalendar).components(componentMask, from: self)
        
        components.minute = (components.minute ?? 0) + interval - ((components.minute ?? 0) % interval)
        components.second = 0
        if (components.minute == 0) {
            components.hour = (components.hour ?? 0) + 1
        }
        
        return Calendar.current.date(from: components)!
    }
    
    //1 pm = 13 instead of 1. Note: uses local timezone.
    func hour24Format() -> Int {
        let componentMask: NSCalendar.Unit = ([NSCalendar.Unit.hour])
        let components = (Calendar.current as NSCalendar).components(componentMask, from: self)
        (components as NSDateComponents).timeZone = TimeZone.autoupdatingCurrent
        let hour = components.hour
        return hour!
    }


}
