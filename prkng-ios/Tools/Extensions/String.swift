//
//  String.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 8/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension String {
    var localizedString: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
    
    var abbreviatedString: String {
        
        var newString = self
        
        let path = NSBundle.mainBundle().pathForResource("Abbreviations", ofType: "strings")
        let dictionary = NSDictionary(contentsOfFile: path!) as! Dictionary<String, String>
        
        for pair in dictionary {
            let target = pair.0
            let abbreviation = pair.1
            newString = newString.stringByReplacingOccurrencesOfString(target, withString: abbreviation, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        }
        
        return newString
    }
    
    var isValidEmail: Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }

    
}