//
//  ParkingRule.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 24/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ParkingRule: NSObject {

    var restrictionType: String
    var code: String
    var maxParkingTime: Int
    var seasonEnd: String
    var desc: String


    init(json: JSON) {

        restrictionType = json["restricty_type"].stringValue
        code = json["code"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
        seasonEnd = json["season_end"].stringValue
        desc = json["description"].stringValue

    }


}
