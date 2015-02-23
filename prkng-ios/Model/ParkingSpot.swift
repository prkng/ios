//
//  ParkingSpot.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import SwiftyJSON

class ParkingSpot: NSObject {

//    [
//    {
//    "geometry": {
//    "type": "string",
//    "coordinates": [
//    {}
//    ]
//    },
//    "type": "string",
//    "id": "string",
//    "properties": {
//    "restrict_typ": "string",
//    "description": "string",
//    "time_max_parking": "string",
//    "season_end": "string",
//    "agenda": {
//    "1": [
//    {}
//    ],
//    "2": [
//    {}
//    ],
//    "3": [
//    {}
//    ],
//    "4": [
//    {}
//    ],
//    "5": [
//    {}
//    ],
//    "6": [
//    {}
//    ],
//    "7": [
//    {}
//    ]
//    },
//    "special_days": "string",
//    "season_start": "string"
//    }
//    }
//    ]
//    
//
//
////    code = parking rule code -- str
////    days  = list of days when the permission apply (1: monday, ..., 7: sunday) -- int
////    description = the french description (source) -- str
////    restrict_typ = special permissions details (may not be used for the v1 i think) -- str
////    season_start = when the permission begins in the year (ex: 12-01 for december 1) -- str
////    season_end = when the permission no longer applies -- str
////    special_days = school days for example -- str
////    time_start = hour of the day when the permission starts -- float
////    time_end =  hour of the day when the permission ends (null if beyond the day) -- float
////    time_max_parking = restriction on parking time (minutes) -- integer
////    time_duration =
//    
    
    var code : String
    var days : Array<JSON>
    var descText : String
    
    
    init(json : JSON) {
      code = json["code"].stringValue
      days = json["days"].arrayValue
      descText = json["description"].stringValue
      
    }
}
