//
//  Settings.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 01/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


struct Settings {
    
    static let SELECTED_CITY_KEY = "prkng_selected_city"
    static let LOCATION_MANAGER_LAST_STATUS_KEY = "location_manager_last_status"
    static let TUTORIAL_PASSED_KEY = "prkng_tutorial_passed_key"
    static let FIRST_USE_PASSED_KEY = "prkng_first_use_passed"
    static let FIRST_CHECKIN_PASSED_KEY = "prkng_first_checkin_passed"
    static let FIRST_MAP_USE_PASSED_KEY = "prkng_first_map_use_passed"
    static let FIRST_CAR_SHARING_USE_PASSED_KEY = "prkng_first_car_sharing_use_passed"
    static let CAR_DESCRIPTION_KEY = "prkng_car_description"
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
    static let PARKING_PANDA_USERNAME_KEY = "prkng_parking_panda_username"
    static let PARKING_PANDA_PASSWORD_KEY = "prkng_parking_panda_password"
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
    
    static let iosVersion = NSString(string: UIDevice.current.systemVersion).doubleValue
    static let screenScale: CGFloat = UIScreen.main.scale
    
    static func selectedCity() -> City  {
        
        if let archivedCity = UserDefaults.standard.object(forKey: SELECTED_CITY_KEY) as? Data {
            let json = JSON(data: archivedCity)
            return City(json: json)
        }
        
        return CityOperations.sharedInstance.montreal!
    }
    
    static func setSelectedCity (_ city : City) {
        do {
            let rawData = try city.json.rawData()
            UserDefaults.standard.set(rawData, forKey: SELECTED_CITY_KEY)
            UserDefaults.standard.synchronize()
        } catch {
            DDLoggerWrapper.logError("Could not save raw spot json data to user defaults. Sad face.")
        }
    }

    static func logout() {
        AuthUtility.saveAuthToken(nil)
        AuthUtility.saveUser(nil)
        checkOut()
        
        if UIApplication.shared.keyWindow!.rootViewController is FirstUseViewController {
            return
        } else {
            UIApplication.shared.keyWindow!.rootViewController = FirstUseViewController()
        }
    }
    
    static func tutorialPassed() -> Bool {
        return UserDefaults.standard.bool(forKey: TUTORIAL_PASSED_KEY)
    }
    
    static func setTutorialPassed(_ tutorialPassed : Bool)  {
        UserDefaults.standard.set(tutorialPassed, forKey: TUTORIAL_PASSED_KEY)
    }
    
    static func firstUse() -> Bool {
        return !UserDefaults.standard.bool(forKey: FIRST_USE_PASSED_KEY)
    }
    
    static func setFirstUsePassed(_ firstUsePassed : Bool)  {
        UserDefaults.standard.set(firstUsePassed, forKey: FIRST_USE_PASSED_KEY)
    }
    
    static func firstCheckin() -> Bool {
        return !UserDefaults.standard.bool(forKey: FIRST_CHECKIN_PASSED_KEY)
    }
    
    static func setFirstCheckinPassed(_ firstCheckinPassed : Bool)  {
        UserDefaults.standard.set(firstCheckinPassed, forKey: FIRST_CHECKIN_PASSED_KEY)
    }
    
    static func firstMapUse() -> Bool {
        return !UserDefaults.standard.bool(forKey: FIRST_MAP_USE_PASSED_KEY)
    }
    
    static func setFirstMapUsePassed(_ firstMapUsePassed : Bool)  {
        UserDefaults.standard.set(firstMapUsePassed, forKey: FIRST_MAP_USE_PASSED_KEY)
        UserDefaults.standard.synchronize()
    }

    static func firstCarSharingUse() -> Bool {
        return !UserDefaults.standard.bool(forKey: FIRST_CAR_SHARING_USE_PASSED_KEY)
    }
    
    static func setFirstCarSharingUsePassed(_ firstCarSharingUsePassed : Bool)  {
        UserDefaults.standard.set(firstCarSharingUsePassed, forKey: FIRST_CAR_SHARING_USE_PASSED_KEY)
        UserDefaults.standard.synchronize()
    }

