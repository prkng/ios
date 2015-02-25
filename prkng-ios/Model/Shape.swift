//
//  Shape.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 24/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class Shape: NSObject {
    
    var coordinates : Array<CLLocationCoordinate2D>
    
    init(json:JSON) {
        
        coordinates = Array<CLLocationCoordinate2D>()
        
        var jsonCoordinates : Array<JSON> = json["coordinates"].arrayValue
        
        for jsonCoordinate in jsonCoordinates {
        
            var coordinate = CLLocationCoordinate2DMake(jsonCoordinate[0].doubleValue, jsonCoordinate[1].doubleValue)
            coordinates.append(coordinate)
            
        }
        
    }
   
}
