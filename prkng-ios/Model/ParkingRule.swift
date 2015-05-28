//
//  ParkingRule.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 24/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum RuleType {
    case Forbidden
    case Limited
}

class ParkingRule: NSObject {

    var ruleType : RuleType
    var restrictionType: String
    var code: String
    var maxParkingTime: Int?
    var seasonEnd: String
    var desc: String
    var agenda : Array<TimePeriod?>


    init(json: JSON) {

        restrictionType = json["restrict_typ"].stringValue
        code = json["code"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
        
        if(maxParkingTime != nil) {
            RuleType = RuleType.Forbidden
        } else {
            RuleType = RuleType.Limited
        }
        
        seasonEnd = json["season_end"].stringValue
        desc = json["description"].stringValue
        
        var agendaJson = json["agenda"]
        
        agenda = Array()
        
        
        
        // MONDAY
        
        var mon : Array<Float> = Array()
        var monStart : Float? = agendaJson["1"][0][0].float
        var monEnd : Float? = agendaJson["1"][0][1].float
        
        var monTimePeriod : TimePeriod? = nil
        
        if monStart != nil && monEnd != nil  {
            monTimePeriod = TimePeriod(startTime: Double(monStart! * 3600), endTime: Double (monEnd! * 3600))
        }
        agenda.append(monTimePeriod)
    
        // TUESDAY
        
        var tue : Array<Float> = Array()
        var tueStart : Float? = agendaJson["2"][0][0].float
        var tueEnd : Float? = agendaJson["2"][0][1].float
        
        var tueTimePeriod : TimePeriod? = nil
        
        if tueStart != nil && tueEnd != nil  {
            tueTimePeriod = TimePeriod(startTime: Double(tueStart! * 3600), endTime: Double (tueEnd! * 3600))
        }
        agenda.append(tueTimePeriod)
        
        // WEDNESDAY
        
        var wed : Array<Float> = Array()
        var wedStart : Float? = agendaJson["3"][0][0].float
        var wedEnd : Float? = agendaJson["3"][0][1].float
        
        var wedTimePeriod : TimePeriod? = nil
        
        if wedStart != nil && wedEnd != nil  {
            wedTimePeriod = TimePeriod(startTime: Double(wedStart! * 3600), endTime: Double (wedEnd! * 3600))
        }
        agenda.append(wedTimePeriod)
        
        // THURSDAY
        
        var thu : Array<Float> = Array()
        var thuStart : Float? = agendaJson["4"][0][0].float
        var thuEnd : Float? = agendaJson["4"][0][1].float
        
        var thuTimePeriod : TimePeriod? = nil
        
        if thuStart != nil && thuEnd != nil  {
            thuTimePeriod = TimePeriod(startTime: Double(thuStart! * 3600), endTime: Double (thuEnd! * 3600))
        }
        agenda.append(thuTimePeriod)
        
        // FRIDAY
        
        var fri : Array<Float> = Array()
        var friStart : Float? = agendaJson["5"][0][0].float
        var friEnd : Float? = agendaJson["5"][0][1].float
        
        var friTimePeriod : TimePeriod? = nil
        
        if friStart != nil && friEnd != nil  {
            friTimePeriod = TimePeriod(startTime: Double(friStart! * 3600), endTime: Double (friEnd! * 3600))
        }
        agenda.append(friTimePeriod)
        
        
        // SATURDAY
        
        var sat : Array<Float> = Array()
        var satStart : Float? = agendaJson["6"][0][0].float
        var satEnd : Float? = agendaJson["6"][0][1].float
        
        var satTimePeriod : TimePeriod? = nil
        
        if satStart != nil && satEnd != nil  {
            satTimePeriod = TimePeriod(startTime: Double(satStart! * 3600), endTime: Double (satEnd! * 3600))
        }
        agenda.append(satTimePeriod)
        
        
        // SUNDAY
        
        var sun : Array<Float> = Array()
        var sunStart : Float? = agendaJson["7"][0][0].float
        var sunEnd : Float? = agendaJson["7"][0][1].float
        
        var sunTimePeriod : TimePeriod? = nil
        
        if sunStart != nil && sunEnd != nil  {
            sunTimePeriod = TimePeriod(startTime: Double(sunStart! * 3600), endTime: Double (sunEnd! * 3600))
        }
        agenda.append(sunTimePeriod)
    }


}


class TimePeriod {
    var start : NSTimeInterval
    var end : NSTimeInterval
    
    init (startTime : Double, endTime : Double) {
        start = startTime
        end = endTime
    }
    
}
