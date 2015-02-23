//
//  SpotOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import AlamoFire
import SwiftyJSON

class SpotOperations: NSObject {
    
    class func getSpot(identifier : NSString) {
        
    }
    
    
    class func findSpots(latitude : Float, longitude : Float) {
        
        var url = APIUtility.APIConstants.rootURLString + "slots/\(latitude)/\(longitude)";
        
        Alamofire.request(.GET, url).responseSwiftyJSON() {
            (request, response, json, error) in
            
            
            
            
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
            
            
//            if(JSON as? Array<Dictionary>) {
//                
//            } else if (JSON as? Dictionary) {
//                
//            }
            
        }
    }
    
}
