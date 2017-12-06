//
//  LotOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 26/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import SwiftyJSON

class ParkingPandaOperations {
    
    //Development (Sandbox) API (Reservations aren’t real, use Braintree sample card numbers to test https://developers.braintreepayments.com/reference/general/testing/node#credit-card-numbers)
//    static let baseUrlString = "http://dev.parkingpanda.com/api/v2/"
//    static let publicKey = "39b5854211924468af84ad0e1d2edf56"
//    static let privateKey = "8bcdcdfb71dd4c87b9dff6d4b75809b7"
    
//    //Real API
//    static let baseUrlString = "https://www.parkingpanda.com/api/v2/"
//    static let publicKey = "908eb2a1edd3491791da7f8b8e5716ee"
//    static let privateKey = "f6a1fb203f334dfe9f75a5b58663a209"
    
    static let baseUrlString = APIUtility.isUsingTestServer ? "http://dev.parkingpanda.com/api/v2/" : "https://www.parkingpanda.com/api/v2/"
    static let publicKey = APIUtility.isUsingTestServer ? "39b5854211924468af84ad0e1d2edf56" : "908eb2a1edd3491791da7f8b8e5716ee"
    static let privateKey = APIUtility.isUsingTestServer ? "8bcdcdfb71dd4c87b9dff6d4b75809b7" : "f6a1fb203f334dfe9f75a5b58663a209"
    
    enum ParkingPandaTransactionTime {
        case all
        case past
        case upcoming
    }

    struct ParkingPandaError {

        enum ParkingPandaErrorType {
            case api
            case `internal`
            case network
            case noError
        }

        var errorType: ParkingPandaErrorType
        var errorDescription: String?
    }


    fileprivate class ParkingPandaHelper {
        
        class func authenticatedManager(username: String, password: String) -> Manager {
            
            let plainString = (username + ":" + password) as NSString//"username:password" as NSString
            let plainData = plainString.data(using: String.Encoding.utf8.rawValue)
            let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

            var headers = Manager.sharedInstance.session.configuration.httpAdditionalHeaders ?? [:]
            headers["Authorization"] = "Basic " + base64String!
            
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = headers
            
            return Manager(configuration: configuration)
        }
    }

    //parses the API response for all Parking Panda requests.
    static func didRequestSucceed(_ response: HTTPURLResponse?, json: JSON, error: NSError?) -> ParkingPandaError {
        
        var returnedError = ParkingPandaError(errorType: .noError, errorDescription: nil)
        
        let parkingPandaErrorCode = json["error"].int
        let parkingPandaErrorMessage = json["message"].string
        let parkingPandaSuccess = json["success"].boolValue
        
        if (response != nil && response?.statusCode == 401) {
                DDLoggerWrapper.logError(String(format: "ParkingPanda Error: Bad network connection"))
                returnedError = ParkingPandaError(errorType: .network, errorDescription: "Bad network connection")
        } else if !parkingPandaSuccess
            || parkingPandaErrorCode != nil
            || parkingPandaErrorMessage != nil {
                DDLoggerWrapper.logError(String(format: "Error: No workie. Reason: %@", parkingPandaErrorMessage ?? json.description))
                returnedError = ParkingPandaError(errorType: .api, errorDescription: parkingPandaErrorMessage ?? json.description)
        }

        DispatchQueue.main.async(execute: { () -> Void in
            switch (returnedError.errorType) {
            case .api, .internal:
                GeneralHelper.warnUserWithErrorMessage(returnedError.errorDescription ?? "")
            case .network:
                GeneralHelper.warnUserWithErrorMessage("connection_error".localizedString)
            case .noError:
                break
            }
        })
        
        return returnedError
    }
    
