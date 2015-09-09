//
//  Lot.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct LotAttribute {

    enum LotAttributeType: Int {
        case Indoor = 0
        case Handicap
        case Clerk
        case Valet
        case Card
    }
    
    var type: LotAttributeType
    var enabled: Bool
    
    var name: String {
        get {
            switch (type) {
            case .Indoor    : return "indoor"//.localizedString
            case .Handicap  : return "handicap"//.localizedString
            case .Clerk     : return "clerk"//.localizedString
            case .Valet     : return "valet"//.localizedString
            case .Card      : return "card"//.localizedString
            }
        }
    }
    
    static func typeFromName(name: String) -> LotAttributeType? {
        switch (name.lowercaseString) {
        case "clerk"    : return .Clerk
        case "indoor"   : return .Indoor
        case "valet"    : return .Valet
        case "handicap" : return .Handicap
        case "card"     : return .Card
        default         : return nil
        }
    }
    
}

func ==(lhs: Lot, rhs: Lot) -> Bool {
    return lhs.identifier == rhs.identifier
}

class Lot: NSObject, Hashable, DetailObject {
   
    var json: JSON
    var identifier: String
    var name: String
    var lotOperator: String
    var address: String
    var capacity: Int
    var attributes: [LotAttribute]
    var agenda: [LotAgendaDay]
    var coordinate: CLLocationCoordinate2D

    var isCurrentlyOpen: Bool {
        
        let currentDay = DateUtil.dayIndexOfTheWeek()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        
        let dayAgenda = LotAgendaDay.getAgendaForDay(currentDay, agenda: self.agenda)
        
        for day in dayAgenda {
            if currentTimeInterval >= day.startHour
                && currentTimeInterval <= day.endHour
                && (day.maxRate != nil || day.hourlyRate != nil) {
                    return true
            }
        }
        
        return false
    }
    //returns the "main" rate ie the one we want to display
    var mainRate: Float {
        
        let currentDay = DateUtil.dayIndexOfTheWeek()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        
        let dayAgenda = LotAgendaDay.getAgendaForDay(currentDay, agenda: self.agenda)
        
        for day in dayAgenda {
            if currentTimeInterval >= day.startHour
                && currentTimeInterval <= day.endHour
                && day.maxRate != nil {
                    return day.maxRate!
            }
        }
        
        return 0
    }
    var mainHourlyRate: Float {
        
        let currentDay = DateUtil.dayIndexOfTheWeek()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        
        let dayAgenda = LotAgendaDay.getAgendaForDay(currentDay, agenda: self.agenda)
        
        for day in dayAgenda {
            if currentTimeInterval >= day.startHour
                && currentTimeInterval <= day.endHour
                && day.hourlyRate != nil {
                    return day.hourlyRate!
            }
        }
        
        return 0
    }
    var endTimeToday: NSTimeInterval {
        
        let currentDay = DateUtil.dayIndexOfTheWeek()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        
        let dayAgenda = LotAgendaDay.getAgendaForDay(currentDay, agenda: self.agenda)
        
        for day in dayAgenda {
            if currentTimeInterval >= day.startHour
                && currentTimeInterval <= day.endHour {
                    return day.endHour
            }
        }
        
        return -1
    }
    //TODO: this is incomplete. needs to be finished
    var nextEndTime: NSTimeInterval {
        
        var beforeItem: LotAgendaDay?
        var afterItem: LotAgendaDay?
        
        let currentDay = DateUtil.dayIndexOfTheWeek()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        
        let dayAgenda = LotAgendaDay.getAgendaForDay(currentDay, agenda: self.agenda)
        for day in dayAgenda {
            if currentTimeInterval >= day.startHour
                && currentTimeInterval <= day.endHour {
                    return day.endHour
            }
//            if currentTimeInterval > day.startHour
//                && currentTimeInterval > day.endHour {
//                    return day.startHour
//            }

        }

//        self.agenda.sort { (first, second) -> Bool in
//            if first.dayIndex == second.dayIndex {
//                return first.startHour < second.startHour
//            } else {
//                return first.dayIndex < second.dayIndex
//            }
//        }
        
        var agendaSortedByToday = self.sortedAgenda

        for day in agendaSortedByToday {
            if currentTimeInterval >= day.startHour
                && currentTimeInterval <= day.endHour {
                    return day.endHour
            }
        }

        if self.agenda.count == 0 {
            return -1
        }
        
        return -1
    }
    
