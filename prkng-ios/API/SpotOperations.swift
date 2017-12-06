//
//  SpotOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct SpotOperations {
    
    static func getSpotDetails(_ spotId: String, completion: @escaping ((_ spot:ParkingSpot?) -> Void)) {
        
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
    
    
    static func findSpots(compact: Bool, location: CLLocationCoordinate2D, radius : Float, duration : Float?, checkinTime : Date?, carsharing: Bool = false, completion: @escaping ((_ spots: [NSObject], _ mapMessage: String?) -> Void)) {
        
        let url = APIUtility.rootURL() + "slots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let compactString = compact ? "true" : "false"

        let carsharingString = carsharing ? "true" : "false"
        
        var params = ["compact": compactString,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "carsharing" : carsharingString
        ] as [String : Any]
        
        //commercial and residential permits!
        var permits = [String]()
        if Settings.shouldFilterForCommercialPermit() {
            permits.append("commercial")
        }
        if Settings.shouldFilterForResidentialPermit() {
            let residentialPermits = Settings.residentialPermits()
            permits.append(contentsOf: residentialPermits)
        }
        params["permit"] = permits.joined(separator: ",")
        
        if(duration != nil) {
            let durationStr = NSString(format: "%.1f", duration!)
            NSLog("getting spots with duration: %@", durationStr)
            params["duration"] = durationStr
        }
        
        var time : Date
        
        if (checkinTime == nil) {
            time = Date()
        } else {
            time = checkinTime!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US")
        params["checkin"] = formatter.string(from: time)
                
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
            (request, response, json, error) in

            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
//            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let spotJsons: Array<JSON> = json["features"].arrayValue
            let spots = spotJsons.map({ (spotJson) -> ParkingSpot in
                ParkingSpot(json: spotJson)
            })
            
            let mapMessage = MapMessageView.createMessage(count: spots.count, response: response, error: error, origin: .spots)
            
            DispatchQueue.main.async(execute: {
                () -> Void in
                completion(spots: spots, mapMessage: mapMessage)

                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }

            })
            
        }
    }
    
    static func checkin (_ spotId : String, completion: @escaping ((_ completed : Bool) -> Void)) {
        
        let url = APIUtility.rootURL() + "checkins"
        let params = ["slot_id" : spotId]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            let checkin = Checkin(json: json)
            Settings.setCheckInId(checkin.checkinId)
            Settings.saveReservedCarShare(nil)
            completion(completed: error == nil)
        }
    }

    static func checkout (_ completion: @escaping ((_ completed : Bool) -> Void)) {
        
        let checkinId = Settings.getCheckInId()
        if checkinId != 0 {
           
            let url = APIUtility.rootURL() + "checkins/" + String(stringInterpolationSegment: checkinId)
            
            APIUtility.authenticatedManager().request(.DELETE, url).responseSwiftyJSON { (request, response, json, error) -> Void in
                completion(completed: error == nil)
            }
            
        } else {
            completion(false)
        }
    }

    static func getCheckins(_ completion : @escaping ((_ checkins : Array<Checkin>?) -> Void)) {
        
        let url = APIUtility.rootURL() + "checkins"
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: nil).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            let checkinJsons: Array<JSON> = json.arrayValue
            let checkins = checkinJsons.map({ (checkinJson) -> Checkin in
                Checkin(json: checkinJson)
            })
            
            completion(checkins: checkins)
            
        }
        
    }
    
    static func hideCheckin(_ checkinID: Int, completion: @escaping ((_ success: Bool) -> Void)) {
        
        let url = APIUtility.rootURL() + "checkins/" + String(checkinID)
        
        let params = ["is_hidden": true]
        
        APIUtility.authenticatedManager().request(.PUT, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            let success = error == nil && response?.statusCode == 200
            completion(success: success)
        }

    }
    
    static func reportParkingRule (_ image : UIImage, location : CLLocationCoordinate2D, notes: String, spotId: String?, completion: @escaping ((_ completed : Bool) -> Void)) {
        
        let url = APIUtility.rootURL() + "images"
        let params = ["image_type" : "report",
            "file_name" : "report.jpg"]
        
        // Step one, get request url
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            
            if let requestUrl = json["request_url"].string {
                
                let accessUrl = json["access_url"].stringValue
                
                let data = UIImageJPEGRepresentation(image, 0.8)!
                
                var headers = Manager.sharedInstance.session.configuration.httpAdditionalHeaders ?? [:]
                headers["Content-Type"] = "image/jpeg"
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = headers
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
