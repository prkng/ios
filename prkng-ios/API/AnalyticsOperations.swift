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
    
    class func sendSearchQueryToAnalytics(query: String) {
        
        let url = APIUtility.APIConstants.rootURLString + "analytics/search"
        let params = ["query" : query]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
        }
        
    }

    func geofencingEvent(coordinate: CLLocationCoordinate2D, entering: Bool, completion : (completed : Bool) -> Void) {
        
        lastUsedCoordinate = coordinate
        
        let url = APIUtility.APIConstants.rootURLString + "analytics/event"
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
        
        let url = APIUtility.APIConstants.rootURLString + "analytics/event"
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
        
        let url = APIUtility.APIConstants.rootURLString + "analytics/event"
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
