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
    var agenda : Array<Array<Float>>


    init(json: JSON) {

        restrictionType = json["restrict_typ"].stringValue
        code = json["code"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
        seasonEnd = json["season_end"].stringValue
        desc = json["description"].stringValue
        
        var agendaJson = json["agenda"]
        
        agenda = Array()
        
        var mon : Array<Float> = Array()
        var monStart : Float? = agendaJson["1"][0][0].float
        var monEnd : Float? = agendaJson["1"][0][1].float
        if monStart != nil && monEnd != nil  {
            mon.append(monStart!)
            mon.append(monEnd!)
        }
        agenda.append(mon)
    
    
        var tue : Array<Float> = Array()
        var tueStart : Float? = agendaJson["2"][0][0].float
        var tueEnd : Float? = agendaJson["2"][0][1].float
        if tueStart != nil && tueEnd != nil  {
            tue.append(tueStart!)
            tue.append(tueEnd!)
        }
        agenda.append(tue)
        
        var wed : Array<Float> = Array()
        var wedStart : Float? = agendaJson["3"][0][0].float
        var wedEnd : Float? = agendaJson["3"][0][1].float
        if wedStart != nil && wedEnd != nil  {
            wed.append(wedStart!)
            wed.append(wedEnd!)
        }
        agenda.append(wed)
        
        var thu : Array<Float> = Array()
        var thuStart : Float? = agendaJson["4"][0][0].float
        var thuEnd : Float? = agendaJson["4"][0][1].float
        if thuStart != nil && thuEnd != nil  {
            thu.append(thuStart!)
            thu.append(thuEnd!)
        }
        agenda.append(thu)
        
        var fri : Array<Float> = Array()
        var friStart : Float? = agendaJson["5"][0][0].float
        var friEnd : Float? = agendaJson["5"][0][1].float
        if friStart != nil && friEnd != nil  {
            fri.append(friStart!)
            fri.append(friEnd!)
        }
        agenda.append(fri)
        
        var sat : Array<Float> = Array()
        var satStart : Float? = agendaJson["6"][0][0].float
        var satEnd : Float? = agendaJson["6"][0][1].float
        if satStart != nil && satEnd != nil  {
            sat.append(satStart!)
            sat.append(satEnd!)
        }
        agenda.append(sat)
        
        var sun : Array<Float> = Array()
        var sunStart : Float? = agendaJson["7"][0][0].float
        var sunEnd : Float? = agendaJson["7"][0][1].float
        if sunStart != nil && sunEnd != nil  {
            sun.append(sunStart!)
            sun.append(sunEnd!)
        }
        agenda.append(sun)
        
        

    }


}
