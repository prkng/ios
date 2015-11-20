//
//  PrkTabBarController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 24/03/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import QuartzCore


class TabController: GAITrackedViewController, PrkTabBarDelegate, MapViewControllerDelegate, SearchViewControllerDelegate, HereViewControllerDelegate, MyCarAbstractViewControllerDelegate, SettingsViewControllerDelegate, CLLocationManagerDelegate {
    
    var selectedTab : PrkTab
    
    var tabBar : PrkTabBar
    var containerView : UIView
    
    var mapViewController : MapViewController
    
    var searchViewController : SearchViewController?
    var hereViewController : HereViewController
    
    var settingsViewController : SettingsViewController?
    
    var activeViewController : UIViewController
    
    var switchingMainView : Bool
    
    var locationManager = CLLocationManager()
    var locationFixAchieved : Bool = false

    init () {
        selectedTab = PrkTab.None
        tabBar = PrkTabBar()
        containerView = UIView()
        switchingMainView = false
        let mapType = NSUserDefaults.standardUserDefaults().integerForKey("map_type")
        switch mapType {
//        case 1:
//            mapViewController = MKMapViewController()
//            break
//        case 2:
//            mapViewController = GoogleMapViewController()
//            break
        default:
            mapViewController = RMMapViewController()
            Settings.setShouldFilterForCarSharing(mapViewController.mapMode == .CarSharing)
            break
        }
        hereViewController = HereViewController()
        activeViewController = hereViewController
        super.init(nibName: nil, bundle: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goToCoordinateNotificationPosted:", name: "goToCoordinate", object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        
        setupViews()
        setupConstraints()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.screenName = "Tab Bar - Controller"
        
        selectedTab = PrkTab.Here
        hereViewController.willMoveToParentViewController(self)
        addChildViewController(hereViewController)
        containerView.addSubview(hereViewController.view)
        tabBar.updateSelected()
        hereViewController.delegate = self
        hereViewController.filterVC.searchFilterView.delegate = self
        hereViewController.view.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.containerView)
        }
        
        if Settings.checkedIn() || Settings.getReservedCarShare() != nil {
            loadMyCarTab()
        }
        
        setCurrentCityFromUserLocation()
        
    }
    
    func setCurrentCityFromUserLocation() {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
    }
    
    func setupViews() {
        
        //making the background white makes the odd blur view not bleed in with the regular black that's normally below it. Take this out and experiment with hiding/showing the bottom slider to see what I mean :)
        self.view.backgroundColor = Styles.Colors.white
        
        containerView.clipsToBounds = true
        view.addSubview(containerView)

        mapViewController.delegate = self
        addChildViewController(mapViewController)
        mapViewController.willMoveToParentViewController(self)
        containerView.addSubview(mapViewController.view)
        
        tabBar.delegate = self
        tabBar.backgroundColor = Styles.Colors.stone
        tabBar.layer.shadowColor = UIColor.blackColor().CGColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowRadius = 0.5
        view.addSubview(tabBar)
    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.tabBar.snp_top)
        }
        
        tabBar.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.tabbarHeight)
        }
        
        /// child view controllers
        
        mapViewController.view.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.containerView)
        }
        
    }
    
    
    func handleTabBadge() {
        
        if Settings.hasNotificationBadge() {
            tabBar.myCarButton.badge.hidden = false
        } else {
            tabBar.myCarButton.badge.hidden = true
        }
        
    }

    // PrkTabBarDelegate
    
    func activeTab() -> PrkTab {
        return selectedTab
    }