    static func createUser(_ email: String, password: String, firstName: String, lastName: String, phone: String, completion: @escaping ((_ user: ParkingPandaUser?, _ error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users"
        let params: [String: AnyObject] = ["apikey": publicKey as AnyObject,
            "email": email as AnyObject,
            "password": password as AnyObject,
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "phone": phone as AnyObject,
            "dontReceiveEmail": true as AnyObject,
//            "invitationCodeForSignup": "some_code",
            "receiveSMSNotifications": false,
            "dontSendWelcomeEmail": false
        ]
        
        ParkingPandaHelper.authenticatedManager(username: "admin", password: "admin")
            .request(.POST, url, parameters: params, encoding: .json)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(user: nil, error: ppError)
                    return
                }
                
                AnalyticsOperations.ppUserDidSignUp(nil)
                let user = ParkingPandaUser(json: json["data"])
                Settings.setParkingPandaCredentials(username: user.email, password: user.apiPassword)
                completion(user: user, error: ppError)
        }

    }
    
    //used to do a login, or to get the user (ie if you're already athenticated, it will use your stored credentials)
    static func login(username: String?, password: String?, includeCreditCards: Bool = false, completion: @escaping ((_ user: ParkingPandaUser?, _ error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users"
        let params: [String: AnyObject] = [
            "apikey": publicKey as AnyObject,
            "includeCreditCards": includeCreditCards as AnyObject //the api does not do anything with this, sadly
        ]

        let creds = Settings.getParkingPandaCredentials()
        let loginUsername = username ?? creds.0
        let loginPassword = password ?? creds.1
        
        if loginUsername == nil || loginPassword == nil {
            completion(nil, ParkingPandaError(errorType: .internal, errorDescription: "No credentials given."))
            return
        }
        
        ParkingPandaHelper.authenticatedManager(username: loginUsername!, password: loginPassword!)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(user: nil, error: ppError)
                    return
                }
                
                AnalyticsOperations.ppUserDidLogin(nil)
                let user = ParkingPandaUser(json: json["data"])
                Settings.setParkingPandaCredentials(username: user.email, password: user.apiPassword)
                completion(user: user, error: ppError)
        }
    }

    static func logout() {
        Settings.setParkingPandaCredentials(username: nil, password: nil)
    }
    
    static func getLocation(_ user: ParkingPandaUser, locationId: String, startDate: Date, endDate: Date, completion: @escaping ((_ location: ParkingPandaLocation?, _ error: ParkingPandaError?) -> Void)) {

        //https://www.parkingpanda.com/api/v2/locations?startdate=02-19-2016&enddate=02-19-2016&startTime=1600&endTime=1900&idLocation=4893
        //That will return a JSON object; the price is at obj[“data”][“locations”][0][“price”]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent

        let startTime = String(format: "%02d:%02d", startDate.hour24Format(), startDate.minute())
        let endTime = String(format: "%02d:%02d", endDate.hour24Format(), endDate.minute())

        let url = baseUrlString + "locations"
        let params: [String: AnyObject] = [
            "apikey": publicKey,
            "startdate": dateFormatter.string(from: startDate), //MM-dd-yyyy
            "enddate": dateFormatter.string(from: endDate), //MM-dd-yyyy
            "startTime": startTime, //HH:mm
            "endTime": endTime, //HH:mm
            "idLocation": locationId
        ]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(location: nil, error: ppError)
                    return
                }
                
