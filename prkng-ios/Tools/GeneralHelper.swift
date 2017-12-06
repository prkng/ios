//
//  GeneralHelper.swift
//  
//
//  Created by Antonino Urbano on 2015-07-17.
//
//

import UIKit

class GeneralHelper {

    static func warnUser(_ message: String) {
        let alert = UIAlertView()
        alert.message = message
        alert.addButton(withTitle: "OK".localizedString)
        alert.show()
    }

    static func warnUserWithErrorMessage(_ message: String) {
        let alert = UIAlertView()
        alert.message = message
        alert.title = "error".localizedString
        alert.addButton(withTitle: "OK".localizedString)
        alert.show()
    }

    static func warnUserWithSucceedMessage(_ message: String) {
        let alert = UIAlertView()
        alert.message = message
        alert.title = "success".localizedString
        alert.addButton(withTitle: "OK".localizedString)
        alert.show()
    }

}
