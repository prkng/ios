//
//  AFDateExtension.swift
//
//  Version 3.1.0
//
//  Created by Melvin Rivera on 7/15/14.
//  Copyright (c) 2014. All rights reserved.
//

import Foundation

// DotNet: "/Date(1268123281843)/"
let DefaultFormat = "EEE MMM dd HH:mm:ss Z yyyy"
let RSSFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ" // "Fri, 09 Sep 2011 15:26:08 +0200"
let AltRSSFormat = "d MMM yyyy HH:mm:ss ZZZ" // "09 Sep 2011 15:26:08 +0200"

public enum ISO8601Format: String {
    
    case Year = "yyyy" // 1997
    case YearMonth = "yyyy-MM" // 1997-07
    case Date = "yyyy-MM-dd" // 1997-07-16
    case DateTime = "yyyy-MM-dd'T'HH:mmZ" // 1997-07-16T19:20+01:00
    case DateTimeSec = "yyyy-MM-dd'T'HH:mm:ssZ" // 1997-07-16T19:20:30+01:00
    case DateTimeMilliSec = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 1997-07-16T19:20:30.45+01:00
    
    init(dateString:String) {
        switch dateString.characters.count {
        case 4:
            self = ISO8601Format(rawValue: ISO8601Format.Year.rawValue)!
        case 7:
            self = ISO8601Format(rawValue: ISO8601Format.YearMonth.rawValue)!
        case 10:
            self = ISO8601Format(rawValue: ISO8601Format.Date.rawValue)!
        case 22:
            self = ISO8601Format(rawValue: ISO8601Format.DateTime.rawValue)!
        case 25:
            self = ISO8601Format(rawValue: ISO8601Format.DateTimeSec.rawValue)!
        default:// 28:
            self = ISO8601Format(rawValue: ISO8601Format.DateTimeMilliSec.rawValue)!
        }
    }
}

public enum DateFormat {
    case iso8601(ISO8601Format?), dotNet, rss, altRSS, custom(String)
}

public extension Date {
    
    // MARK: Intervals In Seconds
    fileprivate static func minuteInSeconds() -> Double { return 60 }
    fileprivate static func hourInSeconds() -> Double { return 3600 }
    fileprivate static func dayInSeconds() -> Double { return 86400 }
    fileprivate static func weekInSeconds() -> Double { return 604800 }
    fileprivate static func yearInSeconds() -> Double { return 31556926 }
    
    // MARK: Components
    fileprivate static func componentFlags() -> NSCalendar.Unit { return [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.weekOfYear] }
    
    fileprivate static func components(fromDate: Date) -> DateComponents! {
        return (Calendar.current as NSCalendar).components(Date.componentFlags(), from: fromDate)
    }
    
    fileprivate func components() -> DateComponents  {
        return Date.components(fromDate: self)!
    }
    
    // MARK: Date From String
    
    /**
    Returns a new NSDate object based on a date string and a formatter type.
    
    :param: fromString :String Date string i.e. "16 July 1972 6:12:00".
    :param: format :DateFormat Formatter type can be .ISO8601(ISO8601Format?), .DotNet, .RSS, .AltRSS or Custom(String).
    
    :returns: NSDate
    :discussion: Use .ISO8601(nil) to generate an automatic ISO8601Format based on the date string.
    */
    
