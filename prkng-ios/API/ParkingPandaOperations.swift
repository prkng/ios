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
            case None
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
        
        let parkingPandaErrorCode = json["error"].int
        let parkingPandaErrorMessage = json["message"].string
        let parkingPandaSuccess = json["success"].boolValue
        
        if (response != nil && response?.statusCode == 401) {
                DDLoggerWrapper.logError(String(format: "ParkingPanda Error: Bad network connection"))
                return ParkingPandaError(errorType: .Network, errorDescription: "Bad network connection")
        } else if !parkingPandaSuccess
            || parkingPandaErrorCode != nil
            || parkingPandaErrorMessage != nil {
                DDLoggerWrapper.logError(String(format: "Error: No workie. Reason: %@", parkingPandaErrorMessage ?? json.description))
                return ParkingPandaError(errorType: .API, errorDescription: parkingPandaErrorMessage ?? json.description)
        }

        return ParkingPandaError(errorType: .None, errorDescription: nil)
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
                if ppError.errorType != .None {
                    completion(user: nil, error: ppError)
                    return
                }
                
                let user = ParkingPandaUser(json: json["data"])
                Settings.setParkingPandaCredentials(username: user.email, password: user.apiPassword)
                completion(user: user, error: ppError)
        }

    }
    
    //used to do a login, or to get the user (ie if you're already athenticated, it will use your stored credentials)
    static func login(username username: String?, password: String?, completion: ((user: ParkingPandaUser?, error: ParkingPandaError?) -> Void)) {
        
        let url = baseUrlString + "users"
        let params: [String: AnyObject] = ["apikey": publicKey]

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
                if ppError.errorType != .None {
                    completion(user: nil, error: ppError)
                    return
                }
                
                let user = ParkingPandaUser(json: json["data"])
                Settings.setParkingPandaCredentials(username: user.email, password: user.apiPassword)
                completion(user: user, error: ppError)
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
                if ppError.errorType != .None {
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
                if ppError.errorType != .None {
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
    
}

//all the properties of a transaction object are available here: https://www.parkingpanda.com/api/v2/Help/ResourceModel?modelName=Transaction
//properties should be parsed as we need them in the UI or for any other reason
class ParkingPandaTransaction {
    
    var json: JSON
    
    init(json: JSON) {
        self.json = json
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
    
    init(json: JSON) {
        self.json = json
        self.id = json["id"].intValue
        self.email = json["email"].stringValue
        self.apiPassword = json["apiPassword"].stringValue
        self.firstName = json["firstname"].stringValue
        self.lastName = json["lastname"].stringValue
    }
    
}
