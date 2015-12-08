//
//  ParkingRule.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 24/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum ParkingRuleType: String {
    case TimeMax = "TimeMax"
    case SnowRestriction = "SnowRestriction"
    case Restriction = "Restriction"
    case Paid = "Paid"
    case PaidTimeMax = "PaidTimeMax"
    case Free = "Free"
}


func ==(lhs: ParkingRule, rhs: ParkingRule) -> Bool {
    var agendaMatches = true
    if lhs.agenda.count == rhs.agenda.count {
        for i in 0..<lhs.agenda.count {
            if lhs.agenda[i] != rhs.agenda[i] {
                agendaMatches = false
            }
        }
    }

    var restrictionTypesMatch = true
    if lhs.restrictionTypes.count == rhs.restrictionTypes.count {
        let leftRestrictionTypes = lhs.restrictionTypes.sort()
        let rightRestrictionTypes = rhs.restrictionTypes.sort()
        for i in 0..<leftRestrictionTypes.count {
            if leftRestrictionTypes[i] != rightRestrictionTypes[i] {
                restrictionTypesMatch = false
            }
        }
    }

    return lhs.paidHourlyRate == rhs.paidHourlyRate
        && lhs.code == rhs.code
        && lhs.maxParkingTime == rhs.maxParkingTime
        && lhs.seasonEnd == rhs.seasonEnd
        && lhs.desc == rhs.desc
        && restrictionTypesMatch
        && agendaMatches
}


class ParkingRule: NSObject {

    var restrictionTypes: [String]
    var paidHourlyRate: Float
    var code: String
    var maxParkingTime: Int
    var seasonEnd: String
    var desc: String
    var agenda : Array<TimePeriod?>
    
    var bullshitRule : Bool // means this rule is empty

    var paidHourlyRateString: String {
        let hourlyRate = Float(round(100*paidHourlyRate)/100)
        return String(format: "%.2f", hourlyRate)
    }
    
    private var _ruleType: ParkingRuleType?
    var ruleType: ParkingRuleType {
        
        if _ruleType != nil {
            return _ruleType!
        }
        
        if bullshitRule {
            return .Free
        }
        
        if restrictionTypes.contains("snow") {
            return .SnowRestriction
        } else if restrictionTypes.contains("paid") {
            if self.maxParkingTime > 0 {
                return .PaidTimeMax
            }
            return .Paid
        }
        if self.maxParkingTime > 0 {
            return .TimeMax
        } else {
            return .Restriction
        }

    }
    
    init(ruleType: ParkingRuleType) {
        _ruleType = ruleType
        restrictionTypes = []
        code = ""
        paidHourlyRate = 0
        maxParkingTime = 0
        seasonEnd = ""
        desc = ""
        agenda = Array()
        bullshitRule = true
    }
    
