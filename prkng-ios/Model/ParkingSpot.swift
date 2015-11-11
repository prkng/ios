//
//  ParkingSpot.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

func ==(lhs: ParkingSpot, rhs: ParkingSpot) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class ParkingSpot: NSObject, DetailObject {
    
    var json: JSON
    var compact: Bool
    var identifier: String
    var code: String
    var name : String
    var desc: String
    var maxParkingTime: Int
    var duration: Int
    var selectedButtonLocation: CLLocationCoordinate2D?
    var buttonLocations: [CLLocationCoordinate2D]
    var rules: Array<ParkingRule>
    var line: Shape
    private var parkingRuleType: ParkingRuleType
    
    var userInfo: [String:AnyObject] //to maintain backwards compatibility with mapbox
        
//    //MARK- MKAnnotation
//    var title: String! { get { return identifier } }
//    var subtitle: String! { get { return name } }
////    var lineSpot: LineParkingSpot { get { return LineParkingSpot(spot: self) } }
//    var buttonSpot: ButtonParkingSpot { get { return ButtonParkingSpot(spot: self) } }

    
    // MARK: DetailObject Protocol
    var headerText: String { get { return name } }
    var headerIconName: String {
        get {
            if self.currentlyActiveRuleType == .Paid || self.currentlyActiveRuleType == .PaidTimeMax {
                return "icon_checkin_pin_pay"
            } else {
                return "icon_checkin_pin"
            }
        }
    }
    var doesHeaderIconWiggle: Bool { get { return true } }
    var headerIconSubtitle: String {
        get {
            if self.currentlyActiveRuleType == .Paid || self.currentlyActiveRuleType == .PaidTimeMax {
                return "check-in-pay".localizedString
            } else {
                return "check-in".localizedString
            }
        }
    }
    
    var bottomLeftTitleText: String? { get { return "hourly".localizedString.uppercaseString } }
    var bottomLeftPrimaryText: NSAttributedString? { get {
        
        switch self.currentlyActiveRuleType {
        case .Paid, .PaidTimeMax:
            let currencyString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: Styles.Fonts.h4rVariable, NSBaselineOffsetAttributeName: 5])
            let numberString = NSMutableAttributedString(string: self.currentlyActiveRule.paidHourlyRateString, attributes: [NSFontAttributeName: Styles.Fonts.h2rVariable])
            currencyString.appendAttributedString(numberString)
            return currencyString
        default:
            return nil
            
        }
        
        }
    }
    var bottomLeftWidth: Int { get { return UIScreen.mainScreen().bounds.width == 320 ? 100 : 110 } }
    
    var bottomRightTitleText: String { get {
        switch self.currentlyActiveRuleType {
        case .Paid:
            return "metered".localizedString.uppercaseString
        default:
            let interval = self.availableTimeInterval()
            
            if (interval > 2*3600) { // greater than 2 hours = show available until... by default
                return "until".localizedString.uppercaseString
            } else {
                return "for".localizedString.uppercaseString
            }

        }

        }
    }
    var bottomRightPrimaryText: NSAttributedString { get {
        switch self.currentlyActiveRuleType {
        case .Paid:
            let interval = self.currentlyActiveRuleEndTime
            return interval.untilAttributedString(Styles.Fonts.h2rVariable, secondPartFont: Styles.FontFaces.light(16))
        default:
            let interval = self.availableTimeInterval()
            
            if (interval > 2*3600) { // greater than 2 hours = show available until... by default
                return ParkingSpot.availableUntilAttributed(interval, firstPartFont: Styles.Fonts.h2rVariable, secondPartFont: Styles.FontFaces.light(16))
            } else {
                return ParkingSpot.availableMinutesOrHoursStringAttributed(interval, font: Styles.Fonts.h2rVariable)
            }
            
        }
        }
    }
    var bottomRightIconName: String? { get { return "btn_schedule" } }
    
    var showsBottomLeftContainer: Bool { get { return self.currentlyActiveRuleType == .Paid  || self.currentlyActiveRuleType == .PaidTimeMax} }

    //MARK- Hashable
    override var hashValue: Int { get { return Int(identifier)! } }
    
    init(spot: ParkingSpot) {
        json = spot.json
        compact = spot.compact
        identifier = spot.identifier
        code = spot.code
        name = spot.name
        desc = spot.desc
        maxParkingTime = spot.maxParkingTime
        duration = spot.duration
        buttonLocations = spot.buttonLocations
        rules = spot.rules
        line = spot.line
        userInfo = spot.userInfo
        parkingRuleType = spot.parkingRuleType
    }
    
    init(json: JSON) {
        
        self.json = json
        compact = json["properties"]["compact"].boolValue
        identifier = json["id"].stringValue
        code = json["code"].stringValue
        name = json["properties"]["way_name"].stringValue.abbreviatedString
        desc = json["properties"]["rules"][0]["description"].stringValue
        maxParkingTime = json["time_max_parking"].intValue
        duration = json["duration"].intValue
        buttonLocations = []
        let buttons = json["properties"]["button_locations"].arrayValue
        let singleButtonLocation = CLLocationCoordinate2D(latitude: json["properties"]["button_location"]["lat"].doubleValue, longitude: json["properties"]["button_location"]["long"].doubleValue)
        for button in buttons {
            let buttonLocation = CLLocationCoordinate2D(latitude: button["lat"].doubleValue, longitude: button["long"].doubleValue)
            buttonLocations.append(buttonLocation)
        }
        if buttons.count == 0 {
            buttonLocations.append(singleButtonLocation)
        }
        
        let selectedLat  = json["selectedButtonLocation"]["lat"].double
        let selectedLong = json["selectedButtonLocation"]["long"].double
        if selectedLat != nil && selectedLong != nil {
            selectedButtonLocation = CLLocationCoordinate2D(latitude: selectedLat!, longitude: selectedLong!)
        }
        
        rules = []
        
        let ruleJsons = json["properties"]["rules"]
        
        // TODO : Fix this when the data is fixed
        for ruleJson in ruleJsons  {
            let rule1 = ParkingRule(json: ruleJson.1, bsIndex: 0)
            
            let permit = Settings.shouldFilterForCarSharing()
            if !permit || !rule1.restrictionTypes.contains("permit") {
                rules.append(rule1)
            }
            
            let rule2 = ParkingRule(json: ruleJson.1, bsIndex: 1)
            if (!rule2.bullshitRule && (!permit || !rule2.restrictionTypes.contains("permit"))) {
                rules.append(rule2)
            }
            
        }
        
        parkingRuleType = json["properties"]["restrict_types"].arrayValue.map({ (json: JSON) -> String in
            json.stringValue
        }).contains("paid") ? .Paid : .Free
        
        line = Shape(json: json["geometry"])
        userInfo = [String:AnyObject]()
    }
    
    //returns something like 29:12
    func availableHourString(limited: Bool) -> String {
        let interval = availableTimeInterval()
        return ParkingSpot.availableHourString(interval, limited: limited)
    }
    
    static func availableHourString(interval: NSTimeInterval, limited: Bool) -> String {
        
        if (limited && interval >= 24 * 3600) {
            return "24:00+"
        }
        
        let minutes  = Int((interval / 60) % 60)
        let hours = Int((interval / 3600))
        return String(format: "%02ld:%02ld", hours, minutes)
    }

    //returns "30 minutes" or "2 hours" or similar
    func availableMinutesOrHoursStringAttributed(font: UIFont) -> NSAttributedString {
        let interval = availableTimeInterval()
        return ParkingSpot.availableMinutesOrHoursStringAttributed(interval, font: font)
    }
    
    static func availableMinutesOrHoursStringAttributed(interval: NSTimeInterval, font: UIFont) -> NSAttributedString {
        let minutes  = Int(interval / 60)
        
        var timeString = String(format: "%ld minutes", minutes)

        if minutes > 60 && minutes % 60 == 0 {
            //show how many hours
            timeString = String(format: "%ld hours", minutes/60)
        }
        
        
        let attrs = [NSFontAttributeName: font]
        let attributedString = NSMutableAttributedString(string: timeString, attributes: attrs)

        return attributedString
    }
    
    //returns something like Wednesday, 7:30 PM
    func availableUntil() -> String {
        let interval = availableTimeInterval()
        return ParkingSpot.availableUntil(interval)
    }
    
    static func availableUntil(availableTimeInterval: NSTimeInterval) -> String {
        
        let dateAtStartOfNextRule = NSDate(timeIntervalSinceNow: availableTimeInterval)
        
        let formatter = NSDateFormatter()
        
        formatter.dateFormat = getDateFormatString(dateAtStartOfNextRule)
        
        var availableUntil = formatter.stringFromDate(dateAtStartOfNextRule)
        
        //this line is to convert aujourd hui back into aujourd'hui
        availableUntil = availableUntil.stringByReplacingOccurrencesOfString("d h", withString: "d'h", options: NSStringCompareOptions.LiteralSearch, range: nil)

        return availableUntil
    }
    
    private static func getDateFormatString(date: NSDate) -> String {
        
        var dateFormatString = "EEEE, " //ex: Wednesday,
        dateFormatString += "'" + date.timeIntervalSinceDate(DateUtil.beginningDay(date)).toString(condensed: false) + "'"
        
        //now make today be 'today' and tomorrow be 'tomorrow' 
        
        if date.isToday() {
            let today = "'" + "today".localizedString + "'"
            dateFormatString = dateFormatString.stringByReplacingOccurrencesOfString("EEEE", withString: today, options: NSStringCompareOptions.LiteralSearch, range: nil)
            dateFormatString = dateFormatString.stringByReplacingOccurrencesOfString("d'h", withString: "d h", options: NSStringCompareOptions.LiteralSearch, range: nil)
        } else if date.isTomorrow() {
            let tomorrow = "'" + "tomorrow".localizedString + "'"
            dateFormatString = dateFormatString.stringByReplacingOccurrencesOfString("EEEE", withString: tomorrow, options: NSStringCompareOptions.LiteralSearch, range: nil)
        }

        return dateFormatString
        
    }
    
    func availableUntilAttributed(firstPartFont firstPartFont: UIFont, secondPartFont: UIFont) -> NSAttributedString {
        let availableTimeInterval = self.availableTimeInterval()
        return ParkingSpot.availableUntilAttributed(availableTimeInterval, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
    }
    
    static func availableUntilAttributed(availableTimeInterval: NSTimeInterval, firstPartFont: UIFont, secondPartFont: UIFont) -> NSAttributedString {
        
        let dateAtStartOfNextRule = NSDate(timeIntervalSinceNow: availableTimeInterval)
        
        let formatter = NSDateFormatter()
        
        let dateFormatString = getDateFormatString(dateAtStartOfNextRule)
        
        formatter.dateFormat = dateFormatString
        var formattedDate = formatter.stringFromDate(dateAtStartOfNextRule)
        
        //this line is to convert aujourd hui back into aujourd'hui
        formattedDate = formattedDate.stringByReplacingOccurrencesOfString("d h", withString: "d'h", options: NSStringCompareOptions.LiteralSearch, range: nil)

        //now we split the AM/PM part out to the second part
        var firstPart = formattedDate
        var secondPart = ""
        if formattedDate[formattedDate.characters.count - 1] == "M" {
            firstPart = formattedDate[0...formattedDate.characters.count - 4]
            secondPart = formattedDate[formattedDate.characters.count - 3...formattedDate.characters.count - 1]
        }
        
        let firstPartAttrs = [NSFontAttributeName: firstPartFont]
        let attributedString = NSMutableAttributedString(string: firstPart, attributes: firstPartAttrs)
        
        let secondPartAttrs = [NSFontAttributeName: secondPartFont]
        attributedString.appendAttributedString(NSMutableAttributedString(string: secondPart, attributes: secondPartAttrs))

        return attributedString
    }

    
    func availableTimeInterval() -> NSTimeInterval {
        let currentSecondsSinceDayStart = DateUtil.timeIntervalSinceDayStart()
        return availableTimeInterval(currentSecondsSinceDayStart)
    }

    //returns the closest future time that this parking spot is available until
    //returns -1 if we are in a restriction
    //returns 1 week from now if there are no restrictions whatsoever
    func availableTimeInterval(currentSecondsSinceDayStart: NSTimeInterval) -> NSTimeInterval {
        let secondsPerDay = 24 * 60 * 60

        var potentialNearestRules:[SimplifiedParkingRule] = []
        var potentialPastRules:[SimplifiedParkingRule] = []
        
        //find the closest time period per rule, then pick whichever computes to the lesser amount of time
        for dayAgenda in sortedTimePeriods() {
            
            for var i = 0; i < 7; i++ {
                if let period = dayAgenda.timePeriods[i] {
                    /*the first day is special because you could be in the middle of a time max, 
                    or there could be something in the past that needs to be taken into consideration 
                    if there is nothing in the future (ie one restriction all week, that was earlier 
                    today).
                    */
                    if i == 0 {
                        if period.start < currentSecondsSinceDayStart && period.end < currentSecondsSinceDayStart {
                            //this time period is completely in the past
                            //we should save this just in case there is never anything in the next week...
                            potentialPastRules.append(SimplifiedParkingRule(timePeriod: period, day: i))
                        } else if period.timeLimit <= 0 && period.start < currentSecondsSinceDayStart && currentSecondsSinceDayStart < period.end {
                            //we're in the middle of a restriction. NOTE: we should never get here, so return a -1...
                            return -1
                        } else if period.timeLimit  > 0 && period.start < currentSecondsSinceDayStart && currentSecondsSinceDayStart < period.end {
                            if period.end - currentSecondsSinceDayStart <= period.timeLimit {
                                //if there's MORE time left than the time limit, then treat it as though we AREN'T in a time max
                                potentialPastRules.append(SimplifiedParkingRule(timePeriod: period, day: i))
                            } else {
                                //if there's LESS time left than the time limit, then return the time limit!
                                return period.timeLimit
                            }
                        } else if currentSecondsSinceDayStart < period.start && currentSecondsSinceDayStart < period.end {
                            //this is the next restriction. save it!
                            potentialNearestRules.append(SimplifiedParkingRule(timePeriod: period, day: i))
                        }
                    } else if !potentialNearestRules.map({ (rule) -> TimePeriod in rule.timePeriod }).contains(period) {
                        //add this if it doesn't exist in another day
                        potentialNearestRules.append(SimplifiedParkingRule(timePeriod: period, day: i))
                    }
                }
            }
        }
        
        //ok, done with fetching all the rules. now let's find the nearest one!
        //if there is nothing in the future, but something in the past, pick the one in the past and make the day 7
        if potentialNearestRules.count == 0 {
            potentialNearestRules = potentialPastRules.map { (rule) -> SimplifiedParkingRule in
                rule.day = 7
                return rule
            }
        }

        var smallestTime = Int.max
        for rule in potentialNearestRules {
            let realStartTime = rule.timePeriod.timeLimit > 0 ? rule.timePeriod.start + rule.timePeriod.timeLimit : rule.timePeriod.start
            let secondsToRule = (secondsPerDay - Int(currentSecondsSinceDayStart))
                + ((rule.day - 1) * secondsPerDay)
                + Int(realStartTime)
            if secondsToRule < smallestTime {
                smallestTime = secondsToRule
            }
        }
        
        smallestTime = smallestTime == Int.max ? 3600*24*7 : smallestTime
        
        return NSTimeInterval(smallestTime)   
    }
    
    // returns an structure that looks like...
    // [ RULE1, RULE2, ETC]
    // where RULE1 is... [nil  , TIMEPERIOD, TIMEPERIOD, nil, nil, nil, nil]
    // ...which means... [today, tomorrow  , after-tom., etc, etc, etc, yesterday]
    func sortedTimePeriods() -> Array<DayArray>{
        var array : Array<DayArray> = []
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        if self.rules.count == 0 {
            return array
        }
        
        for r in 0...(self.rules.count - 1) {
            
            var timePeriods : Array<TimePeriod?> = []
            
            for var i = today; i < 7; ++i {
                timePeriods.append(self.rules[r].agenda[i])
            }
            
            for var j = 0; j < today; ++j {
                timePeriods.append(self.rules[r].agenda[j])
            }
            
            let dayArray = DayArray(timePeriods: timePeriods, rule: rules[r])
            array.append(dayArray)
        }
        
        return array
    }
    
    var currentlyActiveRule: ParkingRule {
        
        var activeRules = [ParkingRule]()
        
        let today = DateUtil.dayIndexOfTheWeek()
        let now = DateUtil.timeIntervalSinceDayStart()
        
        for rule in rules {
            for i in 0...(rule.agenda.count - 1) {
                let timePeriod = rule.agenda[i]
                if today == i
                    && timePeriod?.start <= now
                    && timePeriod?.end >= now {
                        activeRules.append(rule)
                }
            }
        }
        
        activeRules.sortInPlace({ (first: ParkingRule, second: ParkingRule) -> Bool in
            switch (first.ruleType, second.ruleType) {
                
            case (.Restriction, .Free):         return true
            case (.Restriction, .Restriction):  return true
            case (.Restriction, .Paid):         return true
            case (.Restriction, .TimeMax):      return true
            case (.Restriction, .PaidTimeMax):  return true
                
            case (.PaidTimeMax, .Free):         return true
            case (.PaidTimeMax, .Restriction):  return false
            case (.PaidTimeMax, .Paid):         return true
            case (.PaidTimeMax, .TimeMax):      return true
            case (.PaidTimeMax, .PaidTimeMax):  return true

            case (.Paid, .Free):                return true
            case (.Paid, .Restriction):         return false
            case (.Paid, .Paid):                return true
            case (.Paid, .TimeMax):             return true
            case (.Paid, .PaidTimeMax):         return false
                
            case (.TimeMax, .Free):             return true
            case (.TimeMax, .Restriction):      return false
            case (.TimeMax, .Paid):             return false
            case (.TimeMax, .TimeMax):          return true
            case (.TimeMax, .PaidTimeMax):      return false
                
            case (.Free, .Free):                return true
            case (.Free, .Restriction):         return false
            case (.Free, .Paid):                return false
            case (.Free, .TimeMax):             return false
            case (.Free, .PaidTimeMax):         return false
                
            }
        })
        
        return activeRules.first ?? ParkingRule(ruleType: ParkingRuleType.Free)
    }
    
    var currentlyActiveRuleType: ParkingRuleType {
        
        if self.compact {
            return self.parkingRuleType
        } else {
            return currentlyActiveRule.ruleType
        }
    }
    
    var currentlyActiveRuleEndTime: NSTimeInterval {
        var endTime: NSTimeInterval = 0
        let today = DateUtil.dayIndexOfTheWeek()
        let rule = self.currentlyActiveRule
        //validate... just in case!
        if rule.agenda.count >= today - 1 {
            endTime = rule.agenda[today]?.end ?? 0
        }

        return endTime
    }
}

