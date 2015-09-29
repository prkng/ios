//
//  LotOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 26/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

 class LotOperations {
    
    static let sharedInstance = LotOperations()
    
    var sema = dispatch_semaphore_create(0)
    var inProgress = false
    var lots = [Lot]()
    
    func findLots(coordinate: CLLocationCoordinate2D, radius : Float, completion: ((lots: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void)) {
        
        if inProgress {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
        }
        
        inProgress = true
        
        if Settings.isCachedLotDataFresh() {
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(lots: self.lots, underMaintenance: false, outsideServiceArea: false, error: false)
            })
            inProgress = false
            dispatch_semaphore_signal(self.sema)
            return
        }
        
        let url = APIUtility.APIConstants.rootURLString + "lots"
        
        let radiusStr = NSString(format: "%.0f", 30000.0)//radius)
        
        let params = ["latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "radius" : radiusStr,
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in

            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
//            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let lotJsons: [JSON] = json["features"].arrayValue
            self.lots = lotJsons.map({ (lotJson) -> Lot in
                Lot(json: lotJson)
            })
            
            let underMaintenance = response != nil && response!.statusCode == 503
            let outsideServiceArea = response != nil && response!.statusCode == 404

            if error == nil && self.lots.count > 0 {
                Settings.cacheLotsJson(json)
                Settings.setCachedLotDataFresh(true)
            }

            self.inProgress = false
            dispatch_semaphore_signal(self.sema)

            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(lots: self.lots, underMaintenance: underMaintenance, outsideServiceArea: outsideServiceArea, error: error != nil)

                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }

            })
            
        }
    }
    
}
