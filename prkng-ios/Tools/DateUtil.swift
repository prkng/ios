//
//  DateUtil.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 01/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class DateUtil {
   
    class func dayIndexOfTheWeek() -> Int {
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar?.components(.WeekdayCalendarUnit, fromDate: todayDate)
        let weekDay = myComponents?.weekday
        
        if (weekDay == 1) {
            return 6
        }
        
        return (weekDay! - 2)
    }
    
    class func dayIndexOfTheWeekStartingOnMonday() -> Int {
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar?.components(.WeekdayCalendarUnit, fromDate: todayDate)
        let weekDay = myComponents?.weekday
        
        if (weekDay == 1) {
            return 7
        }
        
        return (weekDay! - 1)
    }
    
    
    class func timeIntervalSinceDayStart () -> NSTimeInterval {   // Example : 10:30 -> 10.5 * 3600
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        calendar.locale = NSLocale(localeIdentifier: "en_GB")        
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        
        return NSTimeInterval((hour * 3600) + (minutes * 60))
    }
    
    class func beginningDay(date: NSDate) -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        calendar.locale = NSLocale(localeIdentifier: "en_GB")
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)

        let day = calendar.dateFromComponents(components)

        return day!
    }
}