    static func notificationTime() -> Int {

        var time = UserDefaults.standard.object(forKey: NOTIFICATION_TIME_KEY) as? Int
        
        if (time == nil) {
            time = DEFAULT_NOTIFICATION_TIME
            UserDefaults.standard.set(time, forKey: NOTIFICATION_TIME_KEY)
        }
        
        return time!
    }
    
    static func setNotificationTime(_ notificationTime : Int) {
        DDLoggerWrapper.logInfo("Set notification time to " + String(notificationTime))
        UserDefaults.standard.set(notificationTime, forKey: NOTIFICATION_TIME_KEY)
    }
    
    
    static func checkedIn() -> Bool {
        return UserDefaults.standard.object(forKey: CHECKED_IN_SPOT_ID_KEY) != nil
    }
    
    static func checkInTimeRemaining() -> TimeInterval {
        
        if (!checkedIn()) {
            return TimeInterval(0)
        }
        
        
        let expireInterval = TimeInterval(UserDefaults.standard.double(forKey: LAST_CHECKIN_EXPIRE_KEY))
        let checkInDate = UserDefaults.standard.object(forKey: LAST_CHECKIN_TIME_KEY) as! Date
        let now = Date()
        
        
        return expireInterval - now.timeIntervalSince(checkInDate)
    }
    
    static func checkOut() {
        Settings.setCheckInId(0)
        Settings.saveCheckInData(nil, time: nil)
        Settings.cancelScheduledNotifications()
        Settings.clearRegionsMonitored()
    }
    
    static func setCheckInId(_ checkinId: Int) {
        UserDefaults.standard.set(checkinId, forKey: CHECK_IN_ID_KEY)
    }
    
    static func getCheckInId() -> Int {
        return UserDefaults.standard.integer(forKey: CHECK_IN_ID_KEY)
    }
    
