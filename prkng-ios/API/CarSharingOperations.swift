//
//  CarSharingOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-10-16.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import Foundation

class CarSharingOperations {
    
    static func getCarShares(location: CLLocationCoordinate2D, radius: Float, nearest: Int, completion: @escaping ((_ carShares: [NSObject], _ mapMessage: String?) -> Void)) {
        
        let url = APIUtility.rootURL() + "carshares"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let companies: [String?] = [
            !Settings.hideCar2Go() ? "car2go" : nil,
            !Settings.hideCommunauto() ? "communauto" : nil,
            !Settings.hideAutomobile() ? "auto-mobile" : nil,
            !Settings.hideZipcar() ? "zipcar" : nil,
        ]
        let companiesString = Array.filterNils(companies).joined(separator: ",")
        
        if companiesString == "" {
            let mapMessage = MapMessageView.createMessage(count: 0, response: nil, error: nil, origin: .cars)
            completion(carShares: [], mapMessage: mapMessage)
            return
        }
        
        let params = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "company" : companiesString,
            "permit" : "all",
            "nearest": nearest
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
            (request, response, json, error) in
            
            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
            //            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let carShareJsons: Array<JSON> = json["features"].arrayValue
            let carShares = carShareJsons.map({ (carShareJson) -> CarShare in
                CarShare(json: carShareJson)
            })
            
            let mapMessage = MapMessageView.createMessage(count: carShares.count, response: response, error: error, origin: .cars)
            
            DispatchQueue.main.async(execute: {
                () -> Void in
                completion(carShares: carShares, mapMessage: mapMessage)
                
                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }
                
            })
            
        }
    }

    static func getCarShareLots(location: CLLocationCoordinate2D, radius: Float, nearest: Int, completion: @escaping ((_ carShareLots: [NSObject], _ mapMessage: String?) -> Void)) {
        
        let url = APIUtility.rootURL() + "carshare_lots"
        
        let radiusStr = NSString(format: "%.0f", radius)
        
        let companies: [String?] = [
            !Settings.hideCar2Go() ? "car2go" : nil,
            !Settings.hideCommunauto() ? "communauto" : nil,
            !Settings.hideAutomobile() ? "auto-mobile" : nil,
            !Settings.hideZipcar() ? "zipcar" : nil,
        ]
        let companiesString = Array.filterNils(companies).joined(separator: ",")

        let params = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "radius" : radiusStr,
            "company" : companiesString,
            "permit" : "all",
            "nearest": nearest
        ]
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: params).responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
            (request, response, json, error) in
            
            DDLoggerWrapper.logVerbose(String(format: "Request: %@", request))
            DDLoggerWrapper.logVerbose(String(format: "Response: %@", response ?? ""))
            //            DDLoggerWrapper.logVerbose(String(format: "Json: %@", json.description))
            DDLoggerWrapper.logVerbose(String(format: "error: %@", error ?? ""))
            
            let carShareLotJsons: Array<JSON> = json["features"].arrayValue
            let carShareLots = carShareLotJsons.map({ (carShareLotJson) -> CarShareLot in
                CarShareLot(json: carShareLotJson)
            })
            
            let mapMessage = MapMessageView.createMessage(count: carShareLots.count, response: response, error: error, origin: .spots)
            
            DispatchQueue.main.async(execute: {
                () -> Void in
                completion(carShareLots: carShareLots, mapMessage: mapMessage)
                
                if response != nil && response?.statusCode == 401 {
                    DDLoggerWrapper.logError(String(format: "Error: Could not authenticate. Reason: %@", json.description))
                    Settings.logout()
                }
                
            })
            
        }
    }
    
    static func login(_ carSharingType: CarSharingType) {
        
        switch carSharingType {
        case .CommunautoAutomobile, .Communauto:
            //open the web view
            let vc = CarSharingOperations.CommunautoAutomobile.loginVC
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(vc, animated: true, completion: { () -> Void in
            })
        case .Car2Go:
            CarSharingOperations.Car2Go.getAndSaveCar2GoToken({ (token, tokenSecret) -> Void in
            })
        case .Zipcar, .Generic:
            break
        }

    }
    
    static func reserveCarShare(_ carShare: CarShare, fromVC: UIViewController, completion: @escaping (Bool) -> Void) {
        
        let reservationCompletion = { (reserveResult: ReturnStatus) -> Void in
            switch reserveResult {
            case .success:
                Settings.saveReservedCarShare(carShare)
                SpotOperations.checkout({ (completed) -> Void in
                    Settings.checkOut()
                })
                AnalyticsOperations.reservedCarShareEvent(carShare, completion: { (completed) -> Void in })
                completion(true)
            case .failedError:
                let alert = UIAlertView()
                alert.message = "could_not_reserve".localizedString
                alert.addButton(withTitle: "OK")
                alert.show()
                completion(false)
            case .failedNotLoggedIn:
                let alert = UIAlertView()
                alert.message = "could_not_reserve_not_logged_in".localizedString
                alert.addButton(withTitle: "OK")
                alert.show()
                CarSharingOperations.login(carShare.carSharingType)
                completion(false)
            }
            SVProgressHUD.dismiss()
        }
        
        switch carShare.carSharingType {
        case .CommunautoAutomobile:
            SVProgressHUD.show()
            CarSharingOperations.CommunautoAutomobile.reserveAutomobile(carShare, completion: reservationCompletion)
        case .Communauto:
            //open the web view
            let carID = carShare.partnerId ?? ""
            let vc = PRKWebViewController(englishUrl: CommunautoAutomobile.communautoReserveUrlEnglish + carID, frenchUrl: CommunautoAutomobile.communautoReserveUrlFrench + carID)
            fromVC.present(vc, animated: true, completion: nil)
            completion(false)
        case .Zipcar:
            //open the zip car app if applicable
            Zipcar.goToAppOrAppStore()
            completion(false)
        case .Car2Go:
            //open the zip car app if applicable
            SVProgressHUD.show()
            CarSharingOperations.Car2Go.reserveCar(carShare, completion: reservationCompletion)
        case .Generic:
            print("This car share type cannot be reserved.")
            completion(false)
        }
        
    }

    static func cancelCarShare(_ carShare: CarShare, fromVC: UIViewController, completion: @escaping (Bool) -> Void) {
        
        let cancelationCompletion = { (cancelResult: ReturnStatus) -> Void in
            switch cancelResult {
            case .success:
                let alert = UIAlertView()
                alert.message = "cancelled_reservation".localizedString
                alert.addButton(withTitle: "OK")
                alert.show()
                Settings.saveReservedCarShare(nil)
                completion(true)
            case .failedError:
                let alert = UIAlertView()
                alert.message = "could_not_cancel_reservation".localizedString
                alert.addButton(withTitle: "OK")
                alert.show()
                completion(false)
            case .failedNotLoggedIn:
                let alert = UIAlertView()
                alert.message = "could_not_cancel_not_logged_in".localizedString
                alert.addButton(withTitle: "OK")
                alert.show()
                let vc = CarSharingOperations.CommunautoAutomobile.loginVC
                fromVC.present(vc, animated: true, completion: nil)
                completion(false)
            }
            SVProgressHUD.dismiss()
        }

        switch carShare.carSharingType {
        case .CommunautoAutomobile:
            SVProgressHUD.show()
            CarSharingOperations.CommunautoAutomobile.cancelAutomobile(carShare, completion: cancelationCompletion)
        case .Car2Go:
            SVProgressHUD.show()
            CarSharingOperations.Car2Go.cancelCar(carShare, completion: cancelationCompletion)
        case .Communauto, .Zipcar, .Generic:
            print("This car share type cannot be cancelled.")
            completion(false)
        }
        
    }

    struct Car2Go {
        
        static let consumerKey = "prkng"
        static let consumerSecret = "crUKsH0t4RQeyKYOy%3E%5D6"
        static let callbackURLString = "ng.prk.prkng-ios://oauth-car2go-success"
        static let endpointsHostUrlString = "www.car2go.com/api/v2.1"
        
        static func goToAppOrAppStore() {
            let url = URL(string: "car2go://")!
            let isUrlSupported = UIApplication.shared.canOpenURL(url)
            if isUrlSupported {
                UIApplication.shared.openURL(url)
            } else {
                UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id514921710")!)
            }
        }
        
        static func isLoggedInSynchronous(shouldValidateToken validateToken: Bool) -> Bool {
            
            let token = Settings.car2GoAccessToken()
            let tokenSecret = Settings.car2GoAccessTokenSecret()

            if token != nil && tokenSecret != nil {
                if validateToken {
                    //just a test to see if we're logged in... note: ulm is NOT a valid location
                    let testLoginRequest = TDOAuth.urlRequest(forPath: "/accounts", getParameters: ["format": "json", "loc": "ulm"], scheme: "https", host: endpointsHostUrlString, consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: token, tokenSecret: tokenSecret)
                    var response: URLResponse?
                    do {
                        let _ = try NSURLConnection.sendSynchronousRequest(testLoginRequest!, returning: &response)
                        let success = (response as! HTTPURLResponse).statusCode < 400
                        return success
                    } catch {
                        return false
                    }
                }
                return true
            }
            return false
        }

        static func isLoggedInAsynchronous(shouldValidateToken validateToken: Bool, completion: @escaping ((_ loggedIn: Bool) -> Void)) {
            
            let token = Settings.car2GoAccessToken()
            let tokenSecret = Settings.car2GoAccessTokenSecret()
            
            if token != nil && tokenSecret != nil {
                if validateToken {
                    //just a test to see if we're logged in... note: ulm is NOT a valid location
                    let testLoginRequest = TDOAuth.urlRequest(forPath: "/accounts", getParameters: ["format": "json", "loc": "ulm"], scheme: "https", host: endpointsHostUrlString, consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: token, tokenSecret: tokenSecret)
                    NSURLConnection.sendAsynchronousRequest(testLoginRequest!, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
                        let success = error == nil || (response as! HTTPURLResponse).statusCode < 400
                        completion(success)
                    })
                    
                } else {
                    completion(true)
                }
            } else {
                completion(false)
            }
        }

        static func logout() {
            Settings.setCar2GoBookingID(nil)
            Settings.setCar2GoAccessToken(nil)
            Settings.setCar2GoAccessTokenSecret(nil)
        }
        
        static func getAccountID(_ completion: @escaping (_ accountID: String?) -> Void) {
            let token = Settings.car2GoAccessToken()
            let tokenSecret = Settings.car2GoAccessTokenSecret()

            var cityName = ""
            switch Settings.selectedCity().name {
                case "newyork":
                cityName = "newyorkcity"
            default:
                cityName = Settings.selectedCity().name
            }
            
            let testLoginRequest = TDOAuth.urlRequest(forPath: "/accounts", getParameters: ["format": "json", "loc": cityName], scheme: "https", host: endpointsHostUrlString, consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: token, tokenSecret: tokenSecret)
            NSURLConnection.sendAsynchronousRequest(testLoginRequest!, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
                let success = error == nil || (response as! HTTPURLResponse).statusCode < 400
                if success && data != nil {
                    let json = JSON(data: data!)
                    let accountID = json["account"][0]["accountId"].rawString()
                    completion(accountID: accountID == "null" ? nil : accountID)
                    return
                }
                completion(nil)
            })
        }
        
        static func getAndSaveCar2GoToken(_ completion: @escaping (_ token: String?, _ tokenSecret: String?) -> Void) {
            
            let tokenDict = ["oauth_callback": "oob"] //type is [NSObject : AnyObject]()
            let tokenRequest = TDOAuth.urlRequest(forPath: "/reqtoken", postParameters: tokenDict, host: "www.car2go.com/api", consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: nil, tokenSecret: nil)
            NSURLConnection.sendAsynchronousRequest(tokenRequest!, queue: OperationQueue.main) { (response, data, error) -> Void in
                if data != nil {
                    var params = [AnyHashable: Any]()
                    let stringData = String(data: data!, encoding: String.Encoding.utf8)
                    let stringArray = stringData?.components(separatedBy: "&") ?? []
                    for substring in stringArray {
                        let secondArray = substring.components(separatedBy: "=")
                        params[secondArray[0]] = secondArray[1]
                    }
                    let token1 = params["oauth_token"] as? String ?? ""
                    let tokenSecret = params["oauth_token_secret"] as? String ?? ""
                    
                    //we have the token and token request, now open Safari View Controller to get the user to authenticate
                    let authUrlString = String(format:"https://www.car2go.com/api/authorize?oauth_token=%@&token_secret=%@", token1, tokenSecret)
                    
                    let authVC = PRKWebViewController(url: authUrlString)
                    authVC.willLoadRequestCallback = { (vc, request) -> () in
                        
                        if (request.url?.relativeString ?? "").contains(callbackURLString + "?") {
                            vc.backButtonTapped()
                            var params = [AnyHashable: Any]()
                            let paramsString = (request.url?.relativeString ?? "").replacingOccurrences(of: callbackURLString + "?", with: "")
                            let stringArray = paramsString.components(separatedBy: "&") ?? []
                            for substring in stringArray {
                                let secondArray = substring.components(separatedBy: "=")
                                params[secondArray[0]] = secondArray[1]
                            }
                            let token2 = params["oauth_token"] as? String ?? ""
                            let verifier = params["oauth_verifier"] as? String ?? ""
                            
                            let accessTokenDict = ["oauth_verifier": verifier] //type is [NSObject : AnyObject]()
                            let accessTokenRequest = TDOAuth.urlRequest(forPath: "/accesstoken", postParameters: accessTokenDict, host: "www.car2go.com/api", consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: token2, tokenSecret: tokenSecret)
                            NSURLConnection.sendAsynchronousRequest(accessTokenRequest!, queue: OperationQueue.main) { (response, data, error) -> Void in
                                if data != nil {
                                    var params = [AnyHashable: Any]()
                                    let stringData = String(data: data!, encoding: String.Encoding.utf8)
                                    let stringArray = stringData?.components(separatedBy: "&") ?? []
                                    for substring in stringArray {
                                        let secondArray = substring.components(separatedBy: "=")
                                        params[secondArray[0]] = secondArray[1]
                                    }
                                    //save these two!
                                    let finalToken = params["oauth_token"] as? String ?? ""
                                    let finalTokenSecret = params["oauth_token_secret"] as? String ?? ""
                                    
                                    Settings.setCar2GoAccessToken(finalToken)
                                    Settings.setCar2GoAccessTokenSecret(finalTokenSecret)
                                    
                                    AnalyticsOperations.carShareLoginEvent("car2go", completion: { (completed) -> Void in })
                                    
                                    completion(finalToken, finalTokenSecret)
                                }
                                if error != nil {
                                    completion(nil, nil)
                                }
                            }
                        }
                    }
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(authVC, animated: true, completion: { () -> Void in
                    })
                }
                if error != nil {
                    DDLoggerWrapper.logError(error!.description)
                    completion(nil, nil)
                }
            }
        }
     
        static func reserveCar(_ carShare: CarShare, completion: @escaping (ReturnStatus) -> Void) {

            getAccountID { (accountID) -> Void in
                if accountID != nil {
                    
                    let token = Settings.car2GoAccessToken()
                    let tokenSecret = Settings.car2GoAccessTokenSecret()
                    let params = ["format": "json",
                        "vin": carShare.vin! ?? "",
                        "account": accountID!,
                    ]
                    let testLoginRequest = TDOAuth.urlRequest(forPath: "/bookings", parameters: params, host: endpointsHostUrlString, consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: token, tokenSecret: tokenSecret, scheme: "https", requestMethod: "POST", dataEncoding: TDOAuthContentType.urlEncodedForm, headerValues: nil, signatureMethod: TDOAuthSignatureMethod.hmacSha1)
                    NSURLConnection.sendAsynchronousRequest(testLoginRequest!, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
                        let success = error == nil || (response as! HTTPURLResponse).statusCode < 400
                        if success && data != nil {
                            let json = JSON(data: data!)
                            let returnCode = json["returnValue"]["code"].intValue
                            let bookingID = json["booking"][0]["bookingId"].rawString()
                            if returnCode == 0 {
                                Settings.setCar2GoBookingID(bookingID)
                                completion(ReturnStatus.success)
                            } else {
                                completion(ReturnStatus.failedError)
                            }
                        } else {
                            completion(ReturnStatus.failedError)
                        }
                    })
                    
                } else {
                    completion(ReturnStatus.failedNotLoggedIn)
                }
            }
        }

        static func cancelCar(_ carShare: CarShare, completion: @escaping (ReturnStatus) -> Void) {
            
            let token = Settings.car2GoAccessToken()
            let tokenSecret = Settings.car2GoAccessTokenSecret()
            let bookingID = Settings.car2GoBookingID() ?? ""
            
            let params = ["format": "json", "bookingId": bookingID]
            let testLoginRequest = TDOAuth.urlRequest(forPath: "/booking/"+bookingID, parameters: params, host: endpointsHostUrlString, consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: token, tokenSecret: tokenSecret, scheme: "https", requestMethod: "DELETE", dataEncoding: TDOAuthContentType.urlEncodedForm, headerValues: nil, signatureMethod: TDOAuthSignatureMethod.hmacSha1)
            NSURLConnection.sendAsynchronousRequest(testLoginRequest!, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
                let success = error == nil || (response as! HTTPURLResponse).statusCode < 400
                if success && data != nil {
                    let json = JSON(data: data!)
                    let returnCode = json["returnValue"]["code"].intValue
                    if returnCode == 0 {
                        completion(ReturnStatus.success)
                        Settings.setCar2GoBookingID(nil)
                    } else {
                        completion(ReturnStatus.failedError)
                    }
                } else {
                    completion(ReturnStatus.failedError)
                }
            })
            
        }

    }

    struct Zipcar {
        
        static func goToAppOrAppStore() {
            let url = URL(string: "zipcar://")!
            let isUrlSupported = UIApplication.shared.canOpenURL(url)
            if isUrlSupported {
                UIApplication.shared.openURL(url)
            } else {
                UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id329384702")!)
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
                webView.stringByEvaluatingJavaScript(from: "document.getElementById(\"RememberMe\").checked = true; document.getElementById(\"RememberMe\").parentElement.hidden = true;")
                self.getAndSaveCommunautoCustomerID({ (id) -> Void in
                    if id != nil {
                        vc.backButtonTapped()
                    }
                })
            }
            return vc
        }
        
        static func getAndSaveCommunautoCustomerID(_ completion: @escaping (String?) -> Void) {
            
            let url = URL(string: loginApiUrl)
            let request = URLRequest(url: url!)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
                
                if error != nil || data == nil {
                    DDLoggerWrapper.logError("Either there was an error with the request or there was no data returned")
                    deleteCommunautoCustomerID()
                    completion(nil)
                    return
                }
                
                if data != nil {
                    var json = JSON(data: data!)
                    if json == JSON.null {
                        var stringData = String(data: data!, encoding: String.Encoding.utf8) ?? "  "
                        stringData = stringData[1..<stringData.length()-1]
                        if let properData = stringData.data(using: String.Encoding.utf8) {
                            json = JSON(data: properData)
                        }
                    }
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
                
                deleteCommunautoCustomerID()
                completion(nil)
                return
            }
            
        }
        
        static func deleteCommunautoCustomerID() {
            Settings.setCommunautoCustomerID(nil)
            deleteCommunautoCookies()
        }
        
        fileprivate static func saveCommunautoCookies() {
            //this part is to save cookies, but because we set our cache policy properly any UIWebView and NSURLConnection will use the cookie jar!
            let capturedCookies = HTTPCookieStorage.shared.cookies(for: URL(string: loginWebUrl)!) ?? []
            for i in 0..<capturedCookies.count {
                let cookie = capturedCookies[i]
                UserDefaults.standard.set(cookie.properties, forKey: "prkng_communauto_cookie_"+String(i))
            }
            UserDefaults.standard.set(capturedCookies.count, forKey: "prkng_communauto_cookie_count")
            
        }
        
        fileprivate static func deleteCommunautoCookies() {
            
            let capturedCookies = HTTPCookieStorage.shared.cookies(for: URL(string: loginWebUrl)!) ?? []
            for cookie in capturedCookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
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

        static func reserveAutomobile(_ carShare: CarShare, completion: @escaping (ReturnStatus) -> Void) {
            automobileCustomerIDVehicleIDOperation(automobileCreateBookingUrl, carShare: carShare, completion: completion)
        }

        static func cancelAutomobile(_ carShare: CarShare, completion: @escaping (ReturnStatus) -> Void) {
            automobileCustomerIDVehicleIDOperation(automobileCancelBookingUrl, carShare: carShare, completion: completion)
        }
        
        fileprivate static func automobileCustomerIDVehicleIDOperation(_ urlString: String, carShare: CarShare, completion: @escaping (ReturnStatus) -> Void) {
            
            getAndSaveCommunautoCustomerID { (providerNo) -> Void in
                if providerNo != nil {
                    //we are logged in, let's goooo
                    //this is where we do the actual reservation
                    
                    let url = URL(string: String(format: urlString))//, providerNo, carShare.vin ?? ""))
                    let request = NSMutableURLRequest(url: url!)
                    request.httpMethod = "POST"
                    request.httpBody = String(format:"CustomerID=%@&VehicleID=%@", providerNo!, carShare.vin ?? "").data(using: String.Encoding.utf8)
                    
                    NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main, completionHandler: { (response, data, error) -> Void in
                        
                        if error != nil || data == nil {
                            DDLoggerWrapper.logError("Either there was an error with the request or there was no data returned")
                            completion(.failedError)
                        }
                        
                        if data != nil {
                            let stringData = (String(data: data!, encoding: String.Encoding.utf8) ?? "  ").lowercased()
                            if !stringData.contains("true") {
                                DDLoggerWrapper.logError(stringData)
                                completion(.failedError)
                            } else {
                                completion(.success)
                            }
                        }
                        
                    })

                } else {
                    //we are not logged in, present a login screen to the user
                    completion(.failedNotLoggedIn)
                }
            }
        }
    }
    
    
    enum ReturnStatus {
        case failedNotLoggedIn
        case failedError
        case success
    }

}