    init(fromString string: String, format:DateFormat)
    {
        if string.isEmpty {
            (self as NSDate).init()
            return
        }
        
        let string = string as NSString
        
        switch format {
            
        case .dotNet:
            
            let startIndex = string.range(of: "(").location + 1
            let endIndex = string.range(of: ")").location
            let range = NSRange(location: startIndex, length: endIndex-startIndex)
            let milliseconds = (string.substring(with: range) as NSString).longLongValue
            let interval = TimeInterval(milliseconds / 1000)
            (self as NSDate).init(timeIntervalSince1970: interval)
            
        case .iso8601(let isoFormat):
            
            let dateFormat = (isoFormat != nil) ? isoFormat! : ISO8601Format(dateString: string as String)
            let formatter = Date.formatter(format: dateFormat.rawValue)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.autoupdatingCurrent
            formatter.dateFormat = dateFormat.rawValue
            if let date = formatter.date(from: string as String) {
                (self as NSDate).init(timeInterval:0, since:date)
            } else {
                (self as NSDate).init()
            }
            
        case .rss:
            
            var s  = string
            if string.hasSuffix("Z") {
                s = s.substring(to: s.length-1) + "GMT" as NSString
            }
            let formatter = Date.formatter(format: RSSFormat)
            if let date = formatter.date(from: string as String) {
                (self as NSDate).init(timeInterval:0, since:date)
            } else {
                (self as NSDate).init()
            }
            
        case .altRSS:
            
            var s  = string
            if string.hasSuffix("Z") {
                s = s.substring(to: s.length-1) + "GMT" as NSString
            }
            let formatter = Date.formatter(format: AltRSSFormat)
            if let date = formatter.date(from: string as String) {
                (self as NSDate).init(timeInterval:0, since:date)
            } else {
                (self as NSDate).init()
            }
            
        case .custom(let dateFormat):
            
            let formatter = Date.formatter(format: dateFormat)
            if let date = formatter.date(from: string as String) {
                (self as NSDate).init(timeInterval:0, since:date)
            } else {
                (self as NSDate).init()
            }
        }
    }
    
    
    
    // MARK: Comparing Dates
    
