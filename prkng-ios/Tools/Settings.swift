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
    static let LOCATION_MANAGER_LAST_STATUS_KEY = "location_manager_last_status"
    static let TUTORIAL_PASSED_KEY = "prkng_tutorial_passed_key"
    static let FIRST_USE_PASSED_KEY = "prkng_first_use_passed"
    static let FIRST_CHECKIN_PASSED_KEY = "prkng_first_checkin_passed"
    static let FIRST_MAP_USE_PASSED_KEY = "prkng_first_map_use_passed"
    static let FIRST_CAR_SHARING_USE_PASSED_KEY = "prkng_first_car_sharing_use_passed"
    static let DID_PROMPT_USER_TO_RATE_APP_KEY = "prkng_did_prompt_user_to_rate_app"
    static let CHECKIN_COUNT = "prkng_checkin_count"
    static let APP_LAUNCH_COUNT = "prkng_app_launch_count"
    static let CAR_SHARING_FILTER_KEY = "prkng_car_sharing_filter"
    static let GEOFENCE_LAST_SET_DATE_KEY = "prkng_geofence_last_set_date"
    static let NOTIFICATION_NIGHT_BEFORE_KEY = "prkng_notification_night_before"
    static let NOTIFICATION_TIME_KEY = "prkng_notification_time"
    static let CHECKED_IN_SPOT_KEY = "prkng_checked_in_spot"
    static let CHECK_IN_ID_KEY = "prkng_check_in_id"
    static let CHECKED_IN_SPOT_ID_KEY = "prkng_checked_in_spot_id"
    static let LAST_CHECKIN_TIME_KEY = "prkng_last_checkin_time"
    static let LAST_CHECKIN_EXPIRE_KEY = "prkng_last_checkin_expire_interval"
    static let LOG_FILE_PATH_KEY = "prkng_last_log_file_path"
    static let MAP_USER_MODE = "prkng_map_user_mode"
    static let LOCALLY_CACHED_LOTS = "prkng_locally_cached_lots"
    static let LOCALLY_CACHED_LOTS_FRESH = "prkng_locally_cached_lots_fresh"
    static let LAST_APP_VERSION_KEY = "prkng_last_app_version"

    static let DEFAULT_NOTIFICATION_TIME = 30
    static let availableCities = [City.Montreal, City.QuebecCity]
    
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    static let screenScale: CGFloat = UIScreen.mainScreen().scale
    
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
        
        return availableCities.map({ (city) -> CLLocation in
            let point = self.pointForCity(city)
            let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
            return location
        })
    }

    static func logout() {
        AuthUtility.saveAuthToken(nil)
        AuthUtility.saveUser(nil)
        
        UIApplication.sharedApplication().keyWindow!.rootViewController = FirstUseViewController()
    }
    
    static func tutorialPassed() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(TUTORIAL_PASSED_KEY)
    }
    
    static func setTutorialPassed(tutorialPassed : Bool)  {
        NSUserDefaults.standardUserDefaults().setBool(tutorialPassed, forKey: TUTORIAL_PASSED_KEY)
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

    static func firstCarSharingUse() -> Bool {
        return !NSUserDefaults.standardUserDefaults().boolForKey(FIRST_CAR_SHARING_USE_PASSED_KEY)
    }
    
    static func setFirstCarSharingUsePassed(firstCarSharingUsePassed : Bool)  {
        NSUserDefaults.standardUserDefaults().setObject(firstCarSharingUsePassed, forKey: FIRST_CAR_SHARING_USE_PASSED_KEY)
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
        Settings.setCheckInId(0)
        Settings.saveCheckInData(nil, time: nil)
        Settings.cancelScheduledNotifications()
        
    }
    
    static func setCheckInId(checkinId: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(checkinId, forKey: CHECK_IN_ID_KEY)
    }
    
    static func getCheckInId() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(CHECK_IN_ID_KEY)
    }
    
    static func saveCheckInData(spot : ParkingSpot?, time : NSDate?) {
        
        if (spot != nil && time != nil) {
            Settings.incrementNumberOfCheckins()
            do {
                let rawData = try spot!.json.rawData()
                NSUserDefaults.standardUserDefaults().setObject(rawData, forKey: CHECKED_IN_SPOT_KEY)
            } catch {
                DDLoggerWrapper.logError("Could not save raw spot json data to user defaults. Sad face.")
            }
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
    
    static func cacheLotsJson(lots: JSON) {
        do {
            let rawData = try lots.rawData()
            NSUserDefaults.standardUserDefaults().setObject(rawData, forKey: LOCALLY_CACHED_LOTS)
        } catch {
            DDLoggerWrapper.logError("Could not save raw lots json data to user defaults. Sad face.")
        }
    }
    
    static func getCachedLots() -> [Lot] {
        if let archivedLots = NSUserDefaults.standardUserDefaults().objectForKey(LOCALLY_CACHED_LOTS) as? NSData {
            let json = JSON(data: archivedLots)
            let lotJsons: [JSON] = json["features"].arrayValue
            let lots = lotJsons.map({ (lotJson) -> Lot in
                Lot(json: lotJson)
            })
            return lots

        }
        
        return []
    }
    
    static func isCachedLotDataFresh() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(LOCALLY_CACHED_LOTS_FRESH)
    }
    
    static func setCachedLotDataFresh(fresh: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(fresh, forKey: LOCALLY_CACHED_LOTS_FRESH)
    }
    
    static func lastCheckinTime() -> NSDate? {
        
        if (checkedIn()) {
            return NSUserDefaults.standardUserDefaults().objectForKey(LAST_CHECKIN_TIME_KEY) as? NSDate
        }
        
        return nil
        
    }

    static func resetPromptConditions() {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: APP_LAUNCH_COUNT)
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: CHECKIN_COUNT)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: DID_PROMPT_USER_TO_RATE_APP_KEY)
    }
    
    static func shouldPromptUserToRateApp() -> Bool {
        
        let alreadyPromptedUser = NSUserDefaults.standardUserDefaults().boolForKey(DID_PROMPT_USER_TO_RATE_APP_KEY)
        let appLaunches = NSUserDefaults.standardUserDefaults().integerForKey(APP_LAUNCH_COUNT)
        let numberOfCheckins = NSUserDefaults.standardUserDefaults().integerForKey(CHECKIN_COUNT)
        
        if !alreadyPromptedUser && (appLaunches > 5 || numberOfCheckins > 2) {
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: DID_PROMPT_USER_TO_RATE_APP_KEY)
            return true
        }
        
        return false
    }
    
    static func incrementAppLaunches() {
        var appLaunches = NSUserDefaults.standardUserDefaults().integerForKey(APP_LAUNCH_COUNT)
        NSUserDefaults.standardUserDefaults().setInteger(++appLaunches, forKey: APP_LAUNCH_COUNT)
    }

    static func incrementNumberOfCheckins() {
        var numberOfCheckins = NSUserDefaults.standardUserDefaults().integerForKey(CHECKIN_COUNT)
        NSUserDefaults.standardUserDefaults().setInteger(++numberOfCheckins, forKey: CHECKIN_COUNT)
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
        
        Settings.cancelScheduledNotifications()
        
        let alarmTime = time.dateByAddingTimeInterval(NSTimeInterval(-time.seconds()))
        let alarm = UILocalNotification()
        alarm.userInfo = ["identifier": "regular_app_notification"]
        alarm.alertBody = "alarm_text".localizedString
        alarm.soundName = UILocalNotificationDefaultSoundName
        alarm.fireDate = alarmTime
        alarm.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(alarm)
        
    }

    static func scheduleNotification(spot : ParkingSpot) {
        
        Settings.clearRegionsMonitored()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //first of all, stop monitoring all regions
        for monitoredRegion in delegate.locationManager.monitoredRegions as! Set<CLCircularRegion> {
            if monitoredRegion.identifier.rangeOfString("prkng_check_out_monitor") != nil {
                delegate.locationManager.stopMonitoringForRegion(monitoredRegion)
            }
        }

        var locations = spot.line.coordinates
        for coordinate in spot.buttonLocations {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            locations.append(location)
        }
        
        let userLocation = delegate.locationManager.location
        var useUserLocationAsRegion = false
        if userLocation != nil {
            for location in locations {
                //            NSLog("lat: %f, long: %f", location.coordinate.latitude, location.coordinate.longitude)
                if userLocation?.distanceFromLocation(location) < 10 {
                    //then use this as the only region
                    useUserLocationAsRegion = true
                }
            }
        }
        
        //algorithm:
        //find each point's two closest points and determine what its radius should be.
        //if there is only one closest point (or if it is an edge of the line) then take the distance to the single closest point
        //in the future we may wish to restrict this to just the on-screen or more closely tapped area of a line, to avoid too many regoins being generated
        var regions = [CLCircularRegion]()
        
        //determine the distances!
        var minimumDistance: Double = Double.infinity
        var maximumDistance: Double = 0
        for i in 0..<locations.count {
            let firstLocation = locations[i]
            var distances = [Double]()
            
            for j in 0..<locations.count {
                let secondLocation = locations[j]
                if firstLocation != secondLocation {
                    let distance = firstLocation.distanceFromLocation(secondLocation)
                    distances.append(distance)
                    minimumDistance = distance < minimumDistance ? distance : minimumDistance
                    maximumDistance = distance > maximumDistance ? distance : maximumDistance
                }
            }
            
            distances.sortInPlace({ (one, two) -> Bool in return one < two })
            
            let isEdgePoint = (spot.line.coordinates.first != nil && spot.line.coordinates.first! == firstLocation)
                || (spot.line.coordinates.last != nil && spot.line.coordinates.last! == firstLocation)
            
            if isEdgePoint || distances.count == 1 {
                let distance = 0.75 * distances[0]
                let region = CLCircularRegion(center: firstLocation.coordinate, radius: distance, identifier: "prkng_check_out_monitor")
                regions.append(region)
            } else if distances.count > 1 {
                let largerDistance = distances[0] > distances[1] ? distances[0] : distances[1]
                let distance = 0.75 * largerDistance
                let region = CLCircularRegion(center: firstLocation.coordinate, radius: distance, identifier: "prkng_check_out_monitor")
                regions.append(region)
            }
            
        }
        
        if useUserLocationAsRegion {
            let region = CLCircularRegion(center: userLocation!.coordinate, radius: 5, identifier: "prkng_check_out_monitor")
            delegate.locationManager.startMonitoringForRegion(region)
        } else {
            for region in regions {
//                NSLog("starting monitoring for region %@", region.identifier)
                delegate.locationManager.startMonitoringForRegion(region)
            }
        }
        
        let currentDate = NSDate()
        NSUserDefaults.standardUserDefaults().setDouble(currentDate.timeIntervalSinceReferenceDate, forKey: GEOFENCE_LAST_SET_DATE_KEY)
        
    }
    
    static func geofenceLastSetOnInterval() -> NSTimeInterval {
        let double = NSUserDefaults.standardUserDefaults().doubleForKey(GEOFENCE_LAST_SET_DATE_KEY)
        return NSTimeInterval(double) ?? NSDate().timeIntervalSinceReferenceDate
    }

    
    /**
    Cancels only the scheduled notifications that are used for checkout reminders
    */
    static func cancelScheduledNotifications() {
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications ?? [] {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        clearNotificationBadgeAndNotificationCenter()
    }

    static func clearNotificationBadgeAndNotificationCenter() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    static func clearRegionsMonitored() {

        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

        for monitoredRegion in delegate.locationManager.monitoredRegions as! Set<CLCircularRegion> {
            if monitoredRegion.identifier.rangeOfString("prkng_check_out_monitor") != nil {
                delegate.locationManager.stopMonitoringForRegion(monitoredRegion)
            }
        }
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
    
    static func setMapUserMode(mode: MapUserMode) {
        NSUserDefaults.standardUserDefaults().setValue(mode.rawValue, forKey: MAP_USER_MODE)
    }
    
    static func getMapUserMode() -> MapUserMode {
        let rawValue = (NSUserDefaults.standardUserDefaults().valueForKey(MAP_USER_MODE) as? String) ?? "None"
        return MapUserMode(rawValue: rawValue)!
    }

    static func setLastLocationManagerStatus(status: CLAuthorizationStatus) {
        NSUserDefaults.standardUserDefaults().setInteger(Int(status.rawValue), forKey: LOCATION_MANAGER_LAST_STATUS_KEY)
    }
    
    static func getLastLocationManagerStatus() -> CLAuthorizationStatus {
        let rawValue = Int32(NSUserDefaults.standardUserDefaults().integerForKey(LOCATION_MANAGER_LAST_STATUS_KEY))
        return CLAuthorizationStatus(rawValue: rawValue)!
    }
    
    static func setLastAppVersionString(version: String) {
        return NSUserDefaults.standardUserDefaults().setValue(version, forKey: LAST_APP_VERSION_KEY)
    }

    static func getLastAppVersionString() -> String {
        return NSUserDefaults.standardUserDefaults().stringForKey(LAST_APP_VERSION_KEY) ?? ""
    }



}
