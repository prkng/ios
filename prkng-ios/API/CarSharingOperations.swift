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
        
        let companies: [String?] = [
            !Settings.hideCar2Go() ? "car2go" : nil,
            !Settings.hideCommunauto() ? "communauto" : nil,
            !Settings.hideAutomobile() ? "auto-mobile" : nil,
            !Settings.hideZipcar() ? "zipcar" : nil,
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
            !Settings.hideZipcar() ? "zipcar" : nil,
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
    
    static func reserveCarShare(carShare: CarShare, fromVC: UIViewController, completion: (Bool) -> Void) {
        
        switch carShare.carSharingType {
        case .CommunautoAutomobile:
            SVProgressHUD.show()
            CarSharingOperations.CommunautoAutomobile.reserveAutomobile(carShare, completion: { (reserveResult) -> Void in
                switch reserveResult {
                case .Success:
                    //                let alert = UIAlertView()
                    //                alert.message = "reserved_car_share".localizedString
                    //                alert.addButtonWithTitle("OK")
                    //                alert.show()
                    Settings.saveReservedCarShare(carShare)
                    SpotOperations.checkout({ (completed) -> Void in
                        Settings.checkOut()
                    })
                    AnalyticsOperations.reservedCarShareEvent(carShare, completion: { (completed) -> Void in })
                    completion(true)
                case .FailedError:
                    let alert = UIAlertView()
                    alert.message = "could_not_reserve".localizedString
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    completion(false)
                case .FailedNotLoggedIn:
                    let alert = UIAlertView()
                    alert.message = "could_not_reserve_not_logged_in".localizedString
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    let vc = CarSharingOperations.CommunautoAutomobile.loginVC
                    fromVC.presentViewController(vc, animated: true, completion: nil)
                    completion(false)
                }
                SVProgressHUD.dismiss()
            })
        case .Communauto:
            //open the web view
            let carID = carShare.partnerId ?? ""
            let vc = PRKWebViewController(englishUrl: CommunautoAutomobile.communautoReserveUrlEnglish + carID, frenchUrl: CommunautoAutomobile.communautoReserveUrlFrench + carID)
            fromVC.presentViewController(vc, animated: true, completion: nil)
            completion(false)
        case .Zipcar:
            //open the zip car app if applicable
            Zipcar.goToAppOrAppStore()
            completion(false)
        case .Car2Go:
            //open the zip car app if applicable
            Car2Go.goToAppOrAppStore()
            completion(false)
        case .Generic:
            print("This car share type cannot be reserved.")
            completion(false)
        }
        
    }

    static func cancelCarShare(carShare: CarShare, fromVC: UIViewController, completion: (Bool) -> Void) {
        
        switch carShare.carSharingType {
        case .CommunautoAutomobile:
            SVProgressHUD.show()
            CarSharingOperations.CommunautoAutomobile.cancelAutomobile(carShare, completion: { (cancelResult) -> Void in
                switch cancelResult {
                case .Success:
                    let alert = UIAlertView()
                    alert.message = "cancelled_reservation".localizedString
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    Settings.saveReservedCarShare(nil)
                    completion(true)
                case .FailedError:
                    let alert = UIAlertView()
                    alert.message = "could_not_cancel_reservation".localizedString
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    completion(false)
                case .FailedNotLoggedIn:
                    let alert = UIAlertView()
                    alert.message = "could_not_cancel_not_logged_in".localizedString
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    let vc = CarSharingOperations.CommunautoAutomobile.loginVC
                    fromVC.presentViewController(vc, animated: true, completion: nil)
                    completion(false)
                }
                SVProgressHUD.dismiss()
            })
            
        case .Communauto, .Zipcar, .Car2Go, .Generic:
            print("This car share type cannot be cancelled.")
            completion(false)
        }
        
    }

    struct Car2Go {
        
        static func goToAppOrAppStore() {
            let url = NSURL(string: "car2go://")!
            let isUrlSupported = UIApplication.sharedApplication().canOpenURL(url)
            if isUrlSupported {
                UIApplication.sharedApplication().openURL(url)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id514921710")!)
            }
        }
    }

    struct Zipcar {
        
        static func goToAppOrAppStore() {
            let url = NSURL(string: "zipcar://")!
            let isUrlSupported = UIApplication.sharedApplication().canOpenURL(url)
            if isUrlSupported {
                UIApplication.sharedApplication().openURL(url)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id329384702")!)
            }
        }
    }
    
    struct CommunautoAutomobile {
        
        static let loginApiUrl =        "https://www.reservauto.net/Scripts/Client/Ajax/Mobile/Login.asp"
        static let loginWebUrl =        "https://www.reservauto.net/Scripts/Client/Mobile/Login.asp"
        static let loginWebUrlEnglish = "https://www.reservauto.net/Scripts/Client/Mobile/Login.asp?BranchID=1&CurrentLanguageID=2"
        static let loginWebUrlFrench =  "https://www.reservauto.net/Scripts/Client/Mobile/Login.asp?BranchID=1&CurrentLanguageID=1"

        static let communautoReserveUrlEnglish = "https://www.reservauto.net/Scripts/Client/Mobile/ReservationAdd.asp?BranchID=1&CurrentLanguageID=2"
        static let communautoReserveUrlFrench =  "https://www.reservauto.net/Scripts/Client/Mobile/ReservationAdd.asp?BranchID=1&CurrentLanguageID=1"

        //these next 2 require CarID to be appended
        let communautoReserveUrlEnglish = "https://www.reservauto.net/Scripts/Client/ReservationAdd.asp?Step=2&CurrentLanguageID=2&IgnoreError=False&NbrStation=0&CarID="
        let communautoReserveUrlFrench = "https://www.reservauto.net/Scripts/Client/ReservationAdd.asp?Step=2&CurrentLanguageID=1&IgnoreError=False&NbrStation=0&CarID="
//        static let communautoReserveUrl = "https://www.reservauto.net/Scripts/Client/ReservationAdd.asp?Step=2&CurrentLanguageID="+ lang +"&IgnoreError=False&NbrStation=0&ReservationCityID="+ iRes[0] +"&CarID="+ lngCarID +"&StartYear="+ sD[2] +"&StartMonth="+ sD[1] +"&StartDay="+ sD[0] +"&StartHour="+ iRes[2] +"&StartMinute="+ iRes[3] +"&EndYear="+ eD[2] +"&EndMonth="+ eD[1] +"&EndDay="+ eD[0] +"&EndHour="+ iRes[5] +"&EndMinute="+ iRes[6] +"&StationID="+ StationID +"&OrderBy=2&Accessories="+ iRes[7] +"&Brand="+ iRes[8] +"&ShowGrid=False&ShowMap=True&FeeType="+ iRes[9] +"&DestinationID="+ iRes[10] +"&CustomerLocalizationID="
        
        //note: customerID is actually providerNo
        static let automobileCurrentBookingUrl = "https://www.reservauto.net/WCF/LSI/LSIBookingService.asmx/GetCurrentBooking"//?CustomerID=%@"
        static let automobileCreateBookingUrl = "https://www.reservauto.net/WCF/LSI/LSIBookingService.asmx/CreateBooking"//?CustomerID=%@&VehicleID=%@"
        static let automobileCancelBookingUrl = "https://www.reservauto.net/WCF/LSI/LSIBookingService.asmx/CancelBooking"//?CustomerID=%@&VehicleID=%@"

        static var loginVC: PRKWebViewController {
            let vc = PRKWebViewController(englishUrl: loginWebUrlEnglish, frenchUrl: loginWebUrlFrench)
            vc.didFinishLoadingCallback = { (vc, webView) -> () in
                webView.stringByEvaluatingJavaScriptFromString("document.getElementById(\"RememberMe\").checked = true; document.getElementById(\"RememberMe\").parentElement.hidden = true;")
                self.getAndSaveCommunautoCustomerID({ (id) -> Void in
                    if id != nil {
                        vc.backButtonTapped()
                    }
                })
            }
            return vc
        }
        
        static func getAndSaveCommunautoCustomerID(completion: (String?) -> Void) {
            
            let url = NSURL(string: loginApiUrl)
            let request = NSURLRequest(URL: url!)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                
                if error != nil || data == nil {
                    DDLoggerWrapper.logError("Either there was an error with the request or there was no data returned")
                    deleteCommunautoCustomerID()
                    completion(nil)
                    return
                }
                
                if data != nil {
                    var stringData = String(data: data!, encoding: NSUTF8StringEncoding) ?? "  "
                    stringData = stringData[1..<stringData.length()-1]
                    if let properData = stringData.dataUsingEncoding(NSUTF8StringEncoding) {
                        let json = JSON(data: properData)
                        //if the id string is present, then return true, else return false
                        var returnString: String?
                        if let providerNo = json["data"][0]["ProviderNo"].string {
                            if providerNo != "" {
                                print("Auto-mobile ProviderNo is ", providerNo)
                                Settings.setAutomobileProviderNo(providerNo)
                                saveCommunautoCookies()
                                returnString = providerNo
                            }
                        }
                        if let customerID = json["data"][0]["CustomerID"].string {
                            if customerID != "" {
                                if (Settings.communautoCustomerID() ?? "") != customerID {
                                    AnalyticsOperations.carShareLoginEvent("communauto-auto-mobile", completion: { (completed) -> Void in })
                                }
                                print("Communauto/Auto-mobile Customer ID is ", customerID)
                                Settings.setCommunautoCustomerID(customerID)
                                saveCommunautoCookies()
                                if returnString == nil {
                                    returnString = customerID
                                }
                            }
                        }
                        if returnString != nil {
                            completion(returnString)
                            return
                        }
                    }
                }
                
                deleteCommunautoCustomerID()
                completion(nil)
                return
            }
            
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
        
        //        static func reserveCommunauto() -> ReturnStatus {
        //
        //            if let customerID = getAndSaveCommunautoCustomerID() {
        //                //we are logged in, let's goooo
        //                //this is where we do the actual reservation
        //                return .Success
        //            } else {
        //                //we are not logged in, present a login screen to the user
        //                return .FailedNotLoggedIn
        //            }
        //
        //            return .FailedError
        //        }

        static func reserveAutomobile(carShare: CarShare, completion: (ReturnStatus) -> Void) {
            automobileCustomerIDVehicleIDOperation(automobileCreateBookingUrl, carShare: carShare, completion: completion)
        }

        static func cancelAutomobile(carShare: CarShare, completion: (ReturnStatus) -> Void) {
            automobileCustomerIDVehicleIDOperation(automobileCancelBookingUrl, carShare: carShare, completion: completion)
        }
        
        private static func automobileCustomerIDVehicleIDOperation(urlString: String, carShare: CarShare, completion: (ReturnStatus) -> Void) {
            
            getAndSaveCommunautoCustomerID { (providerNo) -> Void in
                if providerNo != nil {
                    //we are logged in, let's goooo
                    //this is where we do the actual reservation
                    
                    let url = NSURL(string: String(format: urlString))//, providerNo, carShare.vin ?? ""))
                    let request = NSMutableURLRequest(URL: url!)
                    request.HTTPMethod = "POST"
                    request.HTTPBody = String(format:"CustomerID=%@&VehicleID=%@", providerNo!, carShare.vin ?? "").dataUsingEncoding(NSUTF8StringEncoding)
                    
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                        
                        if error != nil || data == nil {
                            DDLoggerWrapper.logError("Either there was an error with the request or there was no data returned")
                            completion(.FailedError)
                        }
                        
                        if data != nil {
                            let stringData = (String(data: data!, encoding: NSUTF8StringEncoding) ?? "  ").lowercaseString
                            if !stringData.containsString("true") {
                                DDLoggerWrapper.logError(stringData)
                                completion(.FailedError)
                            } else {
                                completion(.Success)
                            }
                        }
                        
                    })

                } else {
                    //we are not logged in, present a login screen to the user
                    completion(.FailedNotLoggedIn)
                }
            }
        }
    }
    
    
    enum ReturnStatus {
        case FailedNotLoggedIn
        case FailedError
        case Success
    }

}