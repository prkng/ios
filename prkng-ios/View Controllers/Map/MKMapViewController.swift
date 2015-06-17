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
    var kmlParser: KMLParser
    
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
    
    var trackUserButton : UIButton
        
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
        kmlParser = KMLParser()
        
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
        
        rasterOverlay.delegate = self
        mapView.addOverlay(rasterOverlay)
        
        // Locate the path to the route.kml file in the application's bundle
        // and parse it with the KMLParser.
        if let kmlPath = NSBundle.mainBundle().pathForResource("parking_availability", ofType: "kml") {
            var kmlUrl = NSURL(fileURLWithPath: kmlPath)
            kmlParser = KMLParser(URL: kmlUrl)
            kmlParser.parseKML()
            
            var interiorPolygons: [MKPolygon] = []

            
            if let overlays = kmlParser.overlays as? [MKPolygon] {
                var interiorPolygons: [MKPolygon] = overlays
//                for polygon in overlays {
//                    
//                    //get useable data from the polygon
//                    var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(polygon.pointCount)
//                    polygon.getCoordinates(coordsPointer, range: NSMakeRange(0, polygon.pointCount))
//                    var locations: [CLLocation] = []
//                    for i in 0..<polygon.pointCount {
//                        let coord = coordsPointer[i]
//                        locations.append(CLLocation(latitude: coord.latitude, longitude: coord.longitude))
//                    }
//                    
//                    var interiorPolygon = RMPolygonAnnotation(mapView: mapView, points: locations)
//                    interiorPolygons.append(interiorPolygon)
//                }
                
                var worldCorners: [CLLocation] = [
                    CLLocation(latitude: 85, longitude: -179),
                    CLLocation(latitude: 85, longitude: 179),
                    CLLocation(latitude: -85, longitude: 179),
                    CLLocation(latitude: -85, longitude: -179),
                    CLLocation(latitude: 85, longitude: -179)]
                
                var coordinatesPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(worldCorners.count)

                var polygon = MKPolygon(coordinates: coordinatesPointer, count: worldCorners.count, interiorPolygons: interiorPolygons)
                
//                annotation.userInfo = ["type": "polygon", "points": worldCorners, "interiorPolygons": interiorPolygons]
//                annotation.fillColor = Styles.Colors.beige1.colorWithAlphaComponent(0.7)
//                annotation.lineColor = Styles.Colors.red1
//                annotation.lineWidth = 4.0
                mapView.addOverlay(polygon)
            }
        }

        
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.updateAnnotations()
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
            let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool
            
            var coordinates = spot.line.coordinates2D
            
            var shape = MKPolylineRenderer(polyline: lineOverlay)
//            var shape = MKPolylineView(overlay: polyline)

            if (selected) {
                shape.strokeColor = Styles.Colors.red2
            } else {
                shape.strokeColor = Styles.Colors.petrol2
            }
            
            if mapView.mbx_zoomLevel() > 15.0 && mapView.mbx_zoomLevel() < 16.0 {
                shape.lineWidth = 2.6
            } else {
                shape.lineWidth = 4.4
            }
            
