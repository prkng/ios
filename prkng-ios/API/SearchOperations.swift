//
//  SearchOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchOperations {
    
//    class func searchLocation(name: String, completion: ((results:Array<SearchResult>) -> Void)) {
//        
//        var url = http://api.tiles.mapbox.com/v4/geocode/mapbox.places/dandurand.json?access_token=pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA
//        var params = ["name": name]
//        
//        request(.GET, url, parameters: params).responseSwiftyJSON() {
//            (request, response, json, error) in
//            var spotJsons: Array<JSON> = json["features"].arrayValue
//            var spots = Array<ParkingSpot>();
//            for spotJson in spotJsons {
//                spots.append(ParkingSpot(json: spotJson))
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                () -> Void in
//                completion(spots: spots)
//            })
//            
//        }
//    }
   
    
    
    class func getStreetName(location : CLLocationCoordinate2D, completion : (result : String) -> Void) {
        
        
        var url = "http://nominatim.openstreetmap.org/reverse"
        
        
        var params  = ["lat": "\(location.latitude)", "lon": "\(location.longitude)", "format" : "json"]
        
        request(.GET, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var street : String = json["address"]["road"].stringValue
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
               
                completion(result:street)
                
            })
            
        }
        
        
    }
    
    
    class func searchByStreetName(streetname : String , completion : (results : Array<SearchResult>) -> Void) {
        
        var url = "http://nominatim.openstreetmap.org/search"
        
        var params  = ["format" : "json", "state" : "Quebec", "city" : Settings.selectedCity().rawValue, "country" : "Canada", "street" : streetname]
        
        var numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        request(.GET, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (key: String, subJson: JSON) in json {
                
                var title : String = subJson["display_name"].stringValue
                
                var latStr : String = subJson["lat"].stringValue
                
                var lat : Double = numberFormatter.numberFromString(latStr)!.doubleValue
                
                var lonStr : String = subJson["lon"].stringValue
                
                var lon : Double = numberFormatter.numberFromString(lonStr)!.doubleValue
                
                var location : CLLocation = CLLocation(latitude: lat, longitude: lon)
                
                results.append(SearchResult(title: title, location: location))
                
            }
            
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                
                completion(results: results)
                
            })
            
        }
        
        
    }
    
    
}
