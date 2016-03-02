//
//  LotOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 26/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ParkingPandaOperations {
    
    //Development (Sandbox) API (Reservations aren’t real, use Braintree sample card numbers to test https://developers.braintreepayments.com/reference/general/testing/node#credit-card-numbers)
    static let baseUrlString = "http://dev.parkingpanda.com/api/v2/"
    static let publicKey = "39b5854211924468af84ad0e1d2edf56"
    static let privateKey = "8bcdcdfb71dd4c87b9dff6d4b75809b7"
    
    //TODO: switch to production
//    //Real API
//    static let baseUrlString = "https://www.parkingpanda.com/api/v2/"
//    static let publicKey = "908eb2a1edd3491791da7f8b8e5716ee"
//    static let privateKey = "f6a1fb203f334dfe9f75a5b58663a209"
    
    enum ParkingPandaTransactionTime {
        case All
        case Past
        case Upcoming
    }

    struct ParkingPandaError {

        enum ParkingPandaErrorType {
            case API
            case Internal
            case Network
            case NoError
        }

        var errorType: ParkingPandaErrorType
        var errorDescription: String?
    }


    private class ParkingPandaHelper {
        
        class func authenticatedManager(username username: String, password: String) -> Manager {
            
            let plainString = (username + ":" + password) as NSString//"username:password" as NSString
            let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
            let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))

            var headers = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
            headers["Authorization"] = "Basic " + base64String!
            
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = headers
            
            return Manager(configuration: configuration)
        }
    }

    //parses the API response for all Parking Panda requests.
    static func didRequestSucceed(response: NSHTTPURLResponse?, json: JSON, error: NSError?) -> ParkingPandaError {
        
        var returnedError = ParkingPandaError(errorType: .NoError, errorDescription: nil)
        
        let parkingPandaErrorCode = json["error"].int
        let parkingPandaErrorMessage = json["message"].string
        let parkingPandaSuccess = json["success"].boolValue
        
        if (response != nil && response?.statusCode == 401) {
                DDLoggerWrapper.logError(String(format: "ParkingPanda Error: Bad network connection"))
                returnedError = ParkingPandaError(errorType: .Network, errorDescription: "Bad network connection")
        } else if !parkingPandaSuccess
            || parkingPandaErrorCode != nil
            || parkingPandaErrorMessage != nil {
                DDLoggerWrapper.logError(String(format: "Error: No workie. Reason: %@", parkingPandaErrorMessage ?? json.description))
                returnedError = ParkingPandaError(errorType: .API, errorDescription: parkingPandaErrorMessage ?? json.description)
        }

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //TODO: Localize these strings
            switch (returnedError.errorType) {
            case .API, .Internal:
                GeneralHelper.warnUserWithErrorMessage(returnedError.errorDescription ?? "")
            case .Network:
                GeneralHelper.warnUserWithErrorMessage("Bad network connection, please try again later.")
            case .NoError:
                break
            }
        })
        
        return returnedError
    }
    
    static func createUser(email: String, password: String, firstName: String, lastName: String, phone: String, completion: ((user: ParkingPandaUser?, error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users"
        let params: [String: AnyObject] = ["apikey": publicKey,
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "phone": phone,
            "dontReceiveEmail": true,
//            "invitationCodeForSignup": "some_code",
            "receiveSMSNotifications": false,
            "dontSendWelcomeEmail": false
        ]
        
        ParkingPandaHelper.authenticatedManager(username: "admin", password: "admin")
            .request(.POST, url, parameters: params, encoding: .JSON)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
                    completion(user: nil, error: ppError)
                    return
                }
                
                let user = ParkingPandaUser(json: json["data"])
                Settings.setParkingPandaCredentials(username: user.email, password: user.apiPassword)
                completion(user: user, error: ppError)
        }

    }
    
    //used to do a login, or to get the user (ie if you're already athenticated, it will use your stored credentials)
    static func login(username username: String?, password: String?, includeCreditCards: Bool = false, completion: ((user: ParkingPandaUser?, error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users"
        let params: [String: AnyObject] = [
            "apikey": publicKey,
            "includeCreditCards": includeCreditCards //the api does not do anything with this, sadly
        ]

        let creds = Settings.getParkingPandaCredentials()
        let loginUsername = username ?? creds.0
        let loginPassword = password ?? creds.1
        
        if loginUsername == nil || loginPassword == nil {
            completion(user: nil, error: ParkingPandaError(errorType: .Internal, errorDescription: "No credentials given."))
            return
        }
        
        ParkingPandaHelper.authenticatedManager(username: loginUsername!, password: loginPassword!)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
                    completion(user: nil, error: ppError)
                    return
                }
                
                let user = ParkingPandaUser(json: json["data"])
                Settings.setParkingPandaCredentials(username: user.email, password: user.apiPassword)
                completion(user: user, error: ppError)
        }
    }

    static func logout() {
        Settings.setParkingPandaCredentials(username: nil, password: nil)
    }
    
    static func getLocation(user: ParkingPandaUser, locationId: String, startDate: NSDate, endDate: NSDate, completion: ((location: ParkingPandaLocation?, error: ParkingPandaError?) -> Void)) {

        //https://www.parkingpanda.com/api/v2/locations?startdate=02-19-2016&enddate=02-19-2016&startTime=1600&endTime=1900&idLocation=4893
        //That will return a JSON object; the price is at obj[“data”][“locations”][0][“price”]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()

        let startTime = String(format: "%02d:%02d", startDate.hour24Format(), startDate.minute())
        let endTime = String(format: "%02d:%02d", endDate.hour24Format(), endDate.minute())

        let url = baseUrlString + "locations"
        let params: [String: AnyObject] = [
            "apikey": publicKey,
            "startdate": dateFormatter.stringFromDate(startDate), //MM-dd-yyyy
            "enddate": dateFormatter.stringFromDate(endDate), //MM-dd-yyyy
            "startTime": startTime, //HH:mm
            "endTime": endTime, //HH:mm
            "idLocation": locationId
        ]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
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
    
    static func getTransaction(user: ParkingPandaUser, confirmation: String, completion: ((transaction: ParkingPandaTransaction?, error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/transactions/" + confirmation
        let params: [String: AnyObject] = ["apikey": publicKey]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
                    completion(transaction: nil, error: ppError)
                    return
                }
                
                let transaction = ParkingPandaTransaction(json: json["data"])
                completion(transaction: transaction, error: ppError)
        }
    }
    
    static func getTransactions(user: ParkingPandaUser, forTime: ParkingPandaTransactionTime, completion: ((transactions: [ParkingPandaTransaction], error: ParkingPandaError?) -> Void)) {
        
        var url = baseUrlString + "users/" + String(user.id) + "/transactions"
        
        switch (forTime) {
        case .All:
            break //the default url should return all transactions
        case .Past:
            url += "/past"
        case .Upcoming:
            url += "/upcoming"
        }
        
        let params: [String: AnyObject] = ["apikey": publicKey]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
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
    
    static func createTransaction(user: ParkingPandaUser, location: ParkingPandaLocation, completion: ((transaction: ParkingPandaTransaction?, error: ParkingPandaError?) -> Void)) {
        
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
                    "apikey": publicKey,
                    "paymentMethodToken": billingCreditCard!.token,
                    "idLocation": location.identifier,
                    "startDateAndTime": location.startDateAndTimeString,
                    "endDateAndTime": location.endDateAndTimeString,
                    "vehicleDescription": vehicleDescription
                ]
                
                ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
                    .request(.POST, url, parameters: params, encoding: .JSON)
                    .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                        (request, response, json, error) in
                        
                        let ppError = self.didRequestSucceed(response, json: json, error: error)
                        if ppError.errorType != .NoError {
                            completion(transaction: nil, error: ppError)
                            return
                        }
                        
                        let transactionsJson: [JSON] = json["data"].arrayValue
                        let transactions = transactionsJson.map({ (transactionJson) -> ParkingPandaTransaction in
                            ParkingPandaTransaction(json: transactionJson)
                        })

                        completion(transaction: transactions.first, error: ppError)
                }

                
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //TODO: Localize
                    GeneralHelper.warnUserWithErrorMessage("Please add a credit card in Parking Panda Settings before paying.")
                })
                completion(transaction: nil, error: error)
            }
        }
    }
    
    
    static func getCreditCards(user: ParkingPandaUser, completion: ((creditCards: [ParkingPandaCreditCard], error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards"
        let params: [String: AnyObject] = ["apikey": publicKey]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.GET, url, parameters: params)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
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
    
    static func addCreditCard(user: ParkingPandaUser, cardInfo: CardIOCreditCardInfo, completion: ((creditCard: ParkingPandaCreditCard?, error: ParkingPandaError?) -> Void)) {
        
        let expiryDate = String(format: "%.2d", cardInfo.expiryMonth) + "/" + String(format: "%.4d", cardInfo.expiryYear)
        let name = user.firstName + " " + user.lastName

        ParkingPandaOperations.addCreditCard(user, creditCardNumber: cardInfo.cardNumber, cvv: cardInfo.cvv, billingPostalCode: cardInfo.postalCode, cardholderName: name, expiryDate: expiryDate, completion: completion)
    }
    
    static func addCreditCard(user: ParkingPandaUser, creditCardNumber: String, cvv: String, billingPostalCode: String, cardholderName: String, expiryDate: String, completion: ((creditCard: ParkingPandaCreditCard?, error: ParkingPandaError?) -> Void)) {

        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards"
        let params: [String: AnyObject] = [
            "apikey": publicKey,
            "CreditCardNumber": creditCardNumber,
            "CVV": cvv,
            "BillingPostal": billingPostalCode,
            "CardholderName": cardholderName,
            "ExpirationDate": expiryDate,
        ]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.POST, url, parameters: params, encoding: .JSON)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
                    completion(creditCard: nil, error: ppError)
                    return
                }
                
                let creditCard = ParkingPandaCreditCard(json: json["data"])
                completion(creditCard: creditCard, error: ppError)
        }
    }
    
    static func updateCreditCard(user: ParkingPandaUser, token: String, creditCardNumber: String, cvv: String, billingPostalCode: String, cardholderName: String, expiryDate: String, completion: ((creditCard: ParkingPandaCreditCard?, error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards/" + token
        let params: [String: AnyObject] = [
            "apikey": publicKey,
            "CreditCardNumber": creditCardNumber,
            "CVV": cvv,
            "BillingPostal": billingPostalCode,
            "CardholderName": cardholderName,
            "ExpirationDate": expiryDate,
        ]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.PUT, url, parameters: params)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let ppError = self.didRequestSucceed(response, json: json, error: error)
                if ppError.errorType != .NoError {
                    completion(creditCard: nil, error: ppError)
                    return
                }
                
                let creditCard = ParkingPandaCreditCard(json: json["data"])
                completion(creditCard: creditCard, error: ppError)
        }
    }

    static func deleteCreditCard(user: ParkingPandaUser, token: String, completion: ((error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/credit-cards/" + token
        let params: [String: AnyObject] = ["apikey": publicKey]
        
        ParkingPandaHelper.authenticatedManager(username: user.email, password: user.apiPassword)
            .request(.DELETE, url, parameters: params)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
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
    var startDateAndTime: NSDate?
    var endDateAndTime: NSDate?
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
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = self.location.offsetTimeZone
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.endDateAndTime = dateFormatter.dateFromString(self.endDateAndTimeString)
        self.startDateAndTime = dateFormatter.dateFromString(self.startDateAndTimeString)
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
            self.paymentType = .Amex
        case 1:
            self.paymentType = .Discover
        case 3:
            self.paymentType = .JCB
        case 5:
            self.paymentType = .Mastercard
        case 6:
            self.paymentType = .Visa
        default:
            self.paymentType = .Unrecognized
        }
    }
    
}

