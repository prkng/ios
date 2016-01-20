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
    static let threshholdCheaperLotPercentage = 0.3 //20% of lots should be marked cheaper
    
    private var sema = dispatch_semaphore_create(0)
    private var inProgress = false
    private var lots = [Lot]()
    
    func findLots(coordinate: CLLocationCoordinate2D, radius : Float, completion: ((lots: [NSObject], mapMessage: String?) -> Void)) {
        
        if inProgress {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
        }
        
        inProgress = true
        
//        if Settings.isCachedLotDataFresh() {
//            dispatch_async(dispatch_get_main_queue(), {
//                () -> Void in
//                completion(lots: self.lots, underMaintenance: false, outsideServiceArea: false, error: false)
//            })
//            inProgress = false
//            dispatch_semaphore_signal(self.sema)
//            return
//        }
        
        let url = APIUtility.rootURL() + "lots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let params = ["latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "radius": radiusStr,
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in

            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
//            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let lotJsons: [JSON] = json["features"].arrayValue
            var tempLots = lotJsons.map({ (lotJson) -> Lot in
                Lot(json: lotJson)
            })
            tempLots = LotOperations.processCheapestLots(tempLots)
            self.lots = tempLots
            
            let mapMessage = MapMessageView.createMessage(count: tempLots.count, response: response, error: error, origin: .Lots)

//            if error == nil && self.lots.count > 0 {
//                Settings.cacheLotsJson(json)
//                Settings.setCachedLotDataFresh(true)
//            }

            self.inProgress = false
            dispatch_semaphore_signal(self.sema)

            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(lots: self.lots, mapMessage: mapMessage)

                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }

            })
            
        }
    }
    
    static func processCheapestLots(givenLots: [Lot]) -> [Lot] {
        
        let totalCount = givenLots.count
        let threshholdLotCount = Int(LotOperations.threshholdCheaperLotPercentage * Double(totalCount))
        if threshholdLotCount == 0 {
            return givenLots
        }
        
        var sortedLots = givenLots.sort { (left, right) -> Bool in
            return left.mainRate(preferreCached: true) < right.mainRate(preferreCached: true)
        }
        for i in 0...threshholdLotCount {
            sortedLots[i].isCheaper = true
        }
        for i in threshholdLotCount..<totalCount {
            sortedLots[i].isCheaper = false
        }

        return sortedLots

    }
    
    //if these rmannotations do not contain lots, you're in for a bad time.
    //this only returns annotations whose values have changed
    static func processCheapestLots(givenLotAnnotations: [RMAnnotation]) -> [RMAnnotation] {
        
        let totalCount = givenLotAnnotations.count
        let threshholdLotCount = Int(LotOperations.threshholdCheaperLotPercentage * Double(totalCount))
        if threshholdLotCount == 0 {
            return []
        }
        
        var changedLots = [RMAnnotation]()

        var sortedLots = givenLotAnnotations.sort { (left, right) -> Bool in
            let leftLot = left.userInfo["lot"] as! Lot
            let rightLot = right.userInfo["lot"] as! Lot
            return leftLot.mainRate(preferreCached: true) < rightLot.mainRate(preferreCached: true)
        }
        for i in 0..<threshholdLotCount {
            var userInfo = sortedLots[i].userInfo as! [String:AnyObject]
            if (userInfo["cheaper"] as! Bool) == false {
                userInfo["cheaper"] = true
                userInfo["fadeAnimation"] = true
                let lot = (userInfo["lot"] as! Lot)
                lot.isCheaper = true
                userInfo["lot"] = lot
                sortedLots[i].userInfo = userInfo
                changedLots.append(sortedLots[i])
            }
        }
        for i in threshholdLotCount..<totalCount {
            var userInfo = sortedLots[i].userInfo  as! [String:AnyObject]
            if (userInfo["cheaper"] as! Bool) == true {
                userInfo["cheaper"] = false
                userInfo["fadeAnimation"] = true
                let lot = (userInfo["lot"] as! Lot)
                lot.isCheaper = false
                userInfo["lot"] = lot
                sortedLots[i].userInfo = userInfo
                changedLots.append(sortedLots[i])
            }
        }
        
        return changedLots
    }
    
}
