//
//  AnalyticsOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-11.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AnalyticsOperations {
   
    static let sharedInstance = AnalyticsOperations()
    
    private var lastUsedCoordinate: CLLocationCoordinate2D?
    
    class func sendSearchQueryToAnalytics(query: String, navigate: Bool) {
        
        if query == "" {
            return
        }
        
        let url = APIUtility.rootURL() + "analytics/search"
        let params = ["query": query, "navigate": (navigate ? "true" : "false") ]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
        }
        
    }

    class func sendMapModeChange(mapMode: MapMode) {

        var mapModeString = ""
        switch (mapMode.rawValue) {
        case 0:
            mapModeString = "parking_lot"
            break
        case 1:
            mapModeString = "street_parking"
            break
        case 2:
            mapModeString = "car_sharing"
            break
        default:
            mapModeString = ""
            break
        }
        let url = APIUtility.rootURL() + "analytics/event"
        let params = ["event" : "map_mode_" + mapModeString]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
        }
        
    }
    
    static func carShareLoginEvent(type: String, completion : (completed : Bool) -> Void) {
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params = ["event" : ("login_" + type)]
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (response?.statusCode != 201) {
                completion(completed: false)
            } else {
                completion(completed: true)
            }
            
        }
        
    }

    static func reservedCarShareEvent(carShare: CarShare, completion : (completed : Bool) -> Void) {
                
        let url = APIUtility.rootURL() + "analytics/event"
        let params = ["event" : ("reserved_" + carShare.carSharingType.name),
            "longitude" : String(stringInterpolationSegment: carShare.coordinate.longitude),
            "latitude" : String(stringInterpolationSegment: carShare.coordinate.latitude)]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (response?.statusCode != 201) {
                completion(completed: false)
            } else {
                completion(completed: true)
            }
            
        }
        
    }
    
    func geofencingEvent(coordinate: CLLocationCoordinate2D, entering: Bool, completion : (completed : Bool) -> Void) {
        
        lastUsedCoordinate = coordinate
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params = ["event" : (entering ? "entered_fence" : "left_fence"),
            "longitude" : String(stringInterpolationSegment: coordinate.longitude),
            "latitude" : String(stringInterpolationSegment: coordinate.latitude)]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (response?.statusCode != 201) {
                completion(completed: false)
            } else {
                completion(completed: true)
            }

        }
        
    }

    func geofencingEventUserResponse(response: Bool, completion : (completed : Bool) -> Void) {
        
        let url = APIUtility.rootURL() + "analytics/event"
        var params = ["event" : (response ? "fence_response_yes" : "fence_response_no")]
        
        if let coordinate = self.lastUsedCoordinate {
            params["longitude"] = String(stringInterpolationSegment: coordinate.longitude)
            params["latitude"] = String(stringInterpolationSegment: coordinate.latitude)
        }
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (response?.statusCode != 201) {
                completion(completed: false)
            } else {
                completion(completed: true)
            }
            
        }
        
    }
    
    
    class func locationPermission(authorizationStatus: CLAuthorizationStatus, completion : (completed : Bool) -> Void) {
        
        var statusString = ""
        switch (authorizationStatus) {
        case CLAuthorizationStatus.Restricted:
            statusString = "Restricted"
            break
        case CLAuthorizationStatus.Denied:
            statusString = "Denied"
            break
        case CLAuthorizationStatus.NotDetermined:
            statusString = "NotDetermined"
            break
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            statusString = "AuthorizedWhenInUse"
            break
        case CLAuthorizationStatus.AuthorizedAlways:
            statusString = "AuthorizedAlways"
            break
        }
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params = ["event" : "perm_" + statusString]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (response?.statusCode != 201) {
                completion(completed: false)
            } else {
                completion(completed: true)
            }
            
        }
        
    }

    
}
