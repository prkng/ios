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
}

class CarShare: NSObject {
    
    var coordinate: CLLocationCoordinate2D
    var fuelPercentage: Int?
    var electric: Bool
    var licensePlate: String
    var carSharingType: CarSharingType
    
    private var carSharingTypeName: String {
        switch self.carSharingType {
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
    
    private var fuelPercentageText: String {
        if fuelPercentage != nil {
            return String(format: "%d%%", fuelPercentage!)
        }
        return ""
    }
    
    func pinName(selected: Bool) -> String {
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
        self.licensePlate = json["properties"]["name"].stringValue
        self.fuelPercentage = json["properties"]["fuel"].int
        self.electric = json["properties"]["electric"].boolValue
    }
    
    override init() {
        self.coordinate = Settings.selectedCity().coordinate
        self.carSharingType = CarSharingType.Car2Go
        self.licensePlate = "FJH5504"
        self.fuelPercentage = 66
        self.electric = false
    }
 
    func calloutView() -> (UIView, UIView?) {

        let maximumTotalWidth = UIScreen.mainScreen().bounds.width - 40
        
        let rightViewWidth: CGFloat = 0//55
        let rightView = UIButton()
        rightView.setImage(UIImage(named:"btn_reserve".localizedString), forState: .Normal)
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

        let typeLabel = UILabel()
        typeLabel.textAlignment = .Left
        typeLabel.font = Styles.FontFaces.regular(14)
        typeLabel.textColor = Styles.Colors.red2
        typeLabel.text = self.carSharingTypeName
        leftView.addSubview(typeLabel)

        let licensePlate = UILabel()
        licensePlate.textAlignment = .Left
        licensePlate.font = Styles.FontFaces.light(12)
        licensePlate.textColor = Styles.Colors.red2
        licensePlate.text = self.licensePlate
        leftView.addSubview(licensePlate)
        
        let minLabelWidth = max(licensePlate.intrinsicContentSize().width, typeLabel.intrinsicContentSize().width, CGFloat(minTitleWidth))
        let labelWidth = min(minLabelWidth, CGFloat(maxTitleWidth))
        leftView.frame = CGRect(x: 0, y: 0, width: (labelWidth + CGFloat(leftViewLabelBuffer)), height: 44)
        typeLabel.frame = CGRect(x: CGFloat(leftViewLabelBuffer), y: 0, width: labelWidth, height: 30)
        licensePlate.frame = CGRect(x: CGFloat(leftViewLabelBuffer), y: 15, width: labelWidth, height: 30)
        
        //the separator was manually placed because for the mapbox callout, we don't know exactly how the left and right views are placed.
//        let separator = UIView(frame: CGRect(x: leftView.bounds.width + 5, y: 0, width: 1, height: leftView.bounds.height))
//        separator.backgroundColor = Styles.Colors.transparentBlack
//        leftView.addSubview(separator)

        return (leftView, nil)
    }
    
}