//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 05/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Foundation

class GoogleMapViewController: MapViewController {
    
}

//
//enum PRKGoogleUserTrackingMode {
//    case None
//    case Follow
//}
//
//class GoogleMapViewController: MapViewController, GMSMapViewDelegate {
//    
//    var mapView: GMSMapView
//    var userLastChangedMap: Double
//    var lastMapZoom: Float
//    var lastUserLocation: CLLocation
//    var lastMapCenterCoordinate: CLLocationCoordinate2D
//    var spotIDsDrawnOnMap: Array<String>
//    var lineSpotIDsDrawnOnMap: Array<String>
//    var lineAnnotations: Array<PRK_GMSPolyline>
//    var centerButtonAnnotations: Array<GMSMarker>
//    var searchAnnotations: Array<GMSMarker>
//    var selectedSpot: ParkingSpot?
//    var isSelecting: Bool
//    var radius : Float
//    var updateInProgress : Bool
//    
//    var trackUserButton : UIButton
//    var userTrackingMode: PRKGoogleUserTrackingMode {
//        didSet {
//            
//        }
//    }
//    
//    private(set) var MOVE_DELTA_IN_METERS : Double
//    
//    var zoom: Float { get { return self.mapView.camera.zoom }
//        set(value) {
//            var cameraUpdate = GMSCameraUpdate.zoomTo(value)
//            self.mapView.animateWithCameraUpdate(cameraUpdate)
//        }
//    }
//    
//    convenience init() {
//        self.init(nibName: nil, bundle: nil)
//    }
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        
//        mapView = GMSMapView.mapWithFrame(CGRectMake(0, 0, 100, 100), camera: GMSCameraPosition(target: Settings.pointForCity(Settings.City.Montreal), zoom: 17, bearing: 0, viewingAngle: 0))
//        mapView.tintColor = Styles.Colors.red2
//        mapView.setMinZoom(9, maxZoom: 19)
//        userLastChangedMap = 0
//        lastMapZoom = 0
//        lastUserLocation = CLLocation(latitude: 0, longitude: 0)
//        lastMapCenterCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
//        isSelecting = false
//        spotIDsDrawnOnMap = []
//        lineSpotIDsDrawnOnMap = []
//        lineAnnotations = []
//        centerButtonAnnotations = []
//        searchAnnotations = []
//        radius = 300
//        updateInProgress = false
//        
//        trackUserButton = UIButton()
//        userTrackingMode = PRKGoogleUserTrackingMode.None
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
//        self.mapView.snp_makeConstraints {  (make) -> () in
//            make.edges.equalTo(self.view)
//        }
//        
//        showTrackUserButton()
//        
//        self.mapView.myLocationEnabled = true
//        self.mapView.settings.myLocationButton = true
//
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.userTrackingMode = PRKGoogleUserTrackingMode.Follow
//        self.screenName = "Map - General MapBox View"
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        self.removeSelectedAnnotationIfExists()
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
//        
//        if !wasShown {
//            if let checkIn = Settings.checkedInSpot() {
//                let coordinate = checkIn.buttonLocation.coordinate
//                self.showTrackUserButton()
//                userTrackingMode = PRKGoogleUserTrackingMode.None
//                goToCoordinate(coordinate, named: "", withZoom: 16, showing: false)
//            }
//            
//            wasShown = true
//
//        }
//        
//        hideTrackUserButton()
//    }
//    
//    func updateMapCenterIfNecessary () {
//        
//    }
//    
//    func getTimeSinceLastMapMovement() -> NSTimeInterval {
//        let currentTime = NSDate().timeIntervalSince1970 * 1000
//        let difference = currentTime - userLastChangedMap
//        return difference
//    }
//    
//    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
//
//        if gesture {
//            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
//        }
//        
//    }
//    
//    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
//        
//        userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
//
//        //the following used to happen after a zoom
//        self.radius = (20.0 - self.zoom) * 100
//        
//        if(self.zoom < 15.0) {
//            self.radius = 0
//        }
//        
//        if (abs(self.lastMapZoom - self.zoom) >= 1) {
//            self.spotIDsDrawnOnMap = []
//        }
//        
//        if self.lastMapZoom != self.zoom {
//            self.updateAnnotations()
//            self.lastMapZoom = self.zoom
//            return
//        }
//        
//        //the following used to happen after a map move
//        //        removeSelectedAnnotationIfExists()
//        
//        //reload if the map has moved sufficiently...
//        let lastMapCenterLocation = CLLocation(latitude: self.lastMapCenterCoordinate.latitude, longitude: self.lastMapCenterCoordinate.longitude)
//        let newMapCenterLocation = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
//        let differenceInMeters = lastMapCenterLocation.distanceFromLocation(newMapCenterLocation)
//        //        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
//        if differenceInMeters > self.MOVE_DELTA_IN_METERS {
//            self.updateAnnotations()
//            self.lastMapCenterCoordinate = mapView.camera.target
//        }
//        
//        self.delegate?.mapDidDismissSelection()
//
//    }
//    
//    func afterMapMove(map: GMSMapView!, byUser wasUserAction: Bool) {
//        
//        if wasUserAction {
//            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
//        }
//        
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
//            Int64(0.31 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//
//            self.removeSelectedAnnotationIfExists()
//            
//            //reload if the map has moved sufficiently...
//            let lastMapCenterLocation = CLLocation(latitude: self.lastMapCenterCoordinate.latitude, longitude: self.lastMapCenterCoordinate.longitude)
//            let newMapCenterLocation = CLLocation(latitude: map.camera.target.latitude, longitude: map.camera.target.longitude)
//            let differenceInMeters = lastMapCenterLocation.distanceFromLocation(newMapCenterLocation)
//            //        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
//            if differenceInMeters > self.MOVE_DELTA_IN_METERS
//                && self.getTimeSinceLastMapMovement() > 300 {
//                    self.updateAnnotations()
//                    self.lastMapCenterCoordinate = map.camera.target
//            }
//            self.delegate?.mapDidDismissSelection()
//            
//        }
//        
//    }
//    
//    func afterMapZoom(map: GMSMapView!, byUser wasUserAction: Bool) {
//        
//        if wasUserAction {
//            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
//        }
//
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
//            Int64(0.31 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            
//            self.radius = (20.0 - self.zoom) * 100
//            
//            if(self.zoom < 15.0) {
//                self.radius = 0
//            }
//            
//            if (abs(self.lastMapZoom - self.zoom) >= 1) {
//                self.spotIDsDrawnOnMap = []
//            }
//            
//            if self.getTimeSinceLastMapMovement() > 300 {
//                self.updateAnnotations()
//            }
//            
//            self.lastMapZoom = self.zoom
//        }
//        
//        
//    }
//    
//    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
//        
//        removeSelectedAnnotationIfExists()
//        
//        var userData: [String:AnyObject]? = marker.userData as? [String:AnyObject]
//        if ((userData?["type"] ?? "") as! String) == "button" {
//            var spot = userData!["spot"] as! ParkingSpot
//            customSelectAnnotation(spot)
//            return true
//        }
//        
//        return false
//
//    }
//    
//    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
//        
//        if overlay is PRK_GMSPolyline {
//            //find the corresponding marker
//            let annotations = findAnnotations(overlay.title)
//            for annotation in annotations {
//                if annotation is GMSMarker {
//                    var userData: [String:AnyObject]? = (annotation as! GMSMarker).userData as? [String:AnyObject]
//                    var spot = userData!["spot"] as! ParkingSpot
//                    customSelectAnnotation(spot)
//                }
//            }
//        }
//    }
//    
//    func customSelectAnnotation(spot: ParkingSpot?){
//        
//        if spot == nil {
//            customDeselectAnnotation()
//            return
//        }
//        
//        var annotations = findAnnotations(spot!.identifier)
//        removeAnnotations(annotations)
//        addSpotAnnotation(spot!, selected: true)
//        
//        selectedSpot = spot!
//        
//        self.delegate?.didSelectSpot(selectedSpot!)
//    }
//    
//    func customDeselectAnnotation() {
//        
//        removeSelectedAnnotationIfExists()
//        self.delegate?.mapDidDismissSelection()
//
//    }
//    
//    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//        
//        removeSelectedAnnotationIfExists()
//        
//        var minimumDistance = CGFloat(Float.infinity)
//        var closestAnnotation : GMSOverlay? = nil
//        var closestSpot : ParkingSpot? = nil
//        var loopThroughLines = self.zoom < 17.0
//        let point = mapView.projection.pointForCoordinate(coordinate)
//
//        for annotation in centerButtonAnnotations {
//            
//            var userData: [String:AnyObject]? = (annotation as GMSMarker).userData as? [String:AnyObject]
//            var spot = userData!["spot"] as! ParkingSpot
//            
//            var annotationPoint = mapView.projection.pointForCoordinate(annotation.position)
//            let distance = annotationPoint.distanceToPoint(point)
//            
//            if (distance < minimumDistance) {
//                minimumDistance = distance
//                closestAnnotation = annotation
//                closestSpot = spot
//            }
//            
//        }
//        
//        for annotation in lineAnnotations {
//
//            if loopThroughLines {
//                
//                let spot = annotation.spot
//                let coordinates = spot.line.coordinates2D + [spot.buttonLocation.coordinate]
//                
//                var distances = coordinates.map{(coordinate: CLLocationCoordinate2D) -> CGFloat in
//                    var annotationPoint = mapView.projection.pointForCoordinate(coordinate)
//                    let distance = annotationPoint.distanceToPoint(point)
//                    return distance
//                }
//                
//                for distance in distances {
//                    if (distance < minimumDistance) {
//                        minimumDistance = distance
//                        closestAnnotation = annotation
//                        closestSpot = spot
//                    }
//                }
//                
//            }
//        }
//        
//        if (closestAnnotation != nil && minimumDistance < 60) {
//            customSelectAnnotation(closestSpot)
//        } else {
//            customDeselectAnnotation()
//        }
//
//    }
//    
//    
//    // MARK: Helper Methods
//    
//    func trackUserButtonTapped () {
//        var cameraUpdate = GMSCameraUpdate.zoomTo(17)
//        self.mapView.animateWithCameraUpdate(cameraUpdate)
//        userTrackingMode = PRKGoogleUserTrackingMode.Follow
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
//        if isFarAwayFromAvailableCities(mapView.camera.target) {
//            
//            if canShowMapMessage {
//                self.delegate?.mapDidMoveFarAwayFromAvailableCities()
//            }
//            
//            updateInProgress = false
//
//        } else if (self.zoom >= 15.0) {
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
//                NSLog("updating with duration: %f", duration!)
//            } else {
//                NSLog("updating with duration: nil")
//            }
//            
//            let permit = self.delegate?.activeFilterPermit() ?? false
//            
//            SpotOperations.findSpots(self.mapView.camera.target, radius: radius, duration: duration, checkinTime: checkinTime!, permit: permit, completion:
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
//                        self.spotIDsDrawnOnMap = self.spotIDsDrawnOnMap.filter({ (var spotID: String) -> Bool in
//                            contains(newSpotIDs, spotID)
//                        })
//                        self.lineSpotIDsDrawnOnMap = self.lineSpotIDsDrawnOnMap.filter({ (var spotID: String) -> Bool in
//                            contains(newSpotIDs, spotID)
//                        })
//
//                        self.updateSpotAnnotations(spots)
//                        
//                    })
//                    
//            })
//            
//        } else {
//            
//            removeAnnotations(lineAnnotations)
//            lineAnnotations = []
//            
//            removeAnnotations(centerButtonAnnotations)
//            centerButtonAnnotations = []
//            
//            spotIDsDrawnOnMap = []
//            lineSpotIDsDrawnOnMap = []
//            
//            updateInProgress = false
//
//            self.delegate?.showMapMessage("map_message_too_zoomed_out".localizedString)
//        }
//        
//        
//    }
//    
//    func updateSpotAnnotations(spots: [ParkingSpot]) {
//        
//        dispatch_async(dispatch_get_main_queue(), {
//            
//            let duration = self.delegate?.activeFilterDuration()
//            var tempLineAnnotations = [PRK_GMSPolyline]()
//            var tempButtonAnnotations = [GMSMarker]()
//            
//            for spot in spots {
//                let selected = (self.selectedSpot != nil && self.selectedSpot?.identifier == spot.identifier)
//                var annotations = self.annotationForSpot(spot, selected: selected, addToMapView: false)
//                tempLineAnnotations.append(annotations.0)
//                if let button = annotations.1 {
//                    tempButtonAnnotations.append(button)
//                }
//                
//            }
//        
//            self.removeLinesAndButtons()
//
//            self.lineAnnotations = tempLineAnnotations
//            self.centerButtonAnnotations = tempButtonAnnotations
//
//            self.addAnnotations(self.lineAnnotations)
//            self.addAnnotations(self.centerButtonAnnotations)
//            
//            SVProgressHUD.dismiss()
//            self.updateInProgress = false
//
//        })
//
//    }
//    
//    func addSpotAnnotation(spot: ParkingSpot, selected: Bool) {
//        annotationForSpot(spot, selected: selected, addToMapView: true)
//    }
//    
//    func annotationForSpot(spot: ParkingSpot, selected: Bool, addToMapView: Bool) -> (PRK_GMSPolyline, GMSMarker?) {
//        
//        var annotation: PRK_GMSPolyline
//        var centerButton: GMSMarker?
//        
//        let coordinate = spot.line.coordinates[0].coordinate
//        let shouldAddAnimationForLine = !contains(self.lineSpotIDsDrawnOnMap, spot.identifier)
//        var path = GMSMutablePath()
//        for coord in spot.line.coordinates2D {
//            path.addCoordinate(coord)
//        }
//        annotation = PRK_GMSPolyline(path: path, title: spot.identifier, spot: spot)
////        annotation.userData = ["type": "line", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimationForLine]
//        let shouldAddAnimation = shouldAddAnimationForLine
//        let isCurrentlyPaidSpot = spot.currentlyActiveRule.ruleType == .Paid
//        
//        if selected {
//            annotation.strokeColor = Styles.Colors.red2
//        } else if isCurrentlyPaidSpot {
//            annotation.strokeColor = Styles.Colors.curry
//        } else {
//            annotation.strokeColor = Styles.Colors.petrol2
//        }
//        
//        if self.zoom >= 15.0 && self.zoom < 16.0 {
//            annotation.strokeWidth = 2.6
//        } else {
//            annotation.strokeWidth = 4.4
//        }
//        
////        if shouldAddAnimation {
////            annotation.addScaleAnimation()
////            lineSpotIDsDrawnOnMap.append(spot.identifier)
////        }
//        
//        if addToMapView {
//            self.addAnnotations([annotation])
//            lineAnnotations.append(annotation)
//        }
//        
//        if (self.zoom >= 17.0) {
//            
//            let shouldAddAnimationForButton = !contains(self.spotIDsDrawnOnMap, spot.identifier)
//            centerButton = GMSMarker(position: spot.buttonLocation.coordinate)
//            centerButton?.title = spot.identifier
//            centerButton!.userData = ["type": "button", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimationForButton]
//            
//            //move this somewhere so selections conitnue to work...
//            let isCurrentlyPaidSpot = spot.currentlyActiveRule.ruleType == .Paid
//            let shouldAddAnimation = shouldAddAnimationForButton
//            
//            var imageName = "button_line_"
//            
//            if self.zoom < 18 {
//                imageName += "small_"
//            }
//            if isCurrentlyPaidSpot {
//                imageName += "metered_"
//            }
//            if !selected {
//                imageName += "in"
//            }
//            
//            imageName += "active"
//            
//            var circleImage = UIImage(named: imageName)
//            
//            centerButton?.icon = circleImage
//            centerButton?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//            centerButton?.zIndex = 5
//            
//            if shouldAddAnimation {
////                circleMarker.addScaleAnimation()
//                centerButton?.appearAnimation = kGMSMarkerAnimationPop
//                spotIDsDrawnOnMap.append(spot.identifier)
//            }
//            
//            if (selected) {
//                var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
//                pulseAnimation.duration = 0.7
//                pulseAnimation.fromValue = 0.95
//                pulseAnimation.toValue = 1.10
//                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                pulseAnimation.autoreverses = true
//                pulseAnimation.repeatCount = FLT_MAX
////                circleMarker.addAnimation(pulseAnimation, forKey: nil)
//            }
//            
//            if addToMapView {
//                self.addAnnotations([centerButton!])
//                centerButtonAnnotations.append(centerButton!)
//            }
//            
//        }
//        
//        return (annotation, centerButton)
//        
//    }
//    
//    
//    func addSearchResultMarker(searchResult: SearchResult) {
//        
//        var annotation = GMSMarker(position: searchResult.location.coordinate)
//        annotation.title = searchResult.title
//        annotation.subtitle = searchResult.subtitle
//        annotation.userData = ["type": "searchResult", "details": searchResult]
//        annotation.icon = UIImage(named: "pin_pointer_result")
//        annotation.zIndex = 10
//        annotation.map = self.mapView
//        searchAnnotations.append(annotation)
//    }
//    
//    
//    func findAnnotations(identifier: String) -> [GMSOverlay] {
//        
//        var foundAnnotations: Array<GMSOverlay> = []
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
//            var userData: [String:AnyObject]? = (annotation as GMSMarker).userData as? [String:AnyObject]
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
//    func removeLinesAndButtons() {
//        self.mapView.clear()
//        self.addAnnotations(searchAnnotations)
//        removeMyCarMarker()
//        addMyCarMarker()
//        
//        self.lineAnnotations = []
//        self.centerButtonAnnotations = []
//    }
//    
//    func removeAllAnnotations() {
//        
//        searchAnnotations = []
//        lineAnnotations = []
//        centerButtonAnnotations = []
//        self.mapView.clear()
//        addCityOverlays()
//        addMyCarMarker()
//    }
//    
//    
//    override func addCityOverlaysCallback(polygons: [MKPolygon]) {
//        
////        let polygonAnnotations = MKPolygon.polygonsToRMPolygonAnnotations(polygons, mapView: mapView)
////
////        var worldCorners: [CLLocation] = [
////            CLLocation(latitude: 85, longitude: -179),
////            CLLocation(latitude: 85, longitude: 179),
////            CLLocation(latitude: -85, longitude: 179),
////            CLLocation(latitude: -85, longitude: -179),
////            CLLocation(latitude: 85, longitude: -179)]
////        var annotation = RMPolygonAnnotation(mapView: mapView, points: worldCorners, interiorPolygons: polygonAnnotations)
////        annotation.userData = ["type": "polygon", "points": worldCorners, "interiorPolygons": polygonAnnotations]
////        annotation.fillColor = Styles.Colors.beige1.colorWithAlphaComponent(0.7)
////        annotation.lineColor = Styles.Colors.red1
////        annotation.lineWidth = 4.0
////        
////        let interiorPolygons = MKPolygon.interiorPolygons(polygons)
////        let interiorPolygonAnnotations = MKPolygon.polygonsToRMPolygonAnnotations(interiorPolygons, mapView: mapView)
////        
////        var allAnnotationsToAdd = [annotation]
////        addAnnotations(allAnnotationsToAdd)
//        
//    }
//    
//    func addAnnotations(annotations: [GMSOverlay]) {
//        for annotation in annotations {
//            annotation.map = self.mapView
//        }
//    }
//    
//    func removeAnnotations(annotations: [GMSOverlay]) {
//        for annotation in annotations {
//            annotation.map = nil
//        }
//    }
//    
//    // MARK: SpotDetailViewDelegate
//    
//    override func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) {
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
//        mapView.animateWithCameraUpdate(GMSCameraUpdate.setCamera(GMSCameraPosition.cameraWithTarget(results[0].location.coordinate, zoom: 17)))
//        
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
//        removeAnnotations(self.searchAnnotations)
//    }
//    
//    override func showUserLocation(shouldShow: Bool) {
//        self.mapView.myLocationEnabled = shouldShow
//    }
//    
//    override func trackUser(shouldTrack: Bool) {
//        self.userTrackingMode = shouldTrack ? PRKGoogleUserTrackingMode.Follow : PRKGoogleUserTrackingMode.None
//    }
//    
//    override func addMyCarMarker() {
//        if let spot = Settings.checkedInSpot() {
//            let coordinate = spot.buttonLocation.coordinate
//            let name = spot.name
//            var annotation = GMSMarker(position: coordinate)
//            annotation.title = name
//            annotation.userData = ["type": "previousCheckin"]
//            annotation.icon = UIImage(named: "pin_round_p")
//            annotation.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//            annotation.tappable = false
//            annotation.zIndex = 10
//            myCarAnnotation = annotation
//            self.addAnnotations([annotation])
//        }
//    }
//    
//    override func removeMyCarMarker() {
//        if myCarAnnotation != nil {
//            self.removeAnnotations([myCarAnnotation as! GMSMarker])
//            myCarAnnotation = nil
//        }
//    }
//
//    override func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, withZoom zoom:Float? = nil, showing: Bool = true) {
//        var annotation = GMSMarker(position: coordinate)
//        annotation.userData = ["type": "previousCheckin"]
//        annotation.icon = UIImage(named: "pin_round_p")
//        annotation.groundAnchor = CGPoint(x: 0.5, y: 0.5)
//        annotation.tappable = false
//        annotation.zIndex = 10
//        var cameraPosition = GMSCameraPosition(target: coordinate, zoom: zoom ?? 17, bearing: 0, viewingAngle: 0)
//        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.setCamera(cameraPosition))
//        removeAllAnnotations()
//        if showing {
//            searchAnnotations.append(annotation)
//            self.addAnnotations([annotation])
//        }
//    }
//
//    override func removeSelectedAnnotationIfExists() {
//        if (selectedSpot != nil) {
//            removeAnnotations(findAnnotations(selectedSpot!.identifier))
//            addSpotAnnotation(selectedSpot!, selected: false)
//            selectedSpot = nil
//        }
//    }
//
//
//    
//}
//
