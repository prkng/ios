//
//  CarSharingObject.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-14.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import Foundation

enum CarSharingType: String {
    case CommunautoAutomobile = "auto-mobile"
    case Car2Go = "car2go"
    case Communauto = "communauto"
    case Zipcar = "zipcar"
    case Generic = "generic"
    
    var name: String {
        switch self {
        case .Car2Go:
            return "Car2Go"
        case .Communauto:
            return "Communauto"
        case .CommunautoAutomobile:
            return "Auto-mobile"
        case .Zipcar:
            return "Zipcar"
        case .Generic:
            return "CarSharing"
        }
    }

}

class ISO8610DateFormatter {
    
    static let sharedInstance = ISO8610DateFormatter()
    
    var dateFormatter: NSDateFormatter {
        if _dateFormatter == nil {
            generateDateFormatter()
        }
        return _dateFormatter!
    }
    private var _dateFormatter: NSDateFormatter?
    private func generateDateFormatter() {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        _dateFormatter = formatter
    }
}

class WeekDayAndTimeDateFormatter {
    
    static let sharedInstance = WeekDayAndTimeDateFormatter()
    
    var dateFormatter: NSDateFormatter {
        if _dateFormatter == nil {
            generateDateFormatter()
        }
        return _dateFormatter!
    }
    private var _dateFormatter: NSDateFormatter?
    private func generateDateFormatter() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE"
        _dateFormatter = formatter
    }

    var timeFormatter: NSDateFormatter {
        if _timeFormatter == nil {
            generateTimeFormatter()
        }
        return _timeFormatter!
    }
    private var _timeFormatter: NSDateFormatter?
    private func generateTimeFormatter() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        _timeFormatter = formatter
    }
}

class CarShare: NSObject {
    
    var identifier: String
    var coordinate: CLLocationCoordinate2D
    var fuelPercentage: Int?
    var electric: Bool
    var name: String //sometimes car model, sometimes license plate
    var availableUntil: NSDate?
    var carSharingType: CarSharingType
    var partnerId: String?
    var vin: String?
    var quantity: Int
    var json: JSON
    
    private var fuelPercentageText: String {
        if fuelPercentage != nil {
            return String(format: "%d%%", fuelPercentage!)
        }
        return ""
    }
    
    var subtitle: String {

        if let reservedCarShare = Settings.getReservedCarShare() {
            if reservedCarShare.identifier == self.identifier {
                return "reserved".localizedString
            }
        }
        
        switch self.carSharingType {
        case .Zipcar:
            return String(format: "up_to_x_cars_available".localizedString, self.quantity)
        case .Communauto:
            //format something like "name - Until (available Until date pretty printed)
            return self.name + " - " + "until".localizedString + " " + WeekDayAndTimeDateFormatter.sharedInstance.dateFormatter.stringFromDate(self.availableUntil ?? NSDate()) + " " + WeekDayAndTimeDateFormatter.sharedInstance.timeFormatter.stringFromDate(self.availableUntil ?? NSDate())
        case .Car2Go, .CommunautoAutomobile, .Generic:
            return self.name
        }
    }
    
    func mapPinImageAndReuseIdentifier(selected: Bool) -> (UIImage, String) {
        return CarShare.mapPinImageAndReuseIdentifier(selected, carSharingType: self.carSharingType, electric: self.electric, quantity: self.quantity, identifier: self.identifier)
    }
    
    static func mapPinImageAndReuseIdentifier(selected: Bool, carSharingType: CarSharingType, electric: Bool, quantity: Int, identifier: String) -> (UIImage, String) {
        var reuseIdentifier = "carsharing_pin"
        switch carSharingType {
        case .Car2Go:
            reuseIdentifier += "_car2go"
        case .Communauto:
            reuseIdentifier += "_communauto"
        case .CommunautoAutomobile:
            reuseIdentifier += "_automobile"
        case .Zipcar:
            reuseIdentifier += "_zipcar"
        case .Generic:
        reuseIdentifier += "_automobile"
        }
        if electric {
            reuseIdentifier += "_electric"
        }
        if selected {
            reuseIdentifier += "_selected"
        }
        
        var image = UIImage(named: reuseIdentifier)!
        
        if carSharingType == .Zipcar && quantity == 0 {
            //make it grey, add it to the reuse id
            reuseIdentifier += String(quantity)
            image = image.convertToGrayScale()
        }
        
        if let reservedCarShare = Settings.getReservedCarShare() {
            if reservedCarShare.identifier == identifier {
                let imageToAdd = UIImage(named: "carsharing_pin_reserved_badge")!
                image = image.addImageToTopRight(imageToAdd, valueToMoveIntoImage: 0.25)
                reuseIdentifier += "_reserved"
            }
        }
        
        //we do this next line because w want the callout to appear a bit higher that the default
        image = image.extendHeight(1, andWidth: 0)

        return (image, reuseIdentifier)
    }
    
