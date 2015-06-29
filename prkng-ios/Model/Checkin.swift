//
//  Checkin.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 16/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class Checkin: NSObject {
    
    
//    "created": "2015-06-16 14:50:44.72786",
//    "way_name": "Rue Rose-de-Lima",
//    "long": -73.5800569477762,
//    "active": true,
//    "slot_id": 17406,
//    "lat": 45.4794994741824,
//    "id": 104
    
    var date : NSDate
    var name : String
    var location : CLLocation
    var spotId : String
    var active : Bool
    
    init(json : JSON) {
        name = json["way_name"].stringValue
        let lat = json["lat"].doubleValue
        let lon = json["long"].doubleValue
        location = CLLocation(latitude: lat, longitude: lon)
        date = NSDate()
        spotId = json["slot_id"].stringValue
        active = json["active"].boolValue

        let created = json["created"].stringValue
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        var dateStr = created.substringToIndex(advance(created.startIndex, 19))
        date = formatter.dateFromString(dateStr)!
        
        println(date)
    }
    
   
}
