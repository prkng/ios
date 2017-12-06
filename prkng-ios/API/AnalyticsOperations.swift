//
//  AnalyticsOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-11.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Alamofire

class AnalyticsOperations {
   
    static let sharedInstance = AnalyticsOperations()
    
    fileprivate var lastUsedCoordinate: CLLocationCoordinate2D?
    
    class func sendSearchQueryToAnalytics(_ query: String, navigate: Bool) {
        guard query.isEmpty == false else {
            return
        }
        
        let url = APIUtility.rootURL() + "analytics/search"
        let params: [String : AnyObject] = ["query": query as AnyObject, "navigate": (navigate ? "true" : "false") as AnyObject ]
        
        APIUtility.authenticatedManager().request(url, method: HTTPMethod.post, parameters: params, encoding: .default, headers: nil).validate().responseJSON { (reseponse) in
            //NADA
        }
        
    }

    class func sendMapModeChange(_ mapMode: MapMode) {

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
        let params: [String : AnyObject] = ["event" : ("map_mode_" + mapModeString) as AnyObject ]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            //NADA
        }
        
    }
    
    static func carShareLoginEvent(_ type: String, completion : @escaping (_ completed : Bool) -> Void) {
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params: [String : AnyObject] = ["event" : ("login_" + type) as AnyObject]
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            completion(response?.statusCode != 201 ? false : true)
        }
        
    }

    static func reservedCarShareEvent(_ carShare: CarShare, completion : @escaping (_ completed : Bool) -> Void) {
                
        let url = APIUtility.rootURL() + "analytics/event"
        let params: [String : AnyObject] = ["event" : ("reserved_" + carShare.carSharingType.name) as AnyObject,
            "longitude" : String(stringInterpolationSegment: carShare.coordinate.longitude) as AnyObject,
            "latitude" : String(stringInterpolationSegment: carShare.coordinate.latitude) as AnyObject]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            
            completion(response?.statusCode != 201 ? false : true)
            
        }
        
    }
    
    func geofencingEvent(_ coordinate: CLLocationCoordinate2D, entering: Bool, completion : @escaping (_ completed : Bool) -> Void) {
        
        lastUsedCoordinate = coordinate
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params: [String : AnyObject] = ["event" : (entering ? "entered_fence" : "left_fence") as AnyObject,
            "longitude" : String(stringInterpolationSegment: coordinate.longitude) as AnyObject,
            "latitude" : String(stringInterpolationSegment: coordinate.latitude) as AnyObject]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            completion(response?.statusCode != 201 ? false : true)

        }
        
    }

    func geofencingEventUserResponse(_ response: Bool, completion : @escaping (_ completed : Bool) -> Void) {
        
        let url = APIUtility.rootURL() + "analytics/event"
        var params: [String : AnyObject] = ["event" : (response ? "fence_response_yes" : "fence_response_no") as AnyObject]
        
        if let coordinate = self.lastUsedCoordinate {
            params["longitude"] = String(stringInterpolationSegment: coordinate.longitude) as AnyObject
            params["latitude"] = String(stringInterpolationSegment: coordinate.latitude) as AnyObject
        }
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            
            completion(response?.statusCode != 201 ? false : true)
            
        }
        
    }
    
    class func ppUserDidLogin(_ completion : ((_ completed : Bool) -> Void)?) {
        
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params: [String : AnyObject] = ["event" : ("parking_panda_login") as AnyObject]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            
            completion?(response?.statusCode != 201 ? false : true)
            
        }
        
    }

    class func ppUserDidSignUp(_ completion : ((_ completed : Bool) -> Void)?) {
        
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params: [String : AnyObject] = ["event" : ("parking_panda_signup") as AnyObject]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            
            completion?(response?.statusCode != 201 ? false : true)
            
        }
        
    }
    
    class func ppUserDidCreateTransaction(_ completion : ((_ completed : Bool) -> Void)?) {
        
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params: [String : AnyObject] = ["event" : ("parking_panda_transaction_created") as AnyObject]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            
            completion?(response?.statusCode != 201 ? false : true)
            
        }
        
    }


    class func locationPermission(_ authorizationStatus: CLAuthorizationStatus, completion : @escaping (_ completed : Bool) -> Void) {
        
        var statusString = ""
        switch (authorizationStatus) {
        case CLAuthorizationStatus.restricted:
            statusString = "Restricted"
            break
        case CLAuthorizationStatus.denied:
            statusString = "Denied"
            break
        case CLAuthorizationStatus.notDetermined:
            statusString = "NotDetermined"
            break
        case CLAuthorizationStatus.authorizedWhenInUse:
            statusString = "AuthorizedWhenInUse"
            break
        case CLAuthorizationStatus.authorizedAlways:
            statusString = "AuthorizedAlways"
            break
        }
        
        let url = APIUtility.rootURL() + "analytics/event"
        let params = ["event" : ("perm_" + statusString) as AnyObject]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params, encoding: ParameterEncoding.json).responseSwiftyJSON { (request, response, json, error) in
            
            completion(response?.statusCode != 201 ? false : true)
            
        }
        
    }

    
}
