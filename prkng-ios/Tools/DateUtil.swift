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
    
    //returns today, tomorrow, thursday, riday, etc (sorted!)
    class func sortedDays() -> Array<String> {
        var array : Array<String> = []
        
        var days : Array<String> = []
        
        days.append("monday".localizedString)
        days.append("tuesday".localizedString)
        days.append("wednesday".localizedString)
        days.append("thursday".localizedString)
        days.append("friday".localizedString)
        days.append("saturday".localizedString)
        days.append("sunday".localizedString)
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for var i = today; i < 7; ++i {
            array.append(days[i])
        }
        
        for var j = 0; j < today; ++j {
            array.append(days[j])
        }
        
        array[0] = "today".localizedString
        array[1] = "tomorrow".localizedString
        
        return array
    }
    
    //returns TODAY, FRI, SAT, SUN, etc (sorted!)
    class func sortedDayAbbreviations() -> Array<String> {
        var array : Array<String> = []
        
        var days : Array<String> = []
        
        days.append("monday".localizedString.uppercaseString[0...2])
        days.append("tuesday".localizedString.uppercaseString[0...2])
        days.append("wednesday".localizedString.uppercaseString[0...2])
        days.append("thursday".localizedString.uppercaseString[0...2])
        days.append("friday".localizedString.uppercaseString[0...2])
        days.append("saturday".localizedString.uppercaseString[0...2])
        days.append("sunday".localizedString.uppercaseString[0...2])
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for var i = today; i < 7; ++i {
            array.append(days[i])
        }
        
        for var j = 0; j < today; ++j {
            array.append(days[j])
        }
        
        array[0] = "this_day".localizedString.uppercaseString
        
        return array
    }

}