    var sortedAgenda: [LotAgendaDay] {
        get {
            
            var agendaSortedByToday = [LotAgendaDay]()
            let currentDay = DateUtil.dayIndexOfTheWeek()
            
            for var i = currentDay; i < 7; ++i {
                let itemsForDay = LotAgendaDay.getAgendaForDay(i, agenda: self.agenda)
                agendaSortedByToday += itemsForDay
            }
            
            for var j = 0; j < currentDay; ++j {
                let itemsForDay = LotAgendaDay.getAgendaForDay(j, agenda: self.agenda)
                agendaSortedByToday += itemsForDay
            }
            
            return agendaSortedByToday
        }
    }
    
    //aggregates the open times and returns a list of 7 nullable tuples with the total open times
    //optionally sorted
    func openTimes(sortedByToday: Bool) -> [(NSTimeInterval, NSTimeInterval)] {
        
        var timeIntervals = [(NSTimeInterval, NSTimeInterval)]()
//        NSLog(self.json.description)
        var chosenAgenda = sortedByToday ? self.sortedAgenda : self.agenda
        var groupedAgenda = LotAgendaDay.groupedAgenda(chosenAgenda)
        for group in groupedAgenda {
            
            var earliestStartTime: NSTimeInterval = 24*3600
            var latestEndTime: NSTimeInterval = 0
            
            for item in group {
                if item.startHour < earliestStartTime {
                    earliestStartTime = item.startHour
                }
                if item.endHour > latestEndTime {
                    latestEndTime = item.endHour
                }
            }
            
            if latestEndTime > 0 {
                timeIntervals.append((earliestStartTime, latestEndTime))
            } else {
                timeIntervals.append((0, 0))
            }
        }
        
        return timeIntervals

    }
    

    // MARK: DetailObject Protocol
    var headerText: String { get { return address } }
    var headerIconName: String { get { return "btn_info_styled" } }
    var doesHeaderIconWiggle: Bool { get { return false } }
    var headerIconSubtitle: String { get { return "info" } }
    
