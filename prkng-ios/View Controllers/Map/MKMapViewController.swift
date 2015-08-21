//
//  AppleMapViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 06/10/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Foundation

class MKMapViewController: MapViewController, MKMapViewDelegate, MBXRasterTileOverlayDelegate {
    
    let mapSource = "arnaudspuhler.l54pj66f"
    
    var mapView: MKMapView
    var rasterOverlay: MBXRasterTileOverlay
    
    var lastMapZoom: CGFloat
    var lastUserLocation: CLLocation
    var lastMapCenterCoordinate: CLLocationCoordinate2D
    var spotIdentifiersDrawnOnMap: Array<String>
    var lineAnnotations: Array<LineParkingSpot>
    var centerButtonAnnotations: Array<ButtonParkingSpot>
    var searchAnnotations: Array<MKAnnotation>
    var selectedSpot: ParkingSpot?
    var isSelecting: Bool
    var radius : CGFloat
    var updateInProgress : Bool
            
    private(set) var MOVE_DELTA_IN_METERS : Double
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        mapView = MKMapView(frame: CGRectMake(0, 0, 100, 100))
        
        mapView.userTrackingMode = MKUserTrackingMode.Follow
        
        mapView.tintColor = Styles.Colors.red2
        mapView.showsPointsOfInterest = false
        
        mapView.mbx_setCenterCoordinate(mapView.centerCoordinate, zoomLevel: 16, animated: true)
        
        rasterOverlay = MBXRasterTileOverlay(mapID: mapSource, includeMetadata: false, includeMarkers: false)
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
        
        rasterOverlay.delegate = self
        mapView.addOverlay(rasterOverlay)
        
