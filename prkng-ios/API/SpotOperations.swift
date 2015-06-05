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
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        params["checkin"] = formatter.stringFromDate(time)
        
        request(.GET, url, parameters: params).responseSwiftyJSON() {
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

        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            completion(completed: error != nil)
        }
    }
    
}
