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
    var name : String
    var desc: String
    var maxParkingTime: Int
    var duration: Int
    var buttonLocation: CLLocation
    var rules: ParkingRule
    var line: Shape

    init(json: JSON) {

        identifier = json["id"].stringValue
        code = json["code"].stringValue
        name = json["properties"]["rules"][0]["address"].stringValue
        desc = json["properties"]["rules"][0]["description"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
        duration = json["duration"].intValue
        buttonLocation = CLLocation(latitude: json["properties"]["button_location"]["lat"].doubleValue, longitude: json["properties"]["button_location"]["long"].doubleValue)
        
        rules = ParkingRule(json: json["properties"]["rules"][0])
        
//        for ruleJson in json["properties"]["rules"] {
//            rules.append(ParkingRule(json: ruleJson))
//        }

        line = Shape(json: json["geometry"])
    }
    
    
    
    func availableHourString() -> String{
        
        
        var day = DateUtil.dayIndexOfTheWeek()
        
        var hour : Float = DateUtil.hourFloatRepresentation()
        
        var dayAgenda = self.rules.agenda[day]
        
        if (dayAgenda.count > 0) {
            
            if(dayAgenda[0] > hour) {
                
                let available : Float = dayAgenda[0] - hour
                
                let availableHour = Int(floorf(available))
                
                let availableMin = available - Float(availableHour)
                
                var minStr : String = "\(Int(floorf(availableMin * 60.0)))"
                
                if (count(minStr) == 1) {
                    minStr += "0"
                }
                
                return "\(availableHour)" + ":" + minStr
                
            } else if (dayAgenda[1] > hour) {
                return "00:00"
            }
            
        } else {
            return "24:00+"
        }
        
        return ""
    }
}
