//
//  Settings.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 01/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct Settings {
    
    static let SELECTED_CITY_KEY = "prkng_selected_city"
    static let FIRST_USE_PASSED_KEY = "prkng_first_use_passed"
    static let FIRST_CHECKIN_PASSED_KEY = "prkng_first_checkin_passed"
    static let FIRST_MAP_USE_PASSED_KEY = "prkng_first_map_use_passed"
    static let NOTIFICATION_TIME_KEY = "prkng_notification_time"
    static let CHECKED_IN_SPOT_ID_KEY = "prkng_checked_in_spot_id"
    static let LAST_CHECKIN_TIME_KEY = "prkng_last_checkin_time"
    static let LAST_CHECKIN_EXPIRE_KEY = "prkng_last_checkin_expire_interval"

    
    static let DEFAULT_NOTIFICATION_TIME = 30
    static let availableCities = ["Montreal", "Quebec City"]

    static func selectedCity() -> String  {
        
        var city = NSUserDefaults.standardUserDefaults().objectForKey(SELECTED_CITY_KEY) as? String
        
        if (city == nil) {
            city = availableCities[0]
            NSUserDefaults.standardUserDefaults().setObject(city, forKey: SELECTED_CITY_KEY)
        }
        
        return city!
    }
    
    static func setSelectedCity (city : String) {
        NSUserDefaults.standardUserDefaults().setObject(city, forKey: SELECTED_CITY_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }    
    
    static func firstUse() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey(FIRST_USE_PASSED_KEY)
    }
    
    static func setFirstUsePassed(firstUsePassed : Bool)  {
        NSUserDefaults.standardUserDefaults().setObject(firstUsePassed, forKey: FIRST_USE_PASSED_KEY)
    }
    
    static func firstCheckin() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey(FIRST_CHECKIN_PASSED_KEY)
    }
    
    static func setFirstCheckinPassed(firstCheckinPassed : Bool)  {
        NSUserDefaults.standardUserDefaults().setObject(firstCheckinPassed, forKey: FIRST_CHECKIN_PASSED_KEY)
    }
    
    static func firstMapUse() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey(FIRST_MAP_USE_PASSED_KEY)
    }
    
    static func setFirstMapUsePassed(firstMapUsePassed : Bool)  {
        NSUserDefaults.standardUserDefaults().setObject(firstMapUsePassed, forKey: FIRST_MAP_USE_PASSED_KEY)
    }
    
    static func notificationTime() -> Int {

        var time = NSUserDefaults.standardUserDefaults().objectForKey(NOTIFICATION_TIME_KEY) as? Int
        
        if (time == nil) {
            time = DEFAULT_NOTIFICATION_TIME
            NSUserDefaults.standardUserDefaults().setObject(time, forKey: NOTIFICATION_TIME_KEY)
        }
        
        return time!
    }
    
    static func setNotificationTime(notificationTime : Int) {
        NSUserDefaults.standardUserDefaults().setObject(notificationTime, forKey: NOTIFICATION_TIME_KEY)
    }
    
    
    static func checkedIn() -> Bool {
        return NSUserDefaults.standardUserDefaults().objectForKey(CHECKED_IN_SPOT_ID_KEY) != nil
    }
    
    static func checkInTimeRemaining() -> NSTimeInterval {
        
        if (!checkedIn()) {
            return NSTimeInterval(0)
        }
        
        
        let expireInterval = NSTimeInterval(NSUserDefaults.standardUserDefaults().doubleForKey(LAST_CHECKIN_EXPIRE_KEY))
        let checkInDate = NSUserDefaults.standardUserDefaults().objectForKey(LAST_CHECKIN_TIME_KEY) as! NSDate
        let now = NSDate()
        
        
        return expireInterval - now.timeIntervalSinceDate(checkInDate)
    }
    
    
    static func saveCheckInData(spot : ParkingSpot?, time : NSDate?) {
        
        if (spot != nil && time != nil) {
            NSUserDefaults.standardUserDefaults().setObject(spot!.identifier, forKey: CHECKED_IN_SPOT_ID_KEY)
            NSUserDefaults.standardUserDefaults().setObject(time!, forKey: LAST_CHECKIN_TIME_KEY)
            NSUserDefaults.standardUserDefaults().setObject(spot?.availableTimeInterval(), forKey: LAST_CHECKIN_EXPIRE_KEY)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(CHECKED_IN_SPOT_ID_KEY)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(LAST_CHECKIN_TIME_KEY)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(LAST_CHECKIN_EXPIRE_KEY)

        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func checkedInSpotId () -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(CHECKED_IN_SPOT_ID_KEY)
    }
    
    static func lastCheckinTime() -> NSDate? {
        
        if (checkedIn()) {
            var time = NSUserDefaults.standardUserDefaults().objectForKey(LAST_CHECKIN_TIME_KEY) as! NSDate
        }
        
        return nil
        
    }
   
    
    static func scheduleAlarm(time : NSDate) {
        
        let alarm = UILocalNotification()
        alarm.alertBody = "alarm_text".localizedString
        alarm.soundName = UILocalNotificationDefaultSoundName
        alarm.fireDate = time
        UIApplication.sharedApplication().scheduleLocalNotification(alarm)
    }
    
    
    static func cancelAlarm() {
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications {
            UIApplication.sharedApplication().cancelLocalNotification(notification as! UILocalNotification)
        }
    }
    
}
