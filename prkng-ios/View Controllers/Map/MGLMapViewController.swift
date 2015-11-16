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

//class MGLMapViewController: MapViewController, MGLMapViewDelegate, UIGestureRecognizerDelegate {
//    
//    var mapView: MGLMapView
//    var userLastChangedMap: Double = 0
//    var lastMapZoom: Double = 0
//    var lastUserLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
//    var lastMapCenterCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
//    var spotIDsDrawnOnMap = [String]()
//    var lineSpotIDsDrawnOnMap = [String]()
//    var annotations = [AnyObject]()
//    var searchAnnotations = [MGLAnnotation]()
//    var selectedObject: DetailObject?
//    var isSelecting: Bool = false
//    var recoloringLotPins: Bool = false
//    
//    let MOVE_DELTA_PERCENTAGE : Double = 0.2
//
//    
//    var radius: Float {
//        //get a corner of the map and calculate the meters from the center
//        let center = CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
//        let topRight = CLLocation(latitude: self.mapView.visibleCoordinateBounds.ne.latitude, longitude: self.mapView.visibleCoordinateBounds.ne.longitude)
//        let meters = center.distanceFromLocation(topRight)
//        return Float(meters)
//    }
//
//    convenience init() {
//        self.init(nibName: nil, bundle: nil)
//    }
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        
//        mapView = MGLMapView(frame: CGRectMake(0, 0, 100, 100), styleURL: NSURL(string: "mapbox://styles/arnaudspuhler/cigfc11g0000dcnm73r4o3pi1"))
//        mapView.userTrackingMode = MGLUserTrackingMode.Follow
//        mapView.tintColor = Styles.Colors.red2
//        mapView.setCenterCoordinate(Settings.selectedCity().coordinate, zoomLevel: 17, animated: false)
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
//        self.showUserLocation(true)
//        
//        addCityOverlays()
//        
//        mapView.snp_makeConstraints {  (make) -> () in
//            make.edges.equalTo(self.view)
//        }
//        
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.trackUser()
//        self.screenName = "Map - General Mapbox GL View"
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: "singleTapOnMap:")
//        tapRecognizer.delegate = self
//        self.mapView.addGestureRecognizer(tapRecognizer)
//    }
//    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
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
//                let coordinate = checkIn.selectedButtonLocation ?? checkIn.buttonLocations.first!
//                self.dontTrackUser()
//                goToCoordinate(coordinate, named: "", withZoom: 16, showing: false)
//            }
//            
//            wasShown = true
//            
//        }
//    }
//    
//    func updateMapCenterIfNecessary () {
//        
//    }
//
//    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
//        if annotation is MGLPolygon {
//            return 0.7
//        }
//
//        return 1
//    
//    }
//    
//    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
//        
//        if let line = annotation as? MGLLineParkingSpot {
//            return line.lineColorWithZoom(mapView.zoomLevel)
//        }
//        
//        if annotation is MGLPolygon {
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
//        
//        if let line = annotation as? MGLLineParkingSpot {
//            return line.lineWidthWithZoom(mapView.zoomLevel)
//        }
//        
//        return 1.0
//    }
//    
//    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//        if let genericAnnotation = annotation as? GenericMGLAnnotation {
//            return genericAnnotation.canShowCallout
//        }
//        return false
//    }
//    
//    func mapView(mapView: MGLMapView, leftCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
//        if let genericAnnotation = annotation as? GenericMGLAnnotation {
//            return genericAnnotation.leftCalloutAccessoryView
//        }
//        return nil
//    }
//    
//    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
//        if let genericAnnotation = annotation as? GenericMGLAnnotation {
//            return genericAnnotation.rightCalloutAccessoryView
//        }
//        return nil
//    }
//    
//    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
//        if let genericAnnotation = annotation as? GenericMGLAnnotation {
//            if let annotationType = genericAnnotation.userInfo["type"] as? String {
//                if annotationType == "searchResult" {
//                    AnalyticsOperations.sendSearchQueryToAnalytics(genericAnnotation.title ?? "", navigate: true)
//                    DirectionsAction.perform(onViewController: self, withCoordinate: annotation.coordinate, shouldCallback: true)
//                } else if annotationType == "carsharing" {
//                    if let carShare = userInfo["carshare"] as? CarShare {
//                        CarSharingOperations.reserveCarShare(carShare, fromVC: self)
//                    }
//                }
//            }
//        }
//    }
//
//    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        
//        if let genericAnnotation = annotation as? GenericMGLAnnotation {
//            let imageView = genericAnnotation.annotationImageWithZoom(mapView.zoomLevel)
//            let reuseIdentifier = genericAnnotation.reuseIdentifierWithZoom(mapView.zoomLevel)
//            return MGLAnnotationImage(image: imageView, reuseIdentifier: reuseIdentifier)
//        }
//        
//        return nil
//    }
//
//    func mapView(mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
//        
//        if (mapView.userTrackingMode == MGLUserTrackingMode.Follow ) {
//            self.trackUser()
//        } else {
//            self.dontTrackUser()
//        }
//        
//    }
//    
//    func getTimeSinceLastMapMovement() -> NSTimeInterval {
//        let currentTime = NSDate().timeIntervalSince1970 * 1000
//        let difference = currentTime - userLastChangedMap
//        return difference
//    }
//    
//    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//
////      if self.mapMode == .Garage {
////            mapView.clusteringEnabled = map.zoom <= 12
////          //TODO: clustering on MGLMapView...
////      }
//        
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
//            Int64(0.16 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            //
//            if (abs(self.lastMapZoom - mapView.zoomLevel) >= 1) {
//                self.spotIDsDrawnOnMap = []
//            }
//            
//            let zoomChanged = self.lastMapZoom != mapView.zoomLevel
//            
//            self.removeSelectedAnnotationIfExists()
//            
//            //reload if the map has moved sufficiently...
//            let lastMapCenterLocation = CLLocation(latitude: self.lastMapCenterCoordinate.latitude, longitude: self.lastMapCenterCoordinate.longitude)
//            let newMapCenterLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
//            let centerLatitudeDelta = abs(lastMapCenterLocation.coordinate.latitude - newMapCenterLocation.coordinate.latitude)
//            let centerLongitudeDelta = abs(lastMapCenterLocation.coordinate.longitude - newMapCenterLocation.coordinate.longitude)
//            
//            let latitudeDeltaInDegrees = MGLCoordinateBoundsGetCoordinateSpan(mapView.visibleCoordinateBounds).latitudeDelta
//            let longitudeDeltaInDegrees = MGLCoordinateBoundsGetCoordinateSpan(mapView.visibleCoordinateBounds).longitudeDelta
//            
//            //        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
//            if self.getTimeSinceLastMapMovement() > 150 && (zoomChanged
//                || centerLatitudeDelta/latitudeDeltaInDegrees > self.MOVE_DELTA_PERCENTAGE
//                || centerLongitudeDelta/longitudeDeltaInDegrees > self.MOVE_DELTA_PERCENTAGE) {
//                    self.updateAnnotations()
//                    self.lastMapCenterCoordinate = mapView.centerCoordinate
//            }
//
//            self.delegate?.mapDidDismissSelection(byUser: true)
//            
//            self.lastMapZoom = mapView.zoomLevel
//            
//        }
//    
//    }
//
//    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
//
//        if (isSelecting || annotation is MGLUserLocation) {
//            return
////        } else if annotation.isClusterAnnotation {
////            
////            let nonClusteredAnnotations = getAnnotationsInCluster(annotation)
////            let southWestAndNorthEast = getSouthWestAndNorthEastFromAnnotations(nonClusteredAnnotations, centerCoordinate: annotation.coordinate)
////            let southWest = southWestAndNorthEast.0
////            let northEast = southWestAndNorthEast.1
////            
////            if southWest.latitude == northEast.latitude
////                && southWest.longitude == northEast.longitude {
////                    self.mapView.zoomInToNextNativeZoomAt(annotation.position, animated: true)
////            } else {
////                self.mapView.zoomWithLatitudeLongitudeBoundsSouthWest(southWest, northEast: northEast, animated: true)
////            }
////            return
//        }
//        
//        isSelecting = true
//        shouldCancelTap = true
//        
//        removeSelectedAnnotationIfExists()
//        
//        if annotation is UserInfo {
//
//            var userInfo = (annotation as! UserInfo).userInfo
//            
//            let type: String = userInfo["type"] as? String ?? ""
//            
//            if type == "line" || type == "button" {
//                
//                let spot = userInfo["spot"] as! ParkingSpot
//                
//                let foundAnnotations = findAnnotations(spot.identifier)
//                for annotation in foundAnnotations {
//                    self.mapView.removeAnnotation(annotation as! MGLAnnotation)
//                }
//                
//                addSpotAnnotation(spot, selected: true)
//                
//                spot.selectedButtonLocation = annotation.coordinate
//                spot.json["selectedButtonLocation"].dictionaryObject = ["lat" : annotation.coordinate.latitude, "long" : annotation.coordinate.longitude]
//                selectedObject = spot
//                
//                self.delegate?.didSelectObject(selectedObject as! ParkingSpot)
//                
//            } else if type == "lot" {
//                
//                let lot = userInfo["lot"] as! Lot
//                
//                let foundAnnotations = findAnnotations(lot.identifier)
//                for annotation in foundAnnotations {
//                    self.mapView.removeAnnotation(annotation as! MGLAnnotation)
//                }
//                
//                annotationForLot(lot, selected: true, addToMapView: true, animate: false)
//                selectedObject = lot
//                
//                self.delegate?.didSelectObject(selectedObject as! Lot)
//                
//            } else if (type == "searchResult") {
//                // do nothing for the time being
//                //            var result = userInfo!["spot"] as! ParkingSpot?
//            } else if type == "carsharing" {
//                let newAnnotation = GenericMGLAnnotation(coordinate: annotation.coordinate, title: "", subtitle: nil)
//                newAnnotation.userInfo = ["type": "carsharing", "selected": true, "carshare": (userInfo["carshare"] as! CarShare)]
//                annotations.append(newAnnotation)
//                self.mapView.addAnnotation(newAnnotation)
//                self.mapView.selectAnnotation(newAnnotation, animated: false)
//                self.annotations.remove(annotation as! GenericMGLAnnotation)
//                self.mapView.removeAnnotation(annotation)
//            }
//            
//        }
//        isSelecting = false
//        
//    }
//    func mapView(mapView: MGLMapView, didDeselectAnnotation annotation: MGLAnnotation) {
//        
//        if annotation is MGLUserLocation || isSelecting {//|| annotation.isClusterAnnotation {
//            return
//        }
//        
//        shouldCancelTap = true
//        
//        if annotation is UserInfo {
//            
//            var userInfo = (annotation as! UserInfo).userInfo
//            let type: String = userInfo["type"] as? String ?? ""
//            if type == "line" || type == "button" || type == "lot" {
//                removeSelectedAnnotationIfExists()
//                shouldCancelTap = false
//            } else if (type == "searchResult") {
//                //then the callout was shown, so do nothing because it will dismiss on automatically
//            } else if type == "carsharing" {
//                let newAnnotation = GenericMGLAnnotation(coordinate: annotation.coordinate, title: "", subtitle: nil)
//                newAnnotation.userInfo = ["type": "carsharing", "selected": false, "carshare": (userInfo["carshare"] as! CarShare)]
//                annotations.append(newAnnotation)
//                self.mapView.addAnnotation(newAnnotation)
//                self.annotations.remove(annotation as! GenericMGLAnnotation)
//                self.mapView.removeAnnotation(annotation)
//            }
//        }
//    }
//    
//    func customDeselectAnnotation() {
//        removeSelectedAnnotationIfExists()
//        self.delegate?.mapDidDismissSelection(byUser: true)
//    }
//
//    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
//        //this will run too often, so only run it if we've changed by any significant amount
//        if let userCLLocation = userLocation?.location {
//            let differenceInMeters = lastUserLocation.distanceFromLocation(userCLLocation)
//            
//            if differenceInMeters > 50 //50 meters
//                && mapView.userTrackingMode == MGLUserTrackingMode.Follow {
//                    updateAnnotations()
//                    lastUserLocation = userCLLocation
//            }
//        }
//    }
//    
//    
//    
//    func singleTapOnMap(tapRec: UITapGestureRecognizer) {
//
//        let point = tapRec.locationInView(self.mapView)
//
//        if shouldCancelTap {
//            shouldCancelTap = false
//            return
//        }
//        
//        let before = NSDate().timeIntervalSince1970
//        
//        var minimumDistanceRadius: CGFloat = 40
//        
//        if self.mapMode == .Garage {
//            minimumDistanceRadius = 40
//        }
//        
//        var minimumDistance = CGFloat.infinity
//        var closestAnnotation: MGLAnnotation? = nil
//        let loopThroughLines = mapView.zoomLevel < 17.0
//        
//        //Only get the *real* visible annotations... mapView.visibleAnnotations gets more than just the ones on screen.
//        let tapRect = CGRect(x: point.x - (minimumDistanceRadius*Settings.screenScale)/2,
//            y: point.y - (minimumDistanceRadius*Settings.screenScale)/2,
//            width: minimumDistanceRadius*Settings.screenScale,
//            height: minimumDistanceRadius*Settings.screenScale)
//        
//        //note: on screen annotations are not just those contained within the bounding box, but also those that pass in it at some point (because we can be dealing with lines here!)
//        let onScreenAnnotations = self.annotations.filter({ (annotation) -> Bool in
//            let annotationPoint = self.mapView.convertCoordinate(annotation.coordinate, toPointToView: self.mapView)
//
//            return !(annotation is MGLUserLocation)
//                && !annotation.isKindOfClass(MGLPolygon)
////                && !annotation.isClusterAnnotation
//                && tapRect.contains(annotationPoint)
//        })
//        
//        for annotation: MGLAnnotation in onScreenAnnotations as! [MGLAnnotation] {
//            
//            if annotation is UserInfo {
//                var userInfo: [String:AnyObject]? = (annotation as! UserInfo).userInfo
//                let annotationType = userInfo!["type"] as! String
//                
//                if annotationType == "button" || annotationType == "searchResult" || annotationType == "lot" {
//                    
//                    let annotationPoint = self.mapView.convertCoordinate(annotation.coordinate, toPointToView: self.mapView)
//                    let distance = annotationPoint.distanceToPoint(point)
//                    
//                    if (distance < minimumDistance) {
//                        minimumDistance = distance
//                        closestAnnotation = annotation
//                    }
//                    
//                } else if loopThroughLines && annotationType == "line" {
//                    
//                    let spot = userInfo!["spot"] as! ParkingSpot
//                    let coordinates = spot.line.coordinates2D + spot.buttonLocations
//                    
//                    let distances = coordinates.map{(coordinate: CLLocationCoordinate2D) -> CGFloat in
//                        let annotationPoint = self.mapView.convertCoordinate(annotation.coordinate, toPointToView: self.mapView)
//                        let distance = annotationPoint.distanceToPoint(point)
//                        return distance
//                    }
//                    
//                    for distance in distances {
//                        if (distance < minimumDistance) {
//                            minimumDistance = distance
//                            closestAnnotation = annotation
//                        }
//                    }
//                    
//                }
//            }
//        }
//        
//        NSLog("Took %f ms to find the right annotation", Float((NSDate().timeIntervalSince1970 - before) * 1000))
//        
//        if (closestAnnotation != nil && minimumDistance < minimumDistanceRadius) {
//            mapView.selectAnnotation(closestAnnotation!, animated: true)
//        } else {
//            self.delegate?.mapDidTapIdly()
//            customDeselectAnnotation()
//        }
//        
//    }
//    
//    func mapView(mapView: MGLMapView, didFailToLocateUserWithError error: NSError) {
//        dontTrackUser()
//    }
//    
//    // MARK: Helper Methods
//    
//    override func didTapTrackUserButton () {
//        if self.mapView.userTrackingMode == MGLUserTrackingMode.Follow {
//            dontTrackUser()
//        } else {
//            trackUser()
//        }
//    }
//    
//    override func trackUser() {
//        if self.mapView.userTrackingMode != MGLUserTrackingMode.Follow {
//            self.delegate?.trackUserButton.setImage(UIImage(named:"btn_geo_on"), forState: UIControlState.Normal)
//            self.mapView.setZoomLevel(17, animated: false)
//            self.mapView.userTrackingMode = MGLUserTrackingMode.Follow
//        }
//    }
//    
//    override func dontTrackUser() {
//        self.delegate?.trackUserButton.setImage(UIImage(named:"btn_geo_off"), forState: UIControlState.Normal)
//        self.mapView.userTrackingMode = MGLUserTrackingMode.None
//    }
//    
//    override func updateAnnotations(completion: ((operationCompleted: Bool) -> Void)) {
//        
//        if (self.updateInProgress) {
//            print("Update already in progress, cancelled!")
//            completion(operationCompleted: false)
//            return
//        }
//        
//        self.updateInProgress = true
//        
//        self.removeMyCarMarker()
//        self.addMyCarMarker()
//        
//        if self.isFarAwayFromAvailableCities(self.mapView.centerCoordinate) {
//            
//            if self.canShowMapMessage {
//                self.delegate?.mapDidMoveFarAwayFromAvailableCities()
//            }
//            
//            self.updateInProgress = false
//            completion(operationCompleted: true)
//            
//        } else if self.mapView.zoomLevel >= 15.0
//            || (self.mapMode == .Garage && self.mapView.zoomLevel >= 14.0)
//            || (self.mapView.zoomLevel >= 13.0 && self.mapMode == .CarSharing && self.delegate?.carSharingMode() == .FindCar) {
//                
//                self.delegate?.showMapMessage("map_message_loading".localizedString, onlyIfPreviouslyShown: true, showCityPicker: false)
//                
//                var checkinTime = self.searchCheckinDate
//                var duration = self.searchDuration
//                
//                if (checkinTime == nil) {
//                    checkinTime = NSDate()
//                }
//                
//                if (duration == nil) {
//                    duration = self.delegate?.activeFilterDuration()
//                }
//                
//                let carsharing = self.delegate?.activeCarsharingPermit() ?? false
//                
//                let operationCompletion = { (objects: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void in
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        //only show the spinner if this map is active
//                        if let tabController = self.parentViewController as? TabController {
//                            if tabController.activeTab() == PrkTab.Here {
//                                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
//                                SVProgressHUD.show()
//                                //                            GiFHUD.show()
//                                
//                                if self.canShowMapMessage {
//                                    if underMaintenance {
//                                        self.delegate?.showMapMessage("map_message_under_maintenance".localizedString)
//                                    } else if error {
//                                        self.delegate?.showMapMessage("map_message_error".localizedString)
//                                    } else if outsideServiceArea {
//                                        self.delegate?.showMapMessage("map_message_outside_service_area".localizedString)
//                                    } else if objects.count == 0 {
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
//                        if let spots = objects as? [ParkingSpot] {
//                            //
//                            // spots that have left the screen need to be re-animated next time
//                            // therefore, we remove spots that have not been fetched this time around
//                            //
//                            let newSpotIDs = spots.map{(spot: ParkingSpot) -> String in spot.identifier}
//                            self.spotIDsDrawnOnMap = self.spotIDsDrawnOnMap.filter({ (spotID: String) -> Bool in
//                                newSpotIDs.contains(spotID)
//                            })
//                            self.lineSpotIDsDrawnOnMap = self.lineSpotIDsDrawnOnMap.filter({ (spotID: String) -> Bool in
//                                newSpotIDs.contains(spotID)
//                            })
//                            
//                            self.updateSpotAnnotations(spots, completion: completion)
//                        }
//                        
//                        if let lots = objects as? [Lot] {
//                            self.updateLotAnnotations(lots, completion: completion)
//                        }
//                        
//                        if let carShares = objects as? [CarShare] {
//                            self.updateCarShareAnnotations(carShares, completion: completion)
//                        }
//                        
//                        if let dualObjectsSpecialCase = objects as? [[NSObject]] {
//                            if dualObjectsSpecialCase.count == 2 {
//                                let carShareLots = dualObjectsSpecialCase[0] as? [CarShareLot] ?? []
//                                let spots = dualObjectsSpecialCase[1] as? [ParkingSpot] ?? []
//                                self.updateCarShareLotAnnotations(carShareLots, spots: spots, completion: completion)
//                            }
//                        }
//                        
//                    })
//                }
//                
//                switch(self.mapMode) {
//                case MapMode.CarSharing:
//                    if self.delegate?.carSharingMode() == .FindSpot {
//                        CarSharingOperations.getCarShareLots(location: self.mapView.centerCoordinate, radius: self.radius, completion: { (carShareLots, underMaintenance1, outsideServiceArea1, error1) -> Void in
//                            
//                            SpotOperations.findSpots(compact: true, location: self.mapView.centerCoordinate, radius: self.radius, duration: duration, checkinTime: checkinTime!, carsharing: carsharing, completion: { (spots, underMaintenance2, outsideServiceArea2, error2) -> Void in
//                                
//                                operationCompletion([carShareLots, spots], underMaintenance1 || underMaintenance2, outsideServiceArea1 || outsideServiceArea2, error2)
//                            })
//                            
//                        })
//                    } else {
//                        CarSharingOperations.getCarShares(location: self.mapView.centerCoordinate, radius: self.radius, completion: operationCompletion)
//                    }
//                    break
//                case MapMode.StreetParking:
//                    SpotOperations.findSpots(compact: true, location: self.mapView.centerCoordinate, radius: self.radius, duration: duration, checkinTime: checkinTime!, carsharing: carsharing, completion: operationCompletion)
//                    break
//                case MapMode.Garage:
////                  self.recolorLotPinsIfNeeded()
////                  if self.annotations.count > 0 {
////                      self.updateInProgress = false
////                      completion(operationCompleted: true)
////                  } else {
//                        LotOperations.sharedInstance.findLots(self.mapView.centerCoordinate, radius: self.radius, completion: operationCompletion)
////                  }
//                    break
//                    //            default:
//                    //                self.updateInProgress = false
//                    //                self.removeAnnotations()
//                    //                completion(operationCompleted: true)
//                    //                break
//                }
//                
//        } else {
//            
//            self.removeAnnotations()
//            
//            self.spotIDsDrawnOnMap = []
//            self.lineSpotIDsDrawnOnMap = []
//            
//            self.updateInProgress = false
//            
//            self.delegate?.showMapMessage("map_message_too_zoomed_out".localizedString)
//            
//            completion(operationCompleted: true)
//        }
//        
//        
//    }
//    
//    func spotAnnotations(spots: [ParkingSpot]) -> [AnyObject] {
//        
//        var tempLineAnnotations = [MGLLineParkingSpot]()
//        var tempButtonAnnotations = [GenericMGLAnnotation]()
//        
//        for spot in spots {
//            let selected = (self.selectedObject != nil && self.selectedObject?.identifier == spot.identifier)
//            let generatedAnnotations = annotationForSpot(spot, selected: selected, addToMapView: false)
//            tempLineAnnotations.append(generatedAnnotations.0)
//            let buttons = generatedAnnotations.1
//            tempButtonAnnotations += buttons
//            
//        }
//        
//        let tempAnnotations = (tempLineAnnotations as [AnyObject]) + (tempButtonAnnotations as [AnyObject])
//        return tempAnnotations
//    }
//
//    func updateSpotAnnotations(spots: [ParkingSpot], completion: ((operationCompleted: Bool) -> Void)) {
//        
//        let tempAnnotations = spotAnnotations(spots)
//        
//        dispatch_async(dispatch_get_main_queue(), {
//            
//            self.removeAnnotations()
//            
//            self.annotations = tempAnnotations
////            for annotation in self.annotations {
////                self.mapView.addAnnotation(annotation as! MGLAnnotation)
////            }
//            self.mapView.addAnnotations(self.annotations as! [MGLAnnotation])
//            
//            SVProgressHUD.dismiss()
//            self.updateInProgress = false
//            
//            completion(operationCompleted: true)
//            
//        })
//        
//    }
//
//    func addAnnotation(detailObject: DetailObject, selected: Bool, animate: Bool? = nil) {
//        if detailObject is ParkingSpot {
//            addSpotAnnotation(detailObject as! ParkingSpot, selected: selected)
//        } else if detailObject is Lot {
//            annotationForLot(detailObject as! Lot, selected: selected, addToMapView: true, animate: animate)
//        }
//    }
//
//    func addSpotAnnotation(spot: ParkingSpot, selected: Bool) {
//        annotationForSpot(spot, selected: selected, addToMapView: true)
//    }
//    
//    func annotationForSpot(spot: ParkingSpot, selected: Bool, addToMapView: Bool) -> (MGLLineParkingSpot, [GenericMGLAnnotation]) {
//        
//        var lineAnnotation: MGLLineParkingSpot
//        var invisibleButtonAnnotations = [GenericMGLAnnotation]()
//        var buttonAnnotations = [GenericMGLAnnotation]()
//        
//        let shouldAddAnimation = !self.spotIDsDrawnOnMap.contains(spot.identifier)
//        
//        let userInfo = ["type": "line", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimation]
//        var coordinates = spot.line.coordinates2D
//        
//        //create the proper polyline
//        lineAnnotation = MGLLineParkingSpot(coordinates: &coordinates, count: UInt(coordinates.count))
//        spot.userInfo = userInfo
//        lineAnnotation.parkingSpot = spot
//        
//        let invisibleButtonCoordinates = spot.line.coordinates2D + spot.buttonLocations
//        for coordinate in invisibleButtonCoordinates {
//            let shouldAddAnimationForButton = !self.spotIDsDrawnOnMap.contains(spot.identifier)
//            let centerButton = GenericMGLAnnotation(coordinate: coordinate, title: spot.identifier)
//            centerButton.userInfo = ["type": "button", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimationForButton, "invisible": true]
//            invisibleButtonAnnotations.append(centerButton)
//        }
//        
//        if addToMapView {
//            self.mapView.addAnnotations(invisibleButtonAnnotations)
//            self.annotations += invisibleButtonAnnotations as [AnyObject]
//
//            self.mapView.addAnnotation(lineAnnotation)
//            annotations.append(lineAnnotation)
//        }
//
//        if (mapView.zoomLevel >= 17.0) {
//
//            for coordinate in spot.buttonLocations {
//                let shouldAddAnimationForButton = !self.spotIDsDrawnOnMap.contains(spot.identifier)
//                let centerButton = GenericMGLAnnotation(coordinate: coordinate, title: spot.identifier)
//                centerButton.userInfo = ["type": "button", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimationForButton]
//                buttonAnnotations.append(centerButton)
//            }
//            
//            if addToMapView {
//                self.mapView.addAnnotations(buttonAnnotations)
//                self.annotations += buttonAnnotations as [AnyObject]
//            }
//
//        }
//        
//        return (lineAnnotation, buttonAnnotations+invisibleButtonAnnotations)
//    }
//    
//    func updateLotAnnotations(lots: [Lot], completion: ((operationCompleted: Bool) -> Void)) {
//
//        var tempAnnotations = [MGLAnnotation]()
//
//        for lot in lots {
//            let selected = (self.selectedObject != nil && self.selectedObject?.identifier == String(lot.identifier))
//            let generatedAnnotations = annotationForLot(lot, selected: selected, addToMapView: false)
//            tempAnnotations.append(generatedAnnotations)
//
//        }
//
//        dispatch_async(dispatch_get_main_queue(), {
//
//            self.removeAnnotations()
//
//            self.annotations = tempAnnotations
//
//            self.mapView.addAnnotations(self.annotations as! [MGLAnnotation])
//
//            SVProgressHUD.dismiss()
//            self.updateInProgress = false
//
//            completion(operationCompleted: true)
//
//        })
//
//    }
//
//    func updateCarShareAnnotations(carShares: [CarShare], completion: ((operationCompleted: Bool) -> Void)) {
//
//        var tempAnnotations = [MGLAnnotation]()
//
//        for carShare in carShares {
//            let shouldAddAnimation = !self.spotIDsDrawnOnMap.contains(carShare.identifier)
//            let annotation = GenericMGLAnnotation(coordinate: carShare.coordinate, title: "", subtitle: nil)
//            annotation.userInfo = ["type": "carsharing", "selected": false, "carshare": carShare, "shouldAddAnimation" : shouldAddAnimation]
//            tempAnnotations.append(annotation)
//        }
//
//        dispatch_async(dispatch_get_main_queue(), {
//
//            self.removeAnnotations()
//
//            self.annotations = tempAnnotations
//
//            self.mapView.addAnnotations(self.annotations as! [MGLAnnotation])
//
//            SVProgressHUD.dismiss()
//            self.updateInProgress = false
//
//            completion(operationCompleted: true)
//
//        })
//
//    }
//
//    func updateCarShareLotAnnotations(carShareLots: [CarShareLot], spots: [ParkingSpot], completion: ((operationCompleted: Bool) -> Void)) {
//
//        var tempAnnotations = [AnyObject]()
//
//        for carShareLot in carShareLots {
//            let shouldAddAnimation = !self.spotIDsDrawnOnMap.contains(carShareLot.identifier)
//            let annotation = GenericMGLAnnotation(coordinate: carShareLot.coordinate, title: "", subtitle: nil)
//            annotation.userInfo = ["type": "carsharinglot", "carsharelot": carShareLot, "shouldAddAnimation" : shouldAddAnimation]
//            tempAnnotations.append(annotation)
//        }
//
//        tempAnnotations += spotAnnotations(spots)
//
//        dispatch_async(dispatch_get_main_queue(), {
//
//            self.removeAnnotations()
//
//            self.annotations = tempAnnotations
//
//            self.mapView.addAnnotations(self.annotations as! [MGLAnnotation])
//
//            SVProgressHUD.dismiss()
//            self.updateInProgress = false
//
//            completion(operationCompleted: true)
//
//        })
//
//    }
//
//    func zoomIntoClosestPins(numberOfPins: Int) {
//        //order annotations by distance from map center
//        let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
//        let orderedAnnotations = (self.annotations as! [MGLAnnotation]).sort { (first, second) -> Bool in
//            let firstLocation = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
//            let secondLocation = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
//            return mapCenter.distanceFromLocation(firstLocation) < mapCenter.distanceFromLocation(secondLocation)
//        }
//
//        var annotationsToZoom = [MGLAnnotation]()
//        let newNumberOfPins = orderedAnnotations.count < numberOfPins ? orderedAnnotations.count : numberOfPins
//        for i in 0..<newNumberOfPins {
//            annotationsToZoom.append(orderedAnnotations[i])
//        }
//
////        let southWestAndNorthEast = getSouthWestAndNorthEastFromAnnotations(annotationsToZoom, centerCoordinate: mapCenter.coordinate)
////        let southWest = southWestAndNorthEast.0
////        let northEast = southWestAndNorthEast.1
//
//        self.mapView.showAnnotations(annotationsToZoom, animated: true)
//    }
//
//    func getSouthWestAndNorthEastFromAnnotations(annots: [MGLAnnotation], centerCoordinate: CLLocationCoordinate2D) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
//
//        //determine the southwest and northeast coordinates!
//        var southWest = centerCoordinate
//        var northEast = centerCoordinate
//
//        for annotation in annots {
//            let lat = annotation.coordinate.latitude
//            let long = annotation.coordinate.longitude
//
//            if southWest.latitude > fabs(lat) { southWest.latitude = lat }
//            if southWest.longitude > fabs(long) { southWest.longitude = long }
//
//            if northEast.latitude < fabs(lat) { northEast.latitude = lat }
//            if northEast.longitude < fabs(long) { northEast.longitude = long }
//        }
//
//        //add some padding to the coordinates
//        let latDelta = abs(southWest.latitude - northEast.latitude) / 2
//        let longDelta = abs(southWest.longitude - northEast.longitude) / 2
//        southWest.latitude -= latDelta
//        southWest.longitude -= longDelta
//        northEast.latitude += latDelta
//        northEast.longitude += longDelta
//
//        return (southWest, northEast)
//    }
//
//    func annotationForLot(lot: Lot, selected: Bool, addToMapView: Bool, animate: Bool? = nil) -> MGLAnnotation {
//
//        let shouldAddAnimation = animate ?? !self.spotIDsDrawnOnMap.contains(lot.identifier)
//        let annotation = GenericMGLAnnotation(coordinate: lot.coordinate, title: String(lot.identifier), subtitle: nil)
//        annotation.userInfo = ["type": "lot", "lot": lot, "selected": selected, "cheaper": lot.isCheaper, "shouldAddAnimation": shouldAddAnimation]
//
//        if addToMapView {
//            mapView.addAnnotation(annotation)
//            annotations.append(annotation)
//        }
//        
//        return annotation
//        
//    }
//
//    
//    func addSearchResultMarker(searchResult: SearchResult) {
//        
//        let annotation = GenericMGLAnnotation(coordinate: searchResult.location.coordinate, title: "", subtitle: nil)
//        annotation.userInfo = ["type": "searchResult", "searchresult": searchResult]
//        mapView.addAnnotation(annotation)
//        searchAnnotations.append(annotation)
//    }
//    
//    
//    func findAnnotations(identifier: String) -> [AnyObject] {
//        
//        var foundAnnotations = [AnyObject]()
//        
//        for annotation in annotations {
//            
//            var userInfo: [String:AnyObject]? = annotation.userInfo
//            
//            if let spot = userInfo!["spot"] as? ParkingSpot {
//                
//                if spot.identifier == identifier {
//                    foundAnnotations.append(annotation)
//                }
//            } else if let lot = userInfo!["lot"] as? Lot {
//                
//                if lot.identifier == identifier {
//                    foundAnnotations.append(annotation)
//                }
//            }
//        }
//        
//        return foundAnnotations
//        
//    }
//
//    
//    
//    override func addCityOverlaysCallback(polygons: [MKPolygon]) {
//        //TODO
//        let interiorPolygons = MKPolygon.interiorPolygons(polygons)
//        let invertedPolygon = MKPolygon.invertPolygons(polygons)
////        mapView.addAnnotation(invertedPolygon.toMGLPolygon())
//        mapView.addAnnotations(MKPolygon.toMGLPolygons(interiorPolygons))
////        mapView.addAnnotations(MKPolygon.toMGLPolygons(polygons))
//    }
//    
//    // MARK: SpotDetailViewDelegate
//    
//    override func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) {
//        
//        mapView.zoomLevel = 17
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
//        mapView.centerCoordinate = results[0].location.coordinate
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
//        mapView.removeAnnotations(self.searchAnnotations)
//    }
//    
//    override func showUserLocation(shouldShow: Bool) {
//        self.mapView.showsUserLocation = shouldShow
//    }
//    
//    override func setMapUserMode(mode: MapUserMode) {
//        self.mapView.userTrackingMode = mode == MapUserMode.Follow ? MGLUserTrackingMode.Follow : MGLUserTrackingMode.None
//        Settings.setMapUserMode(mode)
//    }
//    
//    
//    override func addMyCarMarker() {
//        if let spot = Settings.checkedInSpot() {
//            let coordinate = spot.selectedButtonLocation ?? spot.buttonLocations.first!
//            let name = spot.name
//            let annotation = GenericMGLAnnotation(coordinate: coordinate, title: name, subtitle: nil)
//            annotation.userInfo = ["type": "previousCheckin"]
//            myCarAnnotation = annotation
//            self.mapView.addAnnotation(annotation)
//        }
//    }
//    
//    override func removeMyCarMarker() {
//        if myCarAnnotation != nil {
//            self.mapView.removeAnnotation(myCarAnnotation as! UserInfo)
//            myCarAnnotation = nil
//        }
//    }
//    
//    override func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, withZoom zoom:Float? = nil, showing: Bool = true) {
//        let annotation = GenericMGLAnnotation(coordinate: coordinate, title: name, subtitle: nil)
//        annotation.userInfo = ["type": "previousCheckin"]
//        mapView.zoomLevel = Double(zoom ?? 17)
//        mapView.centerCoordinate = coordinate
//        removeAllAnnotations()
//        if showing {
//            searchAnnotations.append(annotation)
//            self.mapView.addAnnotation(annotation)
//        }
//    }
//    
//    //note: mapbox gl calls deselect annotation when we remove an annotaion, so the order in which we execute the operations here matters.
//    override func removeSelectedAnnotationIfExists() {
//        if (selectedObject != nil) {
//            let foundAnnotations = findAnnotations(selectedObject!.identifier)
//            addAnnotation(selectedObject!, selected: false, animate: false)
//            selectedObject = nil
//            for annotation in foundAnnotations {
//                self.mapView.removeAnnotation(annotation as! MGLAnnotation)
//            }
//        }
//    }
//    
//    override func mapModeDidChange(completion: (() -> Void)) {
//        updateAnnotations({ (operationCompleted: Bool) -> Void in
//            completion()
//            if self.mapMode == .Garage {
//                self.zoomIntoClosestPins(5)
//            }
//        })
//    }
//    
//    override func removeRegularAnnotations() {
//        self.removeAnnotations()
//    }
//    
//    func removeAllAnnotations() {
//        mapView.removeAnnotations(self.annotations as! [MGLAnnotation])
//        mapView.removeAnnotations(self.searchAnnotations)
//        searchAnnotations = []
//        annotations = []
//        removeMyCarMarker()
//        addMyCarMarker()
//    }
//    
//    func removeAnnotations() {
//
//        for annotation in self.annotations {
//            self.mapView.removeAnnotation(annotation as! MGLAnnotation)
//        }
//        annotations = []
//    }
//    
//    func recolorLotPinsIfNeeded() {
//        if self.mapMode == .Garage {
//            
//            if self.annotations.count == 0 {
//                return
//            }
//            
//            recoloringLotPins = true
//            
//            //in 150 ms if we haven't finished the operation, show a loader
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
//                Int64(150 * Double(NSEC_PER_MSEC)))
//            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
//                if self.recoloringLotPins {
//                    SVProgressHUD.show()
//                }
//            })
//            
//            let before = NSDate().timeIntervalSince1970
//            
//            //Only get the *real* visible annotations... mapView.visibleAnnotations gets more than just the ones on screen.
//            let visibleLotAnnotations = self.annotations.filter({ (annotation) -> Bool in
//                let annotationPoint = self.mapView.convertCoordinate(annotation.coordinate, toPointToView: self.mapView)
//                if self.mapView.bounds.contains(annotationPoint) {
//                    let userInfo = (annotation as! UserInfo).userInfo
//                    return userInfo["type"] as? String == "lot" && userInfo["selected"] as? Bool == false
//                }
//                return false
//            })
//            
//            NSLog("\n\ngetting proper visible lot annotations took %f milliseconds", Float((NSDate().timeIntervalSince1970 - before) * 1000))
//            
//            let changedLotAnnotations = LotOperations.processCheapestLots(visibleLotAnnotations as? [GenericMGLAnnotation] ?? [])
//            self.mapView.removeAnnotations(changedLotAnnotations)
//            self.annotations.remove(changedLotAnnotations)
//            self.annotations += changedLotAnnotations as [AnyObject]
//            self.mapView.addAnnotations(changedLotAnnotations)
//            
//            NSLog("re-adding changed lots took %f milliseconds", Float((NSDate().timeIntervalSince1970 - before) * 1000))
//            
//            NSLog("Recolor took a total of %f milliseconds", Float((NSDate().timeIntervalSince1970 - before) * 1000))
//            
//            SVProgressHUD.dismiss()
//            recoloringLotPins = false
//        }
//        
//    }
//
//    
//}