struct DayArray {
    
    var timePeriods: Array<TimePeriod?>
    var rule: ParkingRule
}


//func ==(lhs: MGLLineParkingSpot, rhs: MGLLineParkingSpot) -> Bool {
//    return lhs.hashValue == rhs.hashValue
//}
//
//class MGLLineParkingSpot: MGLPolyline, UserInfo {
//    
//    var userInfo: [String:AnyObject] { get { return parkingSpot.userInfo } set(newValue) { parkingSpot.userInfo = newValue } }//to maintain backwards compatibility with mapbox
//    var parkingSpot: ParkingSpot!
//    
//    
//    private var lineWidth: CGFloat = 0
//    func lineWidthWithZoom(zoom: Double) -> CGFloat {
//        setupWithZoom(zoom)
//        return lineWidth
//    }
//    private var lineColor: UIColor = UIColor.clearColor()
//    func lineColorWithZoom(zoom: Double) -> UIColor {
//        setupWithZoom(zoom)
//        return lineColor
//    }
//
//    
//    //MARK- Hashable
//    
//    override var hashValue: Int { get { return Int(parkingSpot.identifier)! } }
//    
//    override init() {
//        super.init()
//    }
//    
//    func setupWithZoom(zoom: Double) {
//        
//        let selected = userInfo["selected"] as! Bool
//        let spot = userInfo["spot"] as! ParkingSpot
//        let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool
//        let isCurrentlyPaidSpot = spot.currentlyActiveRuleType == .Paid || spot.currentlyActiveRuleType == .PaidTimeMax
//        
//        if selected {
//            lineColor = Styles.Colors.red2
//        } else if isCurrentlyPaidSpot {
//            lineColor = Styles.Colors.curry
//        } else {
//            lineColor = Styles.Colors.lineBlue
//        }
//        
//        if zoom >= 15.0 && zoom < 17.0 {
//            lineWidth = 2.6
//        } else {
//            lineWidth = 4.4
//        }
//        
////        for location in spot.line.coordinates as Array<CLLocation> {
////            shape.addLineToCoordinate(location.coordinate)
////        }
//        
////        if shouldAddAnimation {
////            shape.addScaleAnimation()
////            lineSpotIDsDrawnOnMap.append(spot.identifier)
////        }
//        
//    }
//}

