//
//  SpotOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct SpotOperations {
    
    static func getSpotDetails(spotId: String, completion: ((spot:ParkingSpot?) -> Void)) {
        
        let url = APIUtility.rootURL() + "slots/" + spotId
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: nil).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (error == nil) {
                completion(spot: ParkingSpot(json: json))
            } else {
                completion(spot:  nil)
            }
            
        }
        
        
    }
    
    
    static func findSpots(compact compact: Bool, location: CLLocationCoordinate2D, radius : Float, duration : Float?, checkinTime : NSDate?, carsharing: Bool = false, completion: ((spots: [NSObject], mapMessage: String?) -> Void)) {
        
        let url = APIUtility.rootURL() + "slots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let compactString = compact ? "true" : "false"

        let carsharingString = carsharing ? "true" : "false"
        
        var params = ["compact": compactString,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "carsharing" : carsharingString
        ]
        
        //commercial and residential permits!
        var permits = [String]()
        if Settings.shouldFilterForCommercialPermit() {
            permits.append("commercial")
        }
        if Settings.shouldFilterForResidentialPermit() {
            let residentialPermits = Settings.residentialPermits()
            permits.appendContentsOf(residentialPermits)
        }
        params["permit"] = permits.joinWithSeparator(",")
        
        if(duration != nil) {
            let durationStr = NSString(format: "%.1f", duration!)
            NSLog("getting spots with duration: %@", durationStr)
            params["duration"] = durationStr
        }
        
        var time : NSDate
        
        if (checkinTime == nil) {
            time = NSDate()
        } else {
            time = checkinTime!
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        params["checkin"] = formatter.stringFromDate(time)
                
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in

            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
//            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let spotJsons: Array<JSON> = json["features"].arrayValue
            let spots = spotJsons.map({ (spotJson) -> ParkingSpot in
                ParkingSpot(json: spotJson)
            })
            
            let mapMessage = MapMessageView.createMessage(count: spots.count, response: response, error: error, origin: .Spots)
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(spots: spots, mapMessage: mapMessage)

                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }

            })
            
        }
    }
    
    static func checkin (spotId : String, completion: ((completed : Bool) -> Void)) {
        
        let url = APIUtility.rootURL() + "checkins"
        let params = ["slot_id" : spotId]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            let checkin = Checkin(json: json)
            Settings.setCheckInId(checkin.checkinId)
            Settings.saveReservedCarShare(nil)
            completion(completed: error == nil)
        }
    }

    static func checkout (completion: ((completed : Bool) -> Void)) {
        
        let checkinId = Settings.getCheckInId()
        if checkinId != 0 {
           
            let url = APIUtility.rootURL() + "checkins/" + String(stringInterpolationSegment: checkinId)
            
            APIUtility.authenticatedManager().request(.DELETE, url).responseSwiftyJSON { (request, response, json, error) -> Void in
                completion(completed: error == nil)
            }
            
        } else {
            completion(completed: false)
        }
    }

    static func getCheckins(completion : ((checkins : Array<Checkin>?) -> Void)) {
        
        let url = APIUtility.rootURL() + "checkins"
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: nil).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            let checkinJsons: Array<JSON> = json.arrayValue
            let checkins = checkinJsons.map({ (checkinJson) -> Checkin in
                Checkin(json: checkinJson)
            })
            
            completion(checkins: checkins)
            
        }
        
    }
    
    static func hideCheckin(checkinID: Int, completion: ((success: Bool) -> Void)) {
        
        let url = APIUtility.rootURL() + "checkins/" + String(checkinID)
        
        let params = ["is_hidden": true]
        
        APIUtility.authenticatedManager().request(.PUT, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            let success = error == nil && response?.statusCode == 200
            completion(success: success)
        }

    }
    
    static func reportParkingRule (image : UIImage, location : CLLocationCoordinate2D, notes: String, spotId: String?, completion: ((completed : Bool) -> Void)) {
        
        let url = APIUtility.rootURL() + "images"
        let params = ["image_type" : "report",
            "file_name" : "report.jpg"]
        
        // Step one, get request url
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            
            if let requestUrl = json["request_url"].string {
                
                let accessUrl = json["access_url"].stringValue
                
                let data = UIImageJPEGRepresentation(image, 0.8)!
                
                var headers = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
                headers["Content-Type"] = "image/jpeg"
                let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                configuration.HTTPAdditionalHeaders = headers
                let manager = Manager(configuration: configuration)
                
                // Step two, PUT the image to the request url
                manager.upload(.PUT, requestUrl, data : data).responseSwiftyJSON({ (request, response, json, error) -> Void in
     
                    if (response?.statusCode != 200) {
                        completion(completed: false)
                        return
                    }
                    
                    
                    let reportUrl = APIUtility.rootURL() + "reports"
                    
                    var reportParams : [String: AnyObject] = ["latitude" : "\(location.latitude)",
                        "longitude" : "\(location.longitude)",
                        "image_url" : accessUrl,
                        "notes" : notes]
                    
                    if (spotId != nil) {
                        reportParams["slot_id"] = spotId!
                    }
                    
                    // Step three
                    APIUtility.authenticatedManager().request(.POST, reportUrl, parameters: reportParams).responseSwiftyJSON { (request, response, json, error) -> Void in
                        
                        if (response?.statusCode == 201) {
                            completion(completed: true)
                        } else {
                            completion(completed: false)
                        }
                    }
                    
                })
                
            } else {
                    completion(completed: false)
                    return
            }
            
        }
        
        
    }
    
}
