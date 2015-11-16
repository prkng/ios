//
//  CarSharingOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-16.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import Foundation

class CarSharingOperations {
    
    static func getCarShares(location location: CLLocationCoordinate2D, radius : Float, completion: ((carShares: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "carshares"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let companies: [String?] = [!Settings.hideCar2Go() ? "car2go" : nil, !Settings.hideCommunauto() ? "communauto" : nil, !Settings.hideAutomobile() ? "auto-mobile" : nil]
        let companiesString = Array.filterNils(companies).joinWithSeparator(",")
        
        let params = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "permit" : "all",
            "company" : companiesString
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in
            
            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
            //            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let carShareJsons: Array<JSON> = json["features"].arrayValue
            let carShares = carShareJsons.map({ (carShareJson) -> CarShare in
                CarShare(json: carShareJson)
            })
            
            let underMaintenance = response != nil && response!.statusCode == 503
            let outsideServiceArea = response != nil && response!.statusCode == 404
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(carShares: carShares, underMaintenance: underMaintenance, outsideServiceArea: outsideServiceArea, error: error != nil)
                
                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }
                
            })
            
        }
    }

    static func getCarShareLots(location location: CLLocationCoordinate2D, radius : Float, completion: ((carShareLots: [NSObject], underMaintenance: Bool, outsideServiceArea: Bool, error: Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "carshare_lots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let companies: [String?] = [
            !Settings.hideCar2Go() ? "car2go" : nil,
            !Settings.hideCommunauto() ? "communauto" : nil,
            !Settings.hideAutomobile() ? "auto-mobile" : nil,
            !Settings.hideZipCar() ? "zipcar" : nil,
        ]
        let companiesString = Array.filterNils(companies).joinWithSeparator(",")

        let params = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "permit" : "all",
            "company" : companiesString
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
            (request, response, json, error) in
            
            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
            //            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let carShareLotJsons: Array<JSON> = json["features"].arrayValue
            let carShareLots = carShareLotJsons.map({ (carShareLotJson) -> CarShareLot in
                CarShareLot(json: carShareLotJson)
            })
            
            let underMaintenance = response != nil && response!.statusCode == 503
            let outsideServiceArea = response != nil && response!.statusCode == 404
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                completion(carShareLots: carShareLots, underMaintenance: underMaintenance, outsideServiceArea: outsideServiceArea, error: error != nil)
                
                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }
                
            })
            
        }
    }
    
    struct CommunautoAutomobile {
        
        static let loginApiUrl =        "https://www.reservauto.net/Scripts/Client/Ajax/Mobile/Login.asp"
        static let loginWebUrl =        "https://www.reservauto.net/Scripts/Client/Mobile/Login.asp"
        static let loginWebUrlEnglish = "https://www.reservauto.net/Scripts/Client/Mobile/Login.asp?BranchID=1&CurrentLanguageID=2"
        static let loginWebUrlFrench =  "https://www.reservauto.net/Scripts/Client/Mobile/Login.asp?BranchID=1&CurrentLanguageID=1"
        
        static var loginVC: PRKWebViewController {
            let vc = PRKWebViewController(englishUrl: loginWebUrlEnglish, frenchUrl: loginWebUrlFrench)
            vc.didFinishLoadingCallback = { () -> Bool in
                if let _ = getAndSaveCommunautoCustomerID() {
                    return true
                }
                return false
            }
            return vc
        }
        
        static func getAndSaveCommunautoCustomerID() -> String? {
            
            let url = NSURL(string: loginApiUrl)
            let request = NSURLRequest(URL: url!)
            var response: NSURLResponse?
            do {
                let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                var stringData = String(data: data, encoding: NSUTF8StringEncoding) ?? "  "
                stringData = stringData[1..<stringData.length()-1]
                if let properData = stringData.dataUsingEncoding(NSUTF8StringEncoding) {
                    let json = JSON(data: properData)
                    //if the id string is present, then return true, else return false
                    if let customerID = json["data"][0]["CustomerID"].string {
                        if customerID != "" {
                            print("Communauto/Auto-mobile Customer ID is ", customerID)
                            Settings.setCommunautoCustomerID(customerID)
                            saveCommunautoCookies()
                            return customerID//and we have our custoer ID! Hooray!
                        }
                    }
                }
            } catch (let e) {
                print(e)
                deleteCommunautoCustomerID()
                return nil
            }
            
            deleteCommunautoCustomerID()
            return nil
            
        }
        
        static func deleteCommunautoCustomerID() {
            Settings.setCommunautoCustomerID(nil)
            deleteCommunautoCookies()
        }
        
        private static func saveCommunautoCookies() {
            //this part is to save cookies, but because we set our cache policy properly any UIWebView and NSURLConnection will use the cookie jar!
            let capturedCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: loginWebUrl)!) ?? []
            for i in 0..<capturedCookies.count {
                let cookie = capturedCookies[i]
                NSUserDefaults.standardUserDefaults().setObject(cookie.properties, forKey: "prkng_communauto_cookie_"+String(i))
            }
            NSUserDefaults.standardUserDefaults().setInteger(capturedCookies.count, forKey: "prkng_communauto_cookie_count")
            
        }
        
        private static func deleteCommunautoCookies() {
            
            let capturedCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: loginWebUrl)!) ?? []
            for cookie in capturedCookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
            
            //this commented out part is to put saved cookies back into the cookie jar, but because we set our cache policy properly any UIWebView and NSURLConnection will use the cookie jar!
            //        let cookieCount = NSUserDefaults.standardUserDefaults().integerForKey("prkng_communauto_cookie_count")
            //        for i in 0..<cookieCount {
            //            if let cookieProperties = NSUserDefaults.standardUserDefaults().objectForKey("prkng_communauto_cookie_"+String(i)) as? [String : AnyObject] {
            ////                if cookieProperties["Name"] as? String ?? "" == "mySession" {
            ////                    NSLog("MY SESH")
            ////                }
            //                if let cookie = NSHTTPCookie(properties: cookieProperties) {
            //                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
            //                }
            //            }
            //        }
            
        }
        
        static func reserveCommunauto() -> Bool {
            
            if let customerID = getAndSaveCommunautoCustomerID() {
                //we are logged in, let's goooo
                
            } else {
                //we are not logged in, present a login screen to the user
            }
            
            return false
        }
    }
    
}