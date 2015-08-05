//
//  PRK_GMSPolyline.swift
//  
//
//  Created by Antonino Urbano on 2015-08-04.
//
//

import UIKit
import GoogleMaps

class PRK_GMSPolyline: GMSPolyline {

    var spot: ParkingSpot
    
    convenience init(path: GMSMutablePath, title: String, spot: ParkingSpot) {
        self.init(spot: spot)
        self.title = title
        self.path = path
    }
    
    init(spot: ParkingSpot) {
        self.spot = spot
        super.init()
    }

    
}
