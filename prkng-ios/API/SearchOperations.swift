//
//  SearchOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchOperations {
   
    
    
    class func getStreetName(_ location : CLLocationCoordinate2D, completion : @escaping (_ result : String) -> Void) {
        
        
        let url = "https://nominatim.openstreetmap.org/reverse"
        
        
        let params  = ["lat": "\(location.latitude)", "lon": "\(location.longitude)", "format" : "json"]
        
        request(.GET, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let street : String = json["address"]["road"].stringValue
            
            DispatchQueue.main.async(execute: {
                () -> Void in
               
                completion(result:street)
                
            })
            
        }
        
        
    }
    
    class func searchWithInput(_ input : String , forAutocomplete: Bool, completion : @escaping (_ results : Array<SearchResult>) -> Void) {
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            () -> Void in
            self.mapboxPlacesSearchWithInput(input, forAutocomplete: forAutocomplete, completion: { (results1) -> Void in
                self.foursquareSearchWithInput(input, forAutocomplete: forAutocomplete, completion: { (results2) -> Void in
                    
                    if !forAutocomplete {
                        self.nominatimSearchWithStreet(input, completion: { (results3) -> Void in
                            
                            let totalResults = results1 + results2
                            DispatchQueue.main.async(execute: {
                                () -> Void in
                                AnalyticsOperations.sendSearchQueryToAnalytics(input, navigate: false)
                                completion(totalResults)
                            })
                            
                        })
                        
                    } else {
                        
                        let totalResults = results1 + results2
                        DispatchQueue.main.async(execute: {
                            () -> Void in
                            completion(totalResults)
                        })
                    }
                })
            })
        })
    }
    
    
    fileprivate class func nominatimSearchWithStreet(_ input : String , completion : @escaping (_ results : Array<SearchResult>) -> Void) {
        
        let url = "https://nominatim.openstreetmap.org/search"
        
        var params  = ["format" : "json", "state" : "Quebec", "city" : Settings.selectedCity().displayName, "country" : "Canada", "q" : input]
        switch Settings.selectedCity().name {
        case "newyork":
            params  = ["format" : "json", "state" : "New York", "city" : Settings.selectedCity().displayName, "country" : "USA", "q" : input]
        case "seattle":
            params  = ["format" : "json", "state" : "Washington", "city" : Settings.selectedCity().displayName, "country" : "USA", "q" : input]
        default:
            break
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")

        request(.GET, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (_, subJson): (String, JSON) in json {
                
                let title : String = subJson["display_name"].stringValue
                
                let latStr : String = subJson["lat"].stringValue
                
                let lat : Double = numberFormatter.number(from: latStr)!.doubleValue
                
                let lonStr : String = subJson["lon"].stringValue
                
                let lon : Double = numberFormatter.number(from: lonStr)!.doubleValue
                
                let location : CLLocation = CLLocation(latitude: lat, longitude: lon)
                
                results.append(SearchResult(title: title, location: location))
                
            }
            
            
//            dispatch_async(dispatch_get_main_queue(), {
//                () -> Void in
            
                completion(results: results)
                
//            })
            
        }
        
    }

    fileprivate class func mapboxPlacesSearchWithInput(_ input : String , forAutocomplete: Bool, completion : @escaping (_ results : Array<SearchResult>) -> Void) {
        
        let escapedInput = input.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let lat = String(stringInterpolationSegment: Settings.selectedCity().coordinate.latitude)
        let lon = String(stringInterpolationSegment: Settings.selectedCity().coordinate.longitude)

        let url = String(format: "https://api.mapbox.com/geocoding/v5/mapbox.places/%@.json?proximity=%@,%@&access_token=pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA", escapedInput ?? "", lon, lat)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        request(.GET, URLString: url).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (_, subJson): (String, JSON) in json["features"] {
                
                let name = subJson["text"].stringValue
                
                var city = ""
                var postCode = ""
                var state = ""
                var country = ""
                
                for i in Array((0...(subJson["context"].count)).reversed()) {
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
                    matchesCity = city.lowercased().range(of: "montreal") != nil
                        || city.lowercased().range(of: "montréal") != nil
                } else if Settings.selectedCity().name == "quebec" {
                    matchesCity = city.lowercased().range(of: "quebec") != nil
                        || city.lowercased().range(of: "québec") != nil
                } else if Settings.selectedCity().name.contains("newyork") {
                    matchesCity = city.lowercased().contains("newyork")
                } else if Settings.selectedCity().name == "seattle" {
                    matchesCity = city.lowercased() == "seattle"
                }
                
                let matchesProvince = state.lowercased().range(of: "quebec") != nil
                    || state.lowercased().range(of: "québec") != nil
                    || state.lowercased().contains("new york")
                    || state.lowercased() == "washington"
                
                let isPoint = subJson["geometry"]["type"].stringValue == "Point"
                
                if isPoint && (matchesCity || matchesProvince) {
                    
                    var title = name
                    var subtitle = ""

                    let provinceAndCountry = state + ", " + country

                    //if this result is a post code...
                    if subJson["id"].stringValue.lowercased().range(of: "postcode") != nil {
                        subtitle = provinceAndCountry
                    } else {
                    // regular street or place (even though places aren't supported by mapbox at this time
                        let street = name
                        let number = subJson["address"].stringValue
                        
                        let address = number == "" ? street : number + " " + street
                        let cityAndProvince = city + ", " + state
                        
                        let morePreciseLocation = cityAndProvince[0] == "," ? provinceAndCountry : cityAndProvince
                        
                        if address.range(of: name) != nil {
                            title = address
                            subtitle = morePreciseLocation
                        } else {
                            subtitle = address
                        }
                    }
                    
                    let latStr = subJson["geometry"]["coordinates"][1].stringValue
                    let lat = numberFormatter.number(from: latStr)!.doubleValue
                    let lonStr = subJson["geometry"]["coordinates"][0].stringValue
                    let lon = numberFormatter.number(from: lonStr)!.doubleValue
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
    
    
    fileprivate class func foursquareSearchWithInput(_ input : String , forAutocomplete: Bool, completion : @escaping (_ results : Array<SearchResult>) -> Void) {
        
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
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        request(.GET, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            var results : Array<SearchResult> = [];
            
            for (_, subJson): (String, JSON) in json["response"][arrayName] {
                
                let name = subJson["name"].stringValue
                let title = name
                let subtitle = subJson["location"]["address"].stringValue
                
                let latStr = subJson["location"]["lat"].stringValue
                let lat = numberFormatter.number(from: latStr)!.doubleValue
                let lonStr = subJson["location"]["lng"].stringValue
                let lon = numberFormatter.number(from: lonStr)!.doubleValue
                let location = CLLocation(latitude: lat, longitude: lon)
                location.coordinate
                results.append(SearchResult(title: title, subtitle: subtitle, location: location))
                
            }
            
                completion(results: results)
            
        }
        
    }
    
    
}