    static func saveCheckInData(_ spot : ParkingSpot?, time : Date?) {
        
        if (spot != nil && time != nil) {
            Settings.incrementNumberOfCheckins()
            do {
                let rawData = try spot!.json.rawData()
                UserDefaults.standard.set(rawData, forKey: CHECKED_IN_SPOT_KEY)
            } catch {
                DDLoggerWrapper.logError("Could not save raw spot json data to user defaults. Sad face.")
            }
            UserDefaults.standard.set(spot!.identifier, forKey: CHECKED_IN_SPOT_ID_KEY)
            UserDefaults.standard.set(time!, forKey: LAST_CHECKIN_TIME_KEY)
            UserDefaults.standard.set(spot?.availableTimeInterval(), forKey: LAST_CHECKIN_EXPIRE_KEY)
        } else {
            UserDefaults.standard.removeObject(forKey: CHECKED_IN_SPOT_KEY)
            UserDefaults.standard.removeObject(forKey: CHECKED_IN_SPOT_ID_KEY)
            UserDefaults.standard.removeObject(forKey: LAST_CHECKIN_TIME_KEY)
            UserDefaults.standard.removeObject(forKey: LAST_CHECKIN_EXPIRE_KEY)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    static func checkedInSpotId () -> String? {
        return UserDefaults.standard.string(forKey: CHECKED_IN_SPOT_ID_KEY)
    }
    
    static func checkedInSpot () -> ParkingSpot? {
        if let archivedSpot = UserDefaults.standard.object(forKey: CHECKED_IN_SPOT_KEY) as? Data {
            let json = JSON(data: archivedSpot)
            return ParkingSpot(json: json)
        }
        return nil
    }
    
    static func cacheLotsJson(_ lots: JSON) {
        do {
            let rawData = try lots.rawData()
            UserDefaults.standard.set(rawData, forKey: LOCALLY_CACHED_LOTS_KEY)
        } catch {
            DDLoggerWrapper.logError("Could not save raw lots json data to user defaults. Sad face.")
        }
    }
    
    static func getCachedLots() -> [Lot] {
        if let archivedLots = UserDefaults.standard.object(forKey: LOCALLY_CACHED_LOTS_KEY) as? Data {
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
        return UserDefaults.standard.bool(forKey: LOCALLY_CACHED_LOTS_FRESH_KEY)
    }
    
    static func setCachedLotDataFresh(_ fresh: Bool) {
        UserDefaults.standard.set(fresh, forKey: LOCALLY_CACHED_LOTS_FRESH_KEY)
    }
    
    static func lastCheckinTime() -> Date? {
        
        if (checkedIn()) {
            return UserDefaults.standard.object(forKey: LAST_CHECKIN_TIME_KEY) as? Date
        }
        
        return nil
        
    }
    
    static func saveReservedCarShare(_ carShare: CarShare?) {
        if carShare != nil {
            do {
                let rawData = try carShare!.json.rawData()
                UserDefaults.standard.set(rawData, forKey: RESERVED_CARSHARE_KEY)
                UserDefaults.standard.set(Date().dateByAddingMinutes(30), forKey: RESERVED_CARSHARE_SAVED_TIME_KEY)
            } catch {
                DDLoggerWrapper.logError("Could not save raw car share json data to user defaults. Sad face.")
            }
        } else {
            UserDefaults.standard.removeObject(forKey: RESERVED_CARSHARE_KEY)
            UserDefaults.standard.removeObject(forKey: RESERVED_CARSHARE_SAVED_TIME_KEY)
        }
    }
    
    static func getReservedCarShare() -> CarShare? {
        if let archivedCarShare = UserDefaults.standard.object(forKey: RESERVED_CARSHARE_KEY) as? Data,
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

    static func getReservedCarShareTime() -> Date? {
        return UserDefaults.standard.object(forKey: RESERVED_CARSHARE_SAVED_TIME_KEY) as? Date
    }

    static func resetPromptConditions() {
        UserDefaults.standard.set(0, forKey: APP_LAUNCH_COUNT_KEY)
        UserDefaults.standard.set(0, forKey: CHECKIN_COUNT_KEY)
        UserDefaults.standard.set(false, forKey: DID_PROMPT_USER_TO_RATE_APP_KEY)
    }
    
    static func shouldPromptUserToRateApp() -> Bool {
        
        let alreadyPromptedUser = UserDefaults.standard.bool(forKey: DID_PROMPT_USER_TO_RATE_APP_KEY)
        let appLaunches = UserDefaults.standard.integer(forKey: APP_LAUNCH_COUNT_KEY)
        let numberOfCheckins = UserDefaults.standard.integer(forKey: CHECKIN_COUNT_KEY)
        
        if !alreadyPromptedUser && (appLaunches > 5 || numberOfCheckins > 2) {
            
            UserDefaults.standard.set(true, forKey: DID_PROMPT_USER_TO_RATE_APP_KEY)
            return true
        }
        
        return false
    }
    
    static func incrementAppLaunches() {
        var appLaunches = UserDefaults.standard.integer(forKey: APP_LAUNCH_COUNT_KEY)
        UserDefaults.standard.set(++appLaunches, forKey: APP_LAUNCH_COUNT_KEY)
    }

    static func incrementNumberOfCheckins() {
        var numberOfCheckins = UserDefaults.standard.integer(forKey: CHECKIN_COUNT_KEY)
        UserDefaults.standard.set(++numberOfCheckins, forKey: CHECKIN_COUNT_KEY)
    }

    
    static func shouldFilterForCarSharing() -> Bool {
        return UserDefaults.standard.bool(forKey: CAR_SHARING_FILTER_KEY)
        
    }
    
    static func setShouldFilterForCarSharing(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: CAR_SHARING_FILTER_KEY)
    }

    static func shouldFilterForCommercialPermit() -> Bool {
        return UserDefaults.standard.bool(forKey: COMMERCIAL_PERMIT_FILTER_KEY)
    }
    
    static func setShouldFilterForCommercialPermit(_ value: Bool) {
        DDLoggerWrapper.logInfo("Setting commercial permit " + (value ? "ON" : "OFF"))
        UserDefaults.standard.set(value, forKey: COMMERCIAL_PERMIT_FILTER_KEY)
    }
    
    static func shouldNotifyTheNightBefore() -> Bool {
        if let value = UserDefaults.standard.object(forKey: NOTIFICATION_NIGHT_BEFORE_KEY) as? Bool {
            return value
        } else {
            setShouldNotifyTheNightBefore(true)
            return true
        }
    }
    
    static func setShouldFilterForSnowRemoval(_ value: Bool) {
        DDLoggerWrapper.logInfo("Setting snow removal value " + (value ? "ON" : "OFF"))
        UserDefaults.standard.set(value, forKey: SNOW_REMOVAL_FILTER_KEY)
        UserOperations.sharedInstance.helloItsMe { (completed) -> Void in
        }
    }

    static func shouldFilterForSnowRemoval() -> Bool {
        if let value = UserDefaults.standard.object(forKey: SNOW_REMOVAL_FILTER_KEY) as? Bool {
            return value
        } else {
            setShouldFilterForSnowRemoval(true)
            return true
        }
    }

    static func setShouldFilterForResidentialPermit(_ value: Bool) {
        DDLoggerWrapper.logInfo("Setting residential permit " + (value ? "ON" : "OFF"))
        UserDefaults.standard.set(value, forKey: RESIDENTIAL_PERMIT_FILTER_KEY)
    }
    
    static func shouldFilterForResidentialPermit() -> Bool {
        if let value = UserDefaults.standard.object(forKey: RESIDENTIAL_PERMIT_FILTER_KEY) as? Bool {
            return value
        } else {
            setShouldFilterForResidentialPermit(true)
            return true
        }
    }
    
    static func setResidentialPermit(_ value: String?) {
        DDLoggerWrapper.logInfo("Setting residential permit: " + (value ?? ""))
        UserDefaults.standard.set(value, forKey: RESIDENTIAL_PERMITS_KEY)
    }
    
    static func residentialPermit() -> String? {
        if let value = UserDefaults.standard.object(forKey: RESIDENTIAL_PERMITS_KEY) as? String {
            return value
        }
        return nil
    }

    static func setResidentialPermits(_ value: [String]) {
        let listString = value.joined(separator: ",")
        DDLoggerWrapper.logInfo("Setting residential permits: " + listString)
        UserDefaults.standard.set(listString, forKey: RESIDENTIAL_PERMITS_KEY)
    }
    
    static func residentialPermits() -> [String] {
        if let value = UserDefaults.standard.object(forKey: RESIDENTIAL_PERMITS_KEY) as? String {
            let list = value.split(",")
            return list
        }
        return []
    }

    static func setShouldNotifyTheNightBefore(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: NOTIFICATION_NIGHT_BEFORE_KEY)
    }
    
    static func scheduleNotification(_ time : Date) {
        
        Settings.cancelScheduledNotifications()
        
        let alarmTime = time.addingTimeInterval(TimeInterval(-time.seconds()))
        let alarm = UILocalNotification()
        alarm.userInfo = ["identifier": "regular_app_notification"]
        alarm.alertBody = "alarm_text".localizedString
        alarm.soundName = UILocalNotificationDefaultSoundName
        alarm.fireDate = alarmTime
        alarm.applicationIconBadgeNumber = 1
        UIApplication.shared.scheduleLocalNotification(alarm)
        
    }

    static func scheduleNotification(_ spot : ParkingSpot) {
        
        Settings.clearRegionsMonitored()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        //first of all, stop monitoring all regions
        for monitoredRegion in delegate.locationManager.monitoredRegions as! Set<CLCircularRegion> {
            if monitoredRegion.identifier.range(of: "prkng_check_out_monitor") != nil {
                delegate.locationManager.stopMonitoring(for: monitoredRegion)
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
                if userLocation?.distance(from: location) < 10 {
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
                    let distance = firstLocation.distance(from: secondLocation)
                    distances.append(distance)
                    minimumDistance = distance < minimumDistance ? distance : minimumDistance
                    maximumDistance = distance > maximumDistance ? distance : maximumDistance
                }
            }
            
            distances.sort(by: { (one, two) -> Bool in return one < two })
            
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
            delegate.locationManager.startMonitoring(for: region)
            DDLoggerWrapper.logVerbose("Started monitoring region from user location with id: " + region.identifier)
        } else {
            for region in regions {
                delegate.locationManager.startMonitoring(for: region)
                DDLoggerWrapper.logVerbose("Started monitoring region with id: " + region.identifier)
            }
        }
        
        let currentDate = Date()
        UserDefaults.standard.set(currentDate.timeIntervalSinceReferenceDate, forKey: GEOFENCE_LAST_SET_DATE_KEY)
        
    }
    
    static func geofenceLastSetOnInterval() -> TimeInterval {
        let double = UserDefaults.standard.double(forKey: GEOFENCE_LAST_SET_DATE_KEY)
        return TimeInterval(double) ?? Date().timeIntervalSinceReferenceDate
    }

    
    /**
    Cancels only the scheduled notifications that are used for checkout reminders
    */
    static func cancelScheduledNotifications() {
        for notification in UIApplication.shared.scheduledLocalNotifications ?? [] {
            UIApplication.shared.cancelLocalNotification(notification)
        }
        clearNotificationBadgeAndNotificationCenter()
    }

    static func clearNotificationBadgeAndNotificationCenter() {
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        DDLoggerWrapper.logInfo("Cleared applicaiton icon badge and notification center")
    }
    
    static func clearRegionsMonitored() {

        let delegate = UIApplication.shared.delegate as! AppDelegate
        DDLoggerWrapper.logVerbose(String(format: "Clearing %d monitored regions.", delegate.locationManager.monitoredRegions.count))

        for monitoredRegion in delegate.locationManager.monitoredRegions as! Set<CLCircularRegion> {
            if monitoredRegion.identifier.range(of: "prkng_check_out_monitor") != nil {
                delegate.locationManager.stopMonitoring(for: monitoredRegion)
                DDLoggerWrapper.logVerbose("   Stopped monitoring region with id: " + monitoredRegion.identifier)
            }
        }
        DDLoggerWrapper.logVerbose(String(format: "There are now %d monitored regions.", delegate.locationManager.monitoredRegions.count))
    }
    
    static func hasNotificationBadge() -> Bool {
        return UIApplication.shared.applicationIconBadgeNumber != 0
    }
    
    static func setLogFilePath(_ filePath: String) {
        UserDefaults.standard.set(filePath, forKey: LOG_FILE_PATH_KEY)
    }
    
    static func logFilePath() -> String? {
        if let filePath = UserDefaults.standard.object(forKey: LOG_FILE_PATH_KEY) as? String {
            return filePath
        }
        return nil
    }
    
    static func setMapUserMode(_ mode: MapUserMode) {
        UserDefaults.standard.setValue(mode.rawValue, forKey: MAP_USER_MODE_KEY)
    }
    
    static func getMapUserMode() -> MapUserMode {
        let rawValue = (UserDefaults.standard.value(forKey: MAP_USER_MODE_KEY) as? String) ?? "None"
        return MapUserMode(rawValue: rawValue)!
    }

    static func setLastLocationManagerStatus(_ status: CLAuthorizationStatus) {
        UserDefaults.standard.set(Int(status.rawValue), forKey: LOCATION_MANAGER_LAST_STATUS_KEY)
    }
    
    static func getLastLocationManagerStatus() -> CLAuthorizationStatus {
        let rawValue = Int32(UserDefaults.standard.integer(forKey: LOCATION_MANAGER_LAST_STATUS_KEY))
        return CLAuthorizationStatus(rawValue: rawValue)!
    }
    
    static func setLastAppVersionString(_ version: String) {
        return UserDefaults.standard.setValue(version, forKey: LAST_APP_VERSION_KEY)
    }

    static func getLastAppVersionString() -> String {
        return UserDefaults.standard.string(forKey: LAST_APP_VERSION_KEY) ?? ""
    }

    static func lotMainRateIsHourly() -> Bool {
        return UserDefaults.standard.bool(forKey: PARKING_LOTS_PRICE_DAILY_KEY)
    }
    
    static func setLotMainRateIsHourly(_ isHourly : Bool)  {
        DDLoggerWrapper.logInfo("Set lot main rate to " + (isHourly ? "hourly" : "daily"))
        UserDefaults.standard.set(isHourly, forKey: PARKING_LOTS_PRICE_DAILY_KEY)
    }

    static func communautoCustomerID() -> String? {
        return UserDefaults.standard.string(forKey: COMMUNAUTO_CUSTOMER_ID_KEY)
    }

    static func setCommunautoCustomerID(_ customerID: String?) {
        UserDefaults.standard.set(customerID, forKey: COMMUNAUTO_CUSTOMER_ID_KEY)
    }

    static func automobileProviderNo() -> String? {
        return UserDefaults.standard.string(forKey: AUTOMOBILE_PROVIDER_NO_KEY)
    }

    static func setAutomobileProviderNo(_ providerNo: String?) {
        UserDefaults.standard.set(providerNo, forKey: AUTOMOBILE_PROVIDER_NO_KEY)
    }

    static func car2GoBookingID() -> String? {
        return UserDefaults.standard.string(forKey: CAR2GO_BOOKING_ID_KEY)
    }

    static func car2GoAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: CAR2GO_ACCESS_TOKEN_KEY)
    }
    