                let locationsJson: [JSON] = json["data"]["locations"].arrayValue
                let locations = locationsJson.map({ (locationJson) -> ParkingPandaLocation in
                    ParkingPandaLocation(json: locationJson)
                })
                completion(location: locations.first, error: ppError)
        }
    }
    
    static func getTransaction(_ user: ParkingPandaUser, confirmation: String, completion: @escaping ((_ transaction: ParkingPandaTransaction?, _ error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/transactions/" + confirmation
        let params: [String: AnyObject] = ["apikey": publicKey as AnyObject]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(transaction: nil, error: ppError)
                    return
                }
                
                let transaction = ParkingPandaTransaction(json: json["data"])
                completion(transaction: transaction, error: ppError)
        }
    }
    
    static func getTransactions(_ user: ParkingPandaUser, forTime: ParkingPandaTransactionTime, completion: @escaping ((_ transactions: [ParkingPandaTransaction], _ error: ParkingPandaError?) -> Void)) {
        
        var url = baseUrlString + "users/" + String(user.id) + "/transactions"
        
        switch (forTime) {
        case .all:
            break //the default url should return all transactions
        case .past:
            url += "/past"
        case .upcoming:
            url += "/upcoming"
        }
        
        let params: [String: AnyObject] = ["apikey": publicKey as AnyObject]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(transactions: [], error: ppError)
                    return
                }
                
                let transactionsJson: [JSON] = json["data"].arrayValue
                let transactions = transactionsJson.map({ (transactionJson) -> ParkingPandaTransaction in
                    ParkingPandaTransaction(json: transactionJson)
                })
                completion(transactions: transactions, error: ppError)
        }
    }
    
    static func createTransaction(_ user: ParkingPandaUser, location: ParkingPandaLocation, completion: @escaping ((_ transaction: ParkingPandaTransaction?, _ error: ParkingPandaError?) -> Void)) {
        
        getCreditCards(user) { (creditCards, error) -> Void in
            var billingCreditCard: ParkingPandaCreditCard? = creditCards.first
            for creditCard in creditCards {
                if creditCard.isDefault {
                    billingCreditCard = creditCard
                }
            }
            
            if billingCreditCard != nil {
                
                //we have a credit card to use, now let's create the transaction!
                let url = baseUrlString + "users/" + String(user.id) + "/transactions"
                
                let brand: String = Settings.getCarDescription()["brand"] ?? ""
                let plate: String = Settings.getCarDescription()["plate"] ?? ""
                let model: String = Settings.getCarDescription()["model"] ?? ""
                let color: String = Settings.getCarDescription()["color"] ?? ""
                let phone: String = Settings.getCarDescription()["phone"] ?? ""

                let vehicleDescription = String(format: "%@ %@ %@, %@, %@", color, model, brand, plate, phone)
                
                let params: [String: AnyObject] = [
                    "apikey": publicKey as AnyObject,
                    "paymentMethodToken": billingCreditCard!.token as AnyObject,
                    "idLocation": location.identifier as AnyObject,
                    "startDateAndTime": location.startDateAndTimeString as AnyObject,
                    "endDateAndTime": location.endDateAndTimeString as AnyObject,
                    "vehicleDescription": vehicleDescription as AnyObject
                ]
                
                ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
                    .request(.POST, url, parameters: params, encoding: .json)
                    .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                        (request, response, json, error) in
                        
                        let ppError = self.didRequestSucceed(response, json: json, error: error)
                        if ppError.errorType != .noError {
                            completion(transaction: nil, error: ppError)
                            return
                        }
                        
                        AnalyticsOperations.ppUserDidCreateTransaction(nil)
                        let transactionsJson: [JSON] = json["data"].arrayValue
                        let transactions = transactionsJson.map({ (transactionJson) -> ParkingPandaTransaction in
                            ParkingPandaTransaction(json: transactionJson)
                        })

                        completion(transaction: transactions.first, error: ppError)
                }

                
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    GeneralHelper.warnUserWithErrorMessage("parking_panda_cc_error".localizedString)
                })
                completion(nil, error)
            }
        }
    }
    
    
    static func getCreditCards(_ user: ParkingPandaUser, completion: @escaping ((_ creditCards: [ParkingPandaCreditCard], _ error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards"
        let params: [String: AnyObject] = ["apikey": publicKey as AnyObject]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(creditCards: [], error: ppError)
                    return
                }
                
                let creditCardsJson: [JSON] = json["data"].arrayValue
                let creditCards = creditCardsJson.map({ (creditCardJson) -> ParkingPandaCreditCard in
                    ParkingPandaCreditCard(json: creditCardJson)
                })
                completion(creditCards: creditCards, error: ppError)
        }
    }
    
    static func addCreditCard(_ user: ParkingPandaUser, cardInfo: CardIOCreditCardInfo, completion: @escaping ((_ creditCard: ParkingPandaCreditCard?, _ error: ParkingPandaError?) -> Void)) {
        
        let expiryDate = String(format: "%.2d", cardInfo.expiryMonth) + "/" + String(format: "%.4d", cardInfo.expiryYear)
        let name = user.firstName + " " + user.lastName

        ParkingPandaOperations.addCreditCard(user, creditCardNumber: cardInfo.cardNumber, cvv: cardInfo.cvv, billingPostalCode: cardInfo.postalCode, cardholderName: name, expiryDate: expiryDate, completion: completion)
    }
    
    static func addCreditCard(_ user: ParkingPandaUser, creditCardNumber: String, cvv: String, billingPostalCode: String, cardholderName: String, expiryDate: String, completion: @escaping ((_ creditCard: ParkingPandaCreditCard?, _ error: ParkingPandaError?) -> Void)) {

        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards"
        let params: [String: AnyObject] = [
            "apikey": publicKey as AnyObject,
            "CreditCardNumber": creditCardNumber as AnyObject,
            "CVV": cvv as AnyObject,
            "BillingPostal": billingPostalCode as AnyObject,
            "CardholderName": cardholderName as AnyObject,
            "ExpirationDate": expiryDate as AnyObject,
        ]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.POST, url, parameters: params, encoding: .json)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(creditCard: nil, error: ppError)
                    return
                }
                
                let creditCard = ParkingPandaCreditCard(json: json["data"])
                completion(creditCard: creditCard, error: ppError)
        }
    }
    
    static func updateCreditCard(_ user: ParkingPandaUser,
        token: String,
//        creditCardNumber: String,
//        cvv: String,
//        billingPostalCode: String,
//        cardholderName: String,
//        expiryDate: String,
        isDefault: Bool,
        completion: @escaping ((_ creditCard: ParkingPandaCreditCard?, _ error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards/" + token
        let params: [String: AnyObject] = [
            "apikey": publicKey as AnyObject,
//            "CreditCardNumber": creditCardNumber,
//            "CVV": cvv,
//            "BillingPostal": billingPostalCode,
//            "CardholderName": cardholderName,
//            "ExpirationDate": expiryDate,
            "MakeDefault": isDefault as AnyObject
        ]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.PUT, url, parameters: params, encoding: .json)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .noError {
                    completion(creditCard: nil, error: ppError)
                    return
                }
                
                let creditCard = ParkingPandaCreditCard(json: json["data"])
                completion(creditCard: creditCard, error: ppError)
        }
    }

    static func deleteCreditCard(_ user: ParkingPandaUser, token: String, completion: @escaping ((_ error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards/" + token
        let params: [String: AnyObject] = ["apikey": publicKey as AnyObject]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.DELETE, url, parameters: params)
            .responseSwiftyJSONAsync(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), options: JSONSerialization.ReadingOptions.allowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                completion(error: ppError)
        }
    }
    
}

