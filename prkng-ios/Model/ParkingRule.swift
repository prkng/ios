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
    var agenda : Array<TimePeriod?>


    init(json: JSON) {

        restrictionType = json["restrict_typ"].stringValue
        code = json["code"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
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
            monTimePeriod = TimePeriod(startTime: monStart!, endTime: monEnd!)
        }
        agenda.append(monTimePeriod)
    
        // TUESDAY
        
        var tue : Array<Float> = Array()
        var tueStart : Float? = agendaJson["2"][0][0].float
        var tueEnd : Float? = agendaJson["2"][0][1].float
        
        var tueTimePeriod : TimePeriod? = nil
        
        if tueStart != nil && tueEnd != nil  {
            tueTimePeriod = TimePeriod(startTime: tueStart!, endTime: tueEnd!)
        }
        agenda.append(tueTimePeriod)
        
        // WEDNESDAY
        
        var wed : Array<Float> = Array()
        var wedStart : Float? = agendaJson["3"][0][0].float
        var wedEnd : Float? = agendaJson["3"][0][1].float
        
        var wedTimePeriod : TimePeriod? = nil
        
        if wedStart != nil && wedEnd != nil  {
            wedTimePeriod = TimePeriod(startTime: wedStart!, endTime: wedEnd!)
        }
        agenda.append(wedTimePeriod)
        
        // THURSDAY
        
        var thu : Array<Float> = Array()
        var thuStart : Float? = agendaJson["4"][0][0].float
        var thuEnd : Float? = agendaJson["4"][0][1].float
        
        var thuTimePeriod : TimePeriod? = nil
        
        if thuStart != nil && thuEnd != nil  {
            thuTimePeriod = TimePeriod(startTime: thuStart!, endTime: thuEnd!)
        }
        agenda.append(thuTimePeriod)
        
        // FRIDAY
        
        var fri : Array<Float> = Array()
        var friStart : Float? = agendaJson["5"][0][0].float
        var friEnd : Float? = agendaJson["5"][0][1].float
        
        var friTimePeriod : TimePeriod? = nil
        
        if friStart != nil && friEnd != nil  {
            friTimePeriod = TimePeriod(startTime: friStart!, endTime: friEnd!)
        }
        agenda.append(friTimePeriod)
        
        
        // SATURDAY
        
        var sat : Array<Float> = Array()
        var satStart : Float? = agendaJson["6"][0][0].float
        var satEnd : Float? = agendaJson["6"][0][1].float
        
        var satTimePeriod : TimePeriod? = nil
        
        if satStart != nil && satEnd != nil  {
            satTimePeriod = TimePeriod(startTime: satStart!, endTime: satEnd!)
        }
        agenda.append(satTimePeriod)
        
        
        // SUNDAY
        
        var sun : Array<Float> = Array()
        var sunStart : Float? = agendaJson["7"][0][0].float
        var sunEnd : Float? = agendaJson["7"][0][1].float
        
        var sunTimePeriod : TimePeriod? = nil
        
        if sunStart != nil && sunEnd != nil  {
            sunTimePeriod = TimePeriod(startTime: sunStart!, endTime: sunEnd!)
        }
        agenda.append(sunTimePeriod)
    }


}


class TimePeriod {
    var start : Float
    var end : Float
    
    init (startTime : Float, endTime : Float) {
        start = startTime
        end = endTime
    }
    
}
