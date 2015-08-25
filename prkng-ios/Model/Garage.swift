//
//  Garage.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum GarageAttribute: String {
    case Clerk = "clerk"//.localizedString
    case Indoor = "indoor"//.localizedString
    case Valet = "valet"//.localizedString
}

func ==(lhs: Garage, rhs: Garage) -> Bool {
    return lhs.identifier == rhs.identifier
}

class Garage: NSObject, Hashable {
   
    var json: JSON
    var identifier: Int
    var name: String
    var address: String
    var dailyPrice: Float
    var attributes: [GarageAttribute: Bool]
    var agenda: [Int: (Float, Float)?]
    var coordinate: CLLocationCoordinate2D
    
//    var userInfo: [String:AnyObject] //to maintain backwards compatibility with mapbox
    
//    //MARK- MKAnnotation
//    var title: String! { get { return identifier } }
//    var subtitle: String! { get { return name } }
//    //    var lineSpot: LineParkingSpot { get { return LineParkingSpot(spot: self) } }
//    var buttonSpot: ButtonParkingSpot { get { return ButtonParkingSpot(spot: self) } }
    
    //MARK- Hashable
    override var hashValue: Int { get { return identifier } }
    
    init(garage: Garage) {
        self.json = garage.json
        self.identifier = garage.identifier
        self.coordinate = garage.coordinate
        self.address = garage.address
        self.agenda = garage.agenda
        self.attributes = garage.attributes
        self.dailyPrice = garage.dailyPrice
        self.name = garage.name
    }
    
    init(json: JSON) {
        
        self.json = json
        self.identifier = json["id"].intValue
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
       
        self.attributes = [GarageAttribute: Bool]()
        for attr in json["properties"]["attrs"] {
            let attribute = GarageAttribute(rawValue: attr.0)!
            let value = attr.1.boolValue
            self.attributes.updateValue(value, forKey: attribute)
        }

        self.dailyPrice = json["properties"]["daily_price"].floatValue
        self.name = json["properties"]["name"].stringValue
        
    }

}
