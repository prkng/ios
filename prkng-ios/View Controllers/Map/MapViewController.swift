//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-11.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum MapMode: Int {
    case Garage = 0
    case StreetParking
    case CarSharing
}

enum MapUserMode: String {
    case None = "None"
    case Follow = "Follow"
    case FollowWithHeading = "FollowWithHeading"
}

class MapViewController: AbstractViewController {

    var mapModeImageView: UIView?
    var mapMode: MapMode = .StreetParking {
        didSet {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                
                if self.updateInProgress {
                    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.didSetMapMode()
                    
                    //take a screenshot of the current view, do whatever needs to be done, and when a callback returns fade into the "new" view
                    self.removeSnapshot()
                    
//                    let snapshotView = self.view.snapshotViewAfterScreenUpdates(false)
//                    self.mapModeImageView = snapshotView
//                    self.mapModeImageView?.userInteractionEnabled = false
//                    self.view.addSubview(self.mapModeImageView!)
                    
                    SVProgressHUD.setBackgroundColor(UIColor.clearColor())
                    SVProgressHUD.show()
                    
                    self.removeRegularAnnotations()
                    
                    self.mapModeDidChange { () -> Void in
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.mapModeImageView?.alpha = 0
                            }) { (completed) -> Void in
                                SVProgressHUD.dismiss()
                                self.removeSnapshot()
                        }
                    }
                })
            })
        }
    }
    
    var delegate: MapViewControllerDelegate?
    
    func didTapTrackUserButton () { }
    func trackUser() { }
    func dontTrackUser() { }

    var canShowMapMessage: Bool = false
    var updateInProgress: Bool = false {
        didSet {
            if updateInProgress {
                sema = dispatch_semaphore_create(0)
            } else {
                dispatch_semaphore_signal(self.sema)
            }
        }
    }
    var sema = dispatch_semaphore_create(0)
    var myCarAnnotation: NSObject?
    var searchCheckinDate : NSDate?
    var searchDuration : Float?
    var wasShown : Bool = false
    var shouldCancelTap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSetMapMode() { }
    func setDefaultMapZoom() { }
    func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) { }
    func clearSearchResults() { }
    func showUserLocation(shouldShow: Bool) { }
    func setMapUserMode(mode: MapUserMode) { }
    
    func updateAnnotations() {
        if self.updateInProgress {
            NSLog("update already in progress, fuggetaboutit")
            return
        }
        self.updateAnnotations { (operationCompleted: Bool) -> Void in
            self.removeSnapshot()
        }
    }
    func updateAnnotations(completion: ((operationCompleted: Bool) -> Void)) { }

    func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, withZoom zoom:Float? = nil, showing: Bool = true) { }
    
    func showForFirstTime() { }

    func addMyCarMarker() { }
    func removeMyCarMarker() { }
    func removeSelectedAnnotationIfExists() { }
    func removeRegularAnnotations() { }

    func addCityOverlays() {
        getCityOverlays()
    }
    
    func addCityOverlaysCallback(polygons: [MKPolygon]) { }

    private func getCityOverlays() {
        
        let url = APIUtility.rootURL() + "areas"
        
        let currentVersion = NSUserDefaults.standardUserDefaults().integerForKey("city_overlays_version")
        
        if currentVersion == 0 {
            let offlineUrl = NSBundle.mainBundle().URLForResource("AvailabilityMap", withExtension: "json")
            let data = NSData(contentsOfURL: offlineUrl!)
            NSUserDefaults.standardUserDefaults().setValue(data!, forKey: "city_overlays")
        }
        
        request(.GET, URLString: url, parameters: nil).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            if response?.statusCode < 400 && error == nil && !json.isEmpty {
                let supportedArea = SupportedArea(json: json)
                if supportedArea.latestVersion == currentVersion {
                    let cityOverlays = self.returnCityOverlays()
                    self.addCityOverlaysCallback(cityOverlays)
                } else {
                    //download and upon successful completion set the new version
                    self.downloadCityOverlays(supportedArea)
                }
            }
            
        }
    }
    
    private func downloadCityOverlays(supportedArea: SupportedArea) {
        
        if supportedArea.versions.count > 0 {
            let url = supportedArea.versions[supportedArea.latestVersion]!["geojson_addr"]
            request(.GET, URLString: url!, parameters: nil).response { (request, response, object, error) -> Void in
                
                let data = object as! NSData
                if response?.statusCode < 400 && error == nil {
                    
                    NSUserDefaults.standardUserDefaults().setValue(supportedArea.latestVersion, forKey: "city_overlays_version")
                    
                    //if data is zipped... unzip it
                    let jsonData: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    if jsonData != nil {
                        NSUserDefaults.standardUserDefaults().setValue(data, forKey: "city_overlays")
                    } else {
                        //the data needs to be unzipped
                        let uncompressedData = data.gunzippedData()!
                        NSUserDefaults.standardUserDefaults().setValue(uncompressedData, forKey: "city_overlays")
                    }
                    
                }
                
                let cityOverlays = self.returnCityOverlays()
                self.addCityOverlaysCallback(cityOverlays)
                
            }
        } else {
            let cityOverlays = self.returnCityOverlays()
            self.addCityOverlaysCallback(cityOverlays)
        }

    }
    
    private func returnCityOverlays() -> [MKPolygon] {
        
        if let data = NSUserDefaults.standardUserDefaults().dataForKey("city_overlays") {
            let json = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as! [NSObject : AnyObject]
            
            if let overlays = (try? GeoJSONSerialization.shapesFromGeoJSONFeatureCollection(json)) as? [MKPolygon] {
                return overlays
            }
        }

        return []
    }
    
    func isFarAwayFromAvailableCities(centerCoordinate: CLLocationCoordinate2D) -> Bool {
        
        var inAnAvailableCity = false
        
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        for location in CityOperations.sharedInstance.availableCityLocations() {
            let distanceInKm = centerLocation.distanceFromLocation(location) as Double / 1000
            if distanceInKm < 40 {
                inAnAvailableCity = true
            }
        }
        
        return !inAnAvailableCity

    }

    func mapModeDidChange(completion: (() -> Void)) {
        completion()
    }
    
    func removeSnapshot() {
        if mapModeImageView != nil {
            mapModeImageView?.removeFromSuperview()
            mapModeImageView = nil
        }
    }
    

}

protocol MapViewControllerDelegate {
    
    var trackUserButton: UIButton { get }
    
    func mapDidDismissSelection(byUser wasUserAction: Bool)
    func mapDidTapIdly()
    
    func didSelectObject (detailsObject : DetailObject)
        
    func showMapMessage(message: String?)
    func showMapMessage(message: String?, onlyIfPreviouslyShown: Bool, showCityPicker: Bool)
    
    func mapDidMoveFarAwayFromAvailableCities()
    
    func loadMyCarTab()
    
    //returns the number of hours to search for as a minimum parking duration
    func activeFilterDuration() -> Float?
    func activeCarsharingPermit() -> Bool
    func carSharingMode() -> CarSharingMode
    
}