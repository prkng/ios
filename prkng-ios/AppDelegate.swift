//
//  AppDelegate.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 26/01/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import MessageUI
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, PRKDialogViewControllerDelegate, MFMailComposeViewControllerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()

    func loggedInOperations() {
        if AuthUtility.loggedIn() {
            initiateLocationManagerAndPermissions()
            initiateNotificationPermissions()
        }
    }
    
    func initiateLocationManagerAndPermissions() {
        //register for background location usage for updates
        locationManager.delegate = self
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        }
        
        //send analytics on the location manager status
        let currentLocationManagerStatus = CLLocationManager.authorizationStatus()
        if Settings.getLastLocationManagerStatus() != currentLocationManagerStatus {
            AnalyticsOperations.locationPermission(currentLocationManagerStatus, completion: { (completed) -> Void in
                if completed {
                    Settings.setLastLocationManagerStatus(currentLocationManagerStatus)
                }
            })
        }
        locationManager.startUpdatingLocation()
    }
    
    func initiateNotificationPermissions() {
        //
        //notification set up
        //
        let application = UIApplication.shared
        
        if #available(iOS 8.0, *) {
            let yesAction = UIMutableUserNotificationAction()
            yesAction.identifier = "yes"
            yesAction.title = "yes".localizedString
            yesAction.activationMode = .background
            yesAction.isAuthenticationRequired = false
            
            let noAction = UIMutableUserNotificationAction()
            noAction.identifier = "no"
            noAction.title = "no".localizedString
            noAction.activationMode = .background
            noAction.isAuthenticationRequired = false
            
            let category = UIMutableUserNotificationCategory()
            category.identifier = "prkng_check_out_monitor"
            category.setActions([yesAction, noAction], for: UIUserNotificationActionContext.default)
            
            if(UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))){
                application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: (NSSet(object: category) as! Set<UIUserNotificationCategory>)))
            }
        }
        
        if #available(iOS 8.0, *) {
            application.registerForRemoteNotifications()
            //the types are registered above with registerUserNotificationSettings
        } else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .badge, .alert])
        }
        
    }
    
    @available(iOS 9.1, *)
    func initiateDynamicShortcutItems() {
        let application = UIApplication.shared

        // Install initial versions of our two extra dynamic shortcuts.
        if let shortcutItems = application.shortcutItems, shortcutItems.isEmpty {
            // Construct the items.
            let shortcut1 = UIMutableApplicationShortcutItem(type: "ng.prk.prkng-ios.on-street", localizedTitle: "Park On-Street", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.markLocation), userInfo: nil)

            let shortcut2 = UIMutableApplicationShortcutItem(type: "ng.prk.prkng-ios.lots", localizedTitle: "Find a Parking Lot", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.markLocation), userInfo: nil)

            let shortcut3 = UIMutableApplicationShortcutItem(type: "ng.prk.prkng-ios.carshares", localizedTitle: "Find a Car", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.markLocation), userInfo: nil)
            
            let shortcut4 = UIMutableApplicationShortcutItem(type: "ng.prk.prkng-ios.search", localizedTitle: "Search", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.search), userInfo: nil)
            
            // Update the application providing the initial 'dynamic' shortcut items.
            application.shortcutItems = [shortcut1, shortcut2, shortcut3, shortcut4]
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let tabController = window?.rootViewController as? TabController {
            if shortcutItem.type == "ng.prk.prkng-ios.on-street" {
                tabController.loadHereTabWithSliderValue(1)
            } else if shortcutItem.type == "ng.prk.prkng-ios.lots" {
                tabController.loadHereTabWithSliderValue(0)
            } else if shortcutItem.type == "ng.prk.prkng-ios.carshares" {
                tabController.loadHereTabWithSliderValue(2)
            } else if shortcutItem.type == "ng.prk.prkng-ios.search" {
                tabController.loadSearchInHereTab()
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //used to debug app transport security
//        setenv("CFNETWORK_DIAGNOSTICS", "3", 1)
        
        loggedInOperations()
        
        if #available(iOS 9.1, *) {
            initiateDynamicShortcutItems()
        }
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
                
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        RMConfiguration.sharedInstance().accessToken = "pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA"
//        MBXMapKit.setAccessToken("pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA")
//        MGLAccountManager.setAccessToken("pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA")
        GMSServices.provideAPIKey("AIzaSyAjtDb1VW1rnICr_JMFPmzWi3pMshLusA8")

//        Crashlytics.startWithAPIKey("0a552ed905e273700bb769724c451c706ceb78cb")
        Fabric.with([Crashlytics()])
        
        //google analytics setup...
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance().dispatchInterval = 20;
        // Optional: set Logger to VERBOSE for debug information.
        GAI.sharedInstance().logger.logLevel = GAILogLevel.error
        // Initialize tracker. Replace with your tracking ID.
        GAI.sharedInstance().tracker(withTrackingId: "UA-63856349-1")
        
        //configure cocoa lumberjack for logging
        DDLog.add(DDASLLogger.sharedInstance())
        DDLog.add(DDTTYLogger.sharedInstance())

        let fileLogger = DDFileLogger()
        fileLogger?.rollingFrequency = 60 * 60 * 24 // 24 hour rolling
        fileLogger?.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        let filePath = fileLogger?.currentLogFileInfo().filePath
        DDLoggerWrapper.logInfo(String(format: "log file at: %@", filePath!))
        Settings.setLogFilePath(filePath)

        configureGlobals()
        loadInitialViewController()
        
        //configure IQKeyboardManager
        IQKeyboardManager.shared().considerToolbarPreviousNext(inViewClass: PRKInputForm)
        IQKeyboardManager.shared().disableToolbar(inViewControllerClass: NotesModalViewController)//reports
        IQKeyboardManager.shared().disableToolbar(inViewControllerClass: FilterViewController)
        IQKeyboardManager.shared().disableToolbar(inViewControllerClass: LoginEmailViewController)
        IQKeyboardManager.shared().disableToolbar(inViewControllerClass: RegisterEmailViewController)
        IQKeyboardManager.shared().disableToolbar(inViewControllerClass: PPSignInViewController)
        IQKeyboardManager.shared().disableToolbar(inViewControllerClass: PPCreateUserViewController)
        IQKeyboardManager.shared().shouldShowTextFieldPlaceholder = false

        // Override point for customization after application launch.
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        //removes lag when opening the keyboard for the first time on certain devices
        let lagFreeField = UITextField()
        self.window?.addSubview(lagFreeField)
        lagFreeField.becomeFirstResponder()
        lagFreeField.resignFirstResponder()
        lagFreeField.removeFromSuperview()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        DirectionsAction.removeDirectionRegionMonitoring()
        FBSDKAppEvents.activateApp()
        
        if let tabController = window?.rootViewController as? TabController {
            tabController.updateTabBar()
            
            if Settings.shouldPromptUserToRateApp() {
                let dialogVC = PRKDialogViewController(titleIconName: "icon_review", headerImageName: "review_header", titleText: "review_title_text".localizedString, subTitleText: "review_message_text".localizedString, messageText: "", buttonLabels: ["review_rate_us".localizedString, "review_feedback".localizedString, "dismiss".localizedString])
                dialogVC.delegate = self
                dialogVC.showOnViewController(tabController)
            }

        }
        
        if let data = UserDefaults.standard.object(forKey: "prkng_check_out_monitor_notification") as? Data {
            let alert = NSKeyedUnarchiver.unarchiveObject(with: data) as! UILocalNotification
            UIApplication.shared.presentLocalNotificationNow(alert)
        }

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if (url.scheme?.lowercased() == "fb1043720578978201") {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        } else if (url.relativeString ?? "").contains(CarSharingOperations.Car2Go.callbackURLString) {
            return true
        } else {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "registeredUserNotificationSettings"), object: nil)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .trimmingCharacters( in: characterSet )
            .replacingOccurrences( of: " ", with: "" ) as String
        
        DDLoggerWrapper.logInfo(String(format: "Did Register for Remote Notifications with Device Token (%@), stringified: %@", deviceToken as CVarArg, deviceTokenString))
        
        UserOperations.helloItsMe(deviceTokenString) { (completed) -> Void in
        }

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DDLoggerWrapper.logError(String(format: "Did Fail to Register for Remote Notifications.\n Error: %@, %@", error as CVarArg, error.localizedDescription))
        UserOperations.helloItsMe(nil) { (completed) -> Void in
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        DDLoggerWrapper.logInfo(String(format: "Received a remote notification."))
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        let identifier = notification.userInfo != nil ? (notification.userInfo as! [NSObject:String])["identifier"]! : ""
        
        if identifier == "regular_app_notification" {
            let alert = UIAlertView()
            alert.message = notification.alertBody
            alert.addButton(withTitle: "OK")
            alert.show()
            Settings.cancelScheduledNotifications()
        } else if identifier == "prkng_check_out_monitor" {

            //present the custom dialog
            let spotName = Settings.checkedInSpot()?.name ?? ""
            
            let dialogVC = PRKDialogViewController(titleIconName: "icon_howto_checkin", headerImageName: "checkout_question_header", titleText: "on_the_go".localizedString, subTitleText: "left_this_spot_question".localizedString, messageText: "\"" + spotName + "\"")

            Settings.clearNotificationBadgeAndNotificationCenter()

            if window?.rootViewController != nil && window!.rootViewController!.childViewControllers .contains(where: { (vc: UIViewController) -> Bool in
                vc is PRKDialogViewController && (vc as! PRKDialogViewController).titleText == "on_the_go".localizedString
            }) {
                //the dialog is already showing, don't show it again
                return
            }
            
            if let tabController = window?.rootViewController as? TabController {
                dialogVC.showOnViewController(tabController)
            }
            
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {

        let notificationIdentifier = notification.userInfo != nil ? (notification.userInfo as! [NSObject:String])["identifier"]! : ""

        if notificationIdentifier == "prkng_check_out_monitor" {

            application.cancelLocalNotification(notification)
            let answeredYes = identifier == "yes" ? true : false
            geofencingNotificationResponse(answeredYes)
        }
        
        completionHandler()
    }

    func keyboardWasShown(_ notification: Notification) {
        
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        UserDefaults.standard.setValue(keyboardSize.height, forKey: "last_keyboard_height")
    }
    
    
    // MARK: Helper

    func configureGlobals() {
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        Settings.setLastAppVersionString(version)

        //we used to do this when we cached the lots...
//        Settings.setCachedLotDataFresh(false)
//        LotOperations.sharedInstance.findLots(Settings.selectedCity().coordinate, radius: 1.0) { (lots, underMaintenance, outsideServiceArea, error) -> Void in }
        
        GiFHUD.setGif("loader.gif")

        SVProgressHUD.setRingThickness(4)
        SVProgressHUD.setCornerRadius(0)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setForegroundColor(Styles.Colors.red2)
        SVProgressHUD.setDefaultStyle(.custom)
    }

    func loadInitialViewController() {

        if (Settings.firstUse() || AuthUtility.getUser() == nil || AuthUtility.loginType() == nil) {
            AuthUtility.saveAuthToken(nil)
            AuthUtility.saveUser(nil)
            window!.rootViewController = FirstUseViewController()
        } else {
            window!.rootViewController = TabController()
            Settings.incrementAppLaunches()
        }
        
        window!.makeKeyAndVisible()
    }
    
    // MARK: CLLocationManagerDelegate methods

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "changedLocationPermissions"), object: nil)
    }
    
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        
//        //test this instead of region updates...
//        for region in self.locationManager.monitoredRegions as! Set<CLCircularRegion> {
//            for location in locations as! [CLLocation] {
//                if region.identifier.rangeOfString("prkng_check_out_monitor") != nil
//                && region.containsCoordinate(location.coordinate) {
//                    //We've entered one of our regions! Handle it!
//                    let date = Settings.geofenceLastSetOnInterval()
//                    let timeInterval = location.timestamp.timeIntervalSinceReferenceDate
////                    NSLog("%d",timeInterval)
//                    if ((date - timeInterval) / 60) > 5 {
//                        handleRegionEntered(location.coordinate)
//                    }
//                }
//            }
//
//        }
//        
//        
//    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == DirectionsAction.prkng_directions_monitor {
            DirectionsAction.handleDirectionRegionEntered()
        } else {
            handleCheckOutRegionEntered((region as! CLCircularRegion).center)
        }
