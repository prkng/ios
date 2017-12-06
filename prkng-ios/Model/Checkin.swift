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
    
    var checkinId: Int
    var date: Date
    var name: String
    var location: CLLocation
    var spotId: String
    var active: Bool
    var hidden: Bool
    
    init(json : JSON) {

        checkinId = json["id"].intValue
        name = json["way_name"].stringValue
        let lat = json["lat"].doubleValue
        let lon = json["long"].doubleValue
        location = CLLocation(latitude: lat, longitude: lon)
        date = Date()
        spotId = json["slot_id"].stringValue
        active = json["active"].boolValue
        hidden = json["is_hidden"].boolValue
        
        let checkinTime = json["checkin_time"].stringValue
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateStr = checkinTime.substring(to: checkinTime.characters.index(checkinTime.startIndex, offsetBy: 19))
        if let omgDate = formatter.date(from: dateStr) {
            date = omgDate
        } else {
            formatter.locale = Locale(identifier: "en_US")
            if let omgDate2 = formatter.date(from: dateStr) {
                date = omgDate2
            } else {
                DDLoggerWrapper.logError("Could not parse a date... needs attention!")
                date = Date()
            }
        }
        
        print(date)
    }
    
   
}
