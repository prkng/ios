//
//  Lot.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum LotAttribute: String {
    case Clerk = "clerk"//.localizedString
    case Indoor = "indoor"//.localizedString
    case Valet = "valet"//.localizedString
    case Handicap = "handicap"//.localizedString
}

func ==(lhs: Lot, rhs: Lot) -> Bool {
    return lhs.identifier == rhs.identifier
}

class Lot: NSObject, Hashable, DetailObject {
   
    var json: JSON
    var identifier: String
    var name: String
    var address: String
    var attributes: [LotAttribute: Bool]
    var agenda: [LotAgendaDay]
    var coordinate: CLLocationCoordinate2D

    var isCurrentlyOpen: Bool {
        
        let currentDay = DateUtil.dayIndexOfTheWeekStartingOnMonday()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        
        let dayAgenda = LotAgendaDay.getAgendaForDay(currentDay, agenda: self.agenda)
        
        for day in dayAgenda {
            if currentTimeInterval >= day.startHour
                && currentTimeInterval <= day.endHour
                && day.maxRate != nil {
                    return true
            }
        }
        
        return false
    }
    //returns the "main" rate ie the one we want to display
    var mainRate: Float {
        
        let currentDay = DateUtil.dayIndexOfTheWeekStartingOnMonday()
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
    var endTimeToday: NSTimeInterval {
        
        let currentDay = DateUtil.dayIndexOfTheWeekStartingOnMonday()
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
        
        let currentDay = DateUtil.dayIndexOfTheWeekStartingOnMonday()
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
        
        var agendaSortedByToday = [LotAgendaDay]()
        
        for var i = currentDay; i < 8; ++i {
            let itemsForDay = LotAgendaDay.getAgendaForDay(i, agenda: self.agenda)
            agendaSortedByToday += itemsForDay
        }
        
        for var j = 1; j < currentDay; ++j {
            let itemsForDay = LotAgendaDay.getAgendaForDay(j, agenda: self.agenda)
            agendaSortedByToday += itemsForDay
        }

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
    

    // MARK: DetailObject Protocol
    var headerText: String { get { return address } }
    var headerIconName: String { get { return "btn_info_styled" } }
    var headerIconSubtitle: String { get { return "info" } }
    
    var bottomLeftTitleText: String? { get { return "daily".localizedString.uppercaseString } }
    var bottomLeftPrimaryText: NSAttributedString? { get {
        var currencyString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: Styles.FontFaces.regular(16)])
        var numberString = NSMutableAttributedString(string: String(Int(self.mainRate)), attributes: [NSFontAttributeName: Styles.Fonts.h2rVariable])
        currencyString.appendAttributedString(numberString)
        return currencyString
        }
    }
    
    var bottomRightTitleText: String { get {
        if self.isCurrentlyOpen {
            return "open".localizedString.uppercaseString
        } else {
            return "closed".localizedString.uppercaseString
        }
        }
    }
    var bottomRightPrimaryText: NSAttributedString { get {
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
        self.address = lot.address
        self.agenda = lot.agenda
        self.attributes = lot.attributes
        self.name = lot.name
    }
    
    init(json: JSON) {
        
        self.json = json
        self.identifier = json["id"].stringValue
        self.coordinate = CLLocationCoordinate2D(latitude: json["geometry"]["coordinates"][1].doubleValue, longitude: json["geometry"]["coordinates"][0].doubleValue)
        self.address = json["properties"]["address"].stringValue
        
        self.agenda = [LotAgendaDay]()
        for attr in json["properties"]["agenda"] {
            let day = attr.0.toInt()!
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

        self.attributes = [LotAttribute: Bool]()
        for attr in json["properties"]["attrs"] {
            let attribute = LotAttribute(rawValue: attr.0)!
            let value = attr.1.boolValue
            self.attributes.updateValue(value, forKey: attribute)
        }

        self.name = json["properties"]["name"].stringValue
        
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
    
    var description: String { get {
        return String(format: "day: %d, hourly: %f, max: %f, start: %f, end: %f", dayIndex, hourlyRate ?? 0, maxRate ?? 0, startHour, endHour)
        }
    }

    var debugDescription: String { get {
        return String(format: "day: %d, hourly: %f, max: %f, start: %f, end: %f", dayIndex, hourlyRate ?? 0, maxRate ?? 0, startHour, endHour)
        }
    }

}