    static func car2GoAccessTokenSecret() -> String? {
        return UserDefaults.standard.string(forKey: CAR2GO_ACCESS_TOKEN_SECRET_KEY)
    }
    
    static func setCar2GoBookingID(_ bookingID: String?) {
        UserDefaults.standard.set(bookingID, forKey: CAR2GO_BOOKING_ID_KEY)
    }

    static func setCar2GoAccessToken(_ token: String?) {
        UserDefaults.standard.set(token, forKey: CAR2GO_ACCESS_TOKEN_KEY)
    }

    static func setCar2GoAccessTokenSecret(_ tokenSecret: String?) {
        UserDefaults.standard.set(tokenSecret, forKey: CAR2GO_ACCESS_TOKEN_SECRET_KEY)
    }

    static func hideCar2Go() -> Bool {
        return UserDefaults.standard.bool(forKey: HIDE_CAR2GO_KEY)
    }
    
    static func setHideCar2Go(_ hide : Bool)  {
        DDLoggerWrapper.logInfo("Car2go is now " + (hide ? "hidden" : "shown"))
        UserDefaults.standard.set(hide, forKey: HIDE_CAR2GO_KEY)
    }

    static func hideAutomobile() -> Bool {
        return UserDefaults.standard.bool(forKey: HIDE_AUTOMOBILE_KEY)
    }
    
