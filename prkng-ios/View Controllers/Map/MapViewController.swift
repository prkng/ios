//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 05/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Foundation

class MapViewController: AbstractViewController, RMMapViewDelegate {

    var mapView: RMMapView

    override init() {

        let source = RMMapboxSource(mapID: "arnaudspuhler.l54pj66f")
        mapView = RMMapView(frame: CGRectMake(0, 0, 100, 100), andTilesource: source)
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 45.548, longitude: -73.58)

        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = UIView()
        self.view.addSubview(mapView)
        mapView.delegate = self

        mapView.snp_makeConstraints {
            make in
            make.edges.equalTo(self.view)
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SpotOperations.findSpots(self.mapView.centerCoordinate) {
            (spots) -> Void in

            for spot in spots {
                self.addAnnotation(self.mapView, spot: spot)
            }
        }

        // Do any additional setup after loading the view.
    }


    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {


        if (annotation.isUserLocationAnnotation) {
            return nil
        }

        var userInfo : [String : AnyObject]?  = annotation.userInfo as? [String : AnyObject]
        
        var annotationType = userInfo!["type"] as String
        
        switch annotationType {
            
        case "line" :
            
            var shape = RMShape(view: mapView)
            
            shape.lineColor = UIColor(rgba: "#485966")
            shape.lineWidth = 3.0
            
            
            for location in annotation.userInfo as Array<CLLocation> {
                shape.addLineToCoordinate(location.coordinate)
            }
            
            
            return shape;
            
            RMMarker(
            
            break
            
            
        case "button" :
            
            break
            
        default :
            break
            
        }
        

        return nil
    }

    func afterMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }

        mapView.removeAllAnnotations()


        SpotOperations.findSpots(map.centerCoordinate) {
            (spots) -> Void in

            for spot in spots {
                self.addAnnotation(map, spot: spot)
            }
        }


    }


    func afterMapZoom(map: RMMapView!, byUser wasUserAction: Bool) {

    }

    func mapViewRegionDidChange(mapView: RMMapView!) {
        NSLog("regiondidchange")
    }


    // Helper Methods

    func addAnnotation(map: RMMapView, spot: ParkingSpot) {

        var annotation: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: spot.line.coordinates[0].coordinate, andTitle: spot.identifier)
        annotation.setBoundingBoxFromLocations(spot.line.coordinates)
        annotation.userInfo = ["type" : "line", "coordinates" : spot.line.coordinates]
        self.mapView.addAnnotation(annotation)
        

        
        var centerButton: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: spot.line.coordinates[0].coordinate, andTitle: spot.identifier)
        annotation.setBoundingBoxFromLocations(spot.line.coordinates)
        annotation.userInfo = ["type" : "button", "coordinates" : [spot.buttonLocation]]
        self.mapView.addAnnotation(annotation)
        self.mapView.addAnnotation(centerButton)
        
        
        
    }


}
