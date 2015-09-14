//
//  Lot.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct LotAttribute {

    //the display order of the attributes respects the enum order
    enum LotAttributeType: Int {
        case Indoor = 0
        case Card
        case Handicap
        case Valet
        case Clerk
    }
    
    var type: LotAttributeType
    var enabled: Bool
    
    var showAsEnabled: Bool {
        switch (type) {
        case .Indoor    : return true
        default         : return enabled
        }
    }
    
    func name(forIcon: Bool) -> String {
        switch (type) {
        case .Indoor    : return enabled || forIcon ? "indoor" : "outdoor"//.localizedString
        case .Handicap  : return "handicap"//.localizedString
        case .Clerk     : return "clerk"//.localizedString
        case .Valet     : return "valet"//.localizedString
        case .Card      : return "card"//.localizedString
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
    var agenda: [LotAgendaPeriod]
    var coordinate: CLLocationCoordinate2D
    var streetViewPanoramaId: String?
    var streetViewHeading: Double?

    var isCurrentlyOpen: Bool {
        
        if let period = self.currentPeriod {
            return period.isOpen
        }
        return false
    }
    
    //returns the "main" rate ie the one we want to display
    var mainRate: Float {
        
        let period = currentOrNextOpenPeriod
        
        var maxHourly: Float = currentOrNextOpenPeriod?.hourlyRate ?? 0
        var maxMax: Float = currentOrNextOpenPeriod?.maxRate ?? 0
        var maxDaily: Float = currentOrNextOpenPeriod?.dailyRate ?? 0
        
        if maxMax > 0 {
            return maxMax
        } else if maxDaily > 0 {
            return maxDaily
        } else if maxHourly > 0 {
            let hours = ((period?.endHour ?? 0) - (period?.startHour ?? 0)) / 3600
            return maxHourly * Float(hours)
        } else {
            return 0
        }
    }
    
    var hourlyRate: Float {
        return self.currentOrNextOpenPeriod?.hourlyRate ?? 0
    }
    
    //returns the periods flattened and ordered by day, then by start time
    var sortedAgenda: [LotAgendaPeriod] {
        
        var agendaSortedByToday = [LotAgendaPeriod]()
        let currentDay = DateUtil.dayIndexOfTheWeek()
        
        for var i = currentDay; i < 7; ++i {
            var itemsForDay = LotAgendaPeriod.getSortedAgendaForDay(i, agenda: self.agenda)
            agendaSortedByToday += itemsForDay
        }
        
        for var j = 0; j < currentDay; ++j {
            var itemsForDay = LotAgendaPeriod.getSortedAgendaForDay(j, agenda: self.agenda)
            agendaSortedByToday += itemsForDay
        }
        
        return agendaSortedByToday
    }
    
    var currentPeriod: LotAgendaPeriod? {
        
        let currentDay = DateUtil.dayIndexOfTheWeek()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        let dayAgenda = LotAgendaPeriod.getSortedAgendaForDay(currentDay, agenda: self.agenda)
        
        for period in dayAgenda {
            if currentTimeInterval >= period.startHour
                && currentTimeInterval <= period.endHour {
                    return period
            }
        }
        
        return nil
    }

    var currentOrNextOpenPeriod: LotAgendaPeriod? {
        
        let currentPeriod = self.currentPeriod!
        
        if currentPeriod.isOpen {
            return currentPeriod
        }
        
        let currentDay = DateUtil.dayIndexOfTheWeek()
        let currentTimeInterval = DateUtil.timeIntervalSinceDayStart()
        let sortedAgenda = self.sortedAgenda
        
        var nextOpenPeriod: LotAgendaPeriod?
        
        for period in sortedAgenda {
            let isBeforeCurrent = period.startHour < currentPeriod.startHour && period.dayIndex <= currentPeriod.dayIndex
            if period.isOpen {
                nextOpenPeriod = period
                if !isBeforeCurrent {
                    return nextOpenPeriod
                }
            }
        }
        
        return nextOpenPeriod
    }

    //aggregates the open times and returns a list of 7 nullable tuples with the total open times
    //optionally sorted
    func openTimes(sortedByToday: Bool) -> [(NSTimeInterval, NSTimeInterval)] {
        
        var timeIntervals = [(NSTimeInterval, NSTimeInterval)]()
        var chosenAgenda = sortedByToday ? self.sortedAgenda : self.agenda
        var groupedAgenda = LotAgendaPeriod.groupedAgenda(chosenAgenda)
        for group in groupedAgenda {
            
            var earliestStartTime: NSTimeInterval = 24*3600
            var latestEndTime: NSTimeInterval = 0
            
            for item in group {
                if item.isOpen {
                    if item.startHour < earliestStartTime {
                        earliestStartTime = item.startHour
                    }
                    if item.endHour > latestEndTime {
                        latestEndTime = item.endHour
                    }
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
        var currencyString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: Styles.Fonts.h4rVariable, NSBaselineOffsetAttributeName: 5])
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
            return NSAttributedString(string: "24 hour".localizedString.lowercaseString, attributes: [NSFontAttributeName: Styles.Fonts.h2rVariable])
        }

        let interval = currentPeriod!.endHour
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
        self.streetViewPanoramaId = lot.streetViewPanoramaId
        self.streetViewHeading = lot.streetViewHeading
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
        
        self.agenda = [LotAgendaPeriod]()
        for attr in json["properties"]["agenda"] {
            let day = attr.0.toInt()! - 1 //this is 1-indexed on the server, convert it to 0-index
            let timesArray = attr.1.arrayValue
            if timesArray.count == 0 {
                let lotAgendaPeriod = LotAgendaPeriod(day: day, hourly: nil, max: nil, daily: nil, start: NSTimeInterval(0), end: NSTimeInterval(24*3600))
                self.agenda.append(lotAgendaPeriod)
            }
            for item in attr.1.arrayValue {
                let hourly = item["hourly"].float
                let max = item["max"].float
                let daily = item["daily"].float
                
                let floatList = item["hours"].arrayValue
                var firstFloat: Float = floatList.first?.floatValue ?? 0
                var secondFloat: Float = floatList.last?.floatValue ?? 0
                
                let lotAgendaPeriod = LotAgendaPeriod(day: day, hourly: hourly, max: max, daily: daily, start: NSTimeInterval(firstFloat*60*60), end: NSTimeInterval(secondFloat*60*60))
                self.agenda.append(lotAgendaPeriod)
            }
        }

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
//        self.streetViewCoordinate = CLLocationCoordinate2D(latitude: json["properties"]["street_view"]["lat"].doubleValue, longitude: json["properties"]["street_view"]["long"].doubleValue)
        self.streetViewPanoramaId = json["properties"]["street_view"]["id"].string
        self.streetViewHeading = json["properties"]["street_view"]["head"].double
    }


}

class LotAgendaPeriod: Printable, DebugPrintable {
    
    var dayIndex: Int //1 to 7, monday to sunday
    var hourlyRate: Float?
    var maxRate: Float?
    var dailyRate: Float?
    var startHour: NSTimeInterval
    var endHour: NSTimeInterval
    
    var isOpen: Bool { get {
        return hourlyRate != nil || maxRate != nil || dailyRate != nil
        }
    }
    
    init(day: Int, hourly: Float?, max: Float?, daily: Float?, start: NSTimeInterval, end: NSTimeInterval) {
        self.dayIndex = day
        self.hourlyRate = hourly
        self.maxRate = max
        self.dailyRate = daily
        self.startHour = start
        self.endHour = end
    }

    static func getSortedAgendaForDay(day: Int, agenda: [LotAgendaPeriod]) -> [LotAgendaPeriod] {
        
        var agendaForDay = agenda.filter({ (var item: LotAgendaPeriod) -> Bool in
            item.dayIndex == day
        })
        
        agendaForDay.sort({ (first, second) -> Bool in
            if first.dayIndex == second.dayIndex {
                return first.startHour < second.startHour
            } else {
                return first.dayIndex < second.dayIndex
            }
        })

        return agendaForDay

    }
    
    //returns the sorted agenda as an array of arrays
    //ex: [day 0: [LotAgendaPeriod], day 1: [LotAgendaPeriod], etc by day number
    static func groupedAgenda(agenda: [LotAgendaPeriod]) -> [[LotAgendaPeriod]] {
        var groupedAgenda = [[LotAgendaPeriod]]()
        let startIndex = agenda[0].dayIndex
        for i in Range(start: startIndex, end: (7+startIndex)) {
            let index = i % 7
            let agendaForDay = LotAgendaPeriod.getSortedAgendaForDay(index, agenda: agenda)
            groupedAgenda.append(agendaForDay)
        }
        return groupedAgenda
    }
    
    var description: String { get {
        return String(format: "day: %d, hourly: %f, max: %f, daily: %f, start: %f, end: %f", dayIndex, hourlyRate ?? -1, maxRate ?? -1, dailyRate ?? -1, startHour, endHour)
        }
    }

    var debugDescription: String { get {
        return String(format: "day: %d, hourly: %f, max: %f, daily: %f, start: %f, end: %f", dayIndex, hourlyRate ?? -1, maxRate ?? -1, dailyRate ?? -1, startHour, endHour)
        }
    }

}
