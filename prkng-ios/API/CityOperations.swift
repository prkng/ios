//
//  CityOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class CityOperations {
   
    static let sharedInstance = CityOperations()
    
    var availableCities: [City]
    
    init() {
        
        self.availableCities = [City]()
        let citiesJson: [JSON] = JSON(data: citiesData).arrayValue
        let cities = citiesJson.map({ (cityJson) -> City in
            City(json: cityJson)
        })
        self.availableCities = cities

        getCities { (completed, cities) -> Void in
            if completed {
                self.availableCities = cities
            }
        }
    }
    
    var montreal: City? {
        for city in availableCities {
            if city.name == "montreal" {
                return city
            }
        }
        return nil
    }
    
    var quebecCity: City? {
        for city in availableCities {
            if city.name == "quebec" {
                return city
            }
        }
        return nil
    }

//    var newYorkCity: City? {
//        for city in availableCities {
//            if city.name == "newyork" {
//                return city
//            }
//        }
//        return nil
//    }
//
//    var seattle: City? {
//        for city in availableCities {
//            if city.name == "seattle" {
//                return city
//            }
//        }
//        return nil
//    }
    
    func getCities(_ completion : @escaping (_ completed : Bool, _ cities: [City]) -> Void) {
        
        let url = APIUtility.rootURL() + "cities"
        APIUtility.authenticatedManager().request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let citiesJson: [JSON] = JSON(value).array ?? [] //If we got a success, safe to assume you have cities.
                let cities = citiesJson.map({ (cityJson) -> City in
                    City(json: cityJson)
                })
                completion(true, cities)
            case .failure(let error):
                print(error)
                completion(false, [])
            }
        }
        
    }
    
    func setClosestSelectedCity(_ coordinate: CLLocationCoordinate2D) {
        if let closestCity = closestCityToCoordinate(coordinate) {
            Settings.setSelectedCity(closestCity)
        } else {
            Settings.setSelectedCity(self.montreal!)
        }
    }
    
    func closestCityToCoordinate(_ coordinate: CLLocationCoordinate2D) -> City? {
        var shortestDistance = Double.infinity
        var closestCity: City?
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        for city in availableCities {
            let cityPoint = city.coordinate
            let cityLocation = CLLocation(latitude: cityPoint.latitude, longitude: cityPoint.longitude)
            let distance = cityLocation.distance(from: location)
            if distance < shortestDistance {
                shortestDistance = distance
                closestCity = city
            }
        }
        return closestCity
    }
    
    func availableCityLocations() -> [CLLocation] {
        
        return availableCities.map({ (city) -> CLLocation in
            let point = city.coordinate
            let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
            return location
        })
    }
    
    static func getSupportedResidentialPermits(_ city: City, completion : @escaping (_ completed : Bool, _ permits: [String]) -> Void) {

        let url = APIUtility.rootURL() + "permits"
        
        let params: [String : AnyObject] = [
            "city" : city.name as AnyObject,
            "residential" : true as AnyObject
        ]
        
        APIUtility.authenticatedManager().request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let permitsJson: [JSON] = JSON(value).array ?? []
                var permits = permitsJson.map({ (permitJson) -> String in
                    return permitJson["permit"].stringValue
                })
                var stringPermits = permits.filter({ (permitString) -> Bool in
                    Int(permitString) == nil
                })
                stringPermits.sort()
                
                var intPermits = permits.filter({ (permitString) -> Bool in
                    Int(permitString) != nil
                }).map({ (permitString) -> Int in
                    return Int(permitString)!
                })
                intPermits.sort()
                
                permits = intPermits.map({ (intPermit) -> String in
                    String(intPermit)
                }) + stringPermits
                
                completion(true, permits)
                
            case .failure(let error):
                completion(false, [])
                
            }
        }

    }

    fileprivate var citiesString: String { return "[    {        \"display_name\": \"Québec\",         \"id\": \"1\",         \"lat\": 46.82053904,         \"long\": -71.22943997,         \"name\": \"quebec\",         \"urban_area_radius\": 20    },     {        \"display_name\": \"Montréal\",         \"id\": \"2\",         \"lat\": 45.5016889,         \"long\": -73.567256,         \"name\": \"montreal\",         \"urban_area_radius\": 30    },     {        \"display_name\": \"Seattle\",         \"id\": \"3\",         \"lat\": 47.615025,         \"long\": -122.335956,         \"name\": \"seattle\",         \"urban_area_radius\": 30    },     {        \"display_name\": \"New York\",         \"id\": \"4\",         \"lat\": 40.712784,         \"long\": -74.005941,         \"name\": \"newyork\",         \"urban_area_radius\": 30    }]" }
    fileprivate var citiesData: Data { return citiesString.data(using: String.Encoding.utf8)! }
}
