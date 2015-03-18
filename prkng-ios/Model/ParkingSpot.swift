//
//  ParkingSpot.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ParkingSpot: NSObject {

    var identifier: String
    var code: String
    var desc: String
    var maxParkingTime: Int
    var duration: Int
    var buttonLocation: CLLocation
    var rules: Array<ParkingRule>
    var line: Shape

    init(json: JSON) {

        identifier = json["id"].stringValue
        code = json["code"].stringValue
        desc = json["description"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
        duration = json["duration"].intValue
        buttonLocation = CLLocation(latitude: json["properties"]["button_location"]["lat"].doubleValue, longitude: json["properties"]["button_location"]["long"].doubleValue)
        rules = Array<ParkingRule>()
        for ruleJson in json["properties"]["rules"].arrayValue {
            rules.append(ParkingRule(json: ruleJson))
        }

        line = Shape(json: json["geometry"])
    }
}