//    
//    func loadSearchTab() {
//        if (selectedTab == PrkTab.Search || switchingMainView) {
//            return;
//        }
//                
//        if (searchViewController == nil) {
//            searchViewController = SearchViewController()
//            searchViewController!.delegate = self
//        }
//        
//        searchViewController!.markerIcon.hidden = false
//        mapViewController.mapView.zoom = 17
//        mapViewController.trackUserButton.hidden = true
//        mapViewController.mapView.showsUserLocation = false
//        mapViewController.mapView.userTrackingMode = MKUserTrackingMode.None
//        
//        
//        switchActiveViewController(searchViewController!, completion: { (finished) -> Void in
//            self.selectedTab = PrkTab.Search
//            self.tabBar.updateSelected()
//        })
//        
//        
//    }
    
    func loadHereTab() {
        if (selectedTab == PrkTab.Here || switchingMainView) {
            return;
        }
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        mapViewController.removeSelectedAnnotationIfExists()
        mapViewController.clearSearchResults()
        mapViewController.showUserLocation(true)
        
        switchActiveViewController(hereViewController, completion: { (finished) -> Void in
            self.selectedTab = PrkTab.Here
            self.tabBar.updateSelected()
        })
        
        self.mapViewController.showForFirstTime()
        
    }
    
    func loadSearchInHereTab() {
        loadHereTab()
        hereViewController.showFiltersOnAppear = true
    }
    
    
    
    func loadMyCarTab() {
        if (selectedTab == PrkTab.MyCar || switchingMainView) {
            return;
        }
        
        UIApplication.sharedApplication().idleTimerDisabled = false

        var myCarViewController : AbstractViewController?
        
        if Settings.getReservedCarShare() != nil {
            myCarViewController = MyCarReservedCarShareViewController()
            (myCarViewController as! MyCarReservedCarShareViewController).delegate = self
        } else if (Settings.checkedIn()) {
            myCarViewController = MyCarCheckedInViewController()
            (myCarViewController as! MyCarCheckedInViewController).delegate = self
        } else {
            myCarViewController = MyCarNoCheckinViewController()
            (myCarViewController as! MyCarNoCheckinViewController).delegate = self
        }

        let navigationController = UINavigationController(rootViewController: myCarViewController!)
        navigationController.navigationBarHidden = true        

        switchActiveViewController(navigationController, completion: { (finished) -> Void in
            self.selectedTab = PrkTab.MyCar
            self.tabBar.updateSelected()
        })
        
    }
    
    func loadSettingsTab() {
        if (selectedTab == PrkTab.Settings || switchingMainView) {
            return;
        }
        
        UIApplication.sharedApplication().idleTimerDisabled = false

        if(settingsViewController == nil) {
            settingsViewController = SettingsViewController()
        }
        
        settingsViewController?.delegate = self
        
        mapViewController.showUserLocation(false)
        mapViewController.setMapUserMode(MapUserMode.None)

        let navigationController = UINavigationController(rootViewController: settingsViewController!)
        navigationController.navigationBarHidden = true
        
        switchActiveViewController(navigationController, completion: { (finished) -> Void in
            self.selectedTab = PrkTab.Settings
            self.tabBar.updateSelected()
        })
        
    }
    
    
    func updateMapAnnotations() {
        mapViewController.updateAnnotations()
    }
    
    func setDefaultMapZoom() {
        mapViewController.setDefaultMapZoom()
    }
    
    func didSelectMapMode(mapMode: MapMode) {
        if mapMode != mapViewController.mapMode {
            mapViewController.mapMode = mapMode
        }
    }

    func didTapTrackUserButton() {
        self.mapViewController.didTapTrackUserButton()
    }

    func switchActiveViewController  (newViewController : UIViewController, completion : ((finished:Bool) -> Void)) {
        
        if switchingMainView {
            return
        }
        
        switchingMainView = true
        if let abstractVC = self.activeViewController as? AbstractViewController {
            abstractVC.addTransitionView()
        }
        newViewController.view.alpha = 0.0;
        newViewController.willMoveToParentViewController(self)
        addChildViewController(newViewController)
        containerView.addSubview(newViewController.view)
        
        newViewController.view.snp_remakeConstraints(closure: { (make) -> () in
            make.edges.equalTo(self.containerView)
        })
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.activeViewController.view.alpha = 0.0
            newViewController.view.alpha = 1.0
            
            }) { (finished) -> Void in
                self.activeViewController.removeFromParentViewController()
                self.activeViewController.view.removeFromSuperview()
                self.activeViewController.willMoveToParentViewController(nil)
                self.activeViewController = newViewController
                if let abstractVC = self.activeViewController as? AbstractViewController {
                    abstractVC.removeTransitionView()
                }
                self.switchingMainView = false
                completion(finished: finished)
        }
        
        updateTabBar()
        
    }
    
    func updateTabBar() {
        
        if selectedTab == PrkTab.MyCar {
            reloadMyCarTab()
        }
        handleTabBadge()
    }
    
    func showLoginViewController ()  {
        let loginViewController = LoginViewController()
        presentViewController(loginViewController, animated: true) { () -> Void in
            
        }
    }
    
    
    //MARK: MapViewControllerDelegate
    
    var trackUserButton: UIButton { return self.hereViewController.filterVC.trackUserButton }
    func mapDidDismissSelection(byUser wasUserAction: Bool) {
        if wasUserAction {
            hereViewController.updateDetails(nil)
            hereViewController.filterVC.hideFilters(completely: false)
        }
    }
    
    func carSharingMode() -> CarSharingMode {
        return self.hereViewController.filterVC.carSharingMode()
    }


    //used to show and hide the bottom slider
    func mapDidTapIdly() {
        
        if hereViewController.activeDetailObject == nil {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                if self.hereViewController.showModeSelection  {
                    self.hereViewController.modeSelection.snp_remakeConstraints { (make) -> () in
                        make.height.equalTo(60)
                        make.left.equalTo(self.hereViewController.view)
                        make.right.equalTo(self.hereViewController.view)
                        make.top.equalTo(self.hereViewController.view.snp_bottom)
                    }
                    self.hereViewController.showModeSelection = false
                } else {
                    self.hereViewController.modeSelection.snp_remakeConstraints { (make) -> () in
                        make.height.equalTo(60)
                        make.left.equalTo(self.hereViewController.view)
                        make.right.equalTo(self.hereViewController.view)
                        make.bottom.equalTo(self.hereViewController.view)
                    }
                    self.hereViewController.showModeSelection = true
                    
                }
                
                self.hereViewController.view.setNeedsLayout()
                self.hereViewController.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
            })
        }
        
    }
    
    func didSelectObject (detailsObject : DetailObject) {
        
        loadHereTab()
        if detailsObject.compact && detailsObject is ParkingSpot {
            //if after 100 msec we haven't already set a new object (or the object is still nil) then show "loading..."
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(100 * Double(NSEC_PER_MSEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                if self.hereViewController.activeDetailObject?.identifier != detailsObject.identifier {
                    self.hereViewController.updateDetails(DetailObjectLoading(parent: detailsObject))
                }
            })
            SpotOperations.getSpotDetails(detailsObject.identifier, completion: { (spot) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.hereViewController.updateDetails(spot)
                })
            })
        } else {
            hereViewController.updateDetails(detailsObject)            
        }
        
    }
        
    func showMapMessage(message: String?) {
        showMapMessage(message, onlyIfPreviouslyShown: false, showCityPicker: false)
    }
    
    func showMapMessage(message: String?, onlyIfPreviouslyShown: Bool, showCityPicker: Bool) {

        if message != nil {
            hereViewController.mapMessageView.mapMessageLabel.text = message
        }
        
        if !onlyIfPreviouslyShown {

            if showCityPicker {
                let cityPickerVC = CityPickerViewController(parent: self)
                cityPickerVC.showOnViewController(self)
            }
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.hereViewController.view.layoutIfNeeded()
                self.mapViewController.view.layoutIfNeeded()
                
                if message == nil {
                    
                    self.hereViewController.mapMessageView.snp_remakeConstraints { (make) -> () in
                        make.left.equalTo(self.hereViewController.view)
                        make.right.equalTo(self.hereViewController.view)
                        make.bottom.equalTo(self.hereViewController.view.snp_top)
                    }
                    
                    self.hereViewController.filterVC.view.snp_updateConstraints { (make) -> () in
                        make.top.equalTo(self.hereViewController.mapMessageView.snp_bottom)
                    }
                    
                } else {
                    
                    self.hereViewController.mapMessageView.snp_remakeConstraints { (make) -> () in
                        make.left.equalTo(self.hereViewController.view)
                        make.right.equalTo(self.hereViewController.view)
                        make.top.equalTo(self.hereViewController.view.snp_top)
                    }
                    
                    self.hereViewController.filterVC.view.snp_updateConstraints { (make) -> () in
                        make.top.equalTo(self.hereViewController.mapMessageView.snp_bottom).offset(-16)
                    }

                }
                
                self.hereViewController.view.layoutIfNeeded()

            })
        }
    }
    
    func mapDidMoveFarAwayFromAvailableCities() {
        
        showMapMessage("map_message_outside_service_area".localizedString, onlyIfPreviouslyShown: false, showCityPicker: true)

    }
    
    func activeFilterDuration() -> Float? {
        if self.activeCarsharingPermit() {
            return 24
        }
        let hours = hereViewController.filterVC.timeFilterView.selectedValueInHours()
        return hours
    }
    
    func activeCarsharingPermit() -> Bool {
        return Settings.shouldFilterForCarSharing()
    }
    
    
    // MARK: SearchViewControllerDelegate
    
    func setSearchParameters(time : NSDate?, duration : Float?) {
        mapViewController.searchCheckinDate = time
        mapViewController.searchDuration = duration
    }

    
    func displaySearchResults(results : Array<SearchResult>, checkinTime : NSDate?) {
        mapViewController.setMapUserMode(MapUserMode.None)
        mapViewController.displaySearchResults(results, checkinTime: checkinTime)
        self.hereViewController.filterVC.hideFilters(completely: false)
    }
    
    func clearSearchResults() {
        mapViewController.clearSearchResults()
    }
    
    func didGetAutocompleteResults(results: [SearchResult]) {
        hereViewController.filterVC.updateAutocompleteWithValues(results)
    }

    func startSearching() {
        hereViewController.filterVC.showFilters(resettingTimeFilterValue: true)
    }
    
    func endSearchingAndFiltering() {
        hereViewController.filterVC.hideFilters(completely: false)
    }
    
    // MARK: MyCarNoCheckinViewControllerDelegate
    
    
    // MARK : MyCarCheckedInViewControllerDelegate
    
    func reloadMyCarTab() {
        
        mapViewController.showUserLocation(false)
        mapViewController.setMapUserMode(MapUserMode.None)
        
        
        var myCarViewController : AbstractViewController?
        
        if Settings.getReservedCarShare() != nil {
            myCarViewController = MyCarReservedCarShareViewController()
            (myCarViewController as! MyCarReservedCarShareViewController).delegate = self
        } else if (Settings.checkedIn()) {
            myCarViewController = MyCarCheckedInViewController()
            (myCarViewController as! MyCarCheckedInViewController).delegate = self
        } else {
            myCarViewController = MyCarNoCheckinViewController()
            (myCarViewController as! MyCarNoCheckinViewController).delegate = self
        }
        
        let navigationController = UINavigationController(rootViewController: myCarViewController!)
        navigationController.navigationBarHidden = true
        
        switchActiveViewController(navigationController, completion: { (finished) -> Void in
            self.selectedTab = PrkTab.MyCar
            self.tabBar.updateSelected()
        })
        
    }
    
    func goToCoordinateNotificationPosted(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: AnyObject] {
            if let location = userInfo["location"] as? CLLocation, let name = userInfo["name"] as? String {
                goToCoordinate(location.coordinate, named: name)
            }
        }
    }

    // MARK: SettingsViewControllerDelegate
    
    func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, showing: Bool = true) {
        loadHereTab()
        self.mapViewController.setMapUserMode(MapUserMode.None)
        self.mapViewController.goToCoordinate(coordinate, named: name, withZoom: nil, showing: showing)
    }
    
    
    func cityDidChange(fromCity fromCity: City, toCity: City) {
        Settings.setSelectedCity(toCity)
        let coordinate = Settings.selectedCity().coordinate
        self.mapViewController.goToCoordinate(coordinate, named:toCity.displayName, withZoom:13, showing: false)
    }
    
    // MARK: Location Manager Delegate stuff
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let location = locations.last as CLLocation!
            let coord = location.coordinate
            
            print(coord.latitude)
            print(coord.longitude)
            
            manager.stopUpdatingLocation()
            
            CityOperations.sharedInstance.setClosestSelectedCity(coord)
        }
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            
            var locationStatus : NSString = "Not Started"
            
            var shouldIAllow = false
            
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }


}


enum PrkTab {
//    case Search
    case MyCar
    case Here
    case Settings
    case None
}