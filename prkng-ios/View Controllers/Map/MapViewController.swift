//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 05/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Foundation

class MapViewController: AbstractViewController, RMMapViewDelegate, SpotDetailViewDelegate {

    var mapView: RMMapView
    var spots: Array<ParkingSpot>
    var allAnnotations: Array<RMAnnotation>
    var selectedSpot: ParkingSpot?
    var detailView: SpotDetailView
    
    var spotDetailConstraint : Constraint?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let source = RMMapboxSource(mapID: "arnaudspuhler.l54pj66f")
        mapView = RMMapView(frame: CGRectMake(0, 0, 100, 100), andTilesource: source)
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 45.548, longitude: -73.58)
        detailView = SpotDetailView()
        spots = []
        allAnnotations = []
        
        super.init(nibName: nil, bundle: nil)
        
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("HERE", comment: "comment"), image: UIImage(named: "tabbar_here")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: "tabbar_here_active")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
        self.tabBarItem.setTitlePositionAdjustment(UIOffsetMake(0, -5.0))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
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


        //FIXME

        self.view.addSubview(detailView)

        detailView.snp_makeConstraints {
            (make) -> () in
            self.spotDetailConstraint = make.bottom.equalTo(self.view).with.offset(180)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        detailView.delegate = self;
        self.mapView.userTrackingMode = RMUserTrackingModeFollow;

        SpotOperations.findSpots(self.mapView.centerCoordinate) {
            (spots) -> Void in

            self.spots = spots

            for spot in spots {
                self.addAnnotation(self.mapView, spot: spot, selected: false)
            }
        }

        // Do any additional setup after loading the view.
    }


    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {

        if (annotation.isUserLocationAnnotation) {
            return nil
        }

        var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
        var annotationType = userInfo!["type"] as! String
        var selected = userInfo!["selected"] as! Bool
        var spot = userInfo!["spot"] as! ParkingSpot

        switch annotationType {

        case "line":

            var shape = RMShape(view: mapView)

            if (selected) {
                shape.lineColor = Styles.Colors.red2
            } else {
                shape.lineColor = Styles.Colors.petrol2
            }
            shape.lineWidth = 3.0

            for location in spot.line.coordinates as Array<CLLocation> {
                shape.addLineToCoordinate(location.coordinate)
            }

            return shape


        case "button":

            var circle: RMCircle = RMCircle(view: self.mapView, radiusInMeters: 1.3)
            circle.lineWidthInPixels = 2.0;


            if (selected) {
                circle.lineColor = Styles.Colors.stone
                circle.fillColor = Styles.Colors.red2

            } else {
                circle.lineColor = Styles.Colors.stone
                circle.fillColor = Styles.Colors.petrol2
            }


            return circle


        default:
            return nil

        }
    }

    func afterMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }
        NSLog("afterMapMove")

        hideSpotDetails()
        self.selectedSpot = nil
        updateAnnotations()
    }


    func afterMapZoom(map: RMMapView!, byUser wasUserAction: Bool) {

    }

    func mapView(mapView: RMMapView!, didSelectAnnotation annotation: RMAnnotation!) {
        
        if(selectedSpot != nil) {
            removeAnnotations(findAnnotations(selectedSpot!.identifier))
            addAnnotation(self.mapView, spot: selectedSpot!, selected: false)
        }
        
        var userInfo: [String:AnyObject]? = (annotation as RMAnnotation).userInfo as? [String:AnyObject]
        var spot = userInfo!["spot"] as! ParkingSpot?
        
        
        if spot == nil {
            return
        }
        
        var annotations = findAnnotations(spot!.identifier)
        removeAnnotations(annotations)
        addAnnotation(self.mapView, spot: spot!, selected: true)
        self.detailView.titleLabel.text = spot?.name

        selectedSpot = spot
        
        showSpotDetails()

    }

    func mapViewRegionDidChange(mapView: RMMapView!) {
//        NSLog("regiondidchange")
    }


    func annotationSortingComparatorForMapView(mapView: RMMapView!) -> NSComparator {

        return {
            (annotation1: AnyObject!, annotation2: AnyObject!) -> (NSComparisonResult) in

            var userInfo1: [String:AnyObject]? = (annotation1 as! RMAnnotation).userInfo as? [String:AnyObject]
            var type1 = userInfo1!["type"] as! String

            var userInfo2: [String:AnyObject]? = (annotation2 as! RMAnnotation).userInfo as? [String:AnyObject]
            var type2 = userInfo2!["type"] as! String


            if (type1 == "button" && type2 == "line") {
                return NSComparisonResult.OrderedDescending
            } else if (type1 == "line" && type2 == "button") {
                return NSComparisonResult.OrderedAscending
            } else {
                return NSComparisonResult.OrderedSame
            }


        }


    }


    // Helper Methods

    func updateAnnotations() {

        mapView.removeAllAnnotations()

        allAnnotations = []

        SpotOperations.findSpots(self.mapView.centerCoordinate) {
            (spots) -> Void in

            for spot in spots {
                self.addAnnotation(self.mapView, spot: spot, selected: false)
            }
        }
    }


    func addAnnotation(map: RMMapView, spot: ParkingSpot, selected: Bool) {

        var annotation: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: spot.line.coordinates[0].coordinate, andTitle: spot.identifier)
        annotation.setBoundingBoxFromLocations(spot.line.coordinates)
        annotation.userInfo = ["type": "line", "spot" : spot, "selected": selected]
        self.mapView.addAnnotation(annotation)

        var centerButton: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: spot.buttonLocation.coordinate, andTitle: spot.identifier)
        centerButton.setBoundingBoxFromLocations(spot.line.coordinates)
        centerButton.userInfo = ["type": "button", "spot" : spot, "selected": selected]

        self.mapView.addAnnotation(centerButton)

        self.allAnnotations.append(annotation)
        self.allAnnotations.append(centerButton)

    }


    func findAnnotations(identifier: String) -> Array<RMAnnotation> {

        var foundAnnotations: Array<RMAnnotation> = []

        for annotation in allAnnotations {

            var userInfo: [String:AnyObject]? = (annotation as RMAnnotation).userInfo as? [String:AnyObject]
            var spot = userInfo!["spot"] as! ParkingSpot

            if spot.identifier == identifier {
                foundAnnotations.append(annotation)
            }
        }

        return foundAnnotations
    }


    func removeAnnotations(annotations: Array<RMAnnotation>) {
        
        var tempAllAnnotations : Array<RMAnnotation> = []
        
        for ann in self.allAnnotations {
            
            var userInfo: [String:AnyObject]? = (ann as RMAnnotation).userInfo as? [String:AnyObject]
            var spot = userInfo!["spot"] as! ParkingSpot
            
            var found : Bool = false
            for delAnn in annotations {
                
                var delUserInfo: [String:AnyObject]? = (delAnn as RMAnnotation).userInfo as? [String:AnyObject]
                var delSpot = delUserInfo!["spot"] as! ParkingSpot
                
                if delSpot.identifier == spot.identifier {
                    found = true
                    break
                }
            }
            
            if !found {
                tempAllAnnotations.append(ann)
            }
            
        }
        
        self.mapView.removeAnnotations(annotations)

    }
    
    
    // SpotDetailViewDelegate
    
    func scheduleButtonTapped() {
        if selectedSpot != nil {
            var scheduleViewController : UIViewController = ScheduleViewController(spot: selectedSpot!)
            self.navigationController?.pushViewController(scheduleViewController, animated: true)
        }
    }
    
    func checkinButtonTapped() {
        
    }


    func showSpotDetails (completed : ()) {
        
        detailView.snp_remakeConstraints {
            (make) -> () in
            self.spotDetailConstraint = make.bottom.equalTo(self.view).with.offset(0)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }

        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.detailView.layoutIfNeeded()
        });
        
    }
    
    
    func hideSpotDetails (completed : () ) {
        
        detailView.snp_remakeConstraints {
            (make) -> () in
            self.spotDetailConstraint = make.bottom.equalTo(self.view).with.offset(180)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }

        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.detailView.layoutIfNeeded()
        });
        
    }
    
}
