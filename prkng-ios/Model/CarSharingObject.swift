//
//  CarSharingObject.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-14.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import Foundation

enum CarSharingType: String {
    case Car2Go = "car2go"
    case Communauto = "communauto"
    case Generic = "generic"
}

class CarSharingObject: NSObject {
    
    var percentage: Float
    var serialNumber: String
    var carSharingType: CarSharingType
    
    private var carSharingTypeName: String {
        switch self.carSharingType {
        case .Car2Go:
            return "Car2Go"
        case .Communauto:
            return "Communauto"
        case .Generic:
            return "CarSharing"
        }
    }
    
    private var percentageText: String {
        let roundedPercentage = Int(round(percentage * 100))
        return String(format: "%d%%", roundedPercentage)
    }
    
    func pinName(selected: Bool) -> String {
        var pinName = "carsharing_pin"
        switch self.carSharingType {
        case .Car2Go:
            pinName += "_car2go"
        case .Communauto:
            pinName += "_automobile"
        case .Generic:
            pinName += "_automobile"
        }
        if selected {
            pinName += "_selected"
        }
        return pinName
    }
    
    init(json: JSON) {
        self.carSharingType = CarSharingType(rawValue: json["type"].stringValue) ?? CarSharingType.Generic
        self.serialNumber = json["serial_number"].stringValue
        self.percentage = json["percentage"].floatValue
    }
    
    override init() {
        self.carSharingType = CarSharingType.Car2Go
        self.serialNumber = "FJH5504"
        self.percentage = 0.66
    }
 
    func calloutView() -> (UIView, UIView) {

        let maximumTotalWidth = Int(UIScreen.mainScreen().bounds.width) - 40
        let leftViewLabelBuffer = 10 + 52 + 10 //this is the size of the left view minus the percentage label and 10 points on either side of it.
        let maxTitleWidth = maximumTotalWidth - 55 - leftViewLabelBuffer
        let minTitleWidth = 135 - leftViewLabelBuffer
        
        let rightView = UIButton()
        rightView.setImage(UIImage(named:"btn_reserve".localizedString), forState: .Normal)
        rightView.bounds = CGRect(x: 0, y: 0, width: 55, height: 44) //actual width of image is 53.5 points
        rightView.imageView?.contentMode = .Left
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 135, height: 44))

        let percentageLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 52, height: 44))
        percentageLabel.textAlignment = .Left
        percentageLabel.font = Styles.Fonts.h1r
        percentageLabel.textColor = Styles.Colors.red2
        percentageLabel.text = self.percentageText
        leftView.addSubview(percentageLabel)

        let typeLabel = UILabel(frame: CGRect(x: 72, y: 0, width: 52, height: 30))
        typeLabel.textAlignment = .Left
        typeLabel.font = Styles.FontFaces.regular(14)
        typeLabel.textColor = Styles.Colors.red2
        typeLabel.text = self.carSharingTypeName
        leftView.addSubview(typeLabel)

        let serialNumber = UILabel(frame: CGRect(x: 72, y: 14, width: 52, height: 30))
        serialNumber.textAlignment = .Left
        serialNumber.font = Styles.FontFaces.light(12)
        serialNumber.textColor = Styles.Colors.red2
        serialNumber.text = self.serialNumber
        leftView.addSubview(serialNumber)
        
        let minLabelWidth = max(serialNumber.intrinsicContentSize().width, typeLabel.intrinsicContentSize().width, CGFloat(minTitleWidth))
        let labelWidth = min(minLabelWidth, CGFloat(maxTitleWidth))
        leftView.frame = CGRect(x: 0, y: 0, width: (labelWidth + CGFloat(leftViewLabelBuffer)), height: 44)
        typeLabel.frame = CGRect(x: 72, y: 0, width: labelWidth, height: 30)
        serialNumber.frame = CGRect(x: 72, y: 14, width: labelWidth, height: 30)
        
        return (leftView, rightView)
    }
    
}