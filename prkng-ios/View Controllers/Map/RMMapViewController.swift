//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 05/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Foundation

//class RMMapViewController: MapViewController {
//    
//}

class RMMapViewController: MapViewController, RMMapViewDelegate {
    
    let mapSource = "arnaudspuhler.l54pj66f"
        
    var mapView: RMMapView
    var userLastChangedMap: Double
    var lastMapZoom: Float
    var lastUserLocation: CLLocation
    var lastMapCenterCoordinate: CLLocationCoordinate2D
    var spotIDsDrawnOnMap: [String]
    var lineSpotIDsDrawnOnMap: [String]
    var annotations: [RMAnnotation]
    var searchAnnotations: [RMAnnotation]
    var selectedObject: DetailObject?
    var isSelecting: Bool
    var recoloringLotPins: Bool = false
    
    private(set) var MOVE_DELTA_PERCENTAGE : Double
    
    let ZOOM_DEFAULT: Float = 17.0
    let ZOOM_GENERAL_THRESHOLD: Float = 15.0
    let ZOOM_BUTTON_THRESHOLD: Float = 17.0
    let ZOOM_BIG_BUTTON_THRESHOLD: Float = 18.0
    let ZOOM_GARAGE_THRESHOLD: Float = 14.0
    let ZOOM_FIND_CAR_THRESHOLD: Float = 13.0
    
