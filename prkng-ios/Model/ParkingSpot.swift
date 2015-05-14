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
    
    private func todaysAgenda () -> TimePeriod? {
        let day = DateUtil.dayIndexOfTheWeek()
        return self.rules.agenda[day]
    }
    
    private func tomorrowsAgenda () -> TimePeriod?{
        var day : Int = DateUtil.dayIndexOfTheWeek() + 1

        if day > 6 {
            day = 0
        }
        return self.rules.agenda[day]
    }
    
    
    func availableHourString() -> String{
        
        let hour  = DateUtil.hourFloatRepresentation()
        let dayAgenda = todaysAgenda()
        
//        if (dayAgenda.count > 0) {
//            
//            if(dayAgenda[0] > hour) {
//                
//
//                
//            } else if (dayAgenda[1] > hour) {
//                return "Unavailable".lowercaseString
//            }
//            
//        } else {
//            return "24:00+"
//        }
//        
//        return ""
        
        var availableTime : Float = -1

        if (dayAgenda != nil) {
            
            if (hour < dayAgenda!.start) {
                availableTime = dayAgenda!.start - hour
            } else if (hour >= dayAgenda!.start && hour < dayAgenda!.end) {
                // currently in the forbidden period
                availableTime = 0
            } else { // check next day
                
                if let tomorrowAgenda = tomorrowsAgenda() {
                    availableTime = tomorrowAgenda.start + (24.0 - hour)
                }
                
            }
            
        }
        
        
        if (availableTime == 0 ) {
            return "unavailable".localizedString.uppercaseString
        } else if (availableTime == -1 || availableTime > 24.0) {
            return "24:00+"
        }
        
        
        let availableHour = Int(floorf(availableTime))
        let availableMin = availableTime - Float(availableHour)
        
        var minStr : String = "\(Int(floorf(availableMin * 60.0)))"
        
        if (count(minStr) == 1) {
            minStr += "0"
        }
        
        return "\(availableHour)" + ":" + minStr
        
    }
}