    var bottomLeftTitleText: String? { get { return "daily".localizedString.uppercaseString } }
    var bottomLeftPrimaryText: NSAttributedString? { get {
        var currencyString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: Styles.FontFaces.regular(16), NSBaselineOffsetAttributeName: 5])
        var numberString = NSMutableAttributedString(string: String(Int(self.mainRate)), attributes: [NSFontAttributeName: Styles.Fonts.h2rVariable])
        currencyString.appendAttributedString(numberString)
        return currencyString
        }
    }
    var bottomLeftWidth: Int { get { return 95 } }
    
    var bottomRightTitleText: String { get {
        if self.isCurrentlyOpen {
            return "open".localizedString.uppercaseString
        } else {
            return "closed".localizedString.uppercaseString
        }
        }
    }
    var bottomRightPrimaryText: NSAttributedString { get {
        //this logic should be similar to "timeperiodtext" in time span
        let filteredAgenda = self.openTimes(false).filter({ (var item: (NSTimeInterval, NSTimeInterval)) -> Bool in
            item.0 == 0 && item.1 == 24*3600
        })
        if filteredAgenda.count == 7 {
            return NSAttributedString(string: "24H", attributes: [NSFontAttributeName: Styles.Fonts.h2rVariable])
        }

        let interval = endTimeToday
        return interval.untilAttributedString(Styles.Fonts.h2rVariable, secondPartFont: Styles.FontFaces.light(16))
        }
    }
    var bottomRightIconName: String? { get { return nil } }
    
    var showsBottomLeftContainer: Bool { get { return true } }

    
    
    //MARK- Hashable
    override var hashValue: Int { get { return identifier.toInt()! } }
    
    init(lot: Lot) {
        self.json = lot.json
        self.identifier = lot.identifier
        self.coordinate = lot.coordinate
        self.capacity = lot.capacity
        self.address = lot.address
        self.agenda = lot.agenda
        self.attributes = lot.attributes
        self.name = lot.name
        self.lotOperator = lot.lotOperator
        
    }
    
    init(json: JSON) {
        
        self.json = json
        self.identifier = json["id"].stringValue
        self.coordinate = CLLocationCoordinate2D(latitude: json["geometry"]["coordinates"][1].doubleValue, longitude: json["geometry"]["coordinates"][0].doubleValue)
        self.address = json["properties"]["address"].stringValue
        self.capacity = json["properties"]["capacity"].intValue
        
        self.agenda = [LotAgendaDay]()
        for attr in json["properties"]["agenda"] {
            let day = attr.0.toInt()! - 1 //this is 1-indexed on the server, convert it to 0-index
            for item in attr.1.arrayValue {
                let hourly = item["hourly"].float
                let max = item["max"].float
                let daily = item["daily"].float
                
                let floatList = item["hours"].arrayValue
                var firstFloat: Float = floatList.first?.floatValue ?? 0
                var secondFloat: Float = floatList.last?.floatValue ?? 0
                
                let lotAgendaDay = LotAgendaDay(day: day, hourly: hourly, max: max, daily: daily, start: NSTimeInterval(firstFloat*60*60), end: NSTimeInterval(secondFloat*60*60))
                self.agenda.append(lotAgendaDay)
            }
        }
        
        LotAgendaDay.getAgendaForDay(5, agenda: self.agenda)

        self.attributes = [LotAttribute]()
        for attr in json["properties"]["attrs"] {
            let attributeType = LotAttribute.typeFromName(attr.0)
            if attributeType != nil {
                let attribute = LotAttribute(type: attributeType!, enabled: attr.1.boolValue)
                self.attributes.append(attribute)
            } else {
                NSLog("Cannot parse lot attribute type: '" + attr.0 + "'")
            }
        }
        self.attributes.sort { (left, right) -> Bool in
            left.type.rawValue < right.type.rawValue
        }

        self.name = json["properties"]["name"].stringValue
        self.lotOperator = json["properties"]["operator"].stringValue
        
    }


}

class LotAgendaDay: Printable, DebugPrintable {
    
    var dayIndex: Int //1 to 7, monday to sunday
    var hourlyRate: Float?
    var maxRate: Float?
    var dailyRate: Float?
    var startHour: NSTimeInterval
    var endHour: NSTimeInterval
    
    init(day: Int, hourly: Float?, max: Float?, daily: Float?, start: NSTimeInterval, end: NSTimeInterval) {
        self.dayIndex = day
        self.hourlyRate = hourly
        self.maxRate = max
        self.dailyRate = daily
        self.startHour = start
        self.endHour = end
    }

    static func getAgendaForDay(day: Int, agenda: [LotAgendaDay]) -> [LotAgendaDay] {
        
        let agendaForDay = agenda.filter({ (var item: LotAgendaDay) -> Bool in
            item.dayIndex == day
        })
        
        return agendaForDay

    }
    
    //returns the sorted agenda as an array of arrays
    //ex: [day 0: [LotAgendaDay], day 1: [LotAgendaDay], etc by day number
    static func groupedAgenda(agenda: [LotAgendaDay]) -> [[LotAgendaDay]] {
        var groupedAgenda = [[LotAgendaDay]]()
        let startIndex = agenda[0].dayIndex
        for i in Range(start: startIndex, end: (7+startIndex)) {
            let index = i % 7
            let agendaForDay = LotAgendaDay.getAgendaForDay(index, agenda: agenda)
            groupedAgenda.append(agendaForDay)
        }
        return groupedAgenda
    }
    
    var description: String { get {
        return String(format: "day: %d, hourly: %f, max: %f, start: %f, end: %f", dayIndex, hourlyRate ?? 0, maxRate ?? 0, startHour, endHour)
        }
    }

    var debugDescription: String { get {
        return String(format: "day: %d, hourly: %f, max: %f, start: %f, end: %f", dayIndex, hourlyRate ?? 0, maxRate ?? 0, startHour, endHour)
        }
    }

}
