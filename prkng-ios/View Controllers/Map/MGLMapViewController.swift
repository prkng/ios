//
//  AppleMapViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 06/10/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Foundation

/* to avoid build errors but to keep external annotation code in other files, 
we define some classes here. These should be uncommented if we import mapbox gl
*/
protocol MGLPolyline: MGLAnnotation {
    
}

protocol MGLAnnotation: NSObjectProtocol {
    
}

class MGLMapViewController: MapViewController {
    
}

//class MGLMapViewController: MapViewController, MGLMapViewDelegate {
//    
//    let mapSource = "arnaudspuhler.l54pj66f"
//    
//    var mapView: MGLMapView
//    
//    var lastMapZoom: Double
//    var lastUserLocation: CLLocation
//    var lastMapCenterCoordinate: CLLocationCoordinate2D
//    var spotIdentifiersDrawnOnMap: Array<String>
//    var lineAnnotations: Array<MGLLineParkingSpot>
//    var centerButtonAnnotations: Array<ButtonParkingSpot>
//    var searchAnnotations: Array<MKAnnotation>
//    var selectedSpot: ParkingSpot?
//    var isSelecting: Bool
//    var radius : Double
//    var updateInProgress : Bool
//    
//    var trackUserButton : UIButton
//        
//    private(set) var MOVE_DELTA_IN_METERS : Double
//    
//    convenience init() {
//        self.init(nibName: nil, bundle: nil)
//    }
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        
//        mapView = MGLMapView(frame: CGRectMake(0, 0, 100, 100))
//        
//        mapView.userTrackingMode = MGLUserTrackingMode.Follow
//        
//        mapView.tintColor = Styles.Colors.red2
//        lastMapZoom = 0
//        lastUserLocation = CLLocation(latitude: 0, longitude: 0)
//        lastMapCenterCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
//        isSelecting = false
//        spotIdentifiersDrawnOnMap = []
//        lineAnnotations = []
//        centerButtonAnnotations = []
//        searchAnnotations = []
//        radius = 300
//        updateInProgress = false
//        
//        trackUserButton = UIButton()
//        
//        MOVE_DELTA_IN_METERS = 100
//        
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("NSCoding not supported")
//    }
//    
//    override func loadView() {
//        view = UIView()
//        view.addSubview(mapView)
//        mapView.delegate = self
//        
//        addCityOverlays()
//
//        trackUserButton.setImage(UIImage(named: "track_user"), forState: UIControlState.Normal)
//        trackUserButton.addTarget(self, action: "trackUserButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
//        view.addSubview(trackUserButton)
//        
//        mapView.snp_makeConstraints {  (make) -> () in
//            make.edges.equalTo(self.view)
//        }
//        
//        showTrackUserButton()
//
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.mapView.userTrackingMode = MGLUserTrackingMode.Follow
//        self.screenName = "Map - General Apple View"
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
//            Int64(1.5 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            self.canShowMapMessage = true
//            self.updateAnnotations()
//        }
//
//    }
//    
//    override func showForFirstTime() {
//        if !wasShown {
//            
//            if let checkIn = Settings.checkedInSpot() {
//                let coordinate = checkIn.buttonLocation.coordinate
//                self.mapView.userTrackingMode = MGLUserTrackingMode.None
//                goToCoordinate(coordinate, named: "", withZoom: 16, showing: false)
//            }
//            
//            wasShown = true
//        }
//    }
//
//    
//    func updateMapCenterIfNecessary () {
//        
//    }
//
//    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
//        if let polygonOverlay = annotation as? MGLPolygon {
//            return 0.7
//        }
//
//        return 1
//    
//    }
//    
//    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
//        
//        if let lineOverlay = annotation as? MGLLineParkingSpot {
//            
//            let userInfo = lineOverlay.userInfo
//            let selected = userInfo["selected"] as! Bool
//            let spot = userInfo["spot"] as! ParkingSpot
//            let isCurrentlyPaidSpot = spot.currentlyActiveRule.ruleType == .Paid
//            
//            if selected {
//                return Styles.Colors.red2
//            } else if isCurrentlyPaidSpot {
//                return Styles.Colors.curry
//            } else {
//                return Styles.Colors.petrol2
//            }
//            
//        }
//        
//        if let polygonOverlay = annotation as? MGLPolygon {
//            return Styles.Colors.red1
//        }
//        
//        return UIColor.blackColor()
//    }
//    
//    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
//            return Styles.Colors.beige1//.colorWithAlphaComponent(0.7)
//    }
//    
//    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
//        if let lineOverlay = annotation as? MGLLineParkingSpot {
//            
//            if mapView.zoomLevel >= 15.0 && mapView.zoomLevel <= 16.0 {
//                return 1.6
//            } else {
//                return 3.4
//            }
//        }
//        
//        return 1.0
//    }
//    
//    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//        if annotation is SearchResult
//            || annotation is PreviousCheckinSpot {
//                return true
//        }
//        return false
//    }
//    
//    func mapView(mapView: MGLMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
////    func mapView(mapView: MGLMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayView! {
//        if let lineOverlay = overlay as? LineParkingSpot {
//
//            let userInfo = lineOverlay.userInfo
//            let selected = userInfo["selected"] as! Bool
//            let spot = userInfo["spot"] as! ParkingSpot
//            let isCurrentlyPaidSpot = spot.currentlyActiveRule.ruleType == .Paid
//            let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool
//            
//            var coordinates = spot.line.coordinates2D
//            
//            var shape = MKPolylineRenderer(polyline: lineOverlay)
////            var shape = MKPolylineView(overlay: polyline)
//            shape.alpha = 0.5
//            if selected {
//                shape.strokeColor = Styles.Colors.red2
//            } else if isCurrentlyPaidSpot {
//                shape.strokeColor = Styles.Colors.curry
//            } else {
//                shape.strokeColor = Styles.Colors.petrol2
//            }
//            
//            if mapView.zoomLevel >= 15.0 && mapView.zoomLevel <= 16.0 {
//                shape.lineWidth = 1.6
//            } else {
//                shape.lineWidth = 3.4
//            }
//            
//            
//            if shouldAddAnimation {
////                addScaleAnimationtoView(shape.layer)
//                spotIdentifiersDrawnOnMap.append(spot.identifier)
//            }
//            
//            return shape
//            
//        } else if let polygon = overlay as? MKPolygon {
//            var shape = MKPolygonRenderer(polygon: polygon)
//            shape.fillColor = Styles.Colors.beige1.colorWithAlphaComponent(0.7)
//            shape.strokeColor = Styles.Colors.red1
//            shape.lineWidth = 4.0
//            return shape
//        }
//        
//        return nil
//    }
//
//    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        
//        if let buttonAnnotation = annotation as? ButtonParkingSpot {
//            var view = ButtonParkingSpotView(mapboxGLAnnotation: buttonAnnotation, reuseIdentifier: "button", mbxZoomLevel: mapView.zoomLevel)
//            return view.annotationImage
//        } else if let searchResultAnnotation = annotation as? SearchResult {
//            var searchResultImage = MGLAnnotationImage(image: UIImage(named: "pin_pointer_result")!, reuseIdentifier: "searchresult")
//            //note: this can show a callout
//            return searchResultImage
//        } else if let previousCheckinAnnotation = annotation as? PreviousCheckinSpot {
//            var previousCheckinImage = MGLAnnotationImage(image: UIImage(named: "pin_round_p")!, reuseIdentifier: "previouscheckin")
//            //note: this can show a callout
//            return previousCheckinImage
//        }
//        
//        return nil
//    }
//        
//    func mapView(mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
//        
//        if (mapView.userTrackingMode == MGLUserTrackingMode.Follow ) {
//            self.hideTrackUserButton()
//        } else {
//            toggleTrackUserButton(!(delegate != nil && !delegate!.shouldShowUserTrackingButton()))
//            self.mapView.userTrackingMode = MGLUserTrackingMode.None
//        }
//        
//    }
//    
//    func afterMapMove(map: MGLMapView!, byUser wasUserAction: Bool) {
//
//    }
//    
//    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//
//        //the following used to happen after a zoom
//        self.radius = (20.0 - mapView.zoomLevel) * 100
//        
//        if(mapView.zoomLevel < 15.0) {
//            self.radius = 0
//        }
//        
//        if (abs(self.lastMapZoom - mapView.zoomLevel) >= 1) {
//            self.spotIdentifiersDrawnOnMap = []
//        }
//        
//        if self.lastMapZoom != mapView.zoomLevel {
//            self.updateAnnotations()
//            self.lastMapZoom = mapView.zoomLevel
//            return
//        }
//        
//        //the following used to happen after a map move
//        removeSelectedAnnotationIfExists()
//        
//        //reload if the map has moved sufficiently...
//        let lastMapCenterLocation = CLLocation(latitude: self.lastMapCenterCoordinate.latitude, longitude: self.lastMapCenterCoordinate.longitude)
//        let newMapCenterLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
//        let differenceInMeters = lastMapCenterLocation.distanceFromLocation(newMapCenterLocation)
//        //        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
//        if differenceInMeters > self.MOVE_DELTA_IN_METERS {
//            self.updateAnnotations()
//            self.lastMapCenterCoordinate = mapView.centerCoordinate
//        }
//        
//        self.delegate?.mapDidDismissSelection()
//        
//    }
//    
//    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
//        
//        if var button = annotation as? ButtonParkingSpot {
//            removeSelectedAnnotationIfExists()
//            isSelecting = true
//            var annotationsToUpdate = self.findAnnotations(button.identifier)
//            mapView.removeAnnotations(annotationsToUpdate)
//            addSpotAnnotation(button, selected: true)
//            selectedSpot = button
//            self.delegate?.didSelectSpot(selectedSpot!)
//        }
//
//    }
//
//    func mapView(mapView: MGLMapView, didDeselectAnnotation annotation: MGLAnnotation) {
//
//        if var button = annotation as? ButtonParkingSpot {
//            if !isSelecting {
//                removeSelectedAnnotationIfExists()
//                addSpotAnnotation(button, selected: false)
//                self.delegate?.mapDidDismissSelection()
//            }
//            isSelecting = false
//        }
//
//    }
//    
//    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
//        //this will run too often, so only run it if we've changed by any significant amount
//        if let userCLLocation = userLocation?.location {
//            let differenceInMeters = lastUserLocation.distanceFromLocation(userCLLocation)
//            
//            if differenceInMeters > MOVE_DELTA_IN_METERS/10
//                && mapView.userTrackingMode == MGLUserTrackingMode.Follow {
//                updateAnnotations()
//                lastUserLocation = userCLLocation
//            }
//        }
//    }
//    
//
//    
////    func singleTapOnMap(map: MGLMapView!, at point: CGPoint) {
////        var minimumDistance = CGFloat(Float.infinity)
////        var closestAnnotation : MKAnnotation? = nil
////        //loop through the annotations to see if we touched a line or a button
////        for annotation in lineAnnotations {
////        }
////        for annotation: MKAnnotation in map.annotations as! [MKAnnotation] {
////            
////            if (annotation == mapView.userLocation) {
////                continue
////            }
////            
////            var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
////            var annotationType = userInfo!["type"] as! String
////            
////            if (annotationType == "button") {
////                var annotationPoint = map.coordinateToPixel(annotation.coordinate)
////                let xDist = (annotationPoint.x - point.x);
////                let yDist = (annotationPoint.y - point.y);
////                let distance = sqrt((xDist * xDist) + (yDist * yDist));
////                
////                if (distance < minimumDistance) {
////                    minimumDistance = distance
////                    closestAnnotation = annotation
////                }
////            }
////        }
////        
////        if (closestAnnotation != nil && minimumDistance < 60) {
////            map.selectAnnotation(closestAnnotation, animated: true)
////        }
////
////    }
//    
//    
//    // MARK: Helper Methods
//    
//    override func removeSelectedAnnotationIfExists() {
//        if (selectedSpot != nil) {
//            NSLog("called removeSelectedAnnotationIfExists, id is %@", selectedSpot!.identifier)
//            let annotationsToRemove = findAnnotations(selectedSpot!.identifier)
//            self.mapView.removeAnnotations(annotationsToRemove)
//            addSpotAnnotation(selectedSpot!, selected: false)
//            selectedSpot = nil
//        }
//    }
//
//    func trackUserButtonTapped () {
//        self.mapView.userTrackingMode = MGLUserTrackingMode.Follow
//        hideTrackUserButton()
//    }
//    
//    
//    func toggleTrackUserButton(shouldShowButton: Bool) {
//        if (shouldShowButton) {
//            showTrackUserButton()
//        } else {
//            hideTrackUserButton()
//        }
//    }
//    
//    func hideTrackUserButton() {
//        
//        trackUserButton.snp_updateConstraints{ (make) -> () in
//            make.size.equalTo(CGSizeMake(0, 0))
//            make.centerX.equalTo(self.view).multipliedBy(0.33)
//            make.bottom.equalTo(self.view).offset(-48)
//        }
//        animateTrackUserButton()
//    }
//    
//    func showTrackUserButton() {
//        
//        trackUserButton.snp_updateConstraints{ (make) -> () in
//            make.size.equalTo(CGSizeMake(36, 36))
//            make.centerX.equalTo(self.view).multipliedBy(0.33)
//            make.bottom.equalTo(self.view).offset(-30)
//        }
//        animateTrackUserButton()
//    }
//    
//    func animateTrackUserButton() {
//        self.trackUserButton.setNeedsLayout()
//        UIView.animateWithDuration(0.2,
//            delay: 0,
//            options: UIViewAnimationOptions.CurveEaseInOut,
//            animations: { () -> Void in
//                self.trackUserButton.layoutIfNeeded()
//            },
//            completion: { (completed:Bool) -> Void in
//        })
//    }
//    
//    override func updateAnnotations() {
//        
//        if (updateInProgress) {
//            println("Update already in progress, cancelled!")
//            return
//        }
//        
//        updateInProgress = true
//        
//        removeMyCarMarker()
//        addMyCarMarker()
//        
//        //only show the spinner if this map is active
//        if let tabController = self.parentViewController as? TabController {
//            if tabController.activeTab() == PrkTab.Here {
////                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
////                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
//            }
//        }
//        
//        if isFarAwayFromAvailableCities(mapView.centerCoordinate) {
//            
//            if canShowMapMessage {
//                self.delegate?.mapDidMoveFarAwayFromAvailableCities()
//            }
//            
//            updateInProgress = false
//            
//        } else if (mapView.zoomLevel >= 15.0) {
//            
//            self.delegate?.showMapMessage("map_message_loading".localizedString, onlyIfPreviouslyShown: true)
//
//            var checkinTime = searchCheckinDate
//            var duration = searchDuration
//            
//            if (checkinTime == nil) {
//                checkinTime = NSDate()
//            }
//            
//            if (duration == nil) {
//                duration = self.delegate?.activeFilterDuration()
//            }
//            
//            if duration != nil {
//                NSLog("updating with duration: %f",duration!)
//            } else {
//                NSLog("updating with duration: nil")
//            }
//            
//            let permit = self.delegate?.activeFilterPermit() ?? false
//
//            SpotOperations.findSpots(self.mapView.centerCoordinate, radius: Float(radius), duration: duration, checkinTime: checkinTime!, permit: permit, completion:
//                { (spots, underMaintenance, outsideServiceArea, error) -> Void in
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        //only show the spinner if this map is active
//                        if let tabController = self.parentViewController as? TabController {
//                            if tabController.activeTab() == PrkTab.Here {
//                                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
//                                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
//                                
//                                if self.canShowMapMessage {
//                                    if underMaintenance {
//                                        self.delegate?.showMapMessage("map_message_under_maintenance".localizedString)
//                                    } else if error {
//                                        self.delegate?.showMapMessage("map_message_error".localizedString)
//                                    } else if outsideServiceArea {
//                                        self.delegate?.showMapMessage("map_message_outside_service_area".localizedString)
//                                    } else if spots.count == 0 {
//                                        self.delegate?.showMapMessage("map_message_no_spots".localizedString)
//                                    } else {
//                                        self.delegate?.showMapMessage(nil)
//                                    }
//                                }
//                            }
//                        }
//                    })
//
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
//                        
//                        //
//                        // spots that have left the screen need to be re-animated next time
//                        // therefore, we remove spots that have not been fetched this time around
//                        //
//                        var newSpotIDs = spots.map{(var spot: ParkingSpot) -> String in spot.identifier}
//                        self.spotIdentifiersDrawnOnMap = self.spotIdentifiersDrawnOnMap.filter({ (var spotID: String) -> Bool in
//                            contains(newSpotIDs, spotID)
//                        })
//                        
//                        self.updateSpotAnnotations(spots)
//                        
//                        self.updateInProgress = false
//                        
//                        SVProgressHUD.dismiss()
//                        
//                    })
//
//                    
//            })
//            
//        } else {
//            
//            mapView.removeAnnotations(lineAnnotations)
//            lineAnnotations = []
//            
//            mapView.removeAnnotations(centerButtonAnnotations)
//            centerButtonAnnotations = []
//            
//            updateInProgress = false
//            
//            SVProgressHUD.dismiss()
//            
//            self.delegate?.showMapMessage("map_message_too_zoomed_out".localizedString)
//
//        }
//        
//        
//    }
//    
//    
//    func updateSpotAnnotations(spots: [ParkingSpot]) {
//
//        var tempLineAnnotations = [MGLLineParkingSpot]()
//        var tempButtonAnnotations = [ButtonParkingSpot]()
//        let zoomLevel = mapView.zoomLevel
//        
//        for spot in spots {
//            let selected = (self.selectedSpot != nil && self.selectedSpot?.identifier == spot.identifier)
//            var annotations = self.annotationForSpot(spot, selected: selected, addToMapView: false)
//            tempLineAnnotations.append(annotations.0)
//            if let button = annotations.1 {
//                tempButtonAnnotations.append(button)
//            }
//
//        }
//
//        dispatch_async(dispatch_get_main_queue(), {
//            
//            self.removeLinesAndButtons()
//            
//            self.lineAnnotations = tempLineAnnotations
//            self.centerButtonAnnotations = tempButtonAnnotations
//
//            self.mapView.addAnnotations(self.lineAnnotations)
//            self.mapView.addAnnotations(self.centerButtonAnnotations)
//            
//            SVProgressHUD.dismiss()
//            self.updateInProgress = false
//
//        })
//    }
//
//    func addSpotAnnotation(spot: ParkingSpot, selected: Bool) {
//        annotationForSpot(spot, selected: selected, addToMapView: true)
//    }
//
//    func annotationForSpot(spot: ParkingSpot, selected: Bool, addToMapView: Bool) -> (MGLLineParkingSpot, ButtonParkingSpot?) {
//        
//        var annotation: MGLLineParkingSpot
//        var centerButton: ButtonParkingSpot?
//        
//        let shouldAddAnimation = !contains(self.spotIdentifiersDrawnOnMap, spot.identifier)
//        
//        var userInfo = ["type": "line", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimation]
//        var coordinates = spot.line.coordinates2D
//        
//        //create the proper polyline
//        annotation = MGLLineParkingSpot(coordinates: &coordinates, count: UInt(coordinates.count))
//        spot.userInfo = userInfo
//        annotation.parkingSpot = spot
//        
//        if addToMapView {
//            self.mapView.addAnnotation(annotation)
//            lineAnnotations.append(annotation)
//        }
//
//        if (mapView.zoomLevel >= 17.0) {
//            centerButton = spot.buttonSpot
//            centerButton!.userInfo = ["type": "button", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimation]
//            
//            if addToMapView {
//                self.mapView.addAnnotation(centerButton!)
//                centerButtonAnnotations.append(centerButton!)
//            }
//
//        }
//        
//        return (annotation, centerButton)
//    }
//    
//    func addSearchResultMarker(searchResult: SearchResult) {
//        
////        var annotation: MKAnnotation = MKAnnotation(mapView: self.mapView, coordinate: searchResult.location.coordinate, andTitle: searchResult.title)
//        searchResult.userInfo = ["type": "searchResult", "details": searchResult]
//        mapView.addAnnotation(searchResult)
//        searchAnnotations.append(searchResult)
//    }
//    
//    
//    func findAnnotations(identifier: String) -> [AnyObject] {
//        
//        var foundAnnotations = [AnyObject]()
//        
//        for annotation in lineAnnotations {
//            
//            if annotation.title == identifier {
//                foundAnnotations.append(annotation)
//            }
//        }
//        
//        
//        for annotation in centerButtonAnnotations {
//            
//            var userData: [String:AnyObject]? = (annotation as ButtonParkingSpot).userInfo as? [String:AnyObject]
//            var spot = userData!["spot"] as! ParkingSpot
//            
//            if spot.identifier == identifier {
//                foundAnnotations.append(annotation)
//            }
//        }
//        
//        return foundAnnotations
//    }
//
//    
//    
//    override func addCityOverlaysCallback(polygons: [MKPolygon]) {
//        
//        let interiorPolygons = MKPolygon.interiorPolygons(polygons)
//        let invertedPolygon = MKPolygon.invertPolygons(polygons)
////        mapView.addAnnotation(invertedPolygon.toMGLPolygon())
//        mapView.addAnnotations(MKPolygon.toMGLPolygons(interiorPolygons))
//    }
//    
//    // MARK: SpotDetailViewDelegate
//    
//    override func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) {
//        
//        
//        if (results.count == 0) {
//            let alert = UIAlertView()
//            alert.title = "No results found"
//            alert.message = "We couldn't find anything matching the criteria"
//            alert.addButtonWithTitle("Close")
//            alert.show()
//            return
//        }
//        
//        mapView.setCenterCoordinate(results[0].location.coordinate, zoomLevel: 17, animated: true)
//        
//        searchAnnotations = []
//
//        lineAnnotations = []
//        centerButtonAnnotations = []
//        removeAllAnnotations()
//        
//        for result in results {
//            addSearchResultMarker(result)
//        }
//        
//        self.searchCheckinDate = checkinTime
//        
//        updateAnnotations()
//        
//    }
//    
//    override func clearSearchResults() {
//        mapView.removeAnnotations(self.searchAnnotations)
//    }
//    
//    override func showUserLocation(shouldShow: Bool) {
//        self.mapView.showsUserLocation = shouldShow
//    }
//    
//    override func trackUser(shouldTrack: Bool) {
//        self.mapView.userTrackingMode = shouldTrack ? MGLUserTrackingMode.Follow : MGLUserTrackingMode.None
//        
//    }
//    
//    override func addMyCarMarker() {
//        if let spot = Settings.checkedInSpot() {
//            var annotation = PreviousCheckinSpot(spot: spot)
////            annotation.icon = UIImage(named: "pin_round_p")
////            annotation.groundAnchor = CGPoint(x: 0.5, y: 0.5)
////            annotation.tappable = false
////            annotation.zIndex = 10
//            myCarAnnotation = annotation
//            self.mapView.addAnnotation(annotation)
//        }
//    }
//    
//    override func removeMyCarMarker() {
//        if myCarAnnotation != nil {
//            self.mapView.removeAnnotation(myCarAnnotation as! PreviousCheckinSpot)
//            myCarAnnotation = nil
//        }
//    }
//    
//    //shows a checkin on the map as a regular marker
//    override func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, withZoom zoom:Float? = nil, showing: Bool = true) {
//        var annotation = PreviousCheckinSpot(coordinate: coordinate, title: name)
////        annotation.icon = UIImage(named: "pin_round_p")
////        annotation.groundAnchor = CGPoint(x: 0.5, y: 0.5)
////        annotation.tappable = false
////        annotation.zIndex = 10
//        self.mapView.setCenterCoordinate(coordinate, zoomLevel: Double(zoom ?? 17), animated: true)
//        removeAllAnnotations()
//        if showing {
//            searchAnnotations.append(annotation)
//            self.mapView.addAnnotation(annotation)
//        }
//    }
//
//    
//    func removeAllAnnotations() {
//        mapView.removeAnnotations(self.centerButtonAnnotations)
//        mapView.removeAnnotations(self.searchAnnotations)
//        mapView.removeAnnotations(self.lineAnnotations)
//        searchAnnotations = []
//        lineAnnotations = []
//        centerButtonAnnotations = []
//        removeMyCarMarker()
//        addMyCarMarker()
//    }
//    
//    func removeLinesAndButtons() {
//        mapView.removeAnnotations(self.centerButtonAnnotations)
//        mapView.removeAnnotations(self.lineAnnotations)
//        searchAnnotations = []
//        lineAnnotations = []
//    }
//    
//}