        addCityOverlays()

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
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
        self.screenName = "Map - General Apple View"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.canShowMapMessage = true
            self.updateAnnotations()
        }

    }
    
    override func showForFirstTime() {
        if !wasShown {
            
            if let checkIn = Settings.checkedInSpot() {
                let coordinate = checkIn.buttonLocation.coordinate
                self.mapView.userTrackingMode = MKUserTrackingMode.None
                goToCoordinate(coordinate, named: "", withZoom: 16, showing: false)
            }
            
            wasShown = true
        }
    }

    
    func updateMapCenterIfNecessary () {
        
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
//    func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayView! {
        if let lineOverlay = overlay as? LineParkingSpot {

            let userInfo = lineOverlay.userInfo
            let selected = userInfo["selected"] as! Bool
            let spot = userInfo["spot"] as! ParkingSpot
            let isCurrentlyPaidSpot = spot.currentlyActiveRule.ruleType == .Paid
            let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool
            
            var coordinates = spot.line.coordinates2D
            
            var shape = MKPolylineRenderer(polyline: lineOverlay)
//            var shape = MKPolylineView(overlay: polyline)
            shape.alpha = 0.5
            if selected {
                shape.strokeColor = Styles.Colors.red2
            } else if isCurrentlyPaidSpot {
                shape.strokeColor = Styles.Colors.curry
            } else {
                shape.strokeColor = Styles.Colors.petrol2
            }
            
            if mapView.mbx_zoomLevel() >= 15.0 && mapView.mbx_zoomLevel() <= 16.0 {
                shape.lineWidth = 1.6
            } else {
                shape.lineWidth = 3.4
            }
            
            
            if shouldAddAnimation {
//                addScaleAnimationtoView(shape.layer)
                spotIdentifiersDrawnOnMap.append(spot.identifier)
            }
            
            return shape
            
        } else if let tileOverlay = overlay as? MBXRasterTileOverlay {
            // This is boilerplate code to connect mbx tile overlay layers with suitable renderers
            //
            var renderer = MBXRasterTileRenderer(tileOverlay: tileOverlay)
            return renderer
        } else if let polygon = overlay as? MKPolygon {
            var shape = MKPolygonRenderer(polygon: polygon)
            shape.fillColor = Styles.Colors.beige1.colorWithAlphaComponent(0.7)
            shape.strokeColor = Styles.Colors.red1
            shape.lineWidth = 4.0
            return shape
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

//        if (annotation.isUserLocationAnnotation) {
//
//            var marker = RMMarker(UIImage: UIImage(named: "cursor_you"))
//            marker.canShowCallout = false
//            return marker
//        }
        
        if let buttonAnnotation = annotation as? ButtonParkingSpot {
//            var view: ButtonParkingSpotView = mapView.dequeueReusableAnnotationViewWithIdentifier("button")
//            if (view == nil) {
            var view = ButtonParkingSpotView(annotation: buttonAnnotation, reuseIdentifier: "button", mbxZoomLevel: mapView.mbx_zoomLevel())
//            }
//            view.annotation = buttonAnnotation
//            view.setup()
            return view
        } else if let searchResultAnnotation = annotation as? SearchResult {
            var searchResultView: MKPinAnnotationView = MKPinAnnotationView(annotation: searchResultAnnotation, reuseIdentifier: "searchresult")
            searchResultView.image = UIImage(named: "pin_pointer_result")
            searchResultView.canShowCallout = true
            return searchResultView
        } else if let mbxPointAnnotation = annotation as? MBXPointAnnotation{
            // This is boilerplate code to connect annotations with suitable views
            //
            var MBXSimpleStyleReuseIdentifier = "MBXSimpleStyleReuseIdentifier"
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier(MBXSimpleStyleReuseIdentifier)
            if (view == nil) {
                view = MKAnnotationView(annotation: mbxPointAnnotation, reuseIdentifier: MBXSimpleStyleReuseIdentifier)
            }
            view.image = mbxPointAnnotation.image
            view.canShowCallout = true
            return view
        }
        
        return nil
    }
        
    func tileOverlay(overlay: MBXRasterTileOverlay!, didLoadMetadata metadata: [NSObject : AnyObject]!, withError error: NSError!) {
        // This delegate callback is for centering the map once the map metadata has been loaded
        //
        if error != nil {
            NSLog("Failed to load metadata for map ID %@ - (%@)", overlay.mapID, error ?? "");
        } else {
            mapView.mbx_setCenterCoordinate(overlay.center, zoomLevel: UInt(overlay.centerZoom), animated: false)
        }

    }
    
    func tileOverlay(overlay: MBXRasterTileOverlay!, didLoadMarkers markers: [AnyObject]!, withError error: NSError!) {
        // This delegate callback is for adding map markers to an MKMapView once all the markers for the tile overlay have loaded
        //
        if error != nil {
            NSLog("Failed to load markers for map ID %@ - (%@)", overlay.mapID, error ?? "");
        } else {
            mapView.addAnnotations(markers)
        }

    }
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        
        if (mapView.userTrackingMode == MKUserTrackingMode.Follow ) {
            self.hideTrackUserButton()
        } else {
            toggleTrackUserButton(!(delegate != nil && !delegate!.shouldShowUserTrackingButton()))
            self.mapView.userTrackingMode = MKUserTrackingMode.None
        }
        
    }
    
    func afterMapMove(map: MKMapView!, byUser wasUserAction: Bool) {

    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {

        //the following used to happen after a zoom
        self.radius = (20.0 - mapView.mbx_zoomLevel()) * 100
        
        if(mapView.mbx_zoomLevel() < 15.0) {
            self.radius = 0
        }
        
        if (abs(self.lastMapZoom - mapView.mbx_zoomLevel()) >= 1) {
            self.spotIdentifiersDrawnOnMap = []
        }
        
        if self.lastMapZoom != mapView.mbx_zoomLevel() {
            self.updateAnnotations()
            self.lastMapZoom = mapView.mbx_zoomLevel()
            return
        }
        
        //the following used to happen after a map move
        //        removeSelectedAnnotationIfExists()
        
        //reload if the map has moved sufficiently...
        let lastMapCenterLocation = CLLocation(latitude: self.lastMapCenterCoordinate.latitude, longitude: self.lastMapCenterCoordinate.longitude)
        let newMapCenterLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let differenceInMeters = lastMapCenterLocation.distanceFromLocation(newMapCenterLocation)
        //        NSLog("Map moved " + String(stringInterpolationSegment: differenceInMeters) + " meters.")
        if differenceInMeters > self.MOVE_DELTA_IN_METERS {
            self.updateAnnotations()
            self.lastMapCenterCoordinate = mapView.centerCoordinate
        }
        
        self.delegate?.mapDidDismissSelection(byUser: true)
        
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if var button = view as? ButtonParkingSpotView {
            button.buttonParkingSpotAnnotation.userInfo["selected"] = true
            button.setup(mapView.mbx_zoomLevel())
            selectedSpot = button.buttonParkingSpotAnnotation
            self.delegate?.didSelectSpot(selectedSpot!)
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if var button = view as? ButtonParkingSpotView {
            button.buttonParkingSpotAnnotation.userInfo["selected"] = false
            button.setup(mapView.mbx_zoomLevel())
        }
        
        self.delegate?.mapDidDismissSelection(byUser: true)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        //this will run too often, so only run it if we've changed by any significant amount
        if let userCLLocation = userLocation.location {
            let differenceInMeters = lastUserLocation.distanceFromLocation(userCLLocation)
            
            if differenceInMeters > MOVE_DELTA_IN_METERS/10
                && mapView.userTrackingMode == MKUserTrackingMode.Follow {
                updateAnnotations()
                lastUserLocation = userCLLocation
            }
        }
    }
    

    
//    func singleTapOnMap(map: MKMapView!, at point: CGPoint) {
//        var minimumDistance = CGFloat(Float.infinity)
//        var closestAnnotation : MKAnnotation? = nil
//        //loop through the annotations to see if we touched a line or a button
//        for annotation in lineAnnotations {
//        }
//        for annotation: MKAnnotation in map.annotations as! [MKAnnotation] {
//            
//            if (annotation == mapView.userLocation) {
//                continue
//            }
//            
//            var userInfo: [String:AnyObject]? = annotation.userInfo as? [String:AnyObject]
//            var annotationType = userInfo!["type"] as! String
//            
//            if (annotationType == "button") {
//                var annotationPoint = map.coordinateToPixel(annotation.coordinate)
//                let xDist = (annotationPoint.x - point.x);
//                let yDist = (annotationPoint.y - point.y);
//                let distance = sqrt((xDist * xDist) + (yDist * yDist));
//                
//                if (distance < minimumDistance) {
//                    minimumDistance = distance
//                    closestAnnotation = annotation
//                }
//            }
//        }
//        
//        if (closestAnnotation != nil && minimumDistance < 60) {
//            map.selectAnnotation(closestAnnotation, animated: true)
//        }
//
//    }
    
    
    // MARK: Helper Methods
    
//    func removeSelectedAnnotationIfExists() {
//        if (selectedSpot != nil) {
//        removeAnnotations(findAnnotations(selectedSpot!.identifier))
//            addSpotAnnotation(self.mapView, spot: selectedSpot!, selected: false)
//            selectedSpot = nil
//        }
//    }

    func trackUserButtonTapped () {
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow
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
    
    override func updateAnnotations() {
        
        if (updateInProgress) {
            println("Update already in progress, cancelled!")
            return
        }
        
        updateInProgress = true
        
        removeMyCarMarker()
        addMyCarMarker()
        
        //only show the spinner if this map is active
        if let tabController = self.parentViewController as? TabController {
            if tabController.activeTab() == PrkTab.Here {
//                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
//                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
            }
        }
        
        if isFarAwayFromAvailableCities(mapView.centerCoordinate) {
            
            if canShowMapMessage {
                self.delegate?.mapDidMoveFarAwayFromAvailableCities()
            }
            
            updateInProgress = false
            
        } else if (mapView.mbx_zoomLevel() >= 15.0) {
            
            self.delegate?.showMapMessage("map_message_loading".localizedString, onlyIfPreviouslyShown: true)

            var checkinTime = searchCheckinDate
            var duration = searchDuration
            
            if (checkinTime == nil) {
                checkinTime = NSDate()
            }
            
            if (duration == nil) {
                duration = self.delegate?.activeFilterDuration()
            }
            
            if duration != nil {
                NSLog("updating with duration: %f",duration!)
            } else {
                NSLog("updating with duration: nil")
            }
            
            let permit = self.delegate?.activeFilterPermit() ?? false

            SpotOperations.findSpots(self.mapView.centerCoordinate, radius: Float(radius), duration: duration, checkinTime: checkinTime!, permit: permit, completion:
                { (spots, underMaintenance, outsideServiceArea, error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //only show the spinner if this map is active
                        if let tabController = self.parentViewController as? TabController {
                            if tabController.activeTab() == PrkTab.Here {
                                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
                                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
                                
                                if self.canShowMapMessage {
                                    if underMaintenance {
                                        self.delegate?.showMapMessage("map_message_under_maintenance".localizedString)
                                    } else if error {
                                        self.delegate?.showMapMessage("map_message_error".localizedString)
                                    } else if outsideServiceArea {
                                        self.delegate?.showMapMessage("map_message_outside_service_area".localizedString)
                                    } else if spots.count == 0 {
                                        self.delegate?.showMapMessage("map_message_no_spots".localizedString)
                                    } else {
                                        self.delegate?.showMapMessage(nil)
                                    }
                                }
                            }
                        }
                    })

                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        
                        //
                        // spots that have left the screen need to be re-animated next time
                        // therefore, we remove spots that have not been fetched this time around
                        //
                        var newSpotIDs = spots.map{(var spot: ParkingSpot) -> String in spot.identifier}
                        self.spotIdentifiersDrawnOnMap = self.spotIdentifiersDrawnOnMap.filter({ (var spotID: String) -> Bool in
                            contains(newSpotIDs, spotID)
                        })
                        
                        self.updateSpotAnnotations(spots)
                        
                        self.updateInProgress = false
                        
                        SVProgressHUD.dismiss()
                        
                    })

                    
            })
            
        } else {
            
            mapView.removeOverlays(lineAnnotations)
            lineAnnotations = []
            
            mapView.removeAnnotations(centerButtonAnnotations)
            centerButtonAnnotations = []
            
            updateInProgress = false
            
            SVProgressHUD.dismiss()
            
            self.delegate?.showMapMessage("map_message_too_zoomed_out".localizedString)

        }
        
        
    }
    
    
    func updateSpotAnnotations(spots: [ParkingSpot]) {

        var overlays = [LineParkingSpot]()
        var annotations = [ButtonParkingSpot]()
        let zoomLevel = mapView.mbx_zoomLevel()
        
        for spot in spots {
            let selected = (self.selectedSpot != nil && self.selectedSpot?.identifier == spot.identifier)
            let shouldAddAnimation = !contains(self.spotIdentifiersDrawnOnMap, spot.identifier)
            
            var userInfo = ["type": "line", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimation]
            var coordinates = spot.line.coordinates2D
            
            //create the proper polyline
            var polyline = LineParkingSpot(coordinates: &coordinates, count: coordinates.count)
            spot.userInfo = userInfo
            polyline.parkingSpot = spot
            overlays.append(polyline)
            
            if (zoomLevel >= 17.0) {
                var centerButton = spot.buttonSpot
                centerButton.userInfo = ["type": "button", "spot": spot, "selected": selected, "shouldAddAnimation" : shouldAddAnimation]
                annotations.append(centerButton)
            }
            
        }
        
//        //remove overlays and annotations no longer on the screen
//        let visibleMapRect = self.mapView.visibleMapRect
//        
//        var nonVisibleOverlays = lineAnnotations.filter { (var line: LineParkingSpot) -> Bool in
//            !line.intersectsMapRect(visibleMapRect)
//        }
//        var visibleOverlays = lineAnnotations.filter { (var line: LineParkingSpot) -> Bool in
//            line.intersectsMapRect(visibleMapRect)
//        }
//
//        var nonVisibleAnnotations = centerButtonAnnotations.filter { (var button) -> Bool in
//            !MKMapRectContainsPoint(visibleMapRect, MKMapPointForCoordinate(button.coordinate))
//        }
//        var visibleAnnotations = centerButtonAnnotations.filter { (var button) -> Bool in
//            MKMapRectContainsPoint(visibleMapRect, MKMapPointForCoordinate(button.coordinate))
//        }
//
//        var overlaysToAdd = overlays.filter { (var line: LineParkingSpot) -> Bool in
//            !contains(visibleOverlays, line)
//        }
//        var annotationsToAdd = annotations.filter { (var button) -> Bool in
//            !contains(visibleAnnotations, button)
//        }

        self.lineAnnotations = overlays
        self.centerButtonAnnotations = annotations

//        //it's more efficient to do everything in the background and then only update the annotations we need, finally moving into the main thread for the actual adding
        dispatch_async(dispatch_get_main_queue(), {
//            self.mapView.removeOverlays(nonVisibleOverlays)
//            self.mapView.removeAnnotations(nonVisibleAnnotations)
//
//            self.mapView.addOverlays(overlaysToAdd)
//            self.mapView.addAnnotations(annotationsToAdd)
            
            self.removeAllAnnotations()
            self.mapView.addOverlays(overlays)
            self.mapView.addAnnotations(annotations)
            
            SVProgressHUD.dismiss()
        })
    }

    
    func addSearchResultMarker(searchResult: SearchResult) {
        
//        var annotation: MKAnnotation = MKAnnotation(mapView: self.mapView, coordinate: searchResult.location.coordinate, andTitle: searchResult.title)
        searchResult.userInfo = ["type": "searchResult", "details": searchResult]
        mapView.addAnnotation(searchResult)
        searchAnnotations.append(searchResult)
    }
    
    
