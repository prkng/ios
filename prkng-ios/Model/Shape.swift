//
//  Shape.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 24/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class Shape: NSObject {

    var type: String
    var coordinates: Array<CLLocation>
    
    var coordinates2D: [CLLocationCoordinate2D] { get {
        return coordinates.map({ (location: CLLocation) -> CLLocationCoordinate2D in
            return location.coordinate
    }) } }

    init(json: JSON) {

        type = json["type"].stringValue

        coordinates = Array<CLLocation>()
        let jsonCoordinates: Array<JSON> = json["coordinates"].arrayValue
        for jsonCoordinate in jsonCoordinates {
            let coordinate = CLLocation(latitude: jsonCoordinate[1].doubleValue, longitude: jsonCoordinate[0].doubleValue)
            coordinates.append(coordinate)
        }

    }

}
