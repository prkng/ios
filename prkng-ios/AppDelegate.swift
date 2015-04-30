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
        configureGlobals()
        loadInitialViewController()


        return true
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func configureGlobals() {
        UIApplication.sharedApplication().statusBarHidden = true
        
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: Styles.FontFaces.regular(11.0), NSForegroundColorAttributeName: Styles.Colors.anthracite1], forState: UIControlState.Normal )
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: Styles.FontFaces.regular(11.0), NSForegroundColorAttributeName: Styles.Colors.red2], forState: UIControlState.Selected)
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = Styles.Colors.stone

    }

    func loadInitialViewController() {

        var tabbarController: PrkTabController = PrkTabController()

        window!.rootViewController = tabbarController
        window!.makeKeyAndVisible()
    }
}

