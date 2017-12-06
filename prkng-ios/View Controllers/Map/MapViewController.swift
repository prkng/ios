//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-11.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum MapMode: Int {
    case garage = 0
    case streetParking
    case carSharing
}

enum MapUserMode: String {
    case None = "None"
    case Follow = "Follow"
    case FollowWithHeading = "FollowWithHeading"
}

class MapViewController: AbstractViewController {

    var mapModeImageView: UIView?
    var mapMode: MapMode = .streetParking {
        didSet {
            
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: { () -> Void in
                
                if self.updateInProgress {
                    self.sema.wait(timeout: DispatchTime.distantFuture)
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.didSetMapMode()
                    
                    //take a screenshot of the current view, do whatever needs to be done, and when a callback returns fade into the "new" view
                    self.removeSnapshot()
                    
//                    let snapshotView = self.view.snapshotViewAfterScreenUpdates(false)
//                    self.mapModeImageView = snapshotView
//                    self.mapModeImageView?.userInteractionEnabled = false
//                    self.view.addSubview(self.mapModeImageView!)
                    
                    SVProgressHUD.setBackgroundColor(UIColor.clear)
                    SVProgressHUD.show()
                    
                    self.removeRegularAnnotations()
                    
                    self.mapModeDidChange { () -> Void in
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            self.mapModeImageView?.alpha = 0
                            }, completion: { (completed) -> Void in
                                SVProgressHUD.dismiss()
                                self.removeSnapshot()
                        }) 
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
                sema = DispatchSemaphore(value: 0)
            } else {
                self.sema.signal()
            }
        }
    }
    var sema = DispatchSemaphore(value: 0)
    var myCarAnnotation: NSObject?
    var searchCheckinDate : Date?
    var searchDuration : Float?
    var wasShown : Bool = false
    var shouldCancelTap = false
    var returnNearestAnnotations: Int = 0
    
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
    func displaySearchResults(_ results: Array<SearchResult>, checkinTime : Date?) { }
    func clearSearchResults() { }
    func showUserLocation(_ shouldShow: Bool) { }
    func setMapUserMode(_ mode: MapUserMode) { }
    
    func updateAnnotations() {
        if self.updateInProgress {
            NSLog("update already in progress, fuggetaboutit")
            return
        }
        self.updateAnnotations { (operationCompleted: Bool) -> Void in
            self.removeSnapshot()
        }
    }
    func updateAnnotations(_ completion: ((_ operationCompleted: Bool) -> Void)) { }

    func goToCoordinate(_ coordinate: CLLocationCoordinate2D, named name: String, withZoom zoom:Float? = nil, showing: Bool = true) { }
    
    func showForFirstTime() { }

    func addMyCarMarker() { }
    func removeMyCarMarker() { }
    func removeSelectedAnnotationIfExists() { }
    func removeRegularAnnotations() { }

    func addCityOverlays() {
        getCityOverlays()
    }
    
    func addCityOverlaysCallback(_ polygons: [MKPolygon]) { }

    fileprivate func getCityOverlays() {
        
        let url = APIUtility.rootURL() + "areas"
        
        let currentVersion = UserDefaults.standard.integer(forKey: "city_overlays_version")
        
        if currentVersion == 0 {
            let offlineUrl = Bundle.main.url(forResource: "AvailabilityMap", withExtension: "json")
            let data = try? Data(contentsOf: offlineUrl!)
            UserDefaults.standard.setValue(data!, forKey: "city_overlays")
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
    
    fileprivate func downloadCityOverlays(_ supportedArea: SupportedArea) {
        
        if supportedArea.versions.count > 0 {
            let url = supportedArea.versions[supportedArea.latestVersion]!["geojson_addr"]
            request(.GET, URLString: url!, parameters: nil).response { (request, response, object, error) -> Void in
                
                let data = object as! Data
                if response?.statusCode < 400 && error == nil {
                    
                    UserDefaults.standard.setValue(supportedArea.latestVersion, forKey: "city_overlays_version")
                    
                    //if data is zipped... unzip it
                    let jsonData: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    if jsonData != nil {
                        UserDefaults.standard.setValue(data, forKey: "city_overlays")
                    } else {
                        //the data needs to be unzipped
                        let uncompressedData = (data as NSData).gunzipped()!
                        UserDefaults.standard.setValue(uncompressedData, forKey: "city_overlays")
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
    
    fileprivate func returnCityOverlays() -> [MKPolygon] {
        
        if let data = UserDefaults.standard.data(forKey: "city_overlays") {
            let json = (try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as! [AnyHashable: Any]
            
            if let overlays = (try? GeoJSONSerialization.shapes(fromGeoJSONFeatureCollection: json)) as? [MKPolygon] {
                return overlays
            }
        }

        return []
    }
    
    func isFarAwayFromAvailableCities(_ centerCoordinate: CLLocationCoordinate2D) -> Bool {
        
        var inAnAvailableCity = false
        
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        for location in CityOperations.sharedInstance.availableCityLocations() {
            let distanceInKm = centerLocation.distance(from: location) as Double / 1000
            if distanceInKm < 40 {
                inAnAvailableCity = true
            }
        }
        
        return !inAnAvailableCity

    }

    func mapModeDidChange(_ completion: (() -> Void)) {
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
    
    func didSelectObject (_ detailsObject : DetailObject)
        
    func showMapMessage(_ message: String?)
    func showMapMessage(_ message: String?, onlyIfPreviouslyShown: Bool, showCityPicker: Bool)
    
    func mapDidMoveFarAwayFromAvailableCities()
    
    func loadMyCarTab()
    
    //returns the number of hours to search for as a minimum parking duration
    func activeFilterDuration() -> Float?
    func activeCarsharingPermit() -> Bool
    func carSharingMode() -> CarSharingMode
    
}