//all the properties of a transaction object are available here: https://www.parkingpanda.com/api/v2/Help/ResourceModel?modelName=Transaction
//properties should be parsed as we need them in the UI or for any other reason
class ParkingPandaTransaction {
    
    var json: JSON
    var amount: Float
    var startDateAndTime: Date?
    var endDateAndTime: Date?
    var startDateAndTimeString: String
    var endDateAndTimeString: String
    var formattedStartDateAndTime: String
    var formattedEndDateAndTime: String
    var isRefunded: Bool
    var pdfUrlString: String
    var barcodeUrlString: String
    var barcode: String
    var paymentMaskedCardInfo: String
    var confirmation: String
    var location: ParkingPandaLocation
        
    init(json: JSON) {
        self.json = json
        self.amount = json["amount"].floatValue
        self.formattedStartDateAndTime = json["formattedStartDateAndTime"].stringValue
        self.formattedEndDateAndTime = json["formattedEndDateAndTime"].stringValue
        self.startDateAndTimeString = json["startDateAndTime"].stringValue
        self.endDateAndTimeString = json["endDateAndTime"].stringValue
        self.isRefunded = json["isRefunded"].boolValue
        self.pdfUrlString = json["pdfUrl"].stringValue
        self.barcodeUrlString = json["qrCodeUrl"].stringValue
        self.barcode = json["barcode"].string ?? json["barcodeLabel"].stringValue
        self.paymentMaskedCardInfo = json["paymentMaskedCardInfo"].stringValue
        self.confirmation = json["confirmation"].stringValue
        self.location = ParkingPandaLocation(json: json["location"]) //hardly anything is served in this for some reason
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = self.location.offsetTimeZone
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.endDateAndTime = dateFormatter.date(from: self.endDateAndTimeString)
        self.startDateAndTime = dateFormatter.date(from: self.startDateAndTimeString)
    }
    
}

