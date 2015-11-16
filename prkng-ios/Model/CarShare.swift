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
    case Generic = "generic"
    
    var name: String {
        switch self {
        case .Car2Go:
            return "Car2Go"
        case .Communauto:
            return "Communauto"
        case .CommunautoAutomobile:
            return "Auto-mobile"
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

class CarShare: NSObject {
    
    var coordinate: CLLocationCoordinate2D
    var fuelPercentage: Int?
    var electric: Bool
    var name: String //sometimes car model, sometimes license plate
    var availableUntil: NSDate?
    var carSharingType: CarSharingType
    
    var identifier: String {
        return name + carSharingType.name + coordinate.latitude.description + coordinate.longitude.description
    }
    
    private var fuelPercentageText: String {
        if fuelPercentage != nil {
            return String(format: "%d%%", fuelPercentage!)
        }
        return ""
    }
    
    func mapPinName(selected: Bool) -> String {
        var pinName = "carsharing_pin"
        switch self.carSharingType {
        case .Car2Go:
            pinName += "_car2go"
        case .Communauto:
            pinName += "_communauto"
        case .CommunautoAutomobile:
            pinName += "_automobile"
        case .Generic:
            pinName += "_automobile"
        }
        if electric {
            pinName += "_electric"
        }
        if selected {
            pinName += "_selected"
        }
        return pinName
    }
    
    init(json: JSON) {
        self.coordinate = CLLocationCoordinate2D(latitude: json["geometry"]["coordinates"][1].doubleValue, longitude: json["geometry"]["coordinates"][0].doubleValue)
        self.carSharingType = CarSharingType(rawValue: json["properties"]["company"].stringValue) ?? CarSharingType.Generic
        self.name = json["properties"]["name"].stringValue
        self.fuelPercentage = json["properties"]["fuel"].int
        self.electric = json["properties"]["electric"].boolValue
        self.availableUntil = ISO8610DateFormatter.sharedInstance.dateFormatter.dateFromString(json["properties"]["until"].stringValue)
    }
    
    override init() {
        self.coordinate = Settings.selectedCity().coordinate
        self.carSharingType = CarSharingType.Car2Go
        self.name = "FJH5504"
        self.fuelPercentage = 66
        self.electric = false
    }
 
    func calloutView() -> (UIView, UIView?) {

        let maximumTotalWidth = UIScreen.mainScreen().bounds.width - 40
        
        let rightViewWidth: CGFloat = 55
        let rightView = UIButton()
        rightView.setImage(UIImage(named:"btn_reserve".localizedString), forState: .Normal)
        rightView.bounds = CGRect(x: 0, y: 0, width: rightViewWidth, height: 44) //actual width of image is 53.5 points
        rightView.imageView?.contentMode = .Left
        rightView.tag = 200
        
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
        subtitleLabel.text = self.name
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

        return (leftView, rightView)
    }
    
}