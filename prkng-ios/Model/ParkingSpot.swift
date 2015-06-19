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

class ParkingSpot: NSObject, Hashable {
    
    var identifier: String
    var code: String
    var name : String
    var desc: String
    var maxParkingTime: Int
    var duration: Int
    var buttonLocation: CLLocation
    var rules: Array<ParkingRule>
    var line: Shape
    
    var userInfo: [String:AnyObject] //to maintain backwards compatibility with mapbox
    
    //MARK- MKAnnotation
    var title: String! { get { return identifier } }
    var subtitle: String! { get { return name } }
//    var lineSpot: LineParkingSpot { get { return LineParkingSpot(spot: self) } }
    var buttonSpot: ButtonParkingSpot { get { return ButtonParkingSpot(spot: self) } }

    //MARK- Hashable
    override var hashValue: Int { get { return identifier.toInt()! } }
    
    
    init(spot: ParkingSpot) {
        identifier = spot.identifier
        code = spot.code
        name = spot.name
        desc = spot.desc
        maxParkingTime = spot.maxParkingTime
        duration = spot.duration
        buttonLocation = spot.buttonLocation
        rules = spot.rules
        line = spot.line
        userInfo = spot.userInfo
    }
    
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
    
    //returns something like Wednesday, 7:30 PM
    func availableUntil() -> String {
        let interval = availableTimeInterval()
        return ParkingSpot.availableUntil(interval)
    }
    
    static func availableUntil(availableTimeInterval: NSTimeInterval) -> String {
        let dateAtStartOfNextRule = NSDate(timeIntervalSinceNow: availableTimeInterval)
        
        let formatter = NSDateFormatter()
        
        if dateAtStartOfNextRule.minute() > 0 {
            formatter.dateFormat = "EEEE, h:mm a" //Wednesday, 7:30 PM
        } else {
            formatter.dateFormat = "EEEE, h a" //Wednesday, 7 PM
        }
        
        let availableUntil = formatter.stringFromDate(dateAtStartOfNextRule)
        return availableUntil
    }

    static func availableUntilAttributed(availableTimeInterval: NSTimeInterval, firstPartFont: UIFont, secondPartFont: UIFont) -> NSAttributedString {
        let dateAtStartOfNextRule = NSDate(timeIntervalSinceNow: availableTimeInterval)
        
        let formatter = NSDateFormatter()
        
        if dateAtStartOfNextRule.minute() > 0 {
            formatter.dateFormat = "EEEE, h:mm " //Wednesday, 7:30
        } else {
            formatter.dateFormat = "EEEE, h " //Wednesday, 7
        }
        
        let firstPart = formatter.stringFromDate(dateAtStartOfNextRule)

        formatter.dateFormat = "a" //PM
        
        let secondPart = formatter.stringFromDate(dateAtStartOfNextRule)
        
        let firstPartAttrs = [NSFontAttributeName: firstPartFont]
        var attributedString = NSMutableAttributedString(string: firstPart, attributes: firstPartAttrs)
        
        let secondPartAttrs = [NSFontAttributeName: secondPartFont]
        attributedString.appendAttributedString(NSMutableAttributedString(string: secondPart, attributes: secondPartAttrs))

        return attributedString
    }

    
    func availableTimeInterval() -> NSTimeInterval {
        let currentSecondsSinceDayStart = DateUtil.timeIntervalSinceDayStart()
        return availableTimeInterval(currentSecondsSinceDayStart)
    }

    //returns the closest future time that this parking spot is available until
    func availableTimeInterval(currentSecondsSinceDayStart: NSTimeInterval) -> NSTimeInterval {
        let secondsPerDay = 24 * 60 * 60

        var potentialNearestRules:[SimplifiedParkingRule] = []
        var potentialPastRules:[SimplifiedParkingRule] = []
        
        //find the closest time period per rule, then pick whichever computes to the lesser amount of time
        for dayAgenda in sortedTimePeriods() {
            
            for var i = 0; i < 7; i++ {
                if let period = dayAgenda[i] {
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
                    } else if !contains(potentialNearestRules.map({ (var rule) -> TimePeriod in rule.timePeriod }), period) {
                        //add this if it doesn't exist in another day
                        potentialNearestRules.append(SimplifiedParkingRule(timePeriod: period, day: i))
                    }
                }
            }
        }
        
