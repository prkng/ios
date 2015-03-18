//
//  SpotOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SpotOperations: NSObject {

    class func getSpot(identifier: NSString) {

    }

    class func findSpots(location: CLLocationCoordinate2D, completion: ((spots:Array<ParkingSpot>) -> Void)) {

        var url = APIUtility.APIConstants.rootURLString + "slots"
        var params = ["latitude": location.latitude, "longitude": location.longitude]

        request(.GET, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            var spotJsons: Array<JSON> = json["features"].arrayValue
            var spots = Array<ParkingSpot>();
            for spotJson in spotJsons {
                spots.append(ParkingSpot(json: spotJson))
            }

            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(spots: spots)
            })

        }
    }

}
