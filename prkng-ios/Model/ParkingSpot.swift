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
    var rules: Array<ParkingRule>
    var line: Shape
    
    init(json: JSON) {
        
        identifier = json["id"].stringValue
        code = json["code"].stringValue
        name = json["properties"]["rules"][0]["address"].stringValue
        desc = json["properties"]["rules"][0]["description"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
        duration = json["duration"].intValue
        buttonLocation = CLLocation(latitude: json["properties"]["button_location"]["lat"].doubleValue, longitude: json["properties"]["button_location"]["long"].doubleValue)
        
        rules = []
        
        let ruleJsons = json["properties"]["rules"]
        
        // TODO : Fix this when the data is fixed
        for ruleJson in ruleJsons  {
            let rule1 = ParkingRule(json: ruleJson.1, bsIndex: 0)
            rules.append(rule1)
            
            
            let rule2 = ParkingRule(json: ruleJson.1, bsIndex: 1)
            if (!rule2.bullshitRule) {
                rules.append(rule2)
            }
            
        }
        
        line = Shape(json: json["geometry"])
    }
    
    
    func availableTimeInterval() -> NSTimeInterval {
        
        let interval = DateUtil.timeIntervalSinceDayStart()
        
        var smallest : Int = 24 * 3600 // time interval
        
        for period in todaysAgenda() {
            
            if period != nil  {
                
                if (Int(period!.start) > Int(interval)) {
                    
                    // timeLimit is added for "Limited" time periods, otherwise it will always be 0
                    var diff = Int(period!.start) - Int(interval) + Int(period!.timeLimit)
                    
                    if (diff < smallest) {
                        smallest = diff
                    }
                    
                } else if (period!.start <= interval && period!.end > interval && period!.timeLimit > 0) { // we're inside a limited time zone.
                    // no need to check anything else
                    return period!.timeLimit
                }
                
            }
        }
        
        if (smallest  < 24 * 3600) {
            return NSTimeInterval(smallest)
        }
        
        
        // check tomorrow
        for period in tomorrowsAgenda() {
            
            if (period != nil && Int((24 * 3600) + period!.start) > Int(interval)) {
                
                let diff = Int((24 * 3600) + period!.start) - Int(interval) + Int(period!.timeLimit)
                
                if (diff < smallest) {
                    smallest = diff
                }
                
            }
        }
        
        if (smallest > 24 * 3600) {
            return NSTimeInterval(24 * 3600)
        }
        
        return NSTimeInterval(smallest)
    }
    
    func availableHourString() -> String{
        
        
        let interval = availableTimeInterval()
        
        if (interval == 24 * 3600) {
            return "24:00+"
        }
        
        let minutes  = Int((interval / 60) % 60)
        let hours = Int((interval / 3600))
        return  String(NSString(format: "%02ld:%02ld", hours, minutes))
    }
    
    
    func todaysAgenda () -> Array<TimePeriod?> {
        
        let weekDay = DateUtil.dayIndexOfTheWeek()
        
        var agenda : Array<TimePeriod?> = []
        
        for rule in rules {
            agenda.append(rule.agenda[weekDay])
        }
        
        return agenda
    }
    
    
    func tomorrowsAgenda () -> Array<TimePeriod?> {
        
        var weekDay : Int = DateUtil.dayIndexOfTheWeek() + 1
        
        if (weekDay == 7 ) {
            weekDay = 0
        }
        
        var agenda : Array<TimePeriod?> = []
        
        for rule in rules {
            agenda.append(rule.agenda[weekDay])
        }
        
        return agenda
    }
    
}