//all the properties of a user object are available here: http://dev.parkingpanda.com/api/v2/Help/ResourceModel?modelName=Location
//properties should be parsed as we need them in the UI or for any other reason
class ParkingPandaLocation {
    
    var json: JSON
    var price: Float
    var isAvailable: Bool
    var endDateAndTime: NSDate?
    var identifier: String
    var startDateAndTimeString: String
    var endDateAndTimeString: String
    private var timeZoneOffsetFromUTCInSeconds: Int
    var offsetTimeZone: NSTimeZone
    var address: String
    var cityStateAndPostal: String
    
    var fullAddress: String { return self.address + ", " + self.cityStateAndPostal }

    init(json: JSON) {
        self.json = json
        self.identifier = json["id"].stringValue
        self.price = json["price"].floatValue
        self.isAvailable = json["isAvailable"].boolValue
        
        timeZoneOffsetFromUTCInSeconds = Int(json["timeZoneOffsetFromUtc"].floatValue * 3600)
        offsetTimeZone = NSTimeZone(forSecondsFromGMT: timeZoneOffsetFromUTCInSeconds)
        
        self.startDateAndTimeString = json["startDateAndTime"].stringValue
        self.endDateAndTimeString = json["endDateAndTime"].stringValue

        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = offsetTimeZone
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.endDateAndTime = dateFormatter.dateFromString(self.endDateAndTimeString)
        
        self.address = json["displayAddress"].string ?? json["address1"].stringValue
        self.cityStateAndPostal = json["cityStateAndPostal"].stringValue
    }
    
}