    var radius: Float {
        //get a corner of the map and calculate the meters from the center
        let center = self.mapView.centerProjectedPoint
        let topLeft = self.mapView.projectedOrigin
        let meters = RMEuclideanDistanceBetweenProjectedPoints(center, topLeft)
        return Float(meters)
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        if let source = RMMapboxSource(mapID: mapSource) {
            mapView = RMMapView(frame: CGRectMake(0, 0, 100, 100), andTilesource: source)
        } else {
            let offlineSourcePath = NSBundle.mainBundle().pathForResource("OfflineMap", ofType: "json")
            let offlineSource = RMMapboxSource(tileJSON: try? String(contentsOfFile: offlineSourcePath!, encoding: NSUTF8StringEncoding))
            mapView = RMMapView(frame: CGRectMake(0, 0, 100, 100), andTilesource: offlineSource)
        }
        
        mapView.tintColor = Styles.Colors.red2
        mapView.showLogoBug = false
        mapView.hideAttribution = true
        mapView.zoomingInPivotsAroundCenter = true
        mapView.zoom = ZOOM_DEFAULT
        mapView.maxZoom = 19
        mapView.minZoom = 9
        mapView.setCenterCoordinate(Settings.selectedCity().coordinate, animated: false)
        userLastChangedMap = 0
        lastMapZoom = 0
        lastUserLocation = CLLocation(latitude: 0, longitude: 0)
        lastMapCenterCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        isSelecting = false
        spotIDsDrawnOnMap = []
        lineSpotIDsDrawnOnMap = []
        annotations = []
        searchAnnotations = []
        
        MOVE_DELTA_PERCENTAGE = 0.20 //20%
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(mapView)
        mapView.delegate = self
        
        self.showUserLocation(true)
        
        addCityOverlays()
        
        mapView.snp_makeConstraints {  (make) -> () in
            make.edges.equalTo(self.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trackUser()
        self.screenName = "Map - General MapBox View"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.removeSelectedAnnotationIfExists()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.canShowMapMessage = true
            self.updateAnnotations()
        }

        if (mapView.tileSource == nil) {
            if let source = RMMapboxSource(mapID: mapSource) {
                mapView.tileSource = source
            }
        }
    }
    
    override func showForFirstTime() {
        
        if !wasShown {
            if let checkIn = Settings.checkedInSpot() {
                let coordinate = checkIn.selectedButtonLocation ?? checkIn.buttonLocations.first!
                self.dontTrackUser()
                goToCoordinate(coordinate, named: "", withZoom: 16, showing: false)
            }
            
            wasShown = true

        }
    }
    
    func updateMapCenterIfNecessary () {
        
    }
    
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {
        
        if (annotation.isUserLocationAnnotation) {
            
            let marker = RMMarker(UIImage: UIImage(named: "cursor_you"))
            marker.canShowCallout = false
            return marker
        } else if annotation.isClusterAnnotation {
            let countString = NSMutableAttributedString(string: String(annotation.clusteredAnnotations.count), attributes: [NSFontAttributeName: Styles.FontFaces.regular(14)])
//            var size = CGSize(width: 115, height: 115)
//            if annotation.clusteredAnnotations.count >= 2 {
//                size = CGSize(width: 80, height: 80)
//            } else if annotation.clusteredAnnotations.count > 5 {
//                size = CGSize(width: 90, height: 90)
//            } else if annotation.clusteredAnnotations.count > 10 {
//                size = CGSize(width: 100, height: 100)
//            } else if annotation.clusteredAnnotations.count > 20 {
//                size = CGSize(width: 110, height: 110)
//            } else if annotation.clusteredAnnotations.count > 30 {
//                size = CGSize(width: 120, height: 120)
//            }
//            size = CGSize(width: size.width / Settings.screenScale, height: size.height / Settings.screenScale)
            var circleImage = UIImage(named: "pin_cluster")//?.resizeImage(size)
            circleImage = circleImage!.addText(countString, color: Styles.Colors.cream1)
            let marker = RMMarker(UIImage: circleImage)
            marker.canShowCallout = false
//            marker.opacity = 0.75
            marker.textForegroundColor = Styles.Colors.cream1
//            marker.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: size)

            let hash = self.getClusterCustomHashValue(annotation)
            if !spotIDsDrawnOnMap.contains(hash) {
                marker.addScaleAnimation()
                spotIDsDrawnOnMap.append(hash)
            }
            
            return marker
        }
        
        var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
        let annotationType = userInfo!["type"] as! String
        
        switch annotationType {
            
        case "line":
            
            let selected = userInfo!["selected"] as! Bool
            let spot = userInfo!["spot"] as! ParkingSpot
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            let isCurrentlyPaidSpot = spot.currentlyActiveRuleType == .Paid || spot.currentlyActiveRuleType == .PaidTimeMax
            let shape = RMShape(view: mapView)
            
            if selected {
                shape.lineColor = Styles.Colors.red2
            } else if isCurrentlyPaidSpot {
                shape.lineColor = Styles.Colors.curry
            } else {
                shape.lineColor = Styles.Colors.lineBlue
            }
            
            if mapView.zoom >= ZOOM_GENERAL_THRESHOLD && mapView.zoom < ZOOM_BUTTON_THRESHOLD {
                shape.lineWidth = 2.6
            } else {
                shape.lineWidth = 4.4
            }
            
            for location in spot.line.coordinates as Array<CLLocation> {
                shape.addLineToCoordinate(location.coordinate)
            }

            if shouldAddAnimation {
                shape.addScaleAnimation()
                lineSpotIDsDrawnOnMap.append(spot.identifier)
            }
            
            return shape
            
            
        case "button":

            let selected = userInfo!["selected"] as! Bool
            let spot = userInfo!["spot"] as! ParkingSpot
            let isCurrentlyPaidSpot = spot.currentlyActiveRuleType == .Paid || spot.currentlyActiveRuleType == .PaidTimeMax
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            
            var imageName = "button_line_"
            
            if mapView.zoom < ZOOM_BIG_BUTTON_THRESHOLD {
                imageName += "small_"
            }
            if isCurrentlyPaidSpot {
                imageName += "metered_"
            }
            if !selected {
                imageName += "in"
            }
            
            imageName += "active"
            
            let circleImage = UIImage(named: imageName)
            
            let circleMarker: RMMarker = RMMarker(UIImage: circleImage)
            
            if shouldAddAnimation {
                circleMarker.addScaleAnimation()
                spotIDsDrawnOnMap.append(spot.identifier)
            }
            
            if (selected) {
                let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
                pulseAnimation.duration = 0.7
                pulseAnimation.fromValue = 0.95
                pulseAnimation.toValue = 1.10
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = FLT_MAX
                circleMarker.addAnimation(pulseAnimation, forKey: nil)
            }

            return circleMarker

        case "lot":
            
            let selected = userInfo!["selected"] as! Bool
            let cheaper = userInfo!["cheaper"] as! Bool
            let lot = userInfo!["lot"] as! Lot
            let shouldAddFadeAnimation = userInfo!["fadeAnimation"] as? Bool ?? false
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool && !selected && !shouldAddFadeAnimation
            
            var imageName = "lot_pin_closed"
            var zPosition: CGFloat = 0 //this doesn't work!! See?
            
            if lot.isCurrentlyOpen {
                imageName = "lot_pin_open"
                zPosition = 50
                
                if cheaper && !selected {
                    imageName += "_cheaper"
                    zPosition = 100
                }
            }

            if selected {
                imageName += "_selected"
                zPosition = 150
            }
            
            let circleMarker: RMMarker = RMMarker(UIImage: lot.markerImageNamed(imageName), anchorPoint: CGPoint(x: 0.5, y: 1))
            
            if shouldAddAnimation {
                circleMarker.addScaleAnimation()
                spotIDsDrawnOnMap.append(lot.identifier)
            } else if shouldAddFadeAnimation {
                let fromImageName = imageName == "lot_pin_open" ? "lot_pin_open_cheaper" : "lot_pin_open"
                circleMarker.addCrossFadeAnimationFromImage(lot.markerImageNamed(fromImageName), toImage:lot.markerImageNamed(imageName))
            }
            
            circleMarker.zPosition = zPosition
            
            return circleMarker

        case "carsharing":
            
            let selected = userInfo!["selected"] as! Bool
            let carShare = userInfo!["carshare"] as! CarShare
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            let marker = RMMarker(UIImage: carShare.mapPinImageAndReuseIdentifier(selected).0, anchorPoint: CGPoint(x: 0.5, y: 1))
            let calloutView = carShare.calloutView()
            marker.leftCalloutAccessoryView = calloutView.0
            marker.rightCalloutAccessoryView = calloutView.1
            marker.canShowCallout = true
            if shouldAddAnimation {
                marker.addScaleAnimation()
                spotIDsDrawnOnMap.append(carShare.identifier)
            }
            return marker

        case "carsharinglot":
            
            let selected = userInfo!["selected"] as! Bool
            let carShareLot = userInfo!["carsharelot"] as! CarShareLot
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            let marker = RMMarker(UIImage: carShareLot.mapPinImageAndReuseIdentifier(selected).0, anchorPoint: CGPoint(x: 0.5, y: 1))
            let calloutView = carShareLot.calloutView()
            marker.leftCalloutAccessoryView = calloutView.0
            marker.rightCalloutAccessoryView = calloutView.1
            marker.canShowCallout = true
            if shouldAddAnimation {
                marker.addScaleAnimation()
                spotIDsDrawnOnMap.append(carShareLot.identifier)
            }
            return marker

        case "searchResult":
            
            let searchResult = userInfo!["searchresult"] as! SearchResult
            let marker = RMMarker(UIImage: UIImage(named: "pin_pointer_result"))
            let calloutView = searchResult.calloutView()
            marker.leftCalloutAccessoryView = calloutView.0
            marker.rightCalloutAccessoryView = calloutView.1
            marker.canShowCallout = true
            return marker
            
        case "previousCheckin":
            let marker = RMMarker(UIImage: UIImage(named: "pin_round_p")) //"Button_line_active"
            marker.canShowCallout = true
            return marker

            
        default:
            return nil
            
        }
    }
    
    func tapOnCalloutAccessoryControl(control: UIControl!, forAnnotation annotation: RMAnnotation!, onMap map: RMMapView!) {
        
        if let userInfo: [String:AnyObject] = annotation.userInfo as? [String:AnyObject] {
            if let annotationType = userInfo["type"] as? String {
                if annotationType == "searchResult" || annotationType == "carsharinglot" {
                    AnalyticsOperations.sendSearchQueryToAnalytics(annotation.title, navigate: true)
                    DirectionsAction.perform(onViewController: self, withCoordinate: annotation.coordinate, shouldCallback: true)
                } else if annotationType == "carsharing" {
                    if let carShare = userInfo["carshare"] as? CarShare {
                        if control.tag == 100 {
                            //reserve!
                            CarSharingOperations.reserveCarShare(carShare, fromVC: self, completion: { (didReserve) -> Void in
                                if didReserve {
                                    self.delegate?.loadMyCarTab()
                                }
                                SVProgressHUD.dismiss()
                                self.updateAnnotations()
                            })
                        } else if control.tag == 200 {
                            //cancel!
                            CarSharingOperations.cancelCarShare(carShare, fromVC: self, completion: { (completed) -> Void in
                                if completed {
                                    self.updateAnnotations()
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func getTimeSinceLastMapMovement() -> NSTimeInterval {
        let currentTime = NSDate().timeIntervalSince1970 * 1000
        let difference = currentTime - userLastChangedMap
        return difference
    }
    
    func beforeMapZoom(map: RMMapView!, byUser wasUserAction: Bool) {
    
        if wasUserAction {
            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
        }
    
    }
    
    func beforeMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        
        if wasUserAction {
            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
        }
        
        if (mapView.userTrackingMode.rawValue == RMUserTrackingModeFollow.rawValue) {
            self.trackUser()
        } else {
            self.dontTrackUser()
        }
        
    }
    
    func afterMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        
        if wasUserAction {
            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.16 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {

            self.removeSelectedAnnotationIfExists()
            
            //reload if the map has moved sufficiently...
            let lastMapCenterLocation = CLLocation(latitude: self.lastMapCenterCoordinate.latitude, longitude: self.lastMapCenterCoordinate.longitude)
            let newMapCenterLocation = CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)
            let differenceInMeters = lastMapCenterLocation.distanceFromLocation(newMapCenterLocation)
            let mapWidth = map.viewSizeToProjectedSize(map.bounds.size).width //this is the width of the current map in meters
            //        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
            if differenceInMeters/mapWidth > self.MOVE_DELTA_PERCENTAGE
                && self.getTimeSinceLastMapMovement() > 150 {
                    self.updateAnnotations()
                    self.lastMapCenterCoordinate = map.centerCoordinate
            }
            self.delegate?.mapDidDismissSelection(byUser: wasUserAction)
            
        }
        
    }
    
    func afterMapZoom(map: RMMapView!, byUser wasUserAction: Bool) {
        
//        if self.mapMode == .Garage {
//            map.clusteringEnabled = map.zoom <= 12
//        }
        
        if wasUserAction {
            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
        }

        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.16 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            if (abs(self.lastMapZoom - map.zoom) >= 1) {
                self.spotIDsDrawnOnMap = []
            }
            
            if self.getTimeSinceLastMapMovement() > 150 {
                self.updateAnnotations()
            }
            
            self.lastMapZoom = map.zoom
        }
        
        
    }
    
    func mapView(mapView: RMMapView!, didSelectAnnotation annotation: RMAnnotation!) {

        if (isSelecting || annotation.isUserLocationAnnotation) {
            return
        } else if annotation.isClusterAnnotation {
            
            let nonClusteredAnnotations = getAnnotationsInCluster(annotation)
            let southWestAndNorthEast = getSouthWestAndNorthEastFromAnnotations(nonClusteredAnnotations, centerCoordinate: annotation.coordinate)
            let southWest = southWestAndNorthEast.0
            let northEast = southWestAndNorthEast.1
            
            if southWest.latitude == northEast.latitude
                && southWest.longitude == northEast.longitude {
                    self.mapView.zoomInToNextNativeZoomAt(annotation.position, animated: true)
            } else {
                self.mapView.zoomWithLatitudeLongitudeBoundsSouthWest(southWest, northEast: northEast, animated: true)
            }
            return
        }
        
        isSelecting = true
        shouldCancelTap = true
        
        removeSelectedAnnotationIfExists()
        
        var userInfo: [String:AnyObject] = (annotation as RMAnnotation).userInfo as? [String:AnyObject] ?? [String:AnyObject]()
        
        let type: String = userInfo["type"] as? String ?? ""
        
        if type == "line" || type == "button" {
            
            let spot = userInfo["spot"] as! ParkingSpot
            
            let foundAnnotations = findAnnotations(spot.identifier)
            removeAnnotations(foundAnnotations)
            addSpotAnnotation(spot, selected: true)
            
            spot.selectedButtonLocation = annotation.coordinate
            spot.json["selectedButtonLocation"].dictionaryObject = ["lat" : annotation.coordinate.latitude, "long" : annotation.coordinate.longitude]
            selectedObject = spot

            self.delegate?.didSelectObject(selectedObject as! ParkingSpot)
            
        } else if type == "lot" {
            
            let lot = userInfo["lot"] as! Lot
            
            let foundAnnotations = findAnnotations(lot.identifier)
            removeAnnotations(foundAnnotations)
            annotationForLot(lot, selected: true, addToMapView: true, animate: false)
            selectedObject = lot
            
            self.delegate?.didSelectObject(selectedObject as! Lot)

        } else if (type == "searchResult") {
            // do nothing for the time being
//            var result = userInfo!["spot"] as! ParkingSpot?
        } else if type == "carsharing" {
            userInfo["selected"] = true
            annotation.userInfo = userInfo
            let carShare = userInfo["carshare"] as! CarShare
            (annotation.layer as? RMMarker)?.replaceUIImage(carShare.mapPinImageAndReuseIdentifier(true).0, anchorPoint: CGPoint(x: 0.5, y: 1))
        } else if type == "carsharinglot" {
            userInfo["selected"] = true
            annotation.userInfo = userInfo
            let carShareLot = userInfo["carsharelot"] as! CarShareLot
            (annotation.layer as? RMMarker)?.replaceUIImage(carShareLot.mapPinImageAndReuseIdentifier(true).0, anchorPoint: CGPoint(x: 0.5, y: 1))
        }
        
        isSelecting = false

    }
    
    func mapView(mapView: RMMapView!, didDeselectAnnotation annotation: RMAnnotation!) {
        
        shouldCancelTap = true
        
        if annotation.isUserLocationAnnotation || annotation.isClusterAnnotation {
            return
        }
        
        var userInfo: [String:AnyObject] = (annotation as RMAnnotation).userInfo as? [String:AnyObject] ?? [String:AnyObject]()
        let type: String = userInfo["type"] as? String ?? ""
        if type == "line" || type == "button" || type == "lot" {
            removeSelectedAnnotationIfExists()
            shouldCancelTap = false
        } else if (type == "searchResult") {
            //then the callout was shown, so do nothing because it will dismiss on automatically
        } else if type == "carsharing" {
            userInfo["selected"] = false
            annotation.userInfo = userInfo
            let carShare = userInfo["carshare"] as! CarShare
            (annotation.layer as? RMMarker)?.replaceUIImage(carShare.mapPinImageAndReuseIdentifier(false).0, anchorPoint: CGPoint(x: 0.5, y: 1))
        } else if type == "carsharinglot" {
            userInfo["selected"] = false
            annotation.userInfo = userInfo
            let carShareLot = userInfo["carsharelot"] as! CarShareLot
            (annotation.layer as? RMMarker)?.replaceUIImage(carShareLot.mapPinImageAndReuseIdentifier(false).0, anchorPoint: CGPoint(x: 0.5, y: 1))
        }
        
    }
    
    func customDeselectAnnotation() {
        removeSelectedAnnotationIfExists()
        self.delegate?.mapDidDismissSelection(byUser: true)
    }
    
    func mapView(mapView: RMMapView!, didUpdateUserLocation userLocation: RMUserLocation!) {
        //this will run too often, so only run it if we've changed by any significant amount
        if let userCLLocation = userLocation.location {
            let differenceInMeters = lastUserLocation.distanceFromLocation(userCLLocation)
            
            if differenceInMeters > 50 //50 meters
                && mapView.userTrackingMode.rawValue == RMUserTrackingModeFollow.rawValue {
                updateAnnotations()
                lastUserLocation = userCLLocation
            }
        }
    }
    
    func singleTapOnMap(map: RMMapView!, at point: CGPoint) {

        if shouldCancelTap {
            shouldCancelTap = false
            return
        }
        
        if let selected = self.mapView.selectedAnnotation {
            if selected.layer.frame.contains(point) {
                return
            }
        }

        let before = NSDate().timeIntervalSince1970

        var minimumDistanceRadius: CGFloat = 40

        if self.mapMode == .Garage {
            minimumDistanceRadius = 40
        }
        
        var minimumDistance = CGFloat.infinity
        var closestAnnotation: RMAnnotation? = nil
        let loopThroughLines = mapView.zoom < ZOOM_BUTTON_THRESHOLD
        
        //Only get the *real* visible annotations... mapView.visibleAnnotations gets more than just the ones on screen.
        let tapRect = CGRect(x: point.x - (minimumDistanceRadius*Settings.screenScale)/2,
            y: point.y - (minimumDistanceRadius*Settings.screenScale)/2,
            width: minimumDistanceRadius*Settings.screenScale,
            height: minimumDistanceRadius*Settings.screenScale)
        
        //note: on screen annotations are not just those contained within the bounding box, but also those that pass in it at some point (because we can be dealing with lines here!)
        let onScreenAnnotations = (self.mapView.visibleAnnotations as! [RMAnnotation]).filter({ (annotation) -> Bool in
            return !annotation.isUserLocationAnnotation
                && !annotation.isKindOfClass(RMPolygonAnnotation)
                && !annotation.isClusterAnnotation
                && annotation.isAnnotationWithinBounds(tapRect)
        })
        
        for annotation: RMAnnotation in onScreenAnnotations {
            
            if (annotation.isUserLocationAnnotation || annotation.isKindOfClass(RMPolygonAnnotation) || annotation.isClusterAnnotation) {
                continue
            }
            
            var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
            let annotationType = userInfo!["type"] as! String
            
            if annotationType == "button" || annotationType == "searchResult" || annotationType == "lot" {
                
                let annotationPoint = map.coordinateToPixel(annotation.coordinate)
                let distance = annotationPoint.distanceToPoint(point)
                
                if (distance < minimumDistance) {
                    minimumDistance = distance
                    closestAnnotation = annotation
                }
                
            } else if loopThroughLines && annotationType == "line" {
                
                let spot = userInfo!["spot"] as! ParkingSpot
                let coordinates = spot.line.coordinates2D + spot.buttonLocations
                
                let distances = coordinates.map{(coordinate: CLLocationCoordinate2D) -> CGFloat in
                    let annotationPoint = map.coordinateToPixel(coordinate)
                    let distance = annotationPoint.distanceToPoint(point)
                    return distance
                }
                
                for distance in distances {
                    if (distance < minimumDistance) {
                        minimumDistance = distance
                        closestAnnotation = annotation
                    }
                }
                
            }
        }
        
        NSLog("Took %f ms to find the right annotation", Float((NSDate().timeIntervalSince1970 - before) * 1000))
        
        if (closestAnnotation != nil && minimumDistance < minimumDistanceRadius) {
            mapView.selectAnnotation(closestAnnotation, animated: true)
        } else {
            self.delegate?.mapDidTapIdly()
            customDeselectAnnotation()
        }

    }
    
    func mapView(mapView: RMMapView!, didFailToLocateUserWithError error: NSError!) {
        dontTrackUser()
    }
    
    // MARK: Helper Methods
    
    override func didTapTrackUserButton () {
        if self.mapView.userTrackingMode.rawValue == RMUserTrackingModeFollow.rawValue {
            dontTrackUser()
        } else {
            trackUser()
        }
    }
    
    override func trackUser() {
        if self.mapView.userTrackingMode.rawValue != RMUserTrackingModeFollow.rawValue {
            self.delegate?.trackUserButton.setImage(UIImage(named:"btn_geo_on"), forState: UIControlState.Normal)
            self.mapView.setZoom(ZOOM_DEFAULT, animated: false)
            self.mapView.userTrackingMode = RMUserTrackingModeFollow
        }
    }
    
    override func dontTrackUser() {
        self.delegate?.trackUserButton.setImage(UIImage(named:"btn_geo_off"), forState: UIControlState.Normal)
        self.mapView.userTrackingMode = RMUserTrackingModeNone
    }
    
    func getAnnotationsInCluster(cluster: RMAnnotation) -> [RMAnnotation] {
        
        var nonClusteredAnnotations = [RMAnnotation]()
        for subAnnotation in cluster.clusteredAnnotations as! [RMAnnotation] {
            if subAnnotation.isClusterAnnotation {
                nonClusteredAnnotations += getAnnotationsInCluster(subAnnotation)
            } else {
                nonClusteredAnnotations.append(subAnnotation)
            }
        }
        return nonClusteredAnnotations
    }
    
    func getClusterCustomHashValue(cluster: RMAnnotation) -> String {
        var hash = ""
        var annotations = getAnnotationsInCluster(cluster)
        annotations.sortInPlace { (left, right) -> Bool in
            return left.title < right.title
        }
        for annotation in getAnnotationsInCluster(cluster) {
            hash += annotation.title
        }
        return hash
    }
    
//    override func didSetMapMode() {
//        switch (self.mapMode) {
//        case .Garage:
//            self.mapView.clusteringEnabled = self.mapView.zoom <= 12
//            break
//        default:
//            self.mapView.clusteringEnabled = false
//            break
//        }
//    }
    
    override func updateAnnotations(completion: ((operationCompleted: Bool) -> Void)) {
                
        if (self.updateInProgress) {
            print("Update already in progress, cancelled!")
            completion(operationCompleted: false)
            return
        }
        
        self.updateInProgress = true
        
        self.removeMyCarMarker()
        self.addMyCarMarker()
        
        if self.isFarAwayFromAvailableCities(self.mapView.centerCoordinate) {
            
            if self.canShowMapMessage {
                self.delegate?.mapDidMoveFarAwayFromAvailableCities()
            }
            
            self.updateInProgress = false
            completion(operationCompleted: true)
            
        } else if self.mapView.zoom >= ZOOM_GENERAL_THRESHOLD
            || (self.mapMode == .Garage && self.mapView.zoom >= ZOOM_GARAGE_THRESHOLD)
            || (self.mapView.zoom >= ZOOM_FIND_CAR_THRESHOLD && self.mapMode == .CarSharing && self.delegate?.carSharingMode() == .FindCar) {
            
            self.delegate?.showMapMessage("map_message_loading".localizedString, onlyIfPreviouslyShown: true, showCityPicker: false)
            
            var checkinTime = self.searchCheckinDate
            var duration = self.searchDuration
            
            if (checkinTime == nil) {
                checkinTime = NSDate()
            }
            
            if (duration == nil) {
                duration = self.delegate?.activeFilterDuration()
            }
            
            let carsharing = self.delegate?.activeCarsharingPermit() ?? false
            
            let operationCompletion = { (objects: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //only show the spinner if this map is active
                    if let tabController = self.parentViewController as? TabController {
                        if tabController.activeTab() == PrkTab.Here {
                            SVProgressHUD.setBackgroundColor(UIColor.clearColor())
                            //if after 100 msec we haven't already finished the operation, show the loader
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(100 * Double(NSEC_PER_MSEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                                if self.updateInProgress {
                                    SVProgressHUD.show()
//                                    GiFHUD.show()
                                }
                            })
                            
                            if self.canShowMapMessage {
                                if underMaintenance {
                                    self.delegate?.showMapMessage("map_message_under_maintenance".localizedString)
                                } else if error {
                                    self.delegate?.showMapMessage("map_message_error".localizedString)
                                } else if outsideServiceArea {
                                    self.delegate?.showMapMessage("map_message_outside_service_area".localizedString)
                                } else if objects.count == 0 {
                                    self.delegate?.showMapMessage("map_message_no_spots".localizedString)
                                } else {
                                    self.delegate?.showMapMessage(nil)
                                }
                            }
                        }
                    }
                })
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    
                    if let spots = objects as? [ParkingSpot] {
                        //
                        // spots that have left the screen need to be re-animated next time
                        // therefore, we remove spots that have not been fetched this time around
                        //
                        let newSpotIDs = spots.map{(spot: ParkingSpot) -> String in spot.identifier}
                        self.spotIDsDrawnOnMap = self.spotIDsDrawnOnMap.filter({ (spotID: String) -> Bool in
                            newSpotIDs.contains(spotID)
                        })
                        self.lineSpotIDsDrawnOnMap = self.lineSpotIDsDrawnOnMap.filter({ (spotID: String) -> Bool in
                            newSpotIDs.contains(spotID)
                        })
                        
                        self.updateSpotAnnotations(spots, completion: completion)
                    }
                    
                    if let lots = objects as? [Lot] {
                        self.updateLotAnnotations(lots, completion: completion)
                    }
                    
                    if let carShares = objects as? [CarShare] {
                        self.updateCarShareAnnotations(carShares, completion: completion)
                    }
                    
                    if let dualObjectsSpecialCase = objects as? [[NSObject]] {
                        if dualObjectsSpecialCase.count == 2 {
                            let carShareLots = dualObjectsSpecialCase[0] as? [CarShareLot] ?? []
                            let spots = dualObjectsSpecialCase[1] as? [ParkingSpot] ?? []
                            self.updateCarShareLotAnnotations(carShareLots, spots: spots, completion: completion)
                        }
                    }
                    
                })
            }
            
            switch(self.mapMode) {
            case MapMode.CarSharing:
                if self.delegate?.carSharingMode() == .FindSpot {
                    CarSharingOperations.getCarShareLots(location: self.mapView.centerCoordinate, radius: self.radius, completion: { (carShareLots, underMaintenance1, outsideServiceArea1, error1) -> Void in

                        SpotOperations.findSpots(compact: true, location: self.mapView.centerCoordinate, radius: self.radius, duration: duration, checkinTime: checkinTime!, carsharing: carsharing, completion: { (spots, underMaintenance2, outsideServiceArea2, error2) -> Void in
                            
                            operationCompletion([carShareLots, spots], underMaintenance1 || underMaintenance2, outsideServiceArea1 || outsideServiceArea2, error2)
                        })

                    })
                } else {
                    CarSharingOperations.getCarShares(location: self.mapView.centerCoordinate, radius: self.radius, completion: operationCompletion)
                }
                break
            case MapMode.StreetParking:
                SpotOperations.findSpots(compact: true, location: self.mapView.centerCoordinate, radius: self.radius, duration: duration, checkinTime: checkinTime!, carsharing: carsharing, completion: operationCompletion)
                break
            case MapMode.Garage:
//                self.recolorLotPinsIfNeeded()
//                if self.annotations.count > 0 {
//                    self.updateInProgress = false
//                    completion(operationCompleted: true)
//                } else {
                    LotOperations.sharedInstance.findLots(self.mapView.centerCoordinate, radius: self.radius, completion: operationCompletion)
//                }
                break
//            default:
//                self.updateInProgress = false
//                self.removeLinesAndButtons()
//                completion(operationCompleted: true)
//                break
            }
            
        } else {
            
            self.mapView.removeAnnotations(self.annotations)
            self.annotations = []
            
            self.spotIDsDrawnOnMap = []
            self.lineSpotIDsDrawnOnMap = []
            
            self.updateInProgress = false
            
            self.delegate?.showMapMessage("map_message_too_zoomed_out".localizedString)
            
            completion(operationCompleted: true)
        }
        
        
    }
    
    func spotAnnotations(spots: [ParkingSpot]) -> [RMAnnotation] {
        
        var tempAnnotations = [RMAnnotation]()
        
        for spot in spots {
            let selected = (self.selectedObject != nil && self.selectedObject?.identifier == spot.identifier)
            let generatedAnnotations = annotationForSpot(spot, selected: selected, addToMapView: false)
            tempAnnotations.append(generatedAnnotations.0)
            let buttons = generatedAnnotations.1
            tempAnnotations += buttons

        }

        return tempAnnotations
    }
    
    func updateSpotAnnotations(spots: [ParkingSpot], completion: ((operationCompleted: Bool) -> Void)) {
        
        let tempAnnotations = spotAnnotations(spots)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.removeLinesAndButtons()

            self.annotations = tempAnnotations

            self.mapView.addAnnotations(self.annotations)
            
            SVProgressHUD.dismiss()
            self.updateInProgress = false
            
            completion(operationCompleted: true)

        })

    }
    
    func addAnnotation(detailObject: DetailObject, selected: Bool, animate: Bool? = nil) {
        if detailObject is ParkingSpot {
            addSpotAnnotation(detailObject as! ParkingSpot, selected: selected)
        } else if detailObject is Lot {
            annotationForLot(detailObject as! Lot, selected: selected, addToMapView: true, animate: animate)
        }
    }
    
    func addSpotAnnotation(spot: ParkingSpot, selected: Bool) {
        annotationForSpot(spot, selected: selected, addToMapView: true)
    }
    
    func annotationForSpot(spot: ParkingSpot, selected: Bool, addToMapView: Bool) -> (RMAnnotation, [RMAnnotation]) {
        
        var annotation: RMAnnotation
        var centerButtons = [RMAnnotation]()
        
        let coordinate = spot.line.coordinates[0].coordinate
        let shouldAddAnimationForLine = !self.lineSpotIDsDrawnOnMap.contains(spot.identifier)
        annotation = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: spot.identifier)
        annotation.setBoundingBoxFromLocations(spot.line.coordinates)
        annotation.userInfo = ["type": "line", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimationForLine]
        
        if addToMapView {
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
        }
        
        if (mapView.zoom >= ZOOM_BUTTON_THRESHOLD) {
            
            for coordinate in spot.buttonLocations {
                let shouldAddAnimationForButton = !self.spotIDsDrawnOnMap.contains(spot.identifier)
                let centerButton = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: spot.identifier)
                centerButton!.setBoundingBoxFromLocations(spot.line.coordinates)
                centerButton!.userInfo = ["type": "button", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimationForButton]
                centerButtons.append(centerButton)
            }
            
            if addToMapView {
                mapView.addAnnotations(centerButtons)
                annotations += centerButtons
            }
            
        }
        
        return (annotation, centerButtons)
        
    }
    
