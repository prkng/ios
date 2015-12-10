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
    
    internal func indexOf(sub: String) -> Int? {
        var pos: Int?
        
        if let range = self.rangeOfString(sub) {
            if !range.isEmpty {
                pos = self.startIndex.distanceTo(range.startIndex)
            }
        }
        
        return pos
    }
    
    //    internal subscript (r: Range<Int>) -> String {
    //        get {
    //            let startIndex = self.startIndex.advancedBy(r.startIndex)
    //            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
    //
    //            return self[Range(start: startIndex, end: endIndex)]
    //        }
    //    }
    
    func urlEncodedStringWithEncoding(encoding: NSStringEncoding) -> String {
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFStringRef
        let charactersToLeaveUnescaped = "[]." as CFStringRef
        
        let raw: NSString = self
        
        let result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, raw, charactersToLeaveUnescaped, charactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding))
        
        return result as String
    }
    
    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        
        let scanner = NSScanner(string: self)
        
        var key: NSString?
        var value: NSString?
        
        while !scanner.atEnd {
            key = nil
            scanner.scanUpToString("=", intoString: &key)
            scanner.scanString("=", intoString: nil)
            
            value = nil
            scanner.scanUpToString("&", intoString: &value)
            scanner.scanString("&", intoString: nil)
            
            if (key != nil && value != nil) {
                parameters.updateValue(value! as String, forKey: key! as String)
            }
        }
        
        return parameters
    }
    
    var safeStringByRemovingPercentEncoding: String {
        return self.stringByRemovingPercentEncoding ?? self
    }
    
    //分割字符
    func split(s:String) -> [String]{
        if s.isEmpty{
            var x=[String]()
            for y in self.characters{
                x.append(String(y))
            }
            return x
        }
        return self.componentsSeparatedByString(s)
    }
    //去掉左右空格
    func trim() -> String{
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    //是否包含字符串
    func has(s:String) -> Bool{
        if (self.rangeOfString(s) != nil) {
            return true
        }else{
            return false
        }
    }
    //是否包含前缀
    func hasBegin(s:String) -> Bool{
        if self.hasPrefix(s) {
            return true
        }else{
            return false
        }
    }
    //是否包含后缀
    func hasEnd(s:String) -> Bool{
        if self.hasSuffix(s) {
            return true
        }else{
            return false
        }
    }
    //统计长度
    func length() -> Int{
        return self.utf16.count
    }
    //统计长度(别名)
    func size() -> Int{
        return self.utf16.count
    }
    //重复字符串
    func `repeat`(times: Int) -> String{
        var result = ""
        for _ in 0..<times {
            result += self
        }
        return result
    }
    //反转
    func reverse() -> String{
        let s=Array(self.split("").reverse())
        var x=""
        for y in s{
            x+=y
        }
        return x
    }
    
}