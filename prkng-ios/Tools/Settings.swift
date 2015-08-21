//
//  Settings.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 01/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct Settings {
    
    enum City: String {
        case Montreal = "Montréal"
        case QuebecCity = "Québec City"
    }
    
    static let SELECTED_CITY_KEY = "prkng_selected_city"
    static let FIRST_USE_PASSED_KEY = "prkng_first_use_passed"
    static let FIRST_CHECKIN_PASSED_KEY = "prkng_first_checkin_passed"
    static let FIRST_MAP_USE_PASSED_KEY = "prkng_first_map_use_passed"
    static let CAR_SHARING_FILTER_KEY = "prkng_car_sharing_filter"
    static let NOTIFICATION_NIGHT_BEFORE_KEY = "prkng_notification_night_before"
    static let NOTIFICATION_TIME_KEY = "prkng_notification_time"
    static let CHECKED_IN_SPOT_KEY = "prkng_checked_in_spot"
    static let CHECKED_IN_SPOT_ID_KEY = "prkng_checked_in_spot_id"
    static let LAST_CHECKIN_TIME_KEY = "prkng_last_checkin_time"
    static let LAST_CHECKIN_EXPIRE_KEY = "prkng_last_checkin_expire_interval"
    static let LOG_FILE_PATH_KEY = "prkng_last_log_file_path"
    static let MAP_USER_MODE = "prkng_map_user_mode"

    static let DEFAULT_NOTIFICATION_TIME = 30
    static let availableCities = [City.Montreal, City.QuebecCity]
    
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue

    static func selectedCity() -> City  {
        
        var city = NSUserDefaults.standardUserDefaults().objectForKey(SELECTED_CITY_KEY) as? String
        
        if (city == nil) {
            city = availableCities[0].rawValue
            NSUserDefaults.standardUserDefaults().setObject(city, forKey: SELECTED_CITY_KEY)
        }
        
        let actualCity = City(rawValue: city!)
        
        return actualCity!
    }
    
    static func setSelectedCity (city : City) {
        NSUserDefaults.standardUserDefaults().setObject(city.rawValue, forKey: SELECTED_CITY_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func selectedCityPoint() -> CLLocationCoordinate2D {
        return pointForCity(selectedCity())
    }
    
    static func pointForCity(city: City) -> CLLocationCoordinate2D {
        switch city {
        case .Montreal:
            return CLLocationCoordinate2D(latitude: 45.5016889, longitude: -73.567256)
        case .QuebecCity:
            return CLLocationCoordinate2D(latitude: 46.82053904, longitude: -71.22943997)
        }
    }
    
    static func setClosestSelectedCity(point: CLLocationCoordinate2D) {
        var shortestDistance = Double.infinity
        var closestCity: City?
        let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
        for city in availableCities {
            let cityPoint = pointForCity(city)
            let cityLocation = CLLocation(latitude: cityPoint.latitude, longitude: cityPoint.longitude)
            let distance = cityLocation.distanceFromLocation(location)
            if distance < shortestDistance {
                shortestDistance = distance
                closestCity = city
            }
        }
        
        setSelectedCity(closestCity!)
    }
    
    static func availableCityLocations() -> [CLLocation] {
        
        return availableCities.map({ (var city) -> CLLocation in
            let point = self.pointForCity(city)
            let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
            return location
        })
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
        NSUserDefaults.standardUserDefaults().synchronize()
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
    
    static func checkOut() {
        Settings.saveCheckInData(nil, time: nil)
        Settings.cancelNotification()
    }
    
    static func saveCheckInData(spot : ParkingSpot?, time : NSDate?) {
        
        if (spot != nil && time != nil) {
            NSUserDefaults.standardUserDefaults().setObject(spot!.json.rawData(), forKey: CHECKED_IN_SPOT_KEY)
            NSUserDefaults.standardUserDefaults().setObject(spot!.identifier, forKey: CHECKED_IN_SPOT_ID_KEY)
            NSUserDefaults.standardUserDefaults().setObject(time!, forKey: LAST_CHECKIN_TIME_KEY)
            NSUserDefaults.standardUserDefaults().setObject(spot?.availableTimeInterval(), forKey: LAST_CHECKIN_EXPIRE_KEY)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(CHECKED_IN_SPOT_KEY)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(CHECKED_IN_SPOT_ID_KEY)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(LAST_CHECKIN_TIME_KEY)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(LAST_CHECKIN_EXPIRE_KEY)

        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func checkedInSpotId () -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(CHECKED_IN_SPOT_ID_KEY)
    }
    
    static func checkedInSpot () -> ParkingSpot? {
        if let archivedSpot = NSUserDefaults.standardUserDefaults().objectForKey(CHECKED_IN_SPOT_KEY) as? NSData {
            let json = JSON(data: archivedSpot)
            return ParkingSpot(json: json)
        }
        return nil
    }
    
    static func lastCheckinTime() -> NSDate? {
        
        if (checkedIn()) {
            var time = NSUserDefaults.standardUserDefaults().objectForKey(LAST_CHECKIN_TIME_KEY) as! NSDate
        }
        
        return nil
        
    }
   
    
    static func shouldFilterForCarSharing() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(CAR_SHARING_FILTER_KEY)
        
    }
    
    static func setShouldFilterForCarSharing(value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: CAR_SHARING_FILTER_KEY)
    }

    
    static func shouldNotifyTheNightBefore() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(NOTIFICATION_NIGHT_BEFORE_KEY)
        
    }

    static func setShouldNotifyTheNightBefore(value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: NOTIFICATION_NIGHT_BEFORE_KEY)
    }
    
    static func scheduleNotification(time : NSDate) {
        
        Settings.cancelNotification()
        
        let alarmTime = time.dateByAddingTimeInterval(NSTimeInterval(-time.seconds()))
        let alarm = UILocalNotification()
        alarm.alertBody = "alarm_text".localizedString
        alarm.soundName = UILocalNotificationDefaultSoundName
        alarm.fireDate = alarmTime
        alarm.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(alarm)
        
    }
    
    
    static func cancelNotification() {
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications {
            UIApplication.sharedApplication().cancelLocalNotification(notification as! UILocalNotification)
        }
        clearNotificationBadge()
    }
    
    static func clearNotificationBadge() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    static func hasNotificationBadge() -> Bool {
        return UIApplication.sharedApplication().applicationIconBadgeNumber != 0
    }
    
    static func setLogFilePath(filePath: String) {
        NSUserDefaults.standardUserDefaults().setObject(filePath, forKey: LOG_FILE_PATH_KEY)
    }
    
    static func logFilePath() -> String? {
        if let filePath = NSUserDefaults.standardUserDefaults().objectForKey(LOG_FILE_PATH_KEY) as? String {
            return filePath
        }
        return nil
    }
    
    static func iOS8OrLater() -> Bool {
        if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
            return true
        }
        return false
    }
    
    static func setMapUserMode(mode: MapUserMode) {
        NSUserDefaults.standardUserDefaults().setValue(mode.rawValue, forKey: MAP_USER_MODE)
    }
    
    static func getMapUserMode() -> MapUserMode {
        let rawValue = (NSUserDefaults.standardUserDefaults().valueForKey(MAP_USER_MODE) as? String) ?? "None"
        return MapUserMode(rawValue: rawValue)!
    }
    

}
