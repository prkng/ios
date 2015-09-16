//
//  AppDelegate.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 26/01/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        
//        //register for background location usage for updates
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
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
        
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        RMConfiguration.sharedInstance().accessToken = "pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA"
        MBXMapKit.setAccessToken("pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA")
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
        GAI.sharedInstance().logger.logLevel = GAILogLevel.Error
        // Initialize tracker. Replace with your tracking ID.
        GAI.sharedInstance().trackerWithTrackingId("UA-63856349-1")
        
        //configure cocoa lumberjack for logging
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())

        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.addLogger(fileLogger)
        let filePath = fileLogger.currentLogFileInfo().filePath
        DDLoggerWrapper.logInfo(String(format: "log file at: %@", filePath))
        Settings.setLogFilePath(filePath)

        configureGlobals()
        loadInitialViewController()
        
        //configure IQKeyboardManager
        IQKeyboardManager.sharedManager().considerToolbarPreviousNextInViewClass(PRKInputForm)
        IQKeyboardManager.sharedManager().disableToolbarInViewControllerClass(FilterViewController)
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = false

        // Override point for customization after application launch.
        
        //
        //notification set up
        //
        let yesAction = UIMutableUserNotificationAction()
        yesAction.identifier = "yes"
        yesAction.title = "yes".localizedString
        yesAction.activationMode = .Background
        yesAction.authenticationRequired = false
        
        let noAction = UIMutableUserNotificationAction()
        noAction.identifier = "no"
        noAction.title = "no".localizedString
        noAction.activationMode = .Background
        noAction.authenticationRequired = false
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "prkng_check_out_monitor"
        category.setActions([yesAction, noAction], forContext: UIUserNotificationActionContext.Default)

        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))){
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: NSSet(object: category) as Set<NSObject>))
        }
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        
        //removes lag when opening the keyboard for the first time on certain devices
        let lagFreeField = UITextField()
        self.window?.addSubview(lagFreeField)
        lagFreeField.becomeFirstResponder()
        lagFreeField.resignFirstResponder()
        lagFreeField.removeFromSuperview()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        if let tabController = window?.rootViewController as? TabController {
            tabController.updateTabBar()
        }
        
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("prkng_check_out_monitor_notification") as? NSData {
            let alert = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! UILocalNotification
            UIApplication.sharedApplication().presentLocalNotificationNow(alert)
        }

    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        if (url.scheme?.lowercaseString == "fb1043720578978201") {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        } else  {
            return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        }        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        let identifier = notification.userInfo != nil ? (notification.userInfo as! [NSObject:String])["identifier"]! : ""
        
        if identifier == "regular_app_notification" {
            let alert = UIAlertView()
            alert.message = notification.alertBody
            alert.addButtonWithTitle("OK")
            alert.show()
            Settings.cancelNotification()
        } else if identifier == "prkng_check_out_monitor" {

            //present the custom dialog
            let spotName = Settings.checkedInSpot()?.name ?? ""
            
            let dialogVC = PRKDialogViewController(titleIconName: "icon_howto_checkin", headerImageName: "checkout_question_header", titleText: "on_the_go".localizedString, subTitleText: "\"" + spotName + "\"", messageText: "left_this_spot_question".localizedString)

            if let tabController = window?.rootViewController as? TabController {
                dialogVC.showOnViewController(tabController)
            }
            
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {

        let notificationIdentifier = notification.userInfo != nil ? (notification.userInfo as! [NSObject:String])["identifier"]! : ""

        if notificationIdentifier == "prkng_check_out_monitor" {

            application.cancelLocalNotification(notification)
            let answeredYes = identifier == "yes" ? true : false
            geofencingNotificationResponse(answeredYes)
        }
        
        completionHandler()
    }

    func keyboardWasShown(notification: NSNotification) {
        
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
        NSUserDefaults.standardUserDefaults().setValue(keyboardSize.height, forKey: "last_keyboard_height")
    }
    
    
    // MARK: Helper

    func configureGlobals() {
        Settings.setCachedLotDataFresh(false)
        LotOperations.sharedInstance.findLots(Settings.selectedCityPoint(), radius: 1.0) { (lots, underMaintenance, outsideServiceArea, error) -> Void in }
        
        SVProgressHUD.setRingThickness(4)
        SVProgressHUD.setCornerRadius(0)
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.setForegroundColor(Styles.Colors.red2)
        SVProgressHUD.setDefaultStyle(.Custom)
    }

    func loadInitialViewController() {

        if (Settings.firstUse() || AuthUtility.getUser() == nil || AuthUtility.loginType() == nil) {
            AuthUtility.saveAuthToken(nil)
            AuthUtility.saveUser(nil)
            window!.rootViewController = FirstUseViewController()
        } else {
            window!.rootViewController = TabController()
        }
        
        window!.makeKeyAndVisible()
    }
    
    // MARK: CLLocationManagerDelegate methods

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        
        //first of all, stop monitoring regions
        for monitoredRegion in self.locationManager.monitoredRegions as! Set<CLRegion> {
            if monitoredRegion.identifier.rangeOfString("prkng_check_out_monitor") != nil {
                self.locationManager.stopMonitoringForRegion(monitoredRegion)
            }
        }
        
        let spotName = Settings.checkedInSpot()?.name ?? ""
        
        //next create the alert
        let alert = UILocalNotification()
        alert.userInfo = ["identifier" : "prkng_check_out_monitor"]
        alert.alertTitle = "on_the_go".localizedString
        alert.alertBody = String(format: "left_spot_question".localizedString, spotName)
        alert.soundName = UILocalNotificationDefaultSoundName
        alert.category = "prkng_check_out_monitor"
        UIApplication.sharedApplication().presentLocalNotificationNow(alert)

        let data = NSKeyedArchiver.archivedDataWithRootObject(alert)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "prkng_check_out_monitor_notification")
        
        //analytics
        AnalyticsOperations.sharedInstance.geofencingEvent((region as! CLCircularRegion).center, entering: true) { (completed) -> Void in
        }

    }

    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        //do nothing
    }
    
    //MARK: Notification handling
    func geofencingNotificationResponse(answeredYes: Bool) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("prkng_check_out_monitor_notification")
        
        if answeredYes {
            
            let spotIdentifier = Settings.checkedInSpot()?.identifier ?? ""
            SpotOperations.checkout(spotIdentifier, completion: { (completed) -> Void in
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

}

