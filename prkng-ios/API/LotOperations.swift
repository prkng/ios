//
//  LotOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 26/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct LotOperations {
    
    
    static func findLots(coordinate: CLLocationCoordinate2D, radius : Float, completion: ((lots: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "lots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        var params = ["latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "radius" : radiusStr,
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in

            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
//            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            var lotJsons: [JSON] = json["features"].arrayValue
            var lots = lotJsons.map({ (var lotJson) -> Lot in
                Lot(json: lotJson)
            })
            
            let underMaintenance = response != nil && response!.statusCode == 503
            let outsideServiceArea = response != nil && response!.statusCode == 404

            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(lots: lots, underMaintenance: underMaintenance, outsideServiceArea: outsideServiceArea, error: error != nil)
            })
            
        }
    }
    
}
