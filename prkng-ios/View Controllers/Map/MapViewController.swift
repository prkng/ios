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
    
    let mapSource = "arnaudspuhler.l54pj66f"
    
    var delegate: MapViewControllerDelegate?
    
    var mapView: RMMapView
    var spots: Array<ParkingSpot>
    var lineAnnotations: Array<RMAnnotation>
    var centerButtonAnnotations: Array<RMAnnotation>
    var searchAnnotations: Array<RMAnnotation>
    var selectedSpot: ParkingSpot?
    var radius : Float
    var updateInProgress : Bool
    
    var trackUserButton : UIButton
    
    var searchCheckinDate : NSDate?
    var searchDuration : Float?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        if let source = RMMapboxSource(mapID: mapSource) {
            mapView = RMMapView(frame: CGRectMake(0, 0, 100, 100), andTilesource: source)
        } else {
            let offlineSourcePath = NSBundle.mainBundle().pathForResource("OfflineMap", ofType: "json")
            let offlineSource = RMMapboxSource(tileJSON: String(contentsOfFile: offlineSourcePath!, encoding: NSUTF8StringEncoding, error: nil))
            mapView = RMMapView(frame: CGRectMake(0, 0, 100, 100), andTilesource: offlineSource)
        }
        
        mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading
        
        mapView.tintColor = Styles.Colors.red2
        mapView.showLogoBug = false
        mapView.hideAttribution = true
        mapView.zoom = 17
        spots = []
        lineAnnotations = []
        centerButtonAnnotations = []
        searchAnnotations = []
        radius = 300
        updateInProgress = false
        
        trackUserButton = UIButton()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(mapView)
        mapView.delegate = self
        
        trackUserButton.setImage(UIImage(named: "track_user"), forState: UIControlState.Normal)
        trackUserButton.addTarget(self, action: "trackUserButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(trackUserButton)
        
        mapView.snp_makeConstraints {  (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        trackUserButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(36, 36))
            make.centerX.equalTo(self.view).multipliedBy(0.33)
            make.bottom.equalTo(self.view).with.offset(-30)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading
        updateAnnotations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if (mapView.tileSource == nil) {
            if let source = RMMapboxSource(mapID: mapSource) {
                mapView.tileSource = source
            }
        }
    }
    

    func updateMapCenterIfNecessary () {
        
        
    }
    
    
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {
        
        if (annotation.isUserLocationAnnotation) {
            
            var marker = RMMarker(UIImage: UIImage(named: "cursor_you"))
            marker.canShowCallout = false
            return marker
        }
        
        var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
        var annotationType = userInfo!["type"] as! String
        
        
        switch annotationType {
            
        case "line":
            
            var selected = userInfo!["selected"] as! Bool
            var spot = userInfo!["spot"] as! ParkingSpot
            
            var shape = RMShape(view: mapView)
            
            if (selected) {
                shape.lineColor = Styles.Colors.red2
            } else {
                shape.lineColor = Styles.Colors.petrol2
            }
            shape.lineWidth = 4.4
            
            for location in spot.line.coordinates as Array<CLLocation> {
                shape.addLineToCoordinate(location.coordinate)
            }
            
            return shape
            
            
        case "button":
            
            var selected = userInfo!["selected"] as! Bool
            var spot = userInfo!["spot"] as! ParkingSpot
            
            var circle: RMCircle = RMCircle(view: self.mapView, radiusInMeters: 2.0)
            circle.lineWidthInPixels = 4.0
            
            
            if (selected) {
                circle.lineColor = Styles.Colors.berry1
                circle.fillColor = Styles.Colors.red2
            } else {
                circle.lineColor = Styles.Colors.midnight2
                circle.fillColor = Styles.Colors.petrol2
            }
            
            return circle
            
        case "searchResult":
            
            var marker = RMMarker(UIImage: UIImage(named: "pin_pointer_result"))
            marker.canShowCallout = true
            return marker
            
            
        default:
            return nil
            
        }
    }
    
    func beforeMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        
        
        if (mapView.userTrackingMode.value == 2 ) { //RMUserTrackingModeFollowWithHeading
            self.trackUserButton.hidden = true
        } else {
            self.trackUserButton.hidden = (delegate != nil && !delegate!.shouldShowUserTrackingButton())
            self.mapView.userTrackingMode = RMUserTrackingModeNone
        }
    
    }
    
    func afterMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }
        NSLog("afterMapMove")
        
        self.selectedSpot = nil
        updateAnnotations()
        
        self.delegate?.mapDidMove(CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude))
    }
    
    
    func afterMapZoom(map: RMMapView!, byUser wasUserAction: Bool) {
        //        NSLog("afterMapZoom : %f", map.zoom)
        
        radius = (20.0 - map.zoom) * 100
        
        if(map.zoom < 16.0) {
            radius = 0
        }
        
        updateAnnotations()
        
    }
    
    func mapView(mapView: RMMapView!, didSelectAnnotation annotation: RMAnnotation!) {
        
        if (annotation.isUserLocationAnnotation) {
            return
        }
        
        if (selectedSpot != nil) {
            removeAnnotations(findAnnotations(selectedSpot!.identifier))
            addSpotAnnotation(self.mapView, spot: selectedSpot!, selected: false)
        }
        
        var userInfo: [String:AnyObject]? = (annotation as RMAnnotation).userInfo as? [String:AnyObject]
        
        var type: String = userInfo!["type"] as! String
        
        if (type == "line" || type == "button") {
            
            var spot = userInfo!["spot"] as! ParkingSpot?
            
            
            if spot == nil {
                return
            }
            
            var annotations = findAnnotations(spot!.identifier)
            removeAnnotations(annotations)
            addSpotAnnotation(self.mapView, spot: spot!, selected: true)
            
            selectedSpot = spot
            
            self.delegate?.didSelectSpot(selectedSpot!)
            
        } else if (type == "searchResult") {
            
            var result = userInfo!["spot"] as! ParkingSpot?
            
            
        }
    }
    
    func mapViewRegionDidChange(mapView: RMMapView!) {
        //        NSLog("regiondidchange")
    }
    
    