    // bsIndex is a stupid parameter, because the data structure sucks. There may be two rule sets. Remove it when the data structure is fixed.
    init(json: JSON, bsIndex : Int) {

        restrictionTypes = json["restrict_types"].arrayValue.map({ (json: JSON) -> String in
            json.stringValue
        })
        code = json["code"].stringValue
        paidHourlyRate = json["paid_hourly_rate"].floatValue
        
        let timelimit = json["time_max_parking"].int
        
        if(timelimit != nil) {
            maxParkingTime = timelimit!
        } else {
            maxParkingTime = 0
        }
        
        seasonEnd = json["season_end"].stringValue
        desc = json["description"].stringValue
        
        var agendaJson = json["agenda"]
        
        agenda = Array()
        
        bullshitRule = true
        
        // MONDAY
        
        let monStart : Float? = agendaJson["1"][bsIndex][0].float
        let monEnd : Float? = agendaJson["1"][bsIndex][1].float
        
        var monTimePeriod : TimePeriod? = nil
        
        if monStart != nil && monEnd != nil  {
            monTimePeriod = TimePeriod(startTime: Double(monStart! * 3600), endTime: Double (monEnd! * 3600), maxParkingTime : NSTimeInterval(maxParkingTime * 60) )
            
            bullshitRule = false
        }
        agenda.append(monTimePeriod)
    
        // TUESDAY
        
        let tueStart : Float? = agendaJson["2"][bsIndex][0].float
        let tueEnd : Float? = agendaJson["2"][bsIndex][1].float
        
        var tueTimePeriod : TimePeriod? = nil
        
        if tueStart != nil && tueEnd != nil  {
            tueTimePeriod = TimePeriod(startTime: Double(tueStart! * 3600), endTime: Double (tueEnd! * 3600), maxParkingTime : NSTimeInterval(maxParkingTime * 60) )
            
            bullshitRule = false
        }
        agenda.append(tueTimePeriod)
        
        // WEDNESDAY
        
        let wedStart : Float? = agendaJson["3"][bsIndex][0].float
        let wedEnd : Float? = agendaJson["3"][bsIndex][1].float
        
        var wedTimePeriod : TimePeriod? = nil
        
        if wedStart != nil && wedEnd != nil  {
            wedTimePeriod = TimePeriod(startTime: Double(wedStart! * 3600), endTime: Double (wedEnd! * 3600), maxParkingTime : NSTimeInterval(maxParkingTime * 60) )
            
            bullshitRule = false
        }
        agenda.append(wedTimePeriod)
        
        // THURSDAY
        
        let thuStart : Float? = agendaJson["4"][bsIndex][0].float
        let thuEnd : Float? = agendaJson["4"][bsIndex][1].float
        
        var thuTimePeriod : TimePeriod? = nil
        
        if thuStart != nil && thuEnd != nil  {
            thuTimePeriod = TimePeriod(startTime: Double(thuStart! * 3600), endTime: Double (thuEnd! * 3600), maxParkingTime : NSTimeInterval(maxParkingTime * 60) )
            
            bullshitRule = false
        }
        agenda.append(thuTimePeriod)
        
        // FRIDAY
        
        let friStart : Float? = agendaJson["5"][bsIndex][0].float
        let friEnd : Float? = agendaJson["5"][bsIndex][1].float
        
        var friTimePeriod : TimePeriod? = nil
        
        if friStart != nil && friEnd != nil  {
            friTimePeriod = TimePeriod(startTime: Double(friStart! * 3600), endTime: Double (friEnd! * 3600), maxParkingTime : NSTimeInterval(maxParkingTime * 60) )
            
            bullshitRule = false
        }
        agenda.append(friTimePeriod)
        
        
        // SATURDAY
        
        let satStart : Float? = agendaJson["6"][bsIndex][0].float
        let satEnd : Float? = agendaJson["6"][bsIndex][1].float
        
        var satTimePeriod : TimePeriod? = nil
        
        if satStart != nil && satEnd != nil  {
            satTimePeriod = TimePeriod(startTime: Double(satStart! * 3600), endTime: Double (satEnd! * 3600), maxParkingTime : NSTimeInterval(maxParkingTime * 60) )
            
            bullshitRule = false

        }
        agenda.append(satTimePeriod)
        
        
        // SUNDAY
        
        let sunStart : Float? = agendaJson["7"][bsIndex][0].float
        let sunEnd : Float? = agendaJson["7"][bsIndex][1].float
        
        var sunTimePeriod : TimePeriod? = nil
        
        if sunStart != nil && sunEnd != nil  {
            sunTimePeriod = TimePeriod(startTime: Double(sunStart! * 3600), endTime: Double (sunEnd! * 3600), maxParkingTime : NSTimeInterval(maxParkingTime * 60) )
            
            bullshitRule = false

        }
        agenda.append(sunTimePeriod)
    }


}

//a TimePeriod holds the start time and end time in seconds on that day. 
func ==(lhs: TimePeriod, rhs: TimePeriod) -> Bool {
    return lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.timeLimit == rhs.timeLimit
}

class TimePeriod : Equatable {
    var start : NSTimeInterval
    var end : NSTimeInterval
    var timeLimit : NSTimeInterval
    
    init (startTime : NSTimeInterval, endTime : NSTimeInterval, maxParkingTime : NSTimeInterval) {
        start = startTime
        end = endTime
        timeLimit = maxParkingTime
    }
}


class SimplifiedParkingRule {
    var timePeriod: TimePeriod
    var day: Int //0 means today, 1 tomorrow, etc

    init (timePeriod: TimePeriod, day: Int) {
        self.timePeriod = timePeriod
        self.day = day
    }
    
}
