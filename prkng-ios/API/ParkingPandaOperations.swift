//
//  LotOperations.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 26/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

 class ParkingPandaOperations {
    
    
    //Development (Sandbox) API (Reservations aren’t real, use Braintree sample card numbers to test)
    let publicKey = "39b5854211924468af84ad0e1d2edf56"
    let privateKey = "8bcdcdfb71dd4c87b9dff6d4b75809b7"
    
//    //Real API
//    let publicKey = "908eb2a1edd3491791da7f8b8e5716ee"
//    let privateKey = "f6a1fb203f334dfe9f75a5b58663a209"

    let baseUrlString = "https://www.parkingpanda.com/api/v2/"
    
    enum ParkingPandaTransactionTime {
        case All
        case Past
        case Upcoming
    }
    
    //parses the API response for all Parking Panda requests.
    func didRequestSucceed(response: NSHTTPURLResponse?, json: JSON, error: NSError?) -> Bool {
        
        let parkingPandaErrorCode = json["error"].int
        let parkingPandaErrorMessage = json["message"].string
        let parkingPandaSuccess = json["success"].boolValue
        
        if (response != nil && response?.statusCode == 401)
            || !parkingPandaSuccess
            || parkingPandaErrorCode != nil
            || parkingPandaErrorMessage != nil {
                DDLoggerWrapper.logError(String(format: "Error: No workie. Reason: %@", parkingPandaErrorMessage ?? json.description))
                return false
        }

        return true
    }
    
    func login(username: String, password: String, completion: ((user: ParkingPandaUser?) -> Void)) {
        
        let url = baseUrlString + "users"
        let params: [String: AnyObject] = ["apikey": publicKey]
        //basic auth with user_id and api_password
        
        request(.GET, URLString: url, parameters: params)
            .authenticate(user: username, password: password)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let failure = self.didRequestSucceed(response, json: json, error: error)
                if failure {
                    completion(user: nil)
                    return
                }
                
                let user = ParkingPandaUser(json: json["data"])
                completion(user: user)
        }
    }

    func getTransaction(user: ParkingPandaUser, confirmation: String, completion: ((transaction: ParkingPandaTransaction?) -> Void)) {
        
        let url = baseUrlString + "users/" + String(user.id) + "/transactions/" + confirmation
        let params: [String: AnyObject] = ["apikey": publicKey]
        //basic auth with user_id and api_password
        
        request(.GET, URLString: url, parameters: params)
            .authenticate(user: String(user.id), password: user.apiPassword)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let failure = self.didRequestSucceed(response, json: json, error: error)
                if failure {
                    completion(transaction: nil)
                    return
                }
                
                let transaction = ParkingPandaTransaction(json: json["data"])
                completion(transaction: transaction)
        }
    }
    
    func getTransactions(user: ParkingPandaUser, forTime: ParkingPandaTransactionTime, completion: ((transactions: [ParkingPandaTransaction], completed: Bool) -> Void)) {
        
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
        //basic auth with user_id and api_password
        
        request(.GET, URLString: url, parameters: params)
            .authenticate(user: String(user.id), password: user.apiPassword)
            .responseSwiftyJSONAsync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), options: NSJSONReadingOptions.AllowFragments) {
                (request, response, json, error) in
                
                let failure = self.didRequestSucceed(response, json: json, error: error)
                if failure {
                    completion(transactions: [], completed: false)
                    return
                }
                
                let transactionsJson: [JSON] = json["data"].arrayValue
                let transactions = transactionsJson.map({ (transactionJson) -> ParkingPandaTransaction in
                    ParkingPandaTransaction(json: transactionJson)
                })
                completion(transactions: transactions, completed: true)
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
