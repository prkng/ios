//
//  CityOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

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
    
    func getCities(completion : (completed : Bool, cities: [City]) -> Void) {
        
        let url = APIUtility.APIConstants.rootURLString + "cities"
        
        request(.GET, URLString: url).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let citiesJson: [JSON] = json.arrayValue
            let cities = citiesJson.map({ (cityJson) -> City in
                City(json: cityJson)
            })
            
            completion(completed: response != nil && response!.statusCode < 400, cities: cities)
        }
        
    }
    
    func setClosestSelectedCity(point: CLLocationCoordinate2D) {
        var shortestDistance = Double.infinity
        var closestCity: City?
        let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
        for city in availableCities {
            let cityPoint = city.coordinate
            let cityLocation = CLLocation(latitude: cityPoint.latitude, longitude: cityPoint.longitude)
            let distance = cityLocation.distanceFromLocation(location)
            if distance < shortestDistance {
                shortestDistance = distance
                closestCity = city
            }
        }
        
        Settings.setSelectedCity(closestCity!)
    }
    
    func availableCityLocations() -> [CLLocation] {
        
        return availableCities.map({ (city) -> CLLocation in
            let point = city.coordinate
            let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
            return location
        })
    }

    private var citiesString: String { return "[   {      \"urban_area_radius\" : 30,      \"lat\" : 45.5016889,      \"name\" : \"montreal\",      \"long\" : -73.567256,      \"id\" : 2,      \"display_name\" : \"Montréal\"   },   {      \"urban_area_radius\" : 20,      \"lat\" : 46.82053904,      \"name\" : \"quebec\",      \"long\" : -71.22943997,      \"id\" : 1,      \"display_name\" : \"Québec\"   },   {      \"urban_area_radius\" : 30,      \"lat\" : 40.712784,      \"name\" : \"newyork\",      \"long\" : -74.005941,      \"id\" : 3,      \"display_name\" : \"New York\"   }]" }
    private var citiesData: NSData { return citiesString.dataUsingEncoding(NSUTF8StringEncoding)! }
}
