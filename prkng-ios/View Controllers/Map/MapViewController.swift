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
    var lastMapZoom: Float
    var lastUserLocation: CLLocation
    var lastMapCenterCoordinate: CLLocationCoordinate2D
    var spotIdentifiersDrawnOnMap: Array<String>
    var lineAnnotations: Array<RMAnnotation>
    var centerButtonAnnotations: Array<RMAnnotation>
    var searchAnnotations: Array<RMAnnotation>
    var selectedSpot: ParkingSpot?
    var isSelecting: Bool
    var radius : Float
    var updateInProgress : Bool
    
    var trackUserButton : UIButton
    
    var searchCheckinDate : NSDate?
    var searchDuration : Float?
    
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
        
        mapView.userTrackingMode = RMUserTrackingModeFollow
        
        mapView.tintColor = Styles.Colors.red2
        mapView.showLogoBug = false
        mapView.hideAttribution = true
        mapView.zoomingInPivotsAroundCenter = true
        mapView.zoom = 16
        lastMapZoom = 0
        lastUserLocation = CLLocation(latitude: 0, longitude: 0)
        lastMapCenterCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        isSelecting = false
        spotIdentifiersDrawnOnMap = []
        lineAnnotations = []
        centerButtonAnnotations = []
        searchAnnotations = []
        radius = 300
        updateInProgress = false
        
        trackUserButton = UIButton()
        
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
        
        trackUserButton.setImage(UIImage(named: "track_user"), forState: UIControlState.Normal)
        trackUserButton.addTarget(self, action: "trackUserButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(trackUserButton)
        
        mapView.snp_makeConstraints {  (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        showTrackUserButton()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.userTrackingMode = RMUserTrackingModeFollow
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.updateAnnotations()
        }

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
        
        let addAnimation = annotationType
        
        switch annotationType {
            
        case "line":
            
            let selected = userInfo!["selected"] as! Bool
            let spot = userInfo!["spot"] as! ParkingSpot
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            
            var shape = RMShape(view: mapView)
            
            if (selected) {
                shape.lineColor = Styles.Colors.red2
            } else {
                shape.lineColor = Styles.Colors.petrol2
            }
            
            if mapView.zoom > 15.0 && mapView.zoom < 16.0 {
                shape.lineWidth = 2.6
            } else {
                shape.lineWidth = 4.4
            }
            
            for location in spot.line.coordinates as Array<CLLocation> {
                shape.addLineToCoordinate(location.coordinate)
            }

            if shouldAddAnimation {
                addScaleAnimationtoView(shape)
                spotIdentifiersDrawnOnMap.append(spot.identifier)
            }
            
            return shape
            
            
        case "button":

            let selected = userInfo!["selected"] as! Bool
            let spot = userInfo!["spot"] as! ParkingSpot
            let shouldAddAnimation = userInfo!["shouldAddAnimation"] as! Bool
            
            var imageName = "button_line_"
            
            if mapView.zoom < 18 {
                imageName += "small_"
            }
            if !selected {
                imageName += "in"
            }
            
            imageName += "active"
            
            var circleImage = UIImage(named: imageName)
            
            var circleMarker: RMMarker = RMMarker(UIImage: circleImage)
            
            if shouldAddAnimation {
                addScaleAnimationtoView(circleMarker)
                spotIdentifiersDrawnOnMap.append(spot.identifier)
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
            
        case "searchResult":
            
            let marker = RMMarker(UIImage: UIImage(named: "pin_pointer_result"))
            marker.canShowCallout = true
            return marker
            
            
        default:
            return nil
            
        }
    }
    
    func beforeMapMove(map: RMMapView!, byUser wasUserAction: Bool) {
        
        
        if (mapView.userTrackingMode.value == RMUserTrackingModeFollow.value ) {
            self.hideTrackUserButton()
        } else {
            toggleTrackUserButton(!(delegate != nil && !delegate!.shouldShowUserTrackingButton()))
            self.mapView.userTrackingMode = RMUserTrackingModeNone
        }
        
    }
    
    func afterMapMove(map: RMMapView!, byUser wasUserAction: Bool) {

        removeSelectedAnnotationIfExists()
        
        //reload if the map has moved sufficiently...
        let lastMapCenterLocation = CLLocation(latitude: lastMapCenterCoordinate.latitude, longitude: lastMapCenterCoordinate.longitude)
        let newMapCenterLocation = CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)
        let differenceInMeters = lastMapCenterLocation.distanceFromLocation(newMapCenterLocation)
        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
        if differenceInMeters > MOVE_DELTA_IN_METERS {
            updateAnnotations()
            lastMapCenterCoordinate = map.centerCoordinate
        }
        
        self.delegate?.mapDidMove(CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude))
    }
    
    func afterMapZoom(map: RMMapView!, byUser wasUserAction: Bool) {
        radius = (20.0 - map.zoom) * 100
        
        if(map.zoom < 15.0) {
            radius = 0
        }
        
        if (abs(lastMapZoom - map.zoom) >= 1) {
            spotIdentifiersDrawnOnMap = []
        }
        
        updateAnnotations()
        
        lastMapZoom = map.zoom
        
    }
    
    func mapView(mapView: RMMapView!, didSelectAnnotation annotation: RMAnnotation!) {
        
        if (isSelecting || annotation.isUserLocationAnnotation) {
            return
        }
        
        isSelecting = true
        
        removeSelectedAnnotationIfExists()
        
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
        
        isSelecting = false

    }
    
    func mapView(mapView: RMMapView!, didUpdateUserLocation userLocation: RMUserLocation!) {
        //this will run too often, so only run it if we've changed by any significant amount
        if let userCLLocation = userLocation.location {
            let differenceInMeters = lastUserLocation.distanceFromLocation(userCLLocation)
            
            if differenceInMeters > MOVE_DELTA_IN_METERS/10
                && mapView.userTrackingMode.value == RMUserTrackingModeFollow.value {
                updateAnnotations()
                lastUserLocation = userCLLocation
            }
        }
    }
    
    func singleTapOnMap(map: RMMapView!, at point: CGPoint) {
        var minimumDistance = CGFloat(Float.infinity)
        var closestAnnotation : RMAnnotation? = nil
        //loop through the annotations to see if we touched a line or a button
        for annotation in lineAnnotations {
        }
        for annotation: RMAnnotation in map.visibleAnnotations as! [RMAnnotation] {
            
            if (annotation.isUserLocationAnnotation) {
                continue
            }
            
            var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
            var annotationType = userInfo!["type"] as! String
            
            if (annotationType == "button") {
                var annotationPoint = map.coordinateToPixel(annotation.coordinate)
                let xDist = (annotationPoint.x - point.x);
                let yDist = (annotationPoint.y - point.y);
                let distance = sqrt((xDist * xDist) + (yDist * yDist));
                
                if (distance < minimumDistance) {
                    minimumDistance = distance
                    closestAnnotation = annotation
                }
            }
        }
        
        if (closestAnnotation != nil && minimumDistance < 60) {
            map.selectAnnotation(closestAnnotation, animated: true)
        }

    }
    
    
    // MARK: Helper Methods
    
    func removeSelectedAnnotationIfExists() {
        if (selectedSpot != nil) {
        removeAnnotations(findAnnotations(selectedSpot!.identifier))
            addSpotAnnotation(self.mapView, spot: selectedSpot!, selected: false)
            selectedSpot = nil
        }
    }

    func trackUserButtonTapped () {
        self.mapView.userTrackingMode = RMUserTrackingModeFollow
        hideTrackUserButton()
    }
    
    
    func toggleTrackUserButton(shouldShowButton: Bool) {
        if (shouldShowButton) {
            showTrackUserButton()
        } else {
            hideTrackUserButton()
        }
    }
    
    func hideTrackUserButton() {
        
        trackUserButton.snp_updateConstraints{ (make) -> () in
            make.size.equalTo(CGSizeMake(0, 0))
            make.centerX.equalTo(self.view).multipliedBy(0.33)
            make.bottom.equalTo(self.view).with.offset(-48)
        }
        animateTrackUserButton()
    }
    
    func showTrackUserButton() {
        
        trackUserButton.snp_updateConstraints{ (make) -> () in
            make.size.equalTo(CGSizeMake(36, 36))
            make.centerX.equalTo(self.view).multipliedBy(0.33)
            make.bottom.equalTo(self.view).with.offset(-30)
        }
        animateTrackUserButton()
    }
    
    func animateTrackUserButton() {
        self.trackUserButton.setNeedsLayout()
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.trackUserButton.layoutIfNeeded()
            },
            completion: { (completed:Bool) -> Void in
        })
    }
    
    func addScaleAnimationtoView(mapLayer: RMMapLayer) {
        var animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        animation.values = [0,1]
        
        animation.duration = 0.6
        var timingFunctions: Array<CAMediaTimingFunction> = []
        
        for i in 0...animation.values.count {
            timingFunctions.append(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        
        animation.timingFunctions = timingFunctions
        animation.removedOnCompletion = true
        
        mapLayer.addAnimation(animation, forKey: "scale")
        
//        NSLog("Added a scale animation")
    }

    
    func updateAnnotations() {
        
        if (updateInProgress) {
            println("Update already in progress, cancelled!")
            return
        }
        
        updateInProgress = true
        
        //only show the spinner if this map is active
        if let tabController = self.parentViewController as? TabController {
            if tabController.activeTab() == PrkTab.Here {
                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
            }
        }
        
        if (mapView.zoom > 15.0) {
            
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
                    
                    //TODO: Optimize this section, it's likely what causes the sluggish map behaviour (in the addSpotAnnotation method)
                    //do we really need to replace all spots? probably only the ones that are new...
                    
                    var startedOn = NSDate()
                    var format = NSDateFormatter()
                    format.dateFormat = "hh:mm:ss.SSS"
//                    NSLog("findSpots completion - started at: %@", format.stringFromDate(startedOn))
                    self.mapView.removeAnnotations(self.lineAnnotations)
                    self.lineAnnotations = []
                    
                    self.mapView.removeAnnotations(self.centerButtonAnnotations)
                    self.centerButtonAnnotations = []
                    
                    //
                    // spots that have left the screen need to be re-animated next time
                    // therefore, we remove spots that have not been fetched this time around
                    //
                    var newSpotIDs = spots.map{(var spot: ParkingSpot) -> String in spot.identifier}
                    self.spotIdentifiersDrawnOnMap = self.spotIdentifiersDrawnOnMap.filter({ (var spotID: String) -> Bool in
                        contains(newSpotIDs, spotID)
                    })
                    
                    for spot in spots {
                        let selected = (self.selectedSpot != nil && self.selectedSpot?.identifier == spot.identifier)
                        
                        self.addSpotAnnotation(self.mapView, spot: spot, selected: selected)
                    }
                    self.updateInProgress = false
                    
                    var timeInterval = NSDate().timeIntervalSinceDate(startedOn)
                    let milliseconds = CUnsignedLong(timeInterval * 1000)
                    NSLog("findSpots completion took: " + String(milliseconds) + " milliseconds")
//                    NSLog("findSpots completion - ended at: %@", format.stringFromDate(NSDate()))
                    
                    SVProgressHUD.dismiss()
                    
                    
            })
            
        } else {
            
            mapView.removeAnnotations(lineAnnotations)
            lineAnnotations = []
            
            mapView.removeAnnotations(centerButtonAnnotations)
            centerButtonAnnotations = []
            
            updateInProgress = false
            
            SVProgressHUD.dismiss()

        }
        
        
    }
    
    
    func addSpotAnnotation(map: RMMapView, spot: ParkingSpot, selected: Bool) {
        
        let coordinate = spot.line.coordinates[0].coordinate
        let shouldAddAnimation = !contains(self.spotIdentifiersDrawnOnMap, spot.identifier)
        var annotation: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: coordinate, andTitle: spot.identifier)
        annotation.setBoundingBoxFromLocations(spot.line.coordinates)
        annotation.userInfo = ["type": "line", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimation]
        self.mapView.addAnnotation(annotation)
        lineAnnotations.append(annotation)
        
        
        if (mapView.zoom >= 17.0) {
            
            var centerButton: RMAnnotation = RMAnnotation(mapView: self.mapView, coordinate: spot.buttonLocation.coordinate, andTitle: spot.identifier)
            centerButton.setBoundingBoxFromLocations(spot.line.coordinates)
            centerButton.userInfo = ["type": "button", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimation]
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
            alert.message = "We couldn't find anything matching the criteria"
            alert.addButtonWithTitle("Close")
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