//            for location in spot.line.coordinates as Array<CLLocation> {
//                shape.addLineToCoordinate(location.coordinate)
//            }
            
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
            shape.strokeColor = Styles.Colors.red2
            var red = Styles.Colors.red2
            shape.fillColor = red.colorWithAlphaComponent(0.5)
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
            var buttonView: MKAnnotationView = MKAnnotationView(annotation: buttonAnnotation, reuseIdentifier: "button")
            configureButtonView(&buttonView)
            return buttonView
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
    
    func configureButtonViewWithAnnotation(buttonAnnotation:ButtonParkingSpot) -> MKAnnotationView {

        var annotationView: MKAnnotationView = MKAnnotationView(annotation: buttonAnnotation, reuseIdentifier: nil)
        configureButtonView(&annotationView)
        return annotationView
    }
    
    func configureButtonView(inout annotationView:MKAnnotationView) {
        
        let buttonAnnotation = annotationView.annotation as! ButtonParkingSpot
        let userInfo = buttonAnnotation.userInfo
        let selected = userInfo["selected"] as! Bool
        let spot = userInfo["spot"] as! ParkingSpot
        let shouldAddAnimation = userInfo["shouldAddAnimation"] as! Bool
        
        if shouldAddAnimation {
            addScaleAnimationtoView(annotationView.layer)
            spotIdentifiersDrawnOnMap.append(spot.identifier)
        }
        
        var imageName = "button_line_"
        
        if mapView.mbx_zoomLevel() < 18 {
            imageName += "small_"
        }
        if !selected {
            imageName += "in"
        }
        
        imageName += "active"
        
        var circleImage = UIImage(named: imageName)
        
        annotationView.image = circleImage
        
        if (selected) {
            var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 0.7
            pulseAnimation.fromValue = 0.95
            pulseAnimation.toValue = 1.10
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = FLT_MAX
            annotationView.layer.addAnimation(pulseAnimation, forKey: nil)
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
        
        if(mapView.mbx_zoomLevel() <= 15.0) {
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
        
        self.delegate?.mapDidDismissSelection()
        
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if var buttonAnnotation = view.annotation as? ButtonParkingSpot {
            buttonAnnotation.userInfo["selected"] = true
            view.annotation = buttonAnnotation
            var replacementView = configureButtonViewWithAnnotation(buttonAnnotation)
            view.image = replacementView.image
            
            //add annotation
            var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 0.7
            pulseAnimation.fromValue = 0.95
            pulseAnimation.toValue = 1.10
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = FLT_MAX
            view.layer.addAnimation(pulseAnimation, forKey: nil)
            
            selectedSpot = buttonAnnotation
            self.delegate?.didSelectSpot(selectedSpot!)
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if var buttonAnnotation = view.annotation as? ButtonParkingSpot {
            buttonAnnotation.userInfo["selected"] = false
            view.annotation = buttonAnnotation
            var replacementView = configureButtonViewWithAnnotation(buttonAnnotation)
            view.image = replacementView.image
            view.layer.removeAllAnimations()
        }
        
        self.delegate?.mapDidDismissSelection()

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
    
    func addScaleAnimationtoView(mapLayer: CALayer) {
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
//                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
//                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
            }
        }
        
        if (mapView.mbx_zoomLevel() > 15.0) {
            
            var checkinTime = searchCheckinDate
            var duration = searchDuration
            
            if (checkinTime == nil) {
                checkinTime = NSDate()
            }
            
            if (duration == nil) {
                duration = 1
            }
            
            SpotOperations.findSpots(self.mapView.centerCoordinate, radius: Float(radius), duration: duration!, checkinTime: checkinTime!, completion:
                { (spots) -> Void in
                    
                    //TODO: Optimize this section, it's likely what causes the sluggish map behaviour (in the addSpotAnnotation method)
                    //do we really need to replace all spots? probably only the ones that are new...
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        
                        var startedOn = NSDate()
                        var format = NSDateFormatter()
                        format.dateFormat = "hh:mm:ss.SSS"
                        //                    NSLog("findSpots completion - started at: %@", format.stringFromDate(startedOn))
                        
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
                        
                        var timeInterval = NSDate().timeIntervalSinceDate(startedOn)
                        let milliseconds = CUnsignedLong(timeInterval * 1000)
                        //                    NSLog("findSpots completion took: " + String(milliseconds) + " milliseconds")
                        //                    NSLog("findSpots completion - ended at: %@", format.stringFromDate(NSDate()))
                        
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
        
        //remove overlays and annotations no longer on the screen
        let visibleMapRect = self.mapView.visibleMapRect
        
        var nonVisibleOverlays = lineAnnotations.filter { (var line: LineParkingSpot) -> Bool in
            !line.intersectsMapRect(visibleMapRect)
        }
        var visibleOverlays = lineAnnotations.filter { (var line: LineParkingSpot) -> Bool in
            line.intersectsMapRect(visibleMapRect)
        }

        var nonVisibleAnnotations = centerButtonAnnotations.filter { (var button) -> Bool in
            !MKMapRectContainsPoint(visibleMapRect, MKMapPointForCoordinate(button.coordinate))
        }
        var visibleAnnotations = centerButtonAnnotations.filter { (var button) -> Bool in
            MKMapRectContainsPoint(visibleMapRect, MKMapPointForCoordinate(button.coordinate))
        }

        var overlaysToAdd = overlays.filter { (var line: LineParkingSpot) -> Bool in
            !contains(visibleOverlays, line)
        }
        var annotationsToAdd = annotations.filter { (var button) -> Bool in
            !contains(visibleAnnotations, button)
        }

        self.lineAnnotations = overlays
        self.centerButtonAnnotations = annotations

//        //it's more efficient to do everything in the background and then only update the annotations we need, finally moving into the main thread for the actual adding
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.removeOverlays(nonVisibleOverlays)
            self.mapView.removeAnnotations(nonVisibleAnnotations)

            self.mapView.addOverlays(overlaysToAdd)
            self.mapView.addAnnotations(annotationsToAdd)
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
    
    override func trackUser(shouldTrack: Bool) {
        self.mapView.userTrackingMode = shouldTrack ? MKUserTrackingMode.Follow : MKUserTrackingMode.None
        
    }
    
    func removeAllAnnotations() {
        //removes the user location too?
        var annotationsToRemove = mapView.annotations
        mapView.removeAnnotations(annotationsToRemove)
        var overlaysToRemove = mapView.overlays
        mapView.removeOverlays(overlaysToRemove)
    }
    
}