    /**
    Compares dates without while ignoring time.
    
    :param: date :NSDate Date to compare.
    
    :returns: :Bool Returns true if dates are equal.
    */
    func isEqualToDateIgnoringTime(_ date: Date) -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: date)
        return ((comp1!.year == comp2!.year) && (comp1!.month == comp2!.month) && (comp1!.day == comp2!.day))
    }
    
    /**
    Checks if date is today.
    
    :returns: :Bool Returns true if date is today.
    */
    func isToday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date())
    }
    
    /**
    Checks if date is tomorrow.
    
    :returns: :Bool Returns true if date is tomorrow.
    */
    func isTomorrow() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date().dateByAddingDays(1))
    }
    
    /**
    Checks if date is yesterday.
    
    :returns: :Bool Returns true if date is yesterday.
    */
    func isYesterday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(Date().dateBySubtractingDays(1))
    }
    
    /**
    Compares dates to see if they are in the same week.
    
    :param: date :NSDate Date to compare.
    :returns: :Bool Returns true if date is tomorrow.
    */
    func isSameWeekAsDate(_ date: Date) -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: date)
        // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
        if comp1?.weekOfYear != comp2?.weekOfYear {
            return false
        }
        // Must have a time interval under 1 week
        return abs(self.timeIntervalSince(date)) < Date.weekInSeconds()
    }
    
    /**
    Checks if date is this week.
    
    :returns: :Bool Returns true if date is this week.
    */
    func isThisWeek() -> Bool
    {
        return self.isSameWeekAsDate(Date())
    }
    
    /**
    Checks if date is next week.
    
    :returns: :Bool Returns true if date is next week.
    */
    func isNextWeek() -> Bool
    {
        let interval: TimeInterval = Date().timeIntervalSinceReferenceDate + Date.weekInSeconds()
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return self.isSameWeekAsDate(date)
    }
    
    /**
    Checks if date is last week.
    
    :returns: :Bool Returns true if date is last week.
    */
    func isLastWeek() -> Bool
    {
        let interval: TimeInterval = Date().timeIntervalSinceReferenceDate - Date.weekInSeconds()
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return self.isSameWeekAsDate(date)
    }
    
    /**
    Compares dates to see if they are in the same year.
    
    :param: date :NSDate Date to compare.
    :returns: :Bool Returns true if date is this week.
    */
    func isSameYearAsDate(_ date: Date) -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: date)
        return (comp1!.year == comp2!.year)
    }
    
    /**
    Checks if date is this year.
    
    :returns: :Bool Returns true if date is this year.
    */
    func isThisYear() -> Bool
    {
        return self.isSameYearAsDate(Date())
    }
    
    /**
    Checks if date is next year.
    
    :returns: :Bool Returns true if date is next year.
    */
    func isNextYear() -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: Date())
        return (comp1!.year! == comp2!.year! + 1)
    }
    
    /**
    Checks if date is last year.
    
    :returns: :Bool Returns true if date is last year.
    */
    func isLastYear() -> Bool
    {
        let comp1 = Date.components(fromDate: self)
        let comp2 = Date.components(fromDate: Date())
        return (comp1!.year! == comp2!.year! - 1)
    }
    
    /**
    Compares dates to see if it's an earlier date.
    
    :param: date :NSDate Date to compare.
    :returns: :Bool Returns true if date is earlier.
    */
    func isEarlierThanDate(_ date: Date) -> Bool
    {
        return (self as NSDate).earlierDate(date) == self
    }
    
    /**
    Compares dates to see if it's a later date.
    
    :param: date :NSDate Date to compare.
    :returns: :Bool Returns true if date is later.
    */
    func isLaterThanDate(_ date: Date) -> Bool
    {
        return (self as NSDate).laterDate(date) == self
    }
    
    /**
    Checks if date is in future.
    
    :returns: :Bool Returns true if date is in future.
    */
    func isInFuture() -> Bool
    {
        return self.isLaterThanDate(Date())
    }
    
    /**
    Checks if date is in past.
    
    :returns: :Bool Returns true if date is in past.
    */
    func isInPast() -> Bool
    {
        return self.isEarlierThanDate(Date())
    }
    
    
    // MARK: Adjusting Dates
    
    /**
    Returns a new NSDate object by a adding days.
    
    :param: days :Int Days to add.
    :returns: NSDate
    */
    func dateByAddingDays(_ days: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.day = days
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a substracting days.
    
    :param: days :Int Days to substract.
    :returns: NSDate
    */
    func dateBySubtractingDays(_ days: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.day = (days * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a adding hours.
    
    :param: days :Int Hours to add.
    :returns: NSDate
    */
    func dateByAddingHours(_ hours: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.hour = hours
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a substracting hours.
    
    :param: days :Int Hours to substract.
    :returns: NSDate
    */
    func dateBySubtractingHours(_ hours: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.hour = (hours * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a adding minutes.
    
    :param: days :Int Minutes to add.
    :returns: NSDate
    */
    func dateByAddingMinutes(_ minutes: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.minute = minutes
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a adding minutes.
    
    :param: days :Int Minutes to add.
    :returns: NSDate
    */
    func dateBySubtractingMinutes(_ minutes: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.minute = (minutes * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object from the start of the day.
    
    :returns: NSDate
    */
    func dateAtStartOfDay() -> Date
    {
        var components = self.components()
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    /**
    Returns a new NSDate object from the end of the day.
    
    :returns: NSDate
    */
    func dateAtEndOfDay() -> Date
    {
        var components = self.components()
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components)!
    }
    
    /**
    Returns a new NSDate object from the start of the week.
    
    :returns: NSDate
    */
    func dateAtStartOfWeek() -> Date
    {
        let flags :NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday]
        var components = (Calendar.current as NSCalendar).components(flags, from: self)
        components.weekday = Calendar.current.firstWeekday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    /**
    Returns a new NSDate object from the end of the week.
    
    :returns: NSDate
    */
    func dateAtEndOfWeek() -> Date
    {
        let flags :NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday]
        var components = (Calendar.current as NSCalendar).components(flags, from: self)
        components.weekday = Calendar.current.firstWeekday + 6
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    /**
    Return a new NSDate object of the first day of the month
    
    :returns: NSDate
    */
    func dateAtTheStartOfMonth() -> Date
    {
        //Create the date components
        var components = self.components()
        components.day = 1
        //Builds the first day of the month
        let firstDayOfMonthDate :Date = Calendar.current.date(from: components)!
        
        return firstDayOfMonthDate
        
    }
    
    /**
    Return a new NSDate object of the last day of the month
    
    :returns: NSDate
    */
    func dateAtTheEndOfMonth() -> Date {
        
        //Create the date components
        var components = self.components()
        //Set the last day of this month
        components.month += 1
        components.day = 0
        
        //Builds the first day of the month
        let lastDayOfMonth :Date = Calendar.current.date(from: components)!
        
        return lastDayOfMonth
        
    }
    
    
    // MARK: Retrieving Intervals
    
    /**
    Returns the interval in minutes after a date.
    
    :param: date :NSDate Date to compare.
    :returns: Int
    */
    func minutesAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.minuteInSeconds())
    }
    
    /**
    Returns the interval in minutes before a date.
    
    :param: date :NSDate Date to compare.
    :returns: Int
    */
    func minutesBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.minuteInSeconds())
    }
    
    /**
    Returns the interval in hours after a date.
    
    :param: date :NSDate Date to compare.
    :returns: Int
    */
    func hoursAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.hourInSeconds())
    }
    
    /**
    Returns the interval in hours before a date.
    
    :param: date :NSDate Date to compare.
    :returns: Int
    */
    func hoursBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.hourInSeconds())
    }
    
    /**
    Returns the interval in days after a date.
    
    :param: date :NSDate Date to compare.
    :returns: Int
    */
    func daysAfterDate(_ date: Date) -> Int
    {
        let interval = self.timeIntervalSince(date)
        return Int(interval / Date.dayInSeconds())
    }
    
    /**
    Returns the interval in days before a date.
    
    :param: date :NSDate Date to compare.
    :returns: Int
    */
    func daysBeforeDate(_ date: Date) -> Int
    {
        let interval = date.timeIntervalSince(self)
        return Int(interval / Date.dayInSeconds())
    }
    
    
    // MARK: Decomposing Dates
    
    /**
    Returns the nearest hour.
    
    :returns: Int
    */
    func nearestHour () -> Int {
        let halfHour = Date.minuteInSeconds() * 30
        var interval = self.timeIntervalSinceReferenceDate
        if  self.seconds() < 30 {
            interval -= halfHour
        } else {
            interval += halfHour
        }
        let date = Date(timeIntervalSinceReferenceDate: interval)
        return date.hour()
    }
    /**
    Returns the year component.
    
    :returns: Int
    */
    func year () -> Int { return self.components().year!  }
    /**
    Returns the month component.
    
    :returns: Int
    */
    func month () -> Int { return self.components().month! }
    /**
    Returns the week of year component.
    
    :returns: Int
    */
    func week () -> Int { return self.components().weekOfYear! }
    /**
    Returns the day component.
    
    :returns: Int
    */
    func day () -> Int { return self.components().day! }
    /**
    Returns the hour component.
    
    :returns: Int
    */
    func hour () -> Int { return self.components().hour! }
    /**
    Returns the minute component.
    
    :returns: Int
    */
    func minute () -> Int { return self.components().minute! }
    /**
    Returns the seconds component.
    
    :returns: Int
    */
    func seconds () -> Int { return self.components().second! }
    /**
    Returns the weekday component.
    
    :returns: Int
    */
    func weekday () -> Int { return self.components().weekday! }
    /**
    Returns the nth days component. e.g. 2nd Tuesday of the month is 2.
    
    :returns: Int
    */
    func nthWeekday () -> Int { return self.components().weekdayOrdinal! }
    /**
    Returns the days of the month.
    
    :returns: Int
    */
    func monthDays () -> Int { return (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self).length }
    /**
    Returns the first day of the week.
    
    :returns: Int
    */
    func firstDayOfWeek () -> Int {
        let distanceToStartOfWeek = Date.dayInSeconds() * Double(self.components().weekday! - 1)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).day()
    }
    /**
    Returns the last day of the week.
    
    :returns: Int
    */
    func lastDayOfWeek () -> Int {
        let distanceToStartOfWeek = Date.dayInSeconds() * Double(self.components().weekday! - 1)
        let distanceToEndOfWeek = Date.dayInSeconds() * Double(7)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek + distanceToEndOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).day()
    }
    /**
    Checks to see if the date is a weekdday.
    
    :returns: :Bool Returns true if weekday.
    */
    func isWeekday() -> Bool {
        return !self.isWeekend()
    }
    /**
    Checks to see if the date is a weekdend.
    
    :returns: :Bool Returns true if weekend.
    */
    func isWeekend() -> Bool {
        let range = (Calendar.current as NSCalendar).maximumRange(of: NSCalendar.Unit.weekday)
        return (self.weekday() == range.location || self.weekday() == range.length)
    }
    
    
    // MARK: To String
    
    /**
    Returns a new String object using .ShortStyle date style and .ShortStyle time style.
    
    :returns: :String
    */
    func toString() -> String {
        return self.toString(dateStyle: .short, timeStyle: .short, doesRelativeDateFormatting: false)
    }
    
    /**
    Returns a new String object based on a  date format.
    
    :param: format :DateFormat Format of date. Can be .ISO8601(.ISO8601Format?), .DotNet, .RSS, .AltRSS or Custom(FormatString).
    :returns: String
    */
    func toString(format: DateFormat) -> String
    {
        var dateFormat: String
        switch format {
        case .dotNet:
            let offset = NSTimeZone.default.secondsFromGMT() / 3600
            let nowMillis = 1000 * self.timeIntervalSince1970
            return  "/Date(\(nowMillis)\(offset))/"
        case .iso8601(let isoFormat):
            dateFormat = (isoFormat != nil) ? isoFormat!.rawValue : ISO8601Format.DateTimeMilliSec.rawValue
        case .rss:
            dateFormat = RSSFormat
        case .altRSS:
            dateFormat = AltRSSFormat
        case .custom(let string):
            dateFormat = string
        }
        let formatter = Date.formatter(format: dateFormat)
        return formatter.string(from: self)
    }
    
    /**
    Returns a new String object based on a date style, time style and optional relative flag.
    
    :param: dateStyle :NSDateFormatterStyle
    :param: timeStyle :NSDateFormatterStyle
    :param: doesRelativeDateFormatting :Bool
    :returns: String
    */
    func toString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool = false) -> String
    {
        let formatter = Date.formatter(dateStyle: dateStyle, timeStyle: timeStyle, doesRelativeDateFormatting: doesRelativeDateFormatting)
        return formatter.string(from: self)
    }
    
    /**
    Returns a new String object based on a relative time language. i.e. just now, 1 minute ago etc..
    
    :returns: String
    */
    func relativeTimeToString() -> String
    {
        let time = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        
        let seconds = now - time
        let minutes = round(seconds/60)
        let hours = round(minutes/60)
        let days = round(hours/24)
        
        if seconds < 10 {
            return NSLocalizedString("just now", comment: "Show the relative time from a date")
        } else if seconds < 60 {
            let relativeTime = NSLocalizedString("%.f seconds ago", comment: "Show the relative time from a date")
            return String(format: relativeTime, seconds)
        }
        
        if minutes < 60 {
            if minutes == 1 {
                return NSLocalizedString("1 minute ago", comment: "Show the relative time from a date")
            } else {
                let relativeTime = NSLocalizedString("%.f minutes ago", comment: "Show the relative time from a date")
                return String(format: relativeTime, minutes)
            }
        }
        
        if hours < 24 {
            if hours == 1 {
                return NSLocalizedString("1 hour ago", comment: "Show the relative time from a date")
            } else {
                let relativeTime = NSLocalizedString("%.f hours ago", comment: "Show the relative time from a date")
                return String(format: relativeTime, hours)
            }
        }
        
        if days < 7 {
            if days == 1 {
                return NSLocalizedString("1 day ago", comment: "Show the relative time from a date")
            } else {
                let relativeTime = NSLocalizedString("%.f days ago", comment: "Show the relative time from a date")
                return String(format: relativeTime, days)
            }
        }
        
        return self.toString()
    }
    
    /**
    Returns the weekday as a new String object.
    
    :returns: String
    */
    func weekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.weekdaySymbols[self.weekday()-1] as String
    }
    
    /**
    Returns the short weekday as a new String object.
    
    :returns: String
    */
    func shortWeekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.shortWeekdaySymbols[self.weekday()-1] as String
    }
    
    /**
    Returns the very short weekday as a new String object.
    
    :returns: String
    */
    func veryShortWeekdayToString() -> String {
        let formatter = Date.formatter()
        return formatter.veryShortWeekdaySymbols[self.weekday()-1] as String
    }
    
    /**
    Returns the month as a new String object.
    
    :returns: String
    */
    func monthToString() -> String {
        let formatter = Date.formatter()
        return formatter.monthSymbols[self.month()-1] as String
    }
    
    /**
    Returns the short month as a new String object.
    
    :returns: String
    */
    func shortMonthToString() -> String {
        let formatter = Date.formatter()
        return formatter.shortMonthSymbols[self.month()-1] as String
    }
    
    /**
    Returns the very short month as a new String object.
    
    :returns: String
    */
    func veryShortMonthToString() -> String {
        let formatter = Date.formatter()
        return formatter.veryShortMonthSymbols[self.month()-1] as String
    }
    
    
    // MARK: Static Cached Formatters
    
    /**
    Returns a static singleton array of NSDateFormatters so that thy are only created once.
    
    :returns: [String: NSDateFormatter] Array of NSDateFormatters
    */
    fileprivate static func sharedDateFormatters() -> [String: DateFormatter] {
        struct Static {
            static var formatters: [String: DateFormatter]? = nil
            static var once: Int = 0
        }
        dispatch_once(&Static.once) {
            Static.formatters = [String: DateFormatter]()
        }
        return Static.formatters!
    }
    
    /**
    Returns a singleton formatter based on the format, timeZone and locale. Formatters are cached in a singleton array using hashkeys generated by format, timeZone and locale.
    
    :param: format :String
    :param: timeZone :NSTimeZone Uses local time zone as the default
    :param: locale :NSLocale Uses current locale as the default
    :returns: [String: NSDateFormatter] Singleton of NSDateFormatters
    */
    fileprivate static func formatter(format:String = DefaultFormat, timeZone: TimeZone = TimeZone.autoupdatingCurrent, locale: Locale = Locale.current) -> DateFormatter {
        let hashKey = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
        var formatters = Date.sharedDateFormatters()
        if let cachedDateFormatter = formatters[hashKey] {
            return cachedDateFormatter
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = timeZone
            formatter.locale = locale
            formatters[hashKey] = formatter
            return formatter
        }
    }
    
    /**
    Returns a singleton formatter based on date style, time style and relative date. Formatters are cached in a singleton array using hashkeys generated by date style, time style, relative date, timeZone and locale.
    
    :param: dateStyle :NSDateFormatterStyle
    :param: timeStyle :NSDateFormatterStyle
    :param: doesRelativeDateFormatting :Bool
    :param: timeZone :NSTimeZone
    :param: locale :NSLocale
    :returns: [String: NSDateFormatter] Singleton array of NSDateFormatters
    */
    fileprivate static func formatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool, timeZone: TimeZone = TimeZone.autoupdatingCurrent, locale: Locale = Locale.current) -> DateFormatter {
        var formatters = Date.sharedDateFormatters()
        let hashKey = "\(dateStyle.hashValue)\(timeStyle.hashValue)\(doesRelativeDateFormatting.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
        if let cachedDateFormatter = formatters[hashKey] {
            return cachedDateFormatter
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
            formatter.timeZone = timeZone
            formatter.locale = locale
            formatters[hashKey] = formatter
            return formatter
        }
    }
    
    
    
}