//    func annotationSortingComparatorForMapView(mapView: RMMapView!) -> NSComparator {
//        
//        return {
//            (annotation1: AnyObject!, annotation2: AnyObject!) -> (NSComparisonResult) in
//            
//            var userInfo1: [String:AnyObject]? = (annotation1 as! RMAnnotation).userInfo as? [String:AnyObject]
//            var type1 = userInfo1!["type"] as! String
//            
//            var userInfo2: [String:AnyObject]? = (annotation2 as! RMAnnotation).userInfo as? [String:AnyObject]
//            var type2 = userInfo2!["type"] as! String
//            
//            
//            if (type1 == "button" && type2 == "line") {
//                return NSComparisonResult.OrderedDescending
//            } else if (type1 == "line" && type2 == "button") {
//                return NSComparisonResult.OrderedAscending
//            } else {
//                return NSComparisonResult.OrderedSame
//            }
//            
//            
//        }
//        
//        
//    }
    
    
    // Helper Methods
    
    
//    func updateMapBasedOnZoom (zoom : Float) {
//        
//        if (zoom <= 17.0 && zoom > 16.0) {
//            
//            if (centerButtonAnnotations.count > 0) {
//                mapView.removeAnnotations(centerButtonAnnotations)
//            }
//            
//        } else if(zoom <= 16.0) {
//            
//            if (lineAnnotations.count > 0) {
//                mapView.removeAnnotations(lineAnnotations)
//            }
//            
//            if (centerButtonAnnotations.count > 0) {
//                mapView.removeAnnotations(centerButtonAnnotations)
//            }
//        }
//        
//        
//    }
    
    // MARK: Helper Methods
    
    func trackUserButtonTapped () {
        
        self.mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading
        self.trackUserButton.hidden = true
    }
    
    
    func updateAnnotations() {
        
        if (updateInProgress) {
            println("Update already in progress, cancelled!")
            return
        }
        
        updateInProgress = true
        
        if (mapView.zoom > 16.0) {
            
            
            var checkinTime = searchCheckinDate
            var duration = searchDuration
            
            if (checkinTime == nil) {
                checkinTime = NSDate()
            }
            
            if (duration == nil) {
                duration = 1
            }
            
            SpotOperations.findSpots(self.mapView.centerCoordinate, radius: radius, duration: duration!, checkinTime: checkinTime!, completion:
                { (spots) -> Void in
                    
                    self.mapView.removeAnnotations(self.lineAnnotations)
                    self.lineAnnotations = []
                    
                    self.mapView.removeAnnotations(self.centerButtonAnnotations)
                    self.centerButtonAnnotations = []
                    
                    for spot in spots {
                        self.addSpotAnnotation(self.mapView, spot: spot, selected: false)
                    }
                    self.updateInProgress = false
                    
            })
            
                
 
        } else {
            
            mapView.removeAnnotations(lineAnnotations)
            lineAnnotations = []
            
            mapView.removeAnnotations(centerButtonAnnotations)
            centerButtonAnnotations = []
            
            updateInProgress = false
            
        }
        
        
    }
    
    
    func addSpotAnnotation(map: RMMapView, spot: ParkingSpot, selected: Bool) {
        
        var annotation: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: spot.line.coordinates[0].coordinate, andTitle: spot.identifier)
        annotation.setBoundingBoxFromLocations(spot.line.coordinates)
        annotation.userInfo = ["type": "line", "spot": spot, "selected": selected]
        self.mapView.addAnnotation(annotation)
        lineAnnotations.append(annotation)
        
        
        if (mapView.zoom > 17.0) {
            
            var centerButton: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: spot.buttonLocation.coordinate, andTitle: spot.identifier)
            centerButton.setBoundingBoxFromLocations(spot.line.coordinates)
            centerButton.userInfo = ["type": "button", "spot": spot, "selected": selected]
            mapView.addAnnotation(centerButton)
            centerButtonAnnotations.append(centerButton)
            
        } else {
            
        }
        
    }
    
    
    func addSearchResultMarker(searchResult: SearchResult) {
        
        var annotation: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: searchResult.location.coordinate, andTitle: searchResult.title)
        annotation.userInfo = ["type": "searchResult", "details": searchResult]
        mapView.addAnnotation(annotation)
        searchAnnotations.append(annotation)
    }
    
    
    func findAnnotations(identifier: String) -> Array<RMAnnotation> {
        
        var foundAnnotations: Array<RMAnnotation> = []
        
        for annotation in lineAnnotations {
            
            var userInfo: [String:AnyObject]? = (annotation as RMAnnotation).userInfo as? [String:AnyObject]
            var spot = userInfo!["spot"] as! ParkingSpot
            
            if spot.identifier == identifier {
                foundAnnotations.append(annotation)
            }
        }
        
        
        for annotation in centerButtonAnnotations {
            
            var userInfo: [String:AnyObject]? = (annotation as RMAnnotation).userInfo as? [String:AnyObject]
            var spot = userInfo!["spot"] as! ParkingSpot
            
            if spot.identifier == identifier {
                foundAnnotations.append(annotation)
            }
        }
        
        return foundAnnotations
    }
    
    
    func removeAnnotations(annotations: Array<RMAnnotation>) {
        
        var tempLineAnnotations: Array<RMAnnotation> = []
        
        for ann in lineAnnotations {
            
            var userInfo: [String:AnyObject]? = (ann as RMAnnotation).userInfo as? [String:AnyObject]
            var spot = userInfo!["spot"] as! ParkingSpot
            
            var found: Bool = false
            for delAnn in annotations {
                
                var delUserInfo: [String:AnyObject]? = (delAnn as RMAnnotation).userInfo as? [String:AnyObject]
                var delSpot = delUserInfo!["spot"] as! ParkingSpot
                
                if delSpot.identifier == spot.identifier {
                    found = true
                    break
                }
            }
            
            if !found {
                tempLineAnnotations.append(ann)
            }
            
        }
    
        self.lineAnnotations = tempLineAnnotations
        
        
        var tempCenterButtonAnnotations: Array<RMAnnotation> = []

        for ann in centerButtonAnnotations {
            
            var userInfo: [String:AnyObject]? = (ann as RMAnnotation).userInfo as? [String:AnyObject]
            var spot = userInfo!["spot"] as! ParkingSpot
            
            var found: Bool = false
            for delAnn in annotations {
                
                var delUserInfo: [String:AnyObject]? = (delAnn as RMAnnotation).userInfo as? [String:AnyObject]
                var delSpot = delUserInfo!["spot"] as! ParkingSpot
                
                if delSpot.identifier == spot.identifier {
                    found = true
                    break
                }
            }
            
            if !found {
                tempCenterButtonAnnotations.append(ann)
            }
            
        }

        self.centerButtonAnnotations = tempCenterButtonAnnotations

        self.mapView.removeAnnotations(annotations)
        
    }
    
    
    // MARK: SpotDetailViewDelegate
    
    func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) {
        
        mapView.zoom = 17
        
        if (results.count == 0) {
            let alert = UIAlertView()
            alert.title = "No results found"
            alert.message = "We couldn't find anything matching those criterias"
            alert.addButtonWithTitle("Okay")
            alert.show()
            return
        }
        
        mapView.centerCoordinate = results[0].location.coordinate
        
        searchAnnotations = []

        lineAnnotations = []
        centerButtonAnnotations = []
        mapView.removeAllAnnotations()
        
        for result in results {
            addSearchResultMarker(result)
        }
        
        self.searchCheckinDate = checkinTime
        
        updateAnnotations()
        
    }
    
    func clearSearchResults() {
        mapView.removeAnnotations(self.searchAnnotations)
    }
    
    
}

protocol MapViewControllerDelegate {
    
    func mapDidMove(center: CLLocation)
    
    func didSelectSpot(spot: ParkingSpot)
    
    func shouldShowUserTrackingButton() -> Bool
    
}