//all the properties of a user object are available here: https://www.parkingpanda.com/api/v2/Help/ResourceModel?modelName=User
//properties should be parsed as we need them in the UI or for any other reason (in this case, credit cards)
class ParkingPandaUser {
    
    var json: JSON
    var id: Int
    var email: String
    var apiPassword: String
    var firstName: String
    var lastName: String
    var creditCards: [ParkingPandaCreditCard]
    
    init(json: JSON) {
        self.json = json
        self.id = json["id"].intValue
        self.email = json["email"].stringValue
        self.apiPassword = json["apiPassword"].stringValue
        self.firstName = json["firstname"].stringValue
        self.lastName = json["lastname"].stringValue
        self.creditCards = json["creditCards"].arrayValue.map({ (creditCardJson) -> ParkingPandaCreditCard in
            ParkingPandaCreditCard(json: creditCardJson)
        })
    }
    
}

//all the properties of a user object are available here: https://www.parkingpanda.com/api/v2/Help/ResourceModel?modelName=CreditCard
//properties should be parsed as we need them in the UI or for any other reason (in this case, credit cards)
class ParkingPandaCreditCard {
    
    var json: JSON
    var token: String
    var maskedNumber: String
    var lastFour: String
    var billingPostal: String
    var isDefault: Bool
    var isExpired: Bool
    var expirationDate: String
    var cardType: String
    var paymentType: CardIOCreditCardType
    
    init(json: JSON) {
        self.json = json
        self.token = json["token"].stringValue
        self.billingPostal = json["billingPostal"].stringValue
        self.isDefault = json["isDefault"].boolValue
        self.isExpired = json["isExpired"].boolValue
        self.expirationDate = json["expirationDate"].stringValue
        self.maskedNumber = json["maskedNumber"].stringValue
        self.lastFour = json["lastFour"].stringValue
        self.cardType = json["cardType"].stringValue
        
        let paymentTypeEnum = json["paymentType"].intValue
        switch(paymentTypeEnum){
        case 0:
            self.paymentType = .amex
        case 1:
            self.paymentType = .discover
        case 3:
            self.paymentType = .JCB
        case 5:
            self.paymentType = .mastercard
        case 6:
            self.paymentType = .visa
        default:
            self.paymentType = .unrecognized
        }
    }
    
}

//all the properties of a user object are available here: http://dev.parkingpanda.com/api/v2/Help/ResourceModel?modelName=Location
//properties should be parsed as we need them in the UI or for any other reason
class ParkingPandaLocation {
    
    var json: JSON
    var price: Float
    var isAvailable: Bool
    var endDateAndTime: Date?
    var identifier: String
    var startDateAndTimeString: String
    var endDateAndTimeString: String
    fileprivate var timeZoneOffsetFromUTCInSeconds: Int
    var offsetTimeZone: TimeZone
    var address: String
    var cityStateAndPostal: String
    
    var fullAddress: String { return self.address + ", " + self.cityStateAndPostal }

    init(json: JSON) {
        self.json = json
        self.identifier = json["id"].stringValue
        self.price = json["price"].floatValue
        self.isAvailable = json["isAvailable"].boolValue
        
        timeZoneOffsetFromUTCInSeconds = Int(json["timeZoneOffsetFromUtc"].floatValue * 3600)
        offsetTimeZone = TimeZone(secondsFromGMT: timeZoneOffsetFromUTCInSeconds)!
        
        self.startDateAndTimeString = json["startDateAndTime"].stringValue
        self.endDateAndTimeString = json["endDateAndTime"].stringValue

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = offsetTimeZone
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.endDateAndTime = dateFormatter.date(from: self.endDateAndTimeString)
        
        self.address = json["displayAddress"].string ?? json["address1"].stringValue
        self.cityStateAndPostal = json["cityStateAndPostal"].stringValue
    }
    
}