//    func findAnnotations(identifier: String) -> Array<MKAnnotation> {
//        
//        var foundAnnotations: Array<MKAnnotation> = []
//        
//        for annotation in lineAnnotations {
//            
//            var userInfo: [String:AnyObject]? = (annotation as MKAnnotation).userInfo as? [String:AnyObject]
//            var spot = userInfo!["spot"] as! ParkingSpot
//            
//            if spot.identifier == identifier {
//                foundAnnotations.append(annotation)
//            }
//        }
//        
//        
//        for annotation in centerButtonAnnotations {
//            
//            var userInfo: [String:AnyObject]? = (annotation as MKAnnotation).userInfo as? [String:AnyObject]
//            var spot = userInfo!["spot"] as! ParkingSpot
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
//    func removeAnnotations(annotations: Array<MKAnnotation>) {
//        
//        var tempLineAnnotations: Array<MKAnnotation> = []
//        
//        for ann in lineAnnotations {
//            
//            var userInfo: [String:AnyObject]? = (ann as MKAnnotation).userInfo as? [String:AnyObject]
//            var spot = userInfo!["spot"] as! ParkingSpot
//            
//            var found: Bool = false
//            for delAnn in annotations {
//                
//                var delUserInfo: [String:AnyObject]? = (delAnn as MKAnnotation).userInfo as? [String:AnyObject]
//                var delSpot = delUserInfo!["spot"] as! ParkingSpot
//                
//                if delSpot.identifier == spot.identifier {
//                    found = true
//                    break
//                }
//            }
//            
//            if !found {
//                tempLineAnnotations.append(ann)
//            }
//            
//        }
//    
//        self.lineAnnotations = tempLineAnnotations
//        
//        
//        var tempCenterButtonAnnotations: Array<MKAnnotation> = []
//
//        for ann in centerButtonAnnotations {
//            
//            var userInfo: [String:AnyObject]? = (ann as MKAnnotation).userInfo as? [String:AnyObject]
//            var spot = userInfo!["spot"] as! ParkingSpot
//            
//            var found: Bool = false
//            for delAnn in annotations {
//                
//                var delUserInfo: [String:AnyObject]? = (delAnn as MKAnnotation).userInfo as? [String:AnyObject]
//                var delSpot = delUserInfo!["spot"] as! ParkingSpot
//                
//                if delSpot.identifier == spot.identifier {
//                    found = true
//                    break
//                }
//            }
//            
//            if !found {
//                tempCenterButtonAnnotations.append(ann)
//            }
//            
//        }
//
//        self.centerButtonAnnotations = tempCenterButtonAnnotations
//
//        self.mapView.removeAnnotations(annotations)
//        
//    }
    
    
    override func addCityOverlaysCallback(polygons: [MKPolygon]) {
        
        let interiorPolygons = MKPolygon.interiorPolygons(polygons)
        let invertedPolygon = MKPolygon.invertPolygons(polygons)
        mapView.addOverlay(invertedPolygon)
        mapView.addOverlays(interiorPolygons)
        
    }
    
    // MARK: SpotDetailViewDelegate
    
    override func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) {
        
        
        if (results.count == 0) {
            let alert = UIAlertView()
            alert.title = "No results found"
            alert.message = "We couldn't find anything matching the criteria"
            alert.addButtonWithTitle("Close")
            alert.show()
            return
        }
        
        mapView.mbx_setCenterCoordinate(results[0].location.coordinate, zoomLevel: 17, animated: true)
        
        searchAnnotations = []

        lineAnnotations = []
        centerButtonAnnotations = []
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
        self.mapView.userTrackingMode = mode == MapUserMode.Follow ? MKUserTrackingMode.Follow : MKUserTrackingMode.None
        Settings.setMapUserMode(mode)
    }
    
    override func addMyCarMarker() {
        NSLog("Can't yet go to a previous checkin in the apple map")
    }
    
    override func removeMyCarMarker() {
        NSLog("Can't yet go to a previous checkin in the apple map")
    }
    
    //shows a checkin on the map as a regular marker
    override func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, withZoom zoom:Float? = nil, showing: Bool = true) {
        NSLog("Can't yet go to a previous checkin in the apple map")
    }

    
    func removeAllAnnotations() {
        mapView.removeAnnotations(self.centerButtonAnnotations)
        mapView.removeAnnotations(self.searchAnnotations)
        mapView.removeOverlays(self.lineAnnotations)
        searchAnnotations = []
        lineAnnotations = []
        centerButtonAnnotations = []
        removeMyCarMarker()
        addMyCarMarker()
    }
    
}
