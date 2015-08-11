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
    
    class func searchWithInput(input : String , forAutocomplete: Bool, completion : (results : Array<SearchResult>) -> Void) {
        if forAutocomplete {
            peliasSearchWithInput(input, forAutocomplete: forAutocomplete, completion: completion)
        } else {
            nominatimSearchWithStreet(input, completion: completion)
        }
    }
    
    
    private class func nominatimSearchWithStreet(input : String , completion : (results : Array<SearchResult>) -> Void) {
        
        var url = "http://nominatim.openstreetmap.org/search"
        
        var params  = ["format" : "json", "state" : "Quebec", "city" : Settings.selectedCity().rawValue, "country" : "Canada", "q" : input]
        
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
    
    private class func peliasSearchWithInput(input : String , forAutocomplete: Bool, completion : (results : Array<SearchResult>) -> Void) {
        
        var url = "http://pelias.mapzen.com/"
        
        if forAutocomplete {
            url += "suggest"
        } else {
            url += "search"
        }
        
        var params  = ["input" : input,
            "lat" : String(stringInterpolationSegment: Settings.selectedCityPoint().latitude),
            "lon" : String(stringInterpolationSegment: Settings.selectedCityPoint().longitude) ]
        
        var numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        request(.GET, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (key: String, subJson: JSON) in json["features"] {
                
                let name = subJson["properties"]["name"].stringValue
                let admin1 = subJson["properties"]["admin1"].stringValue
                let admin2 = subJson["properties"]["admin2"].stringValue
                
                var matchesCity = false
                if Settings.selectedCity() == Settings.City.Montreal {
                    matchesCity = admin2.lowercaseString.rangeOfString("montreal") != nil
                        || admin2.lowercaseString.rangeOfString("montréal") != nil
                } else if Settings.selectedCity() == Settings.City.QuebecCity {
                    matchesCity = admin2.lowercaseString.rangeOfString("quebec") != nil
                        || admin2.lowercaseString.rangeOfString("québec") != nil
                }
                
                let isPoint = subJson["geometry"]["type"].stringValue == "Point"
                
                if isPoint && matchesCity {
                    
                    let street = subJson["properties"]["address"]["street"].stringValue
                    let number = subJson["properties"]["address"]["number"].stringValue
                    
                    let address = number + " " + street
                    let cityAndProvince = admin2 + ", " + admin1
                    
                    let title = name
                    var subtitle = name.rangeOfString(number) == nil && address != " " ? address : cityAndProvince
                    
                    let latStr = subJson["geometry"]["coordinates"][1].stringValue
                    let lat = numberFormatter.numberFromString(latStr)!.doubleValue
                    let lonStr = subJson["geometry"]["coordinates"][0].stringValue
                    let lon = numberFormatter.numberFromString(lonStr)!.doubleValue
                    let location = CLLocation(latitude: lat, longitude: lon)
                    location.coordinate
                    results.append(SearchResult(title: title, subtitle: subtitle, location: location))
                    
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                
                completion(results: results)
                
            })
            
        }
        
    }

    
}
