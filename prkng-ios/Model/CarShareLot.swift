//
//  CarSharingObject.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-14.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import Foundation

class CarShareLot: NSObject {
    
    var coordinate: CLLocationCoordinate2D
    var carsAvailable: Int
    var carsCapacity: Int
    var name: String
    var carSharingType: CarSharingType
    
    var identifier: String {
        return name + carSharingType.name + coordinate.latitude.description + coordinate.longitude.description
    }

    init(json: JSON) {
        self.coordinate = CLLocationCoordinate2D(latitude: json["geometry"]["coordinates"][1].doubleValue, longitude: json["geometry"]["coordinates"][0].doubleValue)
        self.carSharingType = CarSharingType(rawValue: json["properties"]["company"].stringValue) ?? CarSharingType.Generic
        self.name = json["properties"]["name"].stringValue
        self.carsAvailable = json["properties"]["available"].intValue
        self.carsCapacity = json["properties"]["capacity"].intValue
    }
    
    func mapPinImageAndReuseIdentifier(selected: Bool) -> (UIImage, String) {
        
        //return the CarShare pin if it's a zipcar
        if self.carSharingType == .Zipcar {
            return CarShare.mapPinImageAndReuseIdentifier(selected, carSharingType: self.carSharingType, electric: false, identifier: self.identifier)
        }
        
        let roundPImage = UIImage(named: "carsharing_lot_pin_P")! //14pts by 14pts
        
        var pinColor = Styles.Colors.turtleGreen
        
        var anchorImageName = "carsharing_lot_pin_anchor"
        
        if selected {
            anchorImageName += "_red"
            pinColor = Styles.Colors.red2
        } else if self.carsAvailable == 0 {
            anchorImageName += "_grey"
            pinColor = Styles.Colors.pinGrey
        } else {
            switch self.carSharingType {
            case .Car2Go:
                anchorImageName += "_blue"
                pinColor = Styles.Colors.azuro
            default:
                anchorImageName += "_green"
            }
        }
        let anchorImage = UIImage(named: anchorImageName)!
        
        //cream01, 14pt, regular, 5pt margin everywhere
        let label = UILabel()
        label.font = Styles.FontFaces.regular(14)
        label.textColor = Styles.Colors.cream1
        label.text = String(self.carsAvailable)
        
        let labelWidth = label.intrinsicContentSize().width
        let labelHeight = label.intrinsicContentSize().height
        label.frame = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
        
        let bubbleWidth = 6.5 + 14 + 6.5 + labelWidth + 6.5
        let bubbleHeight: CGFloat = 27
        let bubbleRect = CGRect(x: 0, y: 0, width: bubbleWidth, height: bubbleHeight)
        
        let totalSize = CGSize(width: round(bubbleWidth), height: round(bubbleHeight + 4))
        
        UIGraphicsBeginImageContextWithOptions(bubbleRect.size, false, Settings.screenScale)
        //set size and shape (rounded!)
        //rounded 27 pts elipse (rounded to half of height)
        UIBezierPath(roundedRect: bubbleRect, cornerRadius: bubbleHeight/2).addClip()
        
        //set color
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), pinColor.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), bubbleRect)
        
        //drawthe round P
        //P is 14pt x 14pt with 6.5pt margin around
        roundPImage.drawInRect(CGRect(x: 6.5, y: 6.5, width: 14, height: 14))
        
        //draw the label text
        label.drawTextInRect(CGRect(x: 6.5 + 14 + 6.5, y: (bubbleHeight-labelHeight)/2, width: labelWidth, height: labelHeight))
        
        let bubbleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(totalSize, false, Settings.screenScale)
        bubbleImage.drawInRect(bubbleRect)
        //draw the bottom bit
        //anchor "middle" is actually 6pts in, 12pts total, plus shadow further to the right, so we draw it shifted by 3 points and not half its width
        anchorImage.drawInRect(CGRect(x: bubbleWidth/2 - 3, y: bubbleHeight, width: anchorImage.size.width, height: anchorImage.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return (finalImage, anchorImageName + String(self.carsAvailable))

    }
    
    func calloutView() -> (UIView, UIView) {
        
        let maximumTotalWidth = Int(UIScreen.mainScreen().bounds.width) - 40
        let leftViewLabelBuffer = 10 //this is the size of the left view minus 10 points on the left of it
        let maxTitleWidth = maximumTotalWidth - 55 - leftViewLabelBuffer
        let minTitleWidth = 135 - leftViewLabelBuffer
        
        let rightView = UIButton()
        rightView.setImage(UIImage(named:"btn_directions_red"), forState: .Normal)
        rightView.bounds = CGRect(x: 0, y: 0, width: 55, height: 44) //actual width of image is 41.5 points
        rightView.imageView?.contentMode = .Left
        
        let leftView = UIView()
        
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
        
        let minLabelWidth = max(titleLabel.intrinsicContentSize().width, subtitleLabel.intrinsicContentSize().width, CGFloat(minTitleWidth))
        let labelWidth = min(minLabelWidth, CGFloat(maxTitleWidth))
        leftView.frame = CGRect(x: 0, y: 0, width: (labelWidth + CGFloat(leftViewLabelBuffer)), height: 44)
        titleLabel.frame = CGRect(x: 10, y: 0, width: labelWidth, height: 30)
        subtitleLabel.frame = CGRect(x: 10, y: 15, width: labelWidth, height: 30)
        
        //the separator was manually placed because for the mapbox callout, we don't know exactly how the left and right views are placed.
        let separator = UIView(frame: CGRect(x: leftView.bounds.width + 5, y: 0, width: 1, height: leftView.bounds.height))
        separator.backgroundColor = Styles.Colors.transparentBlack
        leftView.addSubview(separator)
        
        return (leftView, rightView)
    }
    
}