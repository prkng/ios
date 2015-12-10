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
    static let LOCATION_MANAGER_LAST_STATUS_KEY = "location_manager_last_status"
    static let TUTORIAL_PASSED_KEY = "prkng_tutorial_passed_key"
    static let FIRST_USE_PASSED_KEY = "prkng_first_use_passed"
    static let FIRST_CHECKIN_PASSED_KEY = "prkng_first_checkin_passed"
    static let FIRST_MAP_USE_PASSED_KEY = "prkng_first_map_use_passed"
    static let FIRST_CAR_SHARING_USE_PASSED_KEY = "prkng_first_car_sharing_use_passed"
    static let DID_PROMPT_USER_TO_RATE_APP_KEY = "prkng_did_prompt_user_to_rate_app"
    static let PARKING_LOTS_PRICE_DAILY_KEY = "prkng_parking_lots_price_daily"
    static let RESERVED_CARSHARE_KEY = "prkng_reserved_carshare"
    static let RESERVED_CARSHARE_SAVED_TIME_KEY = "prkng_reserved_carshare_saved_time"
    static let AUTOMOBILE_PROVIDER_NO_KEY = "prkng_automobile_provider_no"
    static let COMMUNAUTO_CUSTOMER_ID_KEY = "prkng_communauto_customer_id"
    static let CAR2GO_BOOKING_ID_KEY = "prkng_car2go_booking_id"
    static let CAR2GO_ACCESS_TOKEN_KEY = "prkng_car2go_access_token"
    static let CAR2GO_ACCESS_TOKEN_SECRET_KEY = "prkng_car2go_access_token_secret"
    static let HIDE_CAR2GO_KEY = "prkng_hide_car2go"
    static let HIDE_COMMUNAUTO_KEY = "prkng_hide_communauto"
    static let HIDE_AUTOMOBILE_KEY = "prkng_hide_automobile"
    static let HIDE_ZIPCAR_KEY = "prkng_hide_zipcar"
    static let CHECKIN_COUNT_KEY = "prkng_checkin_count"
    static let APP_LAUNCH_COUNT_KEY = "prkng_app_launch_count"
    static let CAR_SHARING_FILTER_KEY = "prkng_car_sharing_filter"
    static let COMMERCIAL_PERMIT_FILTER_KEY = "prkng_commercial_permit_filter"
    static let SNOW_REMOVAL_FILTER_KEY = "prkng_snow_removal_filter"
    static let RESIDENTIAL_PERMIT_FILTER_KEY = "prkng_residential_permit_filter"
    static let RESIDENTIAL_PERMITS_KEY = "prkng_commercial_permits"
    static let GEOFENCE_LAST_SET_DATE_KEY = "prkng_geofence_last_set_date"
    static let NOTIFICATION_NIGHT_BEFORE_KEY = "prkng_notification_night_before"
    static let NOTIFICATION_TIME_KEY = "prkng_notification_time"
    static let CHECKED_IN_SPOT_KEY = "prkng_checked_in_spot"
    static let CHECK_IN_ID_KEY = "prkng_check_in_id"
    static let CHECKED_IN_SPOT_ID_KEY = "prkng_checked_in_spot_id"
    static let LAST_CHECKIN_TIME_KEY = "prkng_last_checkin_time"
    static let LAST_CHECKIN_EXPIRE_KEY = "prkng_last_checkin_expire_interval"
    static let LOG_FILE_PATH_KEY = "prkng_last_log_file_path"
    static let MAP_USER_MODE_KEY = "prkng_map_user_mode"
    static let LOCALLY_CACHED_LOTS_KEY = "prkng_locally_cached_lots"
    static let LOCALLY_CACHED_LOTS_FRESH_KEY = "prkng_locally_cached_lots_fresh"
    static let LAST_APP_VERSION_KEY = "prkng_last_app_version"

    static let DEFAULT_NOTIFICATION_TIME = 30
    
    static let iosVersion = NSString(string: UIDevice.currentDevice().systemVersion).doubleValue
    static let screenScale: CGFloat = UIScreen.mainScreen().scale
    
    static func selectedCity() -> City  {
        
        if let archivedCity = NSUserDefaults.standardUserDefaults().objectForKey(SELECTED_CITY_KEY) as? NSData {
            let json = JSON(data: archivedCity)
            return City(json: json)
        }
        
        return CityOperations.sharedInstance.montreal!
    }
    
    static func setSelectedCity (city : City) {
        do {
            let rawData = try city.json.rawData()
            NSUserDefaults.standardUserDefaults().setObject(rawData, forKey: SELECTED_CITY_KEY)
            NSUserDefaults.standardUserDefaults().synchronize()
        } catch {
            DDLoggerWrapper.logError("Could not save raw spot json data to user defaults. Sad face.")
        }
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
        DDLoggerWrapper.logInfo("Set notification time to " + String(notificationTime))
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
        Settings.clearRegionsMonitored()
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
            NSUserDefaults.standardUserDefaults().setObject(rawData, forKey: LOCALLY_CACHED_LOTS_KEY)
        } catch {
            DDLoggerWrapper.logError("Could not save raw lots json data to user defaults. Sad face.")
        }
    }
    
    static func getCachedLots() -> [Lot] {
        if let archivedLots = NSUserDefaults.standardUserDefaults().objectForKey(LOCALLY_CACHED_LOTS_KEY) as? NSData {
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
        return NSUserDefaults.standardUserDefaults().boolForKey(LOCALLY_CACHED_LOTS_FRESH_KEY)
    }
    
    static func setCachedLotDataFresh(fresh: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(fresh, forKey: LOCALLY_CACHED_LOTS_FRESH_KEY)
    }
    
    static func lastCheckinTime() -> NSDate? {
        
        if (checkedIn()) {
            return NSUserDefaults.standardUserDefaults().objectForKey(LAST_CHECKIN_TIME_KEY) as? NSDate
        }
        
        return nil
        
    }
    
    static func saveReservedCarShare(carShare: CarShare?) {
        if carShare != nil {
            do {
                let rawData = try carShare!.json.rawData()
                NSUserDefaults.standardUserDefaults().setObject(rawData, forKey: RESERVED_CARSHARE_KEY)
                NSUserDefaults.standardUserDefaults().setObject(NSDate().dateByAddingMinutes(30), forKey: RESERVED_CARSHARE_SAVED_TIME_KEY)
            } catch {
                DDLoggerWrapper.logError("Could not save raw car share json data to user defaults. Sad face.")
            }
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(RESERVED_CARSHARE_KEY)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(RESERVED_CARSHARE_SAVED_TIME_KEY)
        }
    }
    
    static func getReservedCarShare() -> CarShare? {
        if let archivedCarShare = NSUserDefaults.standardUserDefaults().objectForKey(RESERVED_CARSHARE_KEY) as? NSData,
        let time = getReservedCarShareTime() {
            let minutes = time.timeIntervalSinceNow / 60
            if minutes < 0 {
                saveReservedCarShare(nil)
                return nil
            } else {
                let json = JSON(data: archivedCarShare)
                return CarShare(json: json)
            }
        }
        return nil
    }

    static func getReservedCarShareTime() -> NSDate? {
        return NSUserDefaults.standardUserDefaults().objectForKey(RESERVED_CARSHARE_SAVED_TIME_KEY) as? NSDate
    }

    static func resetPromptConditions() {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: APP_LAUNCH_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: CHECKIN_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: DID_PROMPT_USER_TO_RATE_APP_KEY)
    }
    
    static func shouldPromptUserToRateApp() -> Bool {
        
        let alreadyPromptedUser = NSUserDefaults.standardUserDefaults().boolForKey(DID_PROMPT_USER_TO_RATE_APP_KEY)
        let appLaunches = NSUserDefaults.standardUserDefaults().integerForKey(APP_LAUNCH_COUNT_KEY)
        let numberOfCheckins = NSUserDefaults.standardUserDefaults().integerForKey(CHECKIN_COUNT_KEY)
        
        if !alreadyPromptedUser && (appLaunches > 5 || numberOfCheckins > 2) {
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: DID_PROMPT_USER_TO_RATE_APP_KEY)
            return true
        }
        
        return false
    }
    
    static func incrementAppLaunches() {
        var appLaunches = NSUserDefaults.standardUserDefaults().integerForKey(APP_LAUNCH_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().setInteger(++appLaunches, forKey: APP_LAUNCH_COUNT_KEY)
    }

    static func incrementNumberOfCheckins() {
        var numberOfCheckins = NSUserDefaults.standardUserDefaults().integerForKey(CHECKIN_COUNT_KEY)
        NSUserDefaults.standardUserDefaults().setInteger(++numberOfCheckins, forKey: CHECKIN_COUNT_KEY)
    }

    
    static func shouldFilterForCarSharing() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(CAR_SHARING_FILTER_KEY)
        
    }
    
    static func setShouldFilterForCarSharing(value: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: CAR_SHARING_FILTER_KEY)
    }

    static func shouldFilterForCommercialPermit() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(COMMERCIAL_PERMIT_FILTER_KEY)
    }
    
    static func setShouldFilterForCommercialPermit(value: Bool) {
        DDLoggerWrapper.logInfo("Setting commercial permit " + (value ? "ON" : "OFF"))
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: COMMERCIAL_PERMIT_FILTER_KEY)
    }
    
    static func shouldNotifyTheNightBefore() -> Bool {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(NOTIFICATION_NIGHT_BEFORE_KEY) as? Bool {
            return value
        } else {
            setShouldNotifyTheNightBefore(true)
            return true
        }
    }
    
    static func setShouldFilterForSnowRemoval(value: Bool) {
        DDLoggerWrapper.logInfo("Setting snow removal value " + (value ? "ON" : "OFF"))
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: SNOW_REMOVAL_FILTER_KEY)
    }

    static func shouldFilterForSnowRemoval() -> Bool {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(SNOW_REMOVAL_FILTER_KEY) as? Bool {
            return value
        } else {
            setShouldFilterForSnowRemoval(true)
            return true
        }
    }

    static func setShouldFilterForResidentialPermit(value: Bool) {
        DDLoggerWrapper.logInfo("Setting residential permit " + (value ? "ON" : "OFF"))
        NSUserDefaults.standardUserDefaults().setBool(value, forKey: RESIDENTIAL_PERMIT_FILTER_KEY)
    }
    
    static func shouldFilterForResidentialPermit() -> Bool {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(RESIDENTIAL_PERMIT_FILTER_KEY) as? Bool {
            return value
        } else {
            setShouldFilterForResidentialPermit(true)
            return true
        }
    }
    
    static func setResidentialPermit(value: String?) {
        DDLoggerWrapper.logInfo("Setting residential permit: " + (value ?? ""))
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: RESIDENTIAL_PERMITS_KEY)
    }
    
    static func residentialPermit() -> String? {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(RESIDENTIAL_PERMITS_KEY) as? String {
            return value
        }
        return nil
    }

    static func setResidentialPermits(value: [String]) {
        let listString = value.joinWithSeparator(",")
        DDLoggerWrapper.logInfo("Setting residential permits: " + listString)
        NSUserDefaults.standardUserDefaults().setObject(listString, forKey: RESIDENTIAL_PERMITS_KEY)
    }
    
    static func residentialPermits() -> [String] {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey(RESIDENTIAL_PERMITS_KEY) as? String {
            let list = value.split(",")
            return list
        }
        return []
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
                DDLoggerWrapper.logWarning("Found a region that should have already been removed... ")
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
            DDLoggerWrapper.logVerbose("Started monitoring region from user location with id: " + region.identifier)
        } else {
            for region in regions {
                delegate.locationManager.startMonitoringForRegion(region)
                DDLoggerWrapper.logVerbose("Started monitoring region with id: " + region.identifier)
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
        DDLoggerWrapper.logInfo("Cleared applicaiton icon badge and notification center")
    }
    
    static func clearRegionsMonitored() {

        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        DDLoggerWrapper.logVerbose(String(format: "Clearing %d monitored regions.", delegate.locationManager.monitoredRegions.count))

        for monitoredRegion in delegate.locationManager.monitoredRegions as! Set<CLCircularRegion> {
            if monitoredRegion.identifier.rangeOfString("prkng_check_out_monitor") != nil {
                delegate.locationManager.stopMonitoringForRegion(monitoredRegion)
                DDLoggerWrapper.logVerbose("   Stopped monitoring region with id: " + monitoredRegion.identifier)
            }
        }
        DDLoggerWrapper.logVerbose(String(format: "There are now %d monitored regions.", delegate.locationManager.monitoredRegions.count))
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
        NSUserDefaults.standardUserDefaults().setValue(mode.rawValue, forKey: MAP_USER_MODE_KEY)
    }
    
    static func getMapUserMode() -> MapUserMode {
        let rawValue = (NSUserDefaults.standardUserDefaults().valueForKey(MAP_USER_MODE_KEY) as? String) ?? "None"
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

    static func lotMainRateIsHourly() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(PARKING_LOTS_PRICE_DAILY_KEY)
    }
    
    static func setLotMainRateIsHourly(isHourly : Bool)  {
        DDLoggerWrapper.logInfo("Set lot main rate to " + (isHourly ? "hourly" : "daily"))
        NSUserDefaults.standardUserDefaults().setBool(isHourly, forKey: PARKING_LOTS_PRICE_DAILY_KEY)
    }

    static func communautoCustomerID() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(COMMUNAUTO_CUSTOMER_ID_KEY)
    }

    static func setCommunautoCustomerID(customerID: String?) {
        NSUserDefaults.standardUserDefaults().setObject(customerID, forKey: COMMUNAUTO_CUSTOMER_ID_KEY)
    }

    static func automobileProviderNo() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(AUTOMOBILE_PROVIDER_NO_KEY)
    }

    static func setAutomobileProviderNo(providerNo: String?) {
        NSUserDefaults.standardUserDefaults().setObject(providerNo, forKey: AUTOMOBILE_PROVIDER_NO_KEY)
    }

    static func car2GoBookingID() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(CAR2GO_BOOKING_ID_KEY)
    }

    static func car2GoAccessToken() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(CAR2GO_ACCESS_TOKEN_KEY)
    }
    
    static func car2GoAccessTokenSecret() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(CAR2GO_ACCESS_TOKEN_SECRET_KEY)
    }
    
    static func setCar2GoBookingID(bookingID: String?) {
        NSUserDefaults.standardUserDefaults().setObject(bookingID, forKey: CAR2GO_BOOKING_ID_KEY)
    }

    static func setCar2GoAccessToken(token: String?) {
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: CAR2GO_ACCESS_TOKEN_KEY)
    }

    static func setCar2GoAccessTokenSecret(tokenSecret: String?) {
        NSUserDefaults.standardUserDefaults().setObject(tokenSecret, forKey: CAR2GO_ACCESS_TOKEN_SECRET_KEY)
    }

    static func hideCar2Go() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HIDE_CAR2GO_KEY)
    }
    
    static func setHideCar2Go(hide : Bool)  {
        DDLoggerWrapper.logInfo("Car2go is now " + (hide ? "hidden" : "shown"))
        NSUserDefaults.standardUserDefaults().setBool(hide, forKey: HIDE_CAR2GO_KEY)
    }

    static func hideAutomobile() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HIDE_AUTOMOBILE_KEY)
    }
    
    static func setHideAutomobile(hide : Bool)  {
        DDLoggerWrapper.logInfo("Automobile is now " + (hide ? "hidden" : "shown"))
        NSUserDefaults.standardUserDefaults().setBool(hide, forKey: HIDE_AUTOMOBILE_KEY)
    }

    static func hideCommunauto() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HIDE_COMMUNAUTO_KEY)
    }
    
    static func setHideCommunauto(hide : Bool)  {
        DDLoggerWrapper.logInfo("Communauto is now " + (hide ? "hidden" : "shown"))
        NSUserDefaults.standardUserDefaults().setBool(hide, forKey: HIDE_COMMUNAUTO_KEY)
    }

    static func hideZipcar() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(HIDE_ZIPCAR_KEY)
    }
    
    static func setHideZipcar(hide : Bool)  {
        DDLoggerWrapper.logInfo("Zipcar is now " + (hide ? "hidden" : "shown"))
        NSUserDefaults.standardUserDefaults().setBool(hide, forKey: HIDE_ZIPCAR_KEY)
    }

}
