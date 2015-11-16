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
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
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

    //the second string in the tuple is the "main" one ie ("RUE ", "de la commune")
    var splitAddressString: (String, String) {
        
        let myself = self.abbreviatedString
        var longestMatchedString: Int = 0
        var firstString = ""
        var secondString = self.abbreviatedString
        
        let path = NSBundle.mainBundle().pathForResource("AddressSplitting", ofType: "strings")
        let dictionary = NSDictionary(contentsOfFile: path!) as! Dictionary<String, String>
        
        for pair in dictionary {
            let delimittingString = pair.0
//            let replaceMentStringForDelimitter = pair.1
            if let leftRange = myself.rangeOfString(delimittingString, options: NSStringCompareOptions.CaseInsensitiveSearch) {
                let stringCount = delimittingString.characters.count
                if stringCount > longestMatchedString {
                    longestMatchedString = stringCount
                    firstString = myself.substringWithRange(Range(start: myself.startIndex, end: leftRange.endIndex))
                    secondString = myself.substringWithRange(Range(start: leftRange.endIndex, end: myself.endIndex))
                }
            }
            
        }
        
        firstString = firstString.uppercaseString
        
        if secondString.length() <= 6 {
            return ("", myself)
        }
        
        return (firstString, secondString)
    }

    var isValidEmail: Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }

    
}