    static func setHideAutomobile(_ hide : Bool)  {
        DDLoggerWrapper.logInfo("Automobile is now " + (hide ? "hidden" : "shown"))
        UserDefaults.standard.set(hide, forKey: HIDE_AUTOMOBILE_KEY)
    }

    static func hideCommunauto() -> Bool {
        return UserDefaults.standard.bool(forKey: HIDE_COMMUNAUTO_KEY)
    }
    
    static func setHideCommunauto(_ hide : Bool)  {
        DDLoggerWrapper.logInfo("Communauto is now " + (hide ? "hidden" : "shown"))
        UserDefaults.standard.set(hide, forKey: HIDE_COMMUNAUTO_KEY)
    }

    static func hideZipcar() -> Bool {
        return UserDefaults.standard.bool(forKey: HIDE_ZIPCAR_KEY)
    }
    
    static func setHideZipcar(_ hide : Bool)  {
        DDLoggerWrapper.logInfo("Zipcar is now " + (hide ? "hidden" : "shown"))
        UserDefaults.standard.set(hide, forKey: HIDE_ZIPCAR_KEY)
    }
    
    static func setParkingPandaCredentials(username: String?, password: String?) {
        UserDefaults.standard.set(username, forKey: PARKING_PANDA_USERNAME_KEY)
        UserDefaults.standard.set(password, forKey: PARKING_PANDA_PASSWORD_KEY)
    }
    
    static func getParkingPandaCredentials() -> (String?, String?) {
        let username = UserDefaults.standard.object(forKey: PARKING_PANDA_USERNAME_KEY) as? String
        let password = UserDefaults.standard.object(forKey: PARKING_PANDA_PASSWORD_KEY) as? String
        return (username, password)
    }

    static func setCarDescription(_ description: [String: String]) {
        UserDefaults.standard.set(description, forKey: CAR_DESCRIPTION_KEY)
    }

    static func getCarDescription() -> [String: String] {
        if let description = UserDefaults.standard.object(forKey: CAR_DESCRIPTION_KEY) as? [String: String] {
            return description
        }
        return [String: String]()
    }

}
