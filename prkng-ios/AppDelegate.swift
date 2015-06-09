//
//  AppDelegate.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 26/01/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        RMConfiguration.sharedInstance().accessToken = "pk.eyJ1IjoiYXJuYXVkc3B1aGxlciIsImEiOiJSaEctSlVnIn0.R8cfngN9KkHYZx54JQdgJA"

        Crashlytics.startWithAPIKey("0a552ed905e273700bb769724c451c706ceb78cb")
        
        //google analytics setup...
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance().dispatchInterval = 20;
        // Optional: set Logger to VERBOSE for debug information.
        GAI.sharedInstance().logger.logLevel = GAILogLevel.Error
        // Initialize tracker. Replace with your tracking ID.
        GAI.sharedInstance().trackerWithTrackingId("UA-63856349-1")
        
        configureGlobals()
        loadInitialViewController()
        
        
        // Override point for customization after application launch.
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))){
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
        }
        else {
            //do iOS 7 stuff, which is pretty much nothing for local notifications.
        }


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
        let alert = UIAlertView()
        alert.message = "alarm_text".localizedString
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    
    // MARK: Helper

    func configureGlobals() {
        SVProgressHUD.setRingThickness(4)
        SVProgressHUD.setCornerRadius(0)
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.setForegroundColor(Styles.Colors.red2)
    }

    func loadInitialViewController() {

        if (Settings.firstUse() || AuthUtility.getUser() == nil) {
            window!.rootViewController = FirstUseViewController()
        } else {
            window!.rootViewController = TabController()
        }
        
        window!.makeKeyAndVisible()
    }

}

