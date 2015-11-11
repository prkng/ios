//
//  CarSharingOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-16.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import Foundation

class CarSharingOperations {
    
    static func getCarShares(location location: CLLocationCoordinate2D, radius : Float, completion: ((carShares: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "carshares"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let companies: [String?] = [!Settings.hideCar2Go() ? "car2go" : nil, !Settings.hideCommunauto() ? "communauto" : nil, !Settings.hideAutomobile() ? "auto-mobile" : nil]
        let companiesString = Array.filterNils(companies).joinWithSeparator(",")
        
        let params = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "permit" : "all",
            "company" : companiesString
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in
            
            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
            //            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let carShareJsons: Array<JSON> = json["features"].arrayValue
            let carShares = carShareJsons.map({ (carShareJson) -> CarShare in
                CarShare(json: carShareJson)
            })
            
            let underMaintenance = response != nil && response!.statusCode == 503
            let outsideServiceArea = response != nil && response!.statusCode == 404
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(carShares: carShares, underMaintenance: underMaintenance, outsideServiceArea: outsideServiceArea, error: error != nil)
                
                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }
                
            })
            
        }
    }

    static func getCarShareLots(location location: CLLocationCoordinate2D, radius : Float, completion: ((carShareLots: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "carshare_lots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let companies: [String?] = [
            !Settings.hideCar2Go() ? "car2go" : nil,
            !Settings.hideCommunauto() ? "communauto" : nil,
            !Settings.hideAutomobile() ? "auto-mobile" : nil,
            !Settings.hideZipCar() ? "zipcar" : nil,
        ]
        let companiesString = Array.filterNils(companies).joinWithSeparator(",")

        let params = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "permit" : "all",
            "company" : companiesString
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in
            
            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
            //            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let carShareLotJsons: Array<JSON> = json["features"].arrayValue
            let carShareLots = carShareLotJsons.map({ (carShareLotJson) -> CarShareLot in
                CarShareLot(json: carShareLotJson)
            })
            
            let underMaintenance = response != nil && response!.statusCode == 503
            let outsideServiceArea = response != nil && response!.statusCode == 404
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(carShareLots: carShareLots, underMaintenance: underMaintenance, outsideServiceArea: outsideServiceArea, error: error != nil)
                
                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }
                
            })
            
        }
    }

}