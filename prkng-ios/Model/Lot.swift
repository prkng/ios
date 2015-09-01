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
}

func ==(lhs: Lot, rhs: Lot) -> Bool {
    return lhs.identifier == rhs.identifier
}

class Lot: NSObject, Hashable, DetailObject {
   
    var json: JSON
    var identifier: String
    var name: String
    var address: String
    var dailyPrice: Float
    var attributes: [LotAttribute: Bool]
    var agenda: [Int: (Float, Float)?]
    var coordinate: CLLocationCoordinate2D

    //TODO:parse the time and price things and then fill out these properties
    var isOpen: Bool {
        return true
    }

    // MARK: DetailObject Protocol
    var headerText: String { get { return name } }
    var headerIconName: String { get { return "btn_info_styled" } }
    var headerIconSubtitle: String { get { return "info" } }
    
    var bottomLeftTitleText: String? { get { return "daily".localizedString.uppercaseString } }
    var bottomLeftPrimaryText: NSAttributedString? { get { return NSAttributedString(string: name) } }
    
    var bottomRightTitleText: String { get {
        if self.isOpen {
            return "open".localizedString.uppercaseString
        } else {
            return "closed".localizedString.uppercaseString
        }
        }
    }
    var bottomRightPrimaryText: NSAttributedString { get {
        let interval = DateUtil.timeIntervalSinceDayStart()
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
        self.dailyPrice = lot.dailyPrice
        self.name = lot.name
    }
    
    init(json: JSON) {
        
        self.json = json
        self.identifier = json["id"].stringValue
        self.coordinate = CLLocationCoordinate2D(latitude: json["geometry"]["coordinates"][0].doubleValue, longitude: json["geometry"]["coordinates"][1].doubleValue)
        self.address = json["properties"]["address"].stringValue
        
        self.agenda = [Int: (Float, Float)?]()
        for attr in json["properties"]["agenda"] {
            let key = attr.0.toInt()!
            let floatList = attr.1.arrayValue
            var firstFloat: Float = floatList.first?.floatValue ?? 0
            var secondFloat: Float = floatList.last?.floatValue ?? 0
            self.agenda.updateValue(floatList.count == 0 ? nil : (firstFloat, secondFloat), forKey: key)
        }
       
        self.attributes = [LotAttribute: Bool]()
        for attr in json["properties"]["attrs"] {
            let attribute = LotAttribute(rawValue: attr.0)!
            let value = attr.1.boolValue
            self.attributes.updateValue(value, forKey: attribute)
        }

        self.dailyPrice = json["properties"]["daily_price"].floatValue
        self.name = json["properties"]["name"].stringValue
        
    }

}