    init(json: JSON) {
        self.json = json
        self.identifier = String(json["id"].intValue)
        self.coordinate = CLLocationCoordinate2D(latitude: json["geometry"]["coordinates"][1].doubleValue, longitude: json["geometry"]["coordinates"][0].doubleValue)
        self.carSharingType = CarSharingType(rawValue: json["properties"]["company"].stringValue) ?? CarSharingType.Generic
        self.name = json["properties"]["name"].stringValue
        self.partnerId = json["properties"]["partner_id"].string
        self.vin = json["properties"]["vin"].string
        self.fuelPercentage = json["properties"]["fuel"].int
        self.electric = json["properties"]["electric"].boolValue
        self.quantity = json["properties"]["quantity"].intValue
        self.availableUntil = ISO8610DateFormatter.sharedInstance.dateFormatter.dateFromString(json["properties"]["until"].stringValue)
    }
     
    func calloutView() -> (UIView, UIView?) {

        let maximumTotalWidth = UIScreen.mainScreen().bounds.width - 40
        
        let rightViewWidth: CGFloat = 55
        var shouldShowRightView = true
        let rightView = UIButton()
        rightView.setImage(UIImage(named:"btn_reserve".localizedString), forState: .Normal)
        rightView.tag = 100
        if let reservedCarShare = Settings.getReservedCarShare() {
            if self.identifier == reservedCarShare.identifier {
                rightView.setImage(UIImage(named:"btn_cancel".localizedString), forState: .Normal)
                rightView.tag = 200
            } else {
                shouldShowRightView = false
            }
        }
        rightView.bounds = CGRect(x: 0, y: 0, width: rightViewWidth, height: 44) //actual width of image is 53.5 points
        rightView.imageView?.contentMode = .Left
        
        let leftView = UIView()

        let percentageLabel = UILabel()
        percentageLabel.textAlignment = .Left
        percentageLabel.font = Styles.Fonts.h1r
        percentageLabel.textColor = Styles.Colors.red2
        percentageLabel.text = self.fuelPercentageText
        leftView.addSubview(percentageLabel)
        
        let percentageLabelWidth = percentageLabel.intrinsicContentSize().width
        percentageLabel.frame = CGRect(x: 10, y: 0, width: percentageLabelWidth, height: 44)
        
        let leftViewLabelBuffer = self.fuelPercentage == nil ? 10 : 10 + percentageLabelWidth + 10 //this is the size of the left view minus the percentage label and 10 points on either side of it.
        let maxTitleWidth = maximumTotalWidth - rightViewWidth - leftViewLabelBuffer
        let minTitleWidth = 135 - leftViewLabelBuffer - (self.fuelPercentage == nil ? 52 : 0)

        let titleLabel = UILabel()
        titleLabel.textAlignment = .Left
        titleLabel.font = Styles.FontFaces.regular(14)
        titleLabel.textColor = Styles.Colors.red2
        titleLabel.text = self.carSharingType.name
        leftView.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .Left
        subtitleLabel.font = Styles.FontFaces.light(12)
        subtitleLabel.textColor = Styles.Colors.red2
        subtitleLabel.text = self.subtitle
        leftView.addSubview(subtitleLabel)
        
        let minLabelWidth = max(subtitleLabel.intrinsicContentSize().width, titleLabel.intrinsicContentSize().width, CGFloat(minTitleWidth))
        let labelWidth = min(minLabelWidth, CGFloat(maxTitleWidth))
        leftView.frame = CGRect(x: 0, y: 0, width: (labelWidth + CGFloat(leftViewLabelBuffer)), height: 44)
        titleLabel.frame = CGRect(x: CGFloat(leftViewLabelBuffer), y: 0, width: labelWidth, height: 30)
        subtitleLabel.frame = CGRect(x: CGFloat(leftViewLabelBuffer), y: 15, width: labelWidth, height: 30)
        
        //the separator was manually placed because for the mapbox callout, we don't know exactly how the left and right views are placed.
//        let separator = UIView(frame: CGRect(x: leftView.bounds.width + 5, y: 0, width: 1, height: leftView.bounds.height))
//        separator.backgroundColor = Styles.Colors.transparentBlack
//        leftView.addSubview(separator)

        return (leftView, shouldShowRightView ? rightView : nil)
    }
    
}