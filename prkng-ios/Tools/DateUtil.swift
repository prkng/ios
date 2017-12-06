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
        let todayDate = Date()
        let myCalendar = Calendar(identifier: .gregorian)
        let myComponents = (myCalendar as NSCalendar?)?.components(.NSWeekdayCalendarUnit, from: todayDate)
        let weekDay = myComponents?.weekday
        
        if (weekDay == 1) {
            return 6
        }
        
        return (weekDay! - 2)
    }    
    
    class func timeIntervalSinceDayStart() -> TimeInterval {   // Example : 10:30 -> 10.5 * 3600
        let date = Date()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_GB")        
        let components = (calendar as NSCalendar).components([.hour, .minute], from: date)
        let hour = components.hour
        let minutes = components.minute
        
        return TimeInterval((hour! * 3600) + (minutes! * 60))
    }
    
    class func beginningDay(_ date: Date) -> Date {
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_GB")
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: date)

        let day = calendar.date(from: components)

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
        
        for i in today ..< 7 {
            array.append(days[i])
        }
        
        for j in 0 ..< today {
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
        
        days.append("monday".localizedString.uppercased())
        days.append("tuesday".localizedString.uppercased())
        days.append("wednesday".localizedString.uppercased())
        days.append("thursday".localizedString.uppercased())
        days.append("friday".localizedString.uppercased())
        days.append("saturday".localizedString.uppercased())
        days.append("sunday".localizedString.uppercased())
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for i in today ..< 7 {
            array.append(days[i])
        }
        
        for j in 0 ..< today {
            array.append(days[j])
        }
        
        array[0] = "this_day".localizedString.uppercased()
        
        return array
    }

}
