//
//  SearchOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchOperations {
   
    
    
    class func getStreetName(location : CLLocationCoordinate2D, completion : (result : String) -> Void) {
        
        
        let url = "https://nominatim.openstreetmap.org/reverse"
        
        
        let params  = ["lat": "\(location.latitude)", "lon": "\(location.longitude)", "format" : "json"]
        
        request(.GET, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let street : String = json["address"]["road"].stringValue
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
               
                completion(result:street)
                
            })
            
        }
        
        
    }
    
    class func searchWithInput(input : String , forAutocomplete: Bool, completion : (results : Array<SearchResult>) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            () -> Void in
            self.mapboxPlacesSearchWithInput(input, forAutocomplete: forAutocomplete, completion: { (results1) -> Void in
                self.foursquareSearchWithInput(input, forAutocomplete: forAutocomplete, completion: { (results2) -> Void in
                    
                    if !forAutocomplete {
                        self.nominatimSearchWithStreet(input, completion: { (results3) -> Void in
                            
                            let totalResults = results1 + results2
                            dispatch_async(dispatch_get_main_queue(), {
                                () -> Void in
                                AnalyticsOperations.sendSearchQueryToAnalytics(input)
                                completion(results: totalResults)
                            })
                            
                        })
                        
                    } else {
                        
                        let totalResults = results1 + results2
                        dispatch_async(dispatch_get_main_queue(), {
                            () -> Void in
                            completion(results: totalResults)
                        })
                    }
                })
            })
        })
    }
    
    
    private class func nominatimSearchWithStreet(input : String , completion : (results : Array<SearchResult>) -> Void) {
        
        let url = "https://nominatim.openstreetmap.org/search"
        
        let params  = ["format" : "json", "state" : "Quebec", "city" : Settings.selectedCity().displayName, "country" : "Canada", "q" : input]
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        request(.GET, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (_, subJson): (String, JSON) in json {
                
                let title : String = subJson["display_name"].stringValue
                
                let latStr : String = subJson["lat"].stringValue
                
                let lat : Double = numberFormatter.numberFromString(latStr)!.doubleValue
                
                let lonStr : String = subJson["lon"].stringValue
                
                let lon : Double = numberFormatter.numberFromString(lonStr)!.doubleValue
                
                let location : CLLocation = CLLocation(latitude: lat, longitude: lon)
                
                results.append(SearchResult(title: title, location: location))
                
            }
            
            
//            dispatch_async(dispatch_get_main_queue(), {
//                () -> Void in
            
                completion(results: results)
                
//            })
            
        }
        
    }

    private class func mapboxPlacesSearchWithInput(input : String , forAutocomplete: Bool, completion : (results : Array<SearchResult>) -> Void) {
        
        let escapedInput = input.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let lat = String(stringInterpolationSegment: Settings.selectedCity().coordinate.latitude)
        let lon = String(stringInterpolationSegment: Settings.selectedCity().coordinate.longitude)

        let url = String(format: "https://api.mapbox.com/v4/geocode/mapbox.places/%@.json?proximity=%@,%@&access_token=pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA", escapedInput ?? "", lon, lat)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        request(.GET, URLString: url).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (_, subJson): (String, JSON) in json["features"] {
                
                let name = subJson["text"].stringValue
                
                var city = ""
                var postCode = ""
                var state = ""
                var country = ""
                
                for i in Array((0...(subJson["context"].count)).reverse()) {
                    if i - 1 >= 0 {
                        let text = subJson["context"][i - 1]["text"].stringValue
                        if country == "" {
                            country = text
                        } else if state == "" {
                            state = text
                        } else if postCode == "" {
                            postCode = text
                        } else {
                            city = text
                        }
                    }
                }
                
                var matchesCity = false
                if Settings.selectedCity().name == "montreal" {
                    matchesCity = city.lowercaseString.rangeOfString("montreal") != nil
                        || city.lowercaseString.rangeOfString("montréal") != nil
                } else if Settings.selectedCity().name == "quebec" {
                    matchesCity = city.lowercaseString.rangeOfString("quebec") != nil
                        || city.lowercaseString.rangeOfString("québec") != nil
                }
                
                let matchesProvince = state.lowercaseString.rangeOfString("quebec") != nil
                    || state.lowercaseString.rangeOfString("québec") != nil
                
                let isPoint = subJson["geometry"]["type"].stringValue == "Point"
                
                if isPoint && (matchesCity || matchesProvince) {
                    
                    var title = name
                    var subtitle = ""

                    let provinceAndCountry = state + ", " + country

                    //if this result is a post code...
                    if subJson["id"].stringValue.lowercaseString.rangeOfString("postcode") != nil {
                        subtitle = provinceAndCountry
                    } else {
                    // regular street or place (even though places aren't supported by mapbox at this time
                        let street = name
                        let number = subJson["address"].stringValue
                        
                        let address = number == "" ? street : number + " " + street
                        let cityAndProvince = city + ", " + state
                        
                        let morePreciseLocation = cityAndProvince[0] == "," ? provinceAndCountry : cityAndProvince
                        
                        if address.rangeOfString(name) != nil {
                            title = address
                            subtitle = morePreciseLocation
                        } else {
                            subtitle = address
                        }
                    }
                    
                    let latStr = subJson["geometry"]["coordinates"][1].stringValue
                    let lat = numberFormatter.numberFromString(latStr)!.doubleValue
                    let lonStr = subJson["geometry"]["coordinates"][0].stringValue
                    let lon = numberFormatter.numberFromString(lonStr)!.doubleValue
                    let location = CLLocation(latitude: lat, longitude: lon)
                    location.coordinate
                    results.append(SearchResult(title: title, subtitle: subtitle, location: location))
                    
                }
                
            }
            
//            dispatch_async(dispatch_get_main_queue(), {
//                () -> Void in
            
                completion(results: results)
                
//            })
            
        }
        
    }
    
    
    private class func foursquareSearchWithInput(input : String , forAutocomplete: Bool, completion : (results : Array<SearchResult>) -> Void) {
        
        var url = "https://api.foursquare.com/v2/venues/"
        var arrayName = ""
        
        if forAutocomplete {
            url += "suggestcompletion"
            arrayName = "minivenues"
        } else {
            url += "search"
            arrayName = "venues"
        }
        
        let params  = ["query" : input,
            "near" : Settings.selectedCity().displayName,
            "v" : "20150813",
            "client_id" : "E5BZKWTZRKG2NN0RPC0WFFOYQRNS31PUSL0XCTUFWTCUFF4S",
            "client_secret" : "JM1LAQRGMBBUWP00FM2YQ10WQZRT2OR1SEJLL1DDG1S2VFRB"]
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        request(.GET, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (_, subJson): (String, JSON) in json["response"][arrayName] {
                
                let name = subJson["name"].stringValue
                let title = name
                let subtitle = subJson["location"]["address"].stringValue
                
                let latStr = subJson["location"]["lat"].stringValue
                let lat = numberFormatter.numberFromString(latStr)!.doubleValue
                let lonStr = subJson["location"]["lng"].stringValue
                let lon = numberFormatter.numberFromString(lonStr)!.doubleValue
                let location = CLLocation(latitude: lat, longitude: lon)
                location.coordinate
                results.append(SearchResult(title: title, subtitle: subtitle, location: location))
                
            }
            
                completion(results: results)
            
        }
        
    }
    
    
}