        //ok, done with fetching all the rules. now let's find the nearest one!
        //if there is nothing in the future, but something in the past, pick the one in the past and make the day 7
        if potentialNearestRules.count == 0 {
            potentialNearestRules = potentialPastRules.map { (var rule) -> SimplifiedParkingRule in
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
        
        return NSTimeInterval(smallestTime)   
    }
    
    // returns an structure that looks like...
    // [ RULE1, RULE2, ETC]
    // where RULE1 is... [nil  , TIMEPERIOD, TIMEPERIOD, nil, nil, nil, nil]
    // ...which means... [today, tomorrow  , after-tom., etc, etc, etc, yesterday]
    func sortedTimePeriods() -> Array<Array<TimePeriod?>>{
        var array : Array<Array<TimePeriod?>> = []
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for r in 0...(self.rules.count - 1) {
            
            var dayArray : Array<TimePeriod?> = []
            
            for var i = today; i < 7; ++i {
                dayArray.append(self.rules[r].agenda[i])
            }
            
            for var j = 0; j < today; ++j {
                dayArray.append(self.rules[r].agenda[j])
            }
            
            array.append(dayArray)
        }
        
        return array
    }
    
}

func ==(lhs: LineParkingSpot, rhs: LineParkingSpot) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class LineParkingSpot: MKPolyline, Hashable {
    var userInfo: [String:AnyObject] { get { return parkingSpot.userInfo } }//to maintain backwards compatibility with mapbox
    var parkingSpot: ParkingSpot!
    
    //MARK- Hashable
    override var hashValue: Int { get { return parkingSpot.identifier.toInt()! } }

//    convenience init(coordinates coords: UnsafeMutablePointer<CLLocationCoordinate2D>, count: Int, spot: ParkingSpot) {
//        parkingSpot = spot
//        self.init(coordinates: coords, count: count)
//    }
//    
//    init(coordinates coords: UnsafeMutablePointer<CLLocationCoordinate2D>, count: Int) {
//        super.init(coordinates: coords, count: count)
//    }
    override init() {
        super.init()
    }
}

class ButtonParkingSpot: ParkingSpot, MKAnnotation {
    var coordinate: CLLocationCoordinate2D { get { return buttonLocation.coordinate } }
}

class LineParkingSpotRenderer: MKPolylineRenderer {
    override func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        super.drawLayer(layer, inContext: ctx)
    }
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext!) {
        super.drawMapRect(mapRect, zoomScale: zoomScale, inContext: context)
    }
    
}

class ButtonParkingSpotView: MKAnnotationView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init!(annotation: MKAnnotation!, reuseIdentifier: String!, mbxZoomLevel: CGFloat) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup(mbxZoomLevel)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var buttonParkingSpotAnnotation : ButtonParkingSpot!
    
    override var annotation: MKAnnotation! {
        get { return buttonParkingSpotAnnotation }
        set { if newValue == nil || newValue is ButtonParkingSpot {
            buttonParkingSpotAnnotation = newValue as? ButtonParkingSpot
        } else {
            println("Incorrect annotation type for ButtonParkingSpotView")
            }
        }
    }
    
    func setup(mbxZoomLevel: CGFloat) {
        let userInfo = buttonParkingSpotAnnotation.userInfo
        let selected = userInfo["selected"] as! Bool
        let spot = userInfo["spot"] as! ParkingSpot
        let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool
        
        if shouldAddAnimation {
           self.layer.addScaleAnimation()
//            spotIdentifiersDrawnOnMap.append(spot.identifier)
        }
        
        var imageName = "button_line_"
        
        if mbxZoomLevel < 18 {
            imageName += "small_"
        }
        if !selected {
            imageName += "in"
        }
        
        imageName += "active"
        
        var circleImage = UIImage(named: imageName)
        
        self.image = circleImage
        
        if (selected) {
            var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 0.7
            pulseAnimation.fromValue = 0.95
            pulseAnimation.toValue = 1.10
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = FLT_MAX
            self.layer.addAnimation(pulseAnimation, forKey: "pulse")
        } else {
            self.layer.removeAnimationForKey("pulse")
        }

    }
    
}

