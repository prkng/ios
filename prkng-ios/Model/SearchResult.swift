//
//  SearchResult.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchResult: NSObject, MKAnnotation, MGLAnnotation {
    
    var title : String?
    var location : CLLocation
    
    var userInfo: [String:AnyObject] //to maintain backwards compatibility with mapbox

    init(title: String, location : CLLocation) {
        self.title = title
        self.location = location
        self.userInfo = [String:AnyObject]()
    }
    
    //MARK- MKAnnotation
    var coordinate: CLLocationCoordinate2D { get { return location.coordinate } }

   
}
