//
//  GeneralHelper.swift
//  
//
//  Created by Antonino Urbano on 2015-07-17.
//
//

import UIKit

class GeneralHelper {

    static func warnUser (message: String) {
        let alert = UIAlertView()
        alert.message = message
        alert.addButtonWithTitle("OK".localizedString)
        alert.show()
    }


}
