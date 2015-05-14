//
//  SpotOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SpotOperations {
    
    class func getSpot(identifier: NSString) {
        
    }
    
    class func findSpots(location: CLLocationCoordinate2D, radius : Float, duration : Float?, checkinTime : NSDate?, completion: ((spots:Array<ParkingSpot>) -> Void)) {
        
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
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        params["checkinTime"] = formatter.stringFromDate(time)
        
        
        
        
        request(.GET, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            var spotJsons: Array<JSON> = json["features"].arrayValue
            var spots = Array<ParkingSpot>();
            for spotJson in spotJsons {
                spots.append(ParkingSpot(json: spotJson))
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(spots: spots)
            })
            
        }
    }
    
    
    
}