    func updateLotAnnotations(lots: [Lot], completion: ((operationCompleted: Bool) -> Void)) {
        
        var tempAnnotations = [RMAnnotation]()
        
        for lot in lots {
            let selected = (self.selectedObject != nil && self.selectedObject?.identifier == String(lot.identifier))
            let generatedAnnotations = annotationForLot(lot, selected: selected, addToMapView: false)
            tempAnnotations.append(generatedAnnotations)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.removeLinesAndButtons()
            
            self.annotations = tempAnnotations
            
            self.mapView.addAnnotations(self.annotations)
            
            SVProgressHUD.dismiss()
            self.updateInProgress = false
            
            completion(operationCompleted: true)
            
        })
        
    }

    func annotationForCarShare(carShare: CarShare) -> RMAnnotation {
        let shouldAddAnimation = !self.spotIDsDrawnOnMap.contains(carShare.identifier)
        let annotation = RMAnnotation(mapView: self.mapView, coordinate: carShare.coordinate, andTitle: "")
        annotation.userInfo = ["type": "carsharing", "selected": false, "carshare": carShare, "shouldAddAnimation" : shouldAddAnimation]
        return annotation
    }
    
    func updateCarShareAnnotations(carShares: [CarShare], completion: ((operationCompleted: Bool) -> Void)) {
        
        var tempAnnotations = [RMAnnotation]()
        
        for carShare in carShares {
            let annotation = annotationForCarShare(carShare)
            tempAnnotations.append(annotation)
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.removeLinesAndButtons()
            
            self.annotations = tempAnnotations
            
            self.mapView.addAnnotations(self.annotations)
            
            SVProgressHUD.dismiss()
            self.updateInProgress = false
            
            completion(operationCompleted: true)
            
        })
        
    }

    func updateCarShareLotAnnotations(carShareLots: [CarShareLot], spots: [ParkingSpot], completion: ((operationCompleted: Bool) -> Void)) {
        
        var tempAnnotations = [RMAnnotation]()
        
        for carShareLot in carShareLots {
            let shouldAddAnimation = !self.spotIDsDrawnOnMap.contains(carShareLot.identifier)
            let annotation = RMAnnotation(mapView: self.mapView, coordinate: carShareLot.coordinate, andTitle: "")
            annotation.userInfo = ["type": "carsharinglot", "selected": false, "carsharelot": carShareLot, "shouldAddAnimation" : shouldAddAnimation]
            tempAnnotations.append(annotation)
        }
        
        tempAnnotations += spotAnnotations(spots)
            
        dispatch_async(dispatch_get_main_queue(), {
            
            self.removeLinesAndButtons()
            
            self.annotations = tempAnnotations
            
            self.mapView.addAnnotations(self.annotations)
            
            SVProgressHUD.dismiss()
            self.updateInProgress = false
            
            completion(operationCompleted: true)
            
        })
        
    }

    func zoomIntoClosestPins(numberOfPins: Int) {
        //order annotations by distance from map center
        let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let orderedAnnotations = self.annotations.sort { (first, second) -> Bool in
            let firstLocation = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
            let secondLocation = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
            return mapCenter.distanceFromLocation(firstLocation) < mapCenter.distanceFromLocation(secondLocation)
        }
        
        var annotationsToZoom = [RMAnnotation]()
        let newNumberOfPins = orderedAnnotations.count < numberOfPins ? orderedAnnotations.count : numberOfPins
        for i in 0..<newNumberOfPins {
            annotationsToZoom.append(orderedAnnotations[i])
        }
        
        let southWestAndNorthEast = getSouthWestAndNorthEastFromAnnotations(annotationsToZoom, centerCoordinate: mapCenter.coordinate)
        let southWest = southWestAndNorthEast.0
        let northEast = southWestAndNorthEast.1
            
        self.mapView.zoomWithLatitudeLongitudeBoundsSouthWest(southWest, northEast: northEast, animated: true)
    }
    
    func getSouthWestAndNorthEastFromAnnotations(annots: [RMAnnotation], centerCoordinate: CLLocationCoordinate2D) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        
        //determine the southwest and northeast coordinates!
        var southWest = centerCoordinate
        var northEast = centerCoordinate
        
        for annotation in annots {
            let lat = annotation.coordinate.latitude
            let long = annotation.coordinate.longitude
            
            if southWest.latitude > fabs(lat) { southWest.latitude = lat }
            if southWest.longitude > fabs(long) { southWest.longitude = long }
            
            if northEast.latitude < fabs(lat) { northEast.latitude = lat }
            if northEast.longitude < fabs(long) { northEast.longitude = long }
        }
        
        //add some padding to the coordinates
        let latDelta = abs(southWest.latitude - northEast.latitude) / 2
        let longDelta = abs(southWest.longitude - northEast.longitude) / 2
        southWest.latitude -= latDelta
        southWest.longitude -= longDelta
        northEast.latitude += latDelta
        northEast.longitude += longDelta

        return (southWest, northEast)
    }
    
    func annotationForLot(lot: Lot, selected: Bool, addToMapView: Bool, animate: Bool? = nil) -> RMAnnotation {
        
        let shouldAddAnimation = animate ?? !self.spotIDsDrawnOnMap.contains(lot.identifier)
        let annotation = RMAnnotation(mapView: self.mapView, coordinate: lot.coordinate, andTitle: String(lot.identifier))
        annotation.userInfo = ["type": "lot", "lot": lot, "selected": selected, "cheaper": lot.isCheaper, "shouldAddAnimation": shouldAddAnimation]
        
        if addToMapView {
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
        }
        
        return annotation
        
    }

    
    func addSearchResultMarker(searchResult: SearchResult) {
        
        let annotation: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: searchResult.location.coordinate, andTitle: "")
        annotation.userInfo = ["type": "searchResult", "searchresult": searchResult]
        mapView.addAnnotation(annotation)
        searchAnnotations.append(annotation)
    }
    
    
    func findAnnotations(identifier: String) -> Array<RMAnnotation> {
        
        var foundAnnotations = [RMAnnotation]()
        
        for annotation in annotations {
            
            var userInfo: [String:AnyObject]? = (annotation as RMAnnotation).userInfo as? [String:AnyObject]
            
            if let spot = userInfo!["spot"] as? ParkingSpot {
                
                if spot.identifier == identifier {
                    foundAnnotations.append(annotation)
                }
            } else if let lot = userInfo!["lot"] as? Lot {
                
                if lot.identifier == identifier {
                    foundAnnotations.append(annotation)
                }
            }
        }
        
        return foundAnnotations
    }
    
    
    func removeAnnotations(annotationsToRemove: Array<RMAnnotation>) {
        
        var tempAnnotations = [RMAnnotation]()
        
        for ann in annotations {
            
            var userInfo: [String:AnyObject]? = (ann as RMAnnotation).userInfo as? [String:AnyObject]
            if let spot = userInfo!["spot"] as? ParkingSpot {
                
                var found: Bool = false
                for delAnn in annotationsToRemove {
                    
                    var delUserInfo: [String:AnyObject]? = (delAnn as RMAnnotation).userInfo as? [String:AnyObject]
                    if let delSpot = delUserInfo!["spot"] as? ParkingSpot {
                        
                        if delSpot.identifier == spot.identifier {
                            found = true
                            break
                        }
                    }
                }
                
                if !found {
                    tempAnnotations.append(ann)
                }
                
            } else if let lot = userInfo!["lot"] as? Lot {
                
                var found: Bool = false
                for delAnn in annotationsToRemove {
                    
                    var delUserInfo: [String:AnyObject]? = (delAnn as RMAnnotation).userInfo as? [String:AnyObject]
                    if let delSpot = delUserInfo!["lot"] as? Lot {
                        
                        if delSpot.identifier == lot.identifier {
                            found = true
                            break
                        }
                    }
                }
                
                if !found {
                    tempAnnotations.append(ann)
                }
                
            }
            
        }

        self.annotations = tempAnnotations

        self.mapView.removeAnnotations(annotationsToRemove)
        
    }
    
    func removeLinesAndButtons() {

        self.mapView.removeAnnotations(self.annotations)
        annotations = []

    }
    
    func removeAllAnnotations() {
        
        searchAnnotations = []
        annotations = []
        self.mapView.removeAllAnnotations()
        addCityOverlays()
        addMyCarMarker()
    }
    
    func recolorLotPinsIfNeeded() {
        if self.mapMode == .Garage {
            
            recoloringLotPins = true
            
            //in 150 ms if we haven't finished the operation, show a loader
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(150 * Double(NSEC_PER_MSEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                if self.recoloringLotPins {
                    SVProgressHUD.show()
                }
            })

            let before = NSDate().timeIntervalSince1970
            
            //Only get the *real* visible annotations... mapView.visibleAnnotations gets more than just the ones on screen.
            let visibleLotAnnotations = (self.mapView.visibleAnnotations as! [RMAnnotation]).filter({ (annotation) -> Bool in
                if annotation.isAnnotationWithinBounds(self.mapView.bounds) {
                    if let userInfo = annotation.userInfo as? [String:AnyObject] {
                        return userInfo["type"] as? String == "lot" && userInfo["selected"] as? Bool == false
                    }
                }
                return false
            })
            
            NSLog("\n\ngetting proper visible lot annotations took %f milliseconds", Float((NSDate().timeIntervalSince1970 - before) * 1000))

            let changedLotAnnotations = LotOperations.processCheapestLots(visibleLotAnnotations)
            self.mapView.removeAnnotations(changedLotAnnotations)
            self.annotations.remove(changedLotAnnotations)
            self.annotations += changedLotAnnotations
            self.mapView.addAnnotations(changedLotAnnotations)
            
            NSLog("re-adding changed lots took %f milliseconds", Float((NSDate().timeIntervalSince1970 - before) * 1000))

            NSLog("Recolor took a total of %f milliseconds", Float((NSDate().timeIntervalSince1970 - before) * 1000))
            
            SVProgressHUD.dismiss()
            recoloringLotPins = false
        }
        
    }
    
    override func addCityOverlaysCallback(polygons: [MKPolygon]) {
        
        let polygonAnnotations = MKPolygon.polygonsToRMPolygonAnnotations(polygons, mapView: mapView)

        let worldCorners: [CLLocation] = [
            CLLocation(latitude: 85, longitude: -179),
            CLLocation(latitude: 85, longitude: 179),
            CLLocation(latitude: -85, longitude: 179),
            CLLocation(latitude: -85, longitude: -179),
            CLLocation(latitude: 85, longitude: -179)]
        let annotation = RMPolygonAnnotation(mapView: mapView, points: worldCorners, interiorPolygons: polygonAnnotations)
        annotation.userInfo = ["type": "polygon", "points": worldCorners, "interiorPolygons": polygonAnnotations]
        annotation.fillColor = Styles.Colors.beige1.colorWithAlphaComponent(0.7)
        annotation.lineColor = Styles.Colors.red1
        annotation.lineWidth = 4.0
        
        let allAnnotationsToAdd = [annotation]
        mapView.addAnnotations(allAnnotationsToAdd)
        
    }
    
    // MARK: SpotDetailViewDelegate
    
    override func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) {
        
        mapView.zoom = ZOOM_DEFAULT
        
        if (results.count == 0) {
            let alert = UIAlertView()
            alert.title = "No results found"
            alert.message = "We couldn't find anything matching the criteria"
            alert.addButtonWithTitle("Close")
            alert.show()
            return
        }
        
        mapView.centerCoordinate = results[0].location.coordinate

        removeAllAnnotations()
        
        for result in results {
            addSearchResultMarker(result)
        }
        
        self.searchCheckinDate = checkinTime
        
        updateAnnotations()
        
    }
    
    override func clearSearchResults() {
        mapView.removeAnnotations(self.searchAnnotations)
    }
    
    override func showUserLocation(shouldShow: Bool) {
        self.mapView.showsUserLocation = shouldShow
    }
    
    override func setMapUserMode(mode: MapUserMode) {
        self.mapView.userTrackingMode = mode == MapUserMode.Follow ? RMUserTrackingModeFollow : RMUserTrackingModeNone
        Settings.setMapUserMode(mode)
    }

    
    override func addMyCarMarker() {
        if let reservedCarShare = Settings.getReservedCarShare() {
            let annotation = annotationForCarShare(reservedCarShare)
            myCarAnnotation = annotation
            self.mapView.addAnnotation(annotation)
            return
        }
        if let spot = Settings.checkedInSpot() {
            let coordinate = spot.selectedButtonLocation ?? spot.buttonLocations.first!
            let name = spot.name
            let annotation = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: name)
            annotation.userInfo = ["type": "previousCheckin"]
            myCarAnnotation = annotation
            self.mapView.addAnnotation(annotation)
        }
    }
    
    override func removeMyCarMarker() {
        if myCarAnnotation != nil {
            self.mapView.removeAnnotation(myCarAnnotation as! RMAnnotation)
            myCarAnnotation = nil
        }
    }

    override func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, withZoom zoom:Float? = nil, showing: Bool = true) {
        let annotation = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: name)
        annotation.userInfo = ["type": "previousCheckin"]
        mapView.zoom = zoom ?? ZOOM_DEFAULT
        mapView.centerCoordinate = coordinate
        removeAllAnnotations()
        if showing {
            searchAnnotations.append(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }

    override func removeSelectedAnnotationIfExists() {
        if (selectedObject != nil) {
            removeAnnotations(findAnnotations(selectedObject!.identifier))
            addAnnotation(selectedObject!, selected: false, animate: false)
            selectedObject = nil
        }
    }

    override func mapModeDidChange(completion: (() -> Void)) {
        self.setDefaultMapZoom()
        updateAnnotations({ (operationCompleted: Bool) -> Void in
            completion()
        })
    }
    
    override func removeRegularAnnotations() {
        self.removeLinesAndButtons()
    }
    
    override func setDefaultMapZoom() {
        switch self.mapMode {
        case .Garage:
            self.mapView.setZoom(self.ZOOM_GARAGE_THRESHOLD, animated: true)
        case .StreetParking:
            self.mapView.setZoom(self.ZOOM_GENERAL_THRESHOLD, animated: true)
        case .CarSharing:
            switch self.delegate!.carSharingMode() {
            case .FindCar:
                self.mapView.setZoom(self.ZOOM_FIND_CAR_THRESHOLD, animated: true)
            case .FindSpot:
                self.mapView.setZoom(self.ZOOM_GENERAL_THRESHOLD, animated: true)
            case .None:
                break
            }

        }
    }

}

