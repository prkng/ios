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
    
    var reuseIdentifier: String {
        
        var anchorImageName = "carsharing_lot_pin_anchor"
        
        if self.carsAvailable == 0 {
            anchorImageName += "_grey"
        } else {
            switch self.carSharingType {
            case .Car2Go:
                anchorImageName += "_blue"
            default:
                anchorImageName += "_green"
            }
        }
        return anchorImageName + String(self.carsAvailable)
    }
    
    var mapPinImage: UIImage {
        
        let roundPImage = UIImage(named: "carsharing_lot_pin_P")! //14pts by 14pts
        
        var pinColor = Styles.Colors.turtleGreen
        
        var anchorImageName = "carsharing_lot_pin_anchor"
        
        if self.carsAvailable == 0 {
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

        return finalImage

    }

    
}