//        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == DirectionsAction.prkng_directions_monitor {
            DirectionsAction.removeDirectionRegionMonitoring()
        } else {
            handleCheckOutRegionExited((region as! CLCircularRegion).center)
        }
//        self.locationManager.stopUpdatingLocation()
    }
    
    //MARK: Notification handling
    
    //this is what we consider to be an estimated checkout
    //take all the monitored regions and turn them into checkout regions
    func handleCheckOutRegionEntered(_ center: CLLocationCoordinate2D) {
        
        //stop monitoring regions, turn the identifiers into "prkng_check_out_monitor_entered_region"
        for monitoredRegion in self.locationManager.monitoredRegions as! Set<CLCircularRegion> {
            if monitoredRegion.identifier.range(of: "prkng_check_out_monitor") != nil {
                self.locationManager.stopMonitoring(for: monitoredRegion)
                let newMonitoredRegion = CLCircularRegion(center: monitoredRegion.center, radius: monitoredRegion.radius, identifier: "prkng_check_out_monitor_entered_region")
                self.locationManager.startMonitoring(for: newMonitoredRegion)
                DDLoggerWrapper.logVerbose("Turned region monitoring id from " + monitoredRegion.identifier + " to " + newMonitoredRegion.identifier)
            }
        }
        
        //analytics
        AnalyticsOperations.sharedInstance.geofencingEvent(center, entering: true) { (completed) -> Void in
        }

    }

    //this is what we consider to be an estimated checkout
    //if we are leaving AFTER having entered, then we execute! 
    //otherwise we do nothing and simply wait for the region to be entered
    func handleCheckOutRegionExited(_ center: CLLocationCoordinate2D) {
        
        //see if there are regions that the user exited after entering
        var found = false
        for monitoredRegion in self.locationManager.monitoredRegions as! Set<CLCircularRegion> {
            if monitoredRegion.identifier.range(of: "prkng_check_out_monitor_entered_region") != nil
                && monitoredRegion.center.latitude == center.latitude
                && monitoredRegion.center.longitude == center.longitude {
                    found = true
            }
        }
        if !found {
            DDLoggerWrapper.logVerbose("Region monitoring id prkng_check_out_monitor_entered_region not found.")
            return
        }
        
        //we are exiting after having entered... deliver the notification

        //stop monitoring ALL regions
        Settings.clearRegionsMonitored()
        
        let spotName = Settings.checkedInSpot()?.name ?? ""
        
        //next create the alert
        let alert = UILocalNotification()
        alert.userInfo = ["identifier" : "prkng_check_out_monitor"]
        alert.applicationIconBadgeNumber = 1
        if #available(iOS 8.2, *) {
            alert.alertTitle = "on_the_go".localizedString
        }
        alert.alertBody = String(format: "left_spot_question".localizedString, spotName)
        alert.soundName = UILocalNotificationDefaultSoundName
        if #available(iOS 8.0, *) {
            alert.category = "prkng_check_out_monitor"
        }
        
        DDLoggerWrapper.logVerbose("Presenting local notification for a monitored region.")
        UIApplication.shared.presentLocalNotificationNow(alert)

        let data = NSKeyedArchiver.archivedData(withRootObject: alert)
        UserDefaults.standard.set(data, forKey: "prkng_check_out_monitor_notification")
        
        //analytics
        AnalyticsOperations.sharedInstance.geofencingEvent(center, entering: false) { (completed) -> Void in
        }
        
    }

    func geofencingNotificationResponse(_ answeredYes: Bool) {
        
        UserDefaults.standard.removeObject(forKey: "prkng_check_out_monitor_notification")
        Settings.clearRegionsMonitored()
        Settings.clearNotificationBadgeAndNotificationCenter()
        
        if answeredYes {
            
            SpotOperations.checkout({ (completed) -> Void in
                Settings.checkOut()

                if let tabController = self.window?.rootViewController as? TabController {
                    tabController.updateTabBar()
                }

            })
            //analytics
            AnalyticsOperations.sharedInstance.geofencingEventUserResponse(true, completion: { (completed) -> Void in })
            
        } else {
            
            if let tabController = self.window?.rootViewController as? TabController {
                tabController.updateTabBar()
            }

            //analytics
            AnalyticsOperations.sharedInstance.geofencingEventUserResponse(false, completion: { (completed) -> Void in })

        }
        
    }
    
    //MARK: PRKDialogViewControllerDelegate methods

    func listButtonTapped(_ index: Int) {

        if index == 0 {
            //rate it now!
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id999834216")!)
        } else if index == 1 {
            //send feedback?
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setSubject("feedback".localizedString)
            mailVC.setToRecipients(["hello@prk.ng"])
            window?.rootViewController?.present(mailVC, animated: true, completion: nil)
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

