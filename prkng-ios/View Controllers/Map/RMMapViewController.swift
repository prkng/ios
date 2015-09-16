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
    var radius : Float
    
    private(set) var MOVE_DELTA_IN_METERS : Double
    
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
        
        mapView.tintColor = Styles.Colors.red2
        mapView.showLogoBug = false
        mapView.hideAttribution = true
        mapView.zoomingInPivotsAroundCenter = true
        mapView.zoom = 17
        mapView.maxZoom = 19
        mapView.minZoom = 9
        userLastChangedMap = 0
        lastMapZoom = 0
        lastUserLocation = CLLocation(latitude: 0, longitude: 0)
        lastMapCenterCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        isSelecting = false
        spotIDsDrawnOnMap = []
        lineSpotIDsDrawnOnMap = []
        annotations = []
        searchAnnotations = []
        radius = 300
                
        MOVE_DELTA_IN_METERS = 100
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(mapView)
        mapView.delegate = self
        
        addCityOverlays()
        
        trackUserButton.backgroundColor = Styles.Colors.cream2
        trackUserButton.setImage(UIImage(named:"btn_geo_on"), forState: UIControlState.Normal)
        trackUserButton.addTarget(self, action: "trackUserButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(trackUserButton)
        
        mapView.snp_makeConstraints {  (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        trackUserButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.view).with.offset(-12)
            make.top.equalTo(self.view).with.offset(Styles.Sizes.statusBarHeight + 10)
            make.height.equalTo(SearchFilterView.FIELD_HEIGHT)
            make.width.equalTo(46)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.userTrackingMode = RMUserTrackingModeFollow
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
            
            var marker = RMMarker(UIImage: UIImage(named: "cursor_you"))
            marker.canShowCallout = false
            return marker
        } else if annotation.isClusterAnnotation {
            var countString = NSMutableAttributedString(string: String(annotation.clusteredAnnotations.count), attributes: [NSFontAttributeName: Styles.FontFaces.regular(14)])
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
            var marker = RMMarker(UIImage: circleImage)
            marker.canShowCallout = false
//            marker.opacity = 0.75
            marker.textForegroundColor = Styles.Colors.cream1
//            marker.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: size)

            let hash = self.getClusterCustomHashValue(annotation)
            if !contains(spotIDsDrawnOnMap, hash) {
                marker.addScaleAnimation()
                spotIDsDrawnOnMap.append(hash)
            }
            
            return marker
        }
        
        var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
        var annotationType = userInfo!["type"] as! String
        
        let addAnimation = annotationType
        
        switch annotationType {
            
        case "line":
            
            let selected = userInfo!["selected"] as! Bool
            let spot = userInfo!["spot"] as! ParkingSpot
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            let isCurrentlyPaidSpot = spot.currentlyActiveRule.ruleType == .Paid
            var shape = RMShape(view: mapView)
            
            if selected {
                shape.lineColor = Styles.Colors.red2
            } else if isCurrentlyPaidSpot {
                shape.lineColor = Styles.Colors.curry
            } else {
                shape.lineColor = Styles.Colors.lineBlue
            }
            
            if mapView.zoom >= 15.0 && mapView.zoom < 16.0 {
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
            let isCurrentlyPaidSpot = spot.currentlyActiveRule.ruleType == .Paid
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            
            var imageName = "button_line_"
            
            if mapView.zoom < 18 {
                imageName += "small_"
            }
            if isCurrentlyPaidSpot {
                imageName += "metered_"
            }
            if !selected {
                imageName += "in"
            }
            
            imageName += "active"
            
            var circleImage = UIImage(named: imageName)
            
            var circleMarker: RMMarker = RMMarker(UIImage: circleImage)
            
            if shouldAddAnimation {
                circleMarker.addScaleAnimation()
                spotIDsDrawnOnMap.append(spot.identifier)
            }
            
            if (selected) {
                var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
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
            let lot = userInfo!["lot"] as! Lot
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool && !selected
            
            var imageName = "lot_pin_closed"
            
            if lot.isCurrentlyOpen {
                imageName = "lot_pin_open"
            }

            if selected {
                imageName += "_selected"
            }
            
            var circleImage = UIImage(named: imageName)
            if lot.bottomLeftPrimaryText != nil && lot.bottomLeftPrimaryText!.string != "$0" {
                var currencyString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: Styles.FontFaces.regular(9), NSBaselineOffsetAttributeName: 3])
                var numberString = NSMutableAttributedString(string: String(Int(lot.mainRate)), attributes: [NSFontAttributeName: Styles.FontFaces.regular(14)])
                currencyString.appendAttributedString(numberString)
                circleImage = circleImage!.addText(currencyString, color: Styles.Colors.cream1, bottomOffset: 4.5)
            }
            
            var circleMarker: RMMarker = RMMarker(UIImage: circleImage, anchorPoint: CGPoint(x: 0.5, y: 1))
            
            if shouldAddAnimation {
                circleMarker.addScaleAnimation()
                spotIDsDrawnOnMap.append(lot.identifier)
            }
            
//            if (selected) {
//                var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
//                pulseAnimation.duration = 0.7
//                pulseAnimation.fromValue = 0.95
//                pulseAnimation.toValue = 1.10
//                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                pulseAnimation.autoreverses = true
//                pulseAnimation.repeatCount = FLT_MAX
//                circleMarker.addAnimation(pulseAnimation, forKey: nil)
//            }
            
            return circleMarker

        case "searchResult":
            
            let marker = RMMarker(UIImage: UIImage(named: "pin_pointer_result"))
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
        
        if (mapView.userTrackingMode.value == RMUserTrackingModeFollow.value) {
            self.trackUser()
        } else {
            if delegate?.shouldShowUserTrackingButton() ?? false {
                self.dontTrackUser()
            }
        }
        
    }
    
    func afterMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        
        if wasUserAction {
            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.31 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {

            self.removeSelectedAnnotationIfExists()
            
            //reload if the map has moved sufficiently...
            let lastMapCenterLocation = CLLocation(latitude: self.lastMapCenterCoordinate.latitude, longitude: self.lastMapCenterCoordinate.longitude)
            let newMapCenterLocation = CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)
            let differenceInMeters = lastMapCenterLocation.distanceFromLocation(newMapCenterLocation)
            //        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
            if differenceInMeters > self.MOVE_DELTA_IN_METERS
                && self.getTimeSinceLastMapMovement() > 300 {
                    self.updateAnnotations()
                    self.lastMapCenterCoordinate = map.centerCoordinate
            }
            self.delegate?.mapDidDismissSelection(byUser: wasUserAction)
            
        }
        
    }
    
    func afterMapZoom(map: RMMapView!, byUser wasUserAction: Bool) {
        
        if self.mapMode == .Garage {
//            map.clusteringEnabled = map.zoom <= 14
        }
        
        if wasUserAction {
            userLastChangedMap = NSDate().timeIntervalSince1970 * 1000
        }

        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.31 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            self.radius = (20.0 - map.zoom) * 100
            
            if(map.zoom < 15.0) {
                self.radius = 0
            }
            
            if (abs(self.lastMapZoom - map.zoom) >= 1) {
                self.spotIDsDrawnOnMap = []
            }
            
            if self.getTimeSinceLastMapMovement() > 300 {
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
        
        removeSelectedAnnotationIfExists()
        
        var userInfo: [String:AnyObject]? = (annotation as RMAnnotation).userInfo as? [String:AnyObject]
        
        var type: String = userInfo!["type"] as! String
        
        if type == "line" || type == "button" {
            
            var spot = userInfo!["spot"] as! ParkingSpot
            
            var foundAnnotations = findAnnotations(spot.identifier)
            removeAnnotations(foundAnnotations)
            addSpotAnnotation(spot, selected: true)
            
            spot.selectedButtonLocation = annotation.coordinate
            spot.json["selectedButtonLocation"].dictionaryObject = ["lat" : annotation.coordinate.latitude, "long" : annotation.coordinate.longitude]
            selectedObject = spot

            self.delegate?.didSelectObject(selectedObject as! ParkingSpot)
            
        } else if type == "lot" {
            
            var lot = userInfo!["lot"] as! Lot
            
            var foundAnnotations = findAnnotations(lot.identifier)
            removeAnnotations(foundAnnotations)
            annotationForLot(lot, selected: true, addToMapView: true, animate: false)
            selectedObject = lot
            
            self.delegate?.didSelectObject(selectedObject as! Lot)

        } else if (type == "searchResult") {
            
            var result = userInfo!["spot"] as! ParkingSpot?
            
            
        }
        
        isSelecting = false

    }
    
    func customDeselectAnnotation() {
        
        removeSelectedAnnotationIfExists()
        self.delegate?.mapDidDismissSelection(byUser: true)

    }
    
    func mapView(mapView: RMMapView!, didUpdateUserLocation userLocation: RMUserLocation!) {
        //this will run too often, so only run it if we've changed by any significant amount
        if let userCLLocation = userLocation.location {
            let differenceInMeters = lastUserLocation.distanceFromLocation(userCLLocation)
            
            if differenceInMeters > MOVE_DELTA_IN_METERS/10 * 5
                && mapView.userTrackingMode.value == RMUserTrackingModeFollow.value {
                updateAnnotations()
                lastUserLocation = userCLLocation
            }
        }
    }
    
    func singleTapOnMap(map: RMMapView!, at point: CGPoint) {
        
        if self.mapMode == .Garage {
            return
        }
        
        var minimumDistance = CGFloat(Float.infinity)
        var closestAnnotation : RMAnnotation? = nil
        var loopThroughLines = mapView.zoom < 17.0

        for annotation: RMAnnotation in map.visibleAnnotations as! [RMAnnotation] {
            
            if (annotation.isUserLocationAnnotation || annotation.isKindOfClass(RMPolygonAnnotation) || annotation.isClusterAnnotation) {
                continue
            }
            
            var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
            var annotationType = userInfo!["type"] as! String

            if annotationType == "button" || annotationType == "searchResult" || annotationType == "lot" {
            
                var annotationPoint = map.coordinateToPixel(annotation.coordinate)
                let distance = annotationPoint.distanceToPoint(point)
                
                if (distance < minimumDistance) {
                    minimumDistance = distance
                    closestAnnotation = annotation
                }

            } else if loopThroughLines && annotationType == "line" {
                
                let spot = userInfo!["spot"] as! ParkingSpot
                let coordinates = spot.line.coordinates2D + spot.buttonLocations
                
                var distances = coordinates.map{(coordinate: CLLocationCoordinate2D) -> CGFloat in
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
        
        if (closestAnnotation != nil && minimumDistance < 60) {
            mapView.selectAnnotation(closestAnnotation, animated: true)
        } else {
            customDeselectAnnotation()
        }

    }
    
    
    // MARK: Helper Methods
    
    func trackUserButtonTapped () {
        if self.mapView.userTrackingMode.value == RMUserTrackingModeFollow.value {
            dontTrackUser()
        } else {
            trackUser()
        }
    }
    
    func trackUser() {
        if self.mapView.userTrackingMode.value != RMUserTrackingModeFollow.value {
            trackUserButton.setImage(UIImage(named:"btn_geo_on"), forState: UIControlState.Normal)
            self.mapView.setZoom(17, animated: false)
            self.mapView.userTrackingMode = RMUserTrackingModeFollow
        }
    }
    
    func dontTrackUser() {
        trackUserButton.setImage(UIImage(named:"btn_geo_off"), forState: UIControlState.Normal)
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
        annotations.sort { (left, right) -> Bool in
            return left.title < right.title
        }
        for annotation in getAnnotationsInCluster(cluster) {
            hash += annotation.title
        }
        return hash
    }
    
    override func didSetMapMode() {
        switch (self.mapMode) {
        case .Garage:
//            self.mapView.clusteringEnabled = self.mapView.zoom <= 14
            break
        default:
            self.mapView.clusteringEnabled = false
            break
        }
    }
    
    override func updateAnnotations(completion: ((operationCompleted: Bool) -> Void)) {
                
        if (self.updateInProgress) {
            println("Update already in progress, cancelled!")
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
            
        } else if self.mapView.zoom >= 15.0 || self.mapMode == MapMode.Garage {
            
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
//                            SVProgressHUD.setBackgroundColor(UIColor.clearColor())
//                            SVProgressHUD.show()
                            GiFHUD.show()
                            
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
                        var newSpotIDs = spots.map{(var spot: ParkingSpot) -> String in spot.identifier}
                        self.spotIDsDrawnOnMap = self.spotIDsDrawnOnMap.filter({ (var spotID: String) -> Bool in
                            contains(newSpotIDs, spotID)
                        })
                        self.lineSpotIDsDrawnOnMap = self.lineSpotIDsDrawnOnMap.filter({ (var spotID: String) -> Bool in
                            contains(newSpotIDs, spotID)
                        })
                        
                        self.updateSpotAnnotations(spots, completion: completion)
                    }
                    
                    if let lots = objects as? [Lot] {
                        
                        self.updateLotAnnotations(lots, completion: completion)
                        
                    }
                    
                })
            }
            
            switch(self.mapMode) {
            case MapMode.CarSharing:
                SpotOperations.findSpots(self.mapView.centerCoordinate, radius: self.radius, duration: duration, checkinTime: checkinTime!, carsharing: carsharing, completion: operationCompletion)
                break
            case MapMode.StreetParking:
                SpotOperations.findSpots(self.mapView.centerCoordinate, radius: self.radius, duration: duration, checkinTime: checkinTime!, carsharing: carsharing, completion: operationCompletion)
                break
            case MapMode.Garage:
                if self.annotations.count > 0 {
                    self.updateInProgress = false
                    completion(operationCompleted: true)
                } else {
                    LotOperations.sharedInstance.findLots(self.mapView.centerCoordinate, radius: self.radius, completion: operationCompletion)
                }
                break
            default:
                self.updateInProgress = false
                self.removeLinesAndButtons()
                completion(operationCompleted: true)
                break
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
    
    func updateSpotAnnotations(spots: [ParkingSpot], completion: ((operationCompleted: Bool) -> Void)) {
        
        let duration = self.delegate?.activeFilterDuration()
        var tempAnnotations = [RMAnnotation]()
        
        for spot in spots {
            let selected = (self.selectedObject != nil && self.selectedObject?.identifier == spot.identifier)
            var generatedAnnotations = annotationForSpot(spot, selected: selected, addToMapView: false)
            tempAnnotations.append(generatedAnnotations.0)
            let buttons = generatedAnnotations.1
            tempAnnotations += buttons

        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.removeLinesAndButtons()

            self.annotations = tempAnnotations

            self.mapView.addAnnotations(self.annotations)
            
            GiFHUD.dismiss()
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
        let shouldAddAnimationForLine = !contains(self.lineSpotIDsDrawnOnMap, spot.identifier)
        annotation = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: spot.identifier)
        annotation.setBoundingBoxFromLocations(spot.line.coordinates)
        annotation.userInfo = ["type": "line", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimationForLine]
        
        if addToMapView {
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
        }
        
        if (mapView.zoom >= 17.0) {
            
            for coordinate in spot.buttonLocations {
                let shouldAddAnimationForButton = !contains(self.spotIDsDrawnOnMap, spot.identifier)
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
            var generatedAnnotations = annotationForLot(lot, selected: selected, addToMapView: false)
            tempAnnotations.append(generatedAnnotations)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.removeLinesAndButtons()
            
            self.annotations = tempAnnotations
            
            self.mapView.addAnnotations(self.annotations)
            
            GiFHUD.dismiss()
            self.updateInProgress = false
            
            completion(operationCompleted: true)
            
        })
        
    }
    
    func zoomIntoClosestPins(numberOfPins: Int) {
        //order annotations by distance from map center
        let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let orderedAnnotations = self.annotations.sorted { (first, second) -> Bool in
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
            
//        self.mapView.zoomWithLatitudeLongitudeBoundsSouthWest(southWest, northEast: northEast, animated: true)
        self.mapView.zoom = self.mapView.zoom - 2
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
        
        let shouldAddAnimation = animate ?? !contains(self.spotIDsDrawnOnMap, lot.identifier)
        var annotation = RMAnnotation(mapView: self.mapView, coordinate: lot.coordinate, andTitle: String(lot.identifier))
        annotation.userInfo = ["type": "lot", "lot": lot, "selected": selected, "shouldAddAnimation": shouldAddAnimation]
        
        if addToMapView {
            mapView.addAnnotation(annotation)
            annotations.append(annotation)
        }
        
        return annotation
        
    }

    
    func addSearchResultMarker(searchResult: SearchResult) {
        
        var annotation: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: searchResult.location.coordinate, andTitle: searchResult.title)
        annotation.subtitle = searchResult.subtitle
        annotation.userInfo = ["type": "searchResult", "details": searchResult]
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
    
    
    override func addCityOverlaysCallback(polygons: [MKPolygon]) {
        
        let polygonAnnotations = MKPolygon.polygonsToRMPolygonAnnotations(polygons, mapView: mapView)

        var worldCorners: [CLLocation] = [
            CLLocation(latitude: 85, longitude: -179),
            CLLocation(latitude: 85, longitude: 179),
            CLLocation(latitude: -85, longitude: 179),
            CLLocation(latitude: -85, longitude: -179),
            CLLocation(latitude: 85, longitude: -179)]
        var annotation = RMPolygonAnnotation(mapView: mapView, points: worldCorners, interiorPolygons: polygonAnnotations)
        annotation.userInfo = ["type": "polygon", "points": worldCorners, "interiorPolygons": polygonAnnotations]
        annotation.fillColor = Styles.Colors.beige1.colorWithAlphaComponent(0.7)
        annotation.lineColor = Styles.Colors.red1
        annotation.lineWidth = 4.0
        
        let interiorPolygons = MKPolygon.interiorPolygons(polygons)
        let interiorPolygonAnnotations = MKPolygon.polygonsToRMPolygonAnnotations(interiorPolygons, mapView: mapView)
        
        var allAnnotationsToAdd = [annotation]
        mapView.addAnnotations(allAnnotationsToAdd)
        
    }
    
    // MARK: SpotDetailViewDelegate
    
    override func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) {
        
        mapView.zoom = 17
        
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
        if let spot = Settings.checkedInSpot() {
            let coordinate = spot.selectedButtonLocation ?? spot.buttonLocations.first!
            let name = spot.name
            var annotation = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: name)
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
        var annotation = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: name)
        annotation.userInfo = ["type": "previousCheckin"]
        mapView.zoom = zoom ?? 17
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
        updateAnnotations({ (operationCompleted: Bool) -> Void in
            completion()
            if self.mapMode == .Garage {
                self.zoomIntoClosestPins(3)
            }
        })
    }
    
    override func removeRegularAnnotations() {
        self.removeLinesAndButtons()
    }


    
}

