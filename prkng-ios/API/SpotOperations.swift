//
//  SpotOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SpotOperations: NSObject {
    
    class func getSpot(identifier : NSString) {
        
    }
    
    
    class func findSpots(latitude : Float, longitude : Float) {
        
        var url = APIUtility.APIConstants.rootURLString + "slots/\(latitude)/\(longitude)";
        
        request(.GET, url).responseSwiftyJSON() {
            (request, response, json, error) in
            
            
            var spotJsons : Array<JSON> = json["features"].arrayValue
            var spots = Array<ParkingSpot>();
            for spotJson in spotJsons {
                spots.append(ParkingSpot(json: spotJson))
            }
            
            
            
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                
//                var responseJSON: JSON(data)
//                
//                
//                if error != nil || object == nil{
//                    responseJSON = JSON.nullJSON
//                } else {
//                    responseJSON = SwiftyJSON.JSON(object!)
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                   
//                    // return
//                    
//                })
//            })
//            
            
            
            
        }
    }
    
}
