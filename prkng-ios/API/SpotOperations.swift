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
        
        let url = APIUtility.APIConstants.rootURLString + "slot/" + spotId
        
        request(.GET, url, parameters: nil).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (error == nil) {
                completion(spot: ParkingSpot(json: json))
            } else {
                completion(spot:  nil)
            }
            
        }
        
        
    }
    
    
    static func findSpots(location: CLLocationCoordinate2D, radius : Float, duration : Float?, checkinTime : NSDate?, completion: ((spots:Array<ParkingSpot>) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "slots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        
        var params = ["latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr
        ]
        
        
        if(duration != nil) {
            let durationStr = NSString(format: "%.0f", duration!)
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
        params["checkin"] = formatter.stringFromDate(time)
        
        request(.GET, url, parameters: params).responseSwiftyJSONAsync(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in

            var spotJsons: Array<JSON> = json["features"].arrayValue
            var spots = spotJsons.map({ (var spotJson) -> ParkingSpot in
                ParkingSpot(json: spotJson)
            })
            

            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(spots: spots)
            })
            
        }
    }
    
    static func checkin (spotId : String, completion: ((completed : Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "slot/checkin"
        let params = ["slot_id" : spotId]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            completion(completed: error != nil)
        }
    }
    
    static func getCheckins(completion : ((checkins : Array<Checkin>?) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "slot/checkin"
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: nil).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            var checkinJsons: Array<JSON> = json.arrayValue
            var checkins = checkinJsons.map({ (var checkinJson) -> Checkin in
                Checkin(json: checkinJson)
            })
            
            completion(checkins: checkins)
            
        }
        
    }
    
    static func reportParkingRule (image : UIImage, location : CLLocationCoordinate2D, spotId: String?, completion: ((completed : Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "image"
        let params = ["image_type" : "report",
            "file_name" : "report.jpg"]
        
        // Step one, get request url
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            
            if let requestUrl = json["request_url"].string {
                
                let accessUrl = json["access_url"].stringValue
                
                let data = UIImageJPEGRepresentation(image, 0.8)
                
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
                    
                    
                    let reportUrl = APIUtility.APIConstants.rootURLString + "report"
                    
                    var reportParams : [String: AnyObject] = ["latitude" : "\(location.latitude)",
                        "longitude" : "\(location.longitude)",
                        "image_url" : accessUrl]
                    
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
