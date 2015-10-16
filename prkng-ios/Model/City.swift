//
//  City.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-14.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import Foundation

class City: NSObject {
    
    var json: JSON
    var urbanAreaRadius: Int
    var coordinate: CLLocationCoordinate2D
    var name: String
    var displayName: String
    
    init(json: JSON) {
        self.json = json
        self.urbanAreaRadius = json["urban_area_radius"].int ?? 40
        self.name = json["name"].stringValue
        self.displayName = json["display_name"].stringValue
        self.coordinate = CLLocationCoordinate2D(latitude: json["lat"].doubleValue, longitude: json["long"].doubleValue)
    }
    
}
