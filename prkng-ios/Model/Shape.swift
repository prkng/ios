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

    init(json: JSON) {

        type = json["type"].stringValue

        coordinates = Array<CLLocation>()
        var jsonCoordinates: Array<JSON> = json["coordinates"].arrayValue
        for jsonCoordinate in jsonCoordinates {
            var coordinate = CLLocation(latitude: jsonCoordinate[1].doubleValue, longitude: jsonCoordinate[0].doubleValue)
            coordinates.append(coordinate)
        }

    }

}