protocol UserInfo: MGLAnnotation {
    var userInfo: [String:AnyObject] { get set }//to maintain backwards compatibility with mapbox
}

class GenericMGLAnnotation: NSObject, MGLAnnotation, UserInfo {
    
    @objc var coordinate: CLLocationCoordinate2D { get { return _coordinate } }
    @objc var title: String? { get { return _title } }
    @objc var subtitle: String? { get { return _subtitle } }
    
    private var _coordinate: CLLocationCoordinate2D
    private var _title: String?
    private var _subtitle: String?
    
    var userInfo = [String:AnyObject]()
    
    private var annotationImage: UIImage?
    func annotationImageWithZoom(zoom: Double) -> UIImage {
        setupWithZoom(zoom)
        return annotationImage!
    }
    private var reuseIdentifier: String = ""
    func reuseIdentifierWithZoom(zoom: Double) -> String {
        setupWithZoom(zoom)
        return reuseIdentifier
    }
    
    var leftCalloutAccessoryView: UIView?
    var rightCalloutAccessoryView: UIView?
    
    var canShowCallout: Bool {
        
        let annotationType = userInfo["type"] as! String
        if annotationType == "carsharing"
            || annotationType == "searchResult"
            || annotationType == "previousCheckin" {
                return true
        }
        
        return false

    }
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self._coordinate = coordinate
        self._title = title
        self._subtitle = subtitle
    }
    
    func setupWithZoom(zoom: Double) {
        
        let annotationType = userInfo["type"] as! String

        switch annotationType {

        case "button":

            let selected = userInfo["selected"] as! Bool
            let spot = userInfo["spot"] as! ParkingSpot
            let isCurrentlyPaidSpot = spot.currentlyActiveRuleType == .Paid || spot.currentlyActiveRuleType == .PaidTimeMax
            let invisible = userInfo["invisible"] as? Bool ?? false
            let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool
            
            if invisible {
                let invisibleImage = UIImage.transparentImageWithSize(CGSize(width: 16, height: 16))
                annotationImage = invisibleImage
                reuseIdentifier = "invisible"
                return
            }
            
            var imageName = "button_line_"
            
            if zoom < 18 {
                imageName += "small_"
            }
            if isCurrentlyPaidSpot {
                imageName += "metered_"
            }
            if !selected {
                imageName += "in"
            }
            
            imageName += "active"
            
            let circleImage = UIImage(named: imageName)
            annotationImage = circleImage!
            reuseIdentifier = imageName
            return
            
//                    let circleMarker: RMMarker = RMMarker(UIImage: circleImage)
//            //
//            //        if shouldAddAnimation {
//            //            circleMarker.addScaleAnimation()
//            //            spotIDsDrawnOnMap.append(spot.identifier)
//            //        }
//            
//                    if (selected) {
//                        let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
//                        pulseAnimation.duration = 0.7
//                        pulseAnimation.fromValue = 0.95
//                        pulseAnimation.toValue = 1.10
//                        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                        pulseAnimation.autoreverses = true
//                        pulseAnimation.repeatCount = FLT_MAX
//                        circleMarker.addAnimation(pulseAnimation, forKey: nil)
//                    }
//                    
//                    return circleMarker

        case "lot":

            let selected = userInfo["selected"] as! Bool
            let cheaper = userInfo["cheaper"] as! Bool
            let lot = userInfo["lot"] as! Lot
            let shouldAddFadeAnimation = userInfo["fadeAnimation"] as? Bool ?? false
            let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool && !selected && !shouldAddFadeAnimation

            var imageName = "lot_pin_closed"
            var zPosition: CGFloat = 0 //this doesn't work!! See?

            if lot.isCurrentlyOpen {
                imageName = "lot_pin_open"
                zPosition = 50

                if cheaper && !selected {
                    imageName += "_cheaper"
                    zPosition = 100
                }
            }

            if selected {
                imageName += "_selected"
                zPosition = 150
            }

//            let circleMarker: RMMarker = RMMarker(UIImage: lot.markerImageNamed(imageName), anchorPoint: CGPoint(x: 0.5, y: 1))
//
//            if shouldAddAnimation {
//                circleMarker.addScaleAnimation()
//                spotIDsDrawnOnMap.append(lot.identifier)
//            } else if shouldAddFadeAnimation {
//                let fromImageName = imageName == "lot_pin_open" ? "lot_pin_open_cheaper" : "lot_pin_open"
//                circleMarker.addCrossFadeAnimationFromImage(lot.markerImageNamed(fromImageName), toImage:lot.markerImageNamed(imageName))
//            }
//
//            circleMarker.zPosition = zPosition
            
            annotationImage = lot.markerImageNamed(imageName)
            reuseIdentifier = lot.markerReuseIdentifierWithImageNamed(imageName)
            return


        case "carsharing":

            let selected = userInfo["selected"] as! Bool
            let carShare = userInfo["carshare"] as! CarShare
            let calloutView = carShare.calloutView()
            leftCalloutAccessoryView = calloutView.0
            rightCalloutAccessoryView = calloutView.1
            reuseIdentifier = carShare.mapPinName(selected)
            annotationImage = UIImage(named: reuseIdentifier)
            return


        case "carsharinglot":
            
            let carShareLot = userInfo["carsharelot"] as! CarShareLot
//            let marker = RMMarker(UIImage: carShareLot.mapPinImage, anchorPoint: CGPoint(x: 0.5, y: 1))
            reuseIdentifier = carShareLot.reuseIdentifier
            annotationImage = carShareLot.mapPinImage
            return

        case "searchResult":
            
            let searchResult = userInfo["searchresult"] as! SearchResult
            let calloutView = searchResult.calloutView()
            leftCalloutAccessoryView = calloutView.0
            rightCalloutAccessoryView = calloutView.1
            reuseIdentifier = "pin_pointer_result"
            annotationImage = UIImage(named: reuseIdentifier)!
            return
            
        case "previousCheckin":
            reuseIdentifier = "pin_round_p"
            annotationImage = UIImage(named: reuseIdentifier)!
            return

            
        default:
            return
            
        }

    }
}