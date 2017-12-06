//
//  String.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 8/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension String {
    var localizedString: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substring(with: (characters.index(startIndex, offsetBy: r.lowerBound) ..< characters.index(startIndex, offsetBy: r.upperBound)))
    }
    
    var abbreviatedString: String {
        
        var newString = self
        
        let path = Bundle.main.path(forResource: "Abbreviations", ofType: "strings")
        let dictionary = NSDictionary(contentsOfFile: path!) as! Dictionary<String, String>
        
        for pair in dictionary {
            let target = pair.0
            let abbreviation = pair.1
            newString = newString.replacingOccurrences(of: target, with: abbreviation, options: NSString.CompareOptions.caseInsensitive, range: nil)
        }
        
        return newString
    }

    //the second string in the tuple is the "main" one ie ("RUE ", "de la commune")
    var splitAddressString: (String, String) {
        
        let myself = self.abbreviatedString
        var longestMatchedString: Int = 0
        var firstString = ""
        var secondString = self.abbreviatedString
        
        let path = Bundle.main.path(forResource: "AddressSplitting", ofType: "strings")
        let dictionary = NSDictionary(contentsOfFile: path!) as! Dictionary<String, String>
        
        for pair in dictionary {
            let delimittingString = pair.0
//            let replaceMentStringForDelimitter = pair.1
            if let leftRange = myself.range(of: delimittingString, options: NSString.CompareOptions.caseInsensitive) {
                let stringCount = delimittingString.characters.count
                if stringCount > longestMatchedString {
                    longestMatchedString = stringCount
                    firstString = myself.substring(with: (myself.startIndex ..< leftRange.upperBound))
                    secondString = myself.substring(with: (leftRange.upperBound ..< myself.endIndex))
                }
            }
            
        }
        
        firstString = firstString.uppercased()
        
        if secondString.length() <= 6 {
            return ("", myself)
        }
        
        return (firstString, secondString)
    }

    var isValidEmail: Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    internal func indexOf(_ sub: String) -> Int? {
        var pos: Int?
        
        if let range = self.range(of: sub) {
            if !range.isEmpty {
                pos = self.characters.distance(from: self.startIndex, to: range.lowerBound)
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
    
    func urlEncodedStringWithEncoding(_ encoding: String.Encoding) -> String {
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFString
        let charactersToLeaveUnescaped = "[]." as CFString
        
        let raw: NSString = self as NSString
        
        let result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, raw, charactersToLeaveUnescaped, charactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding.rawValue))
        
        return result as! String
    }
    
    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        
        let scanner = Scanner(string: self)
        
        var key: NSString?
        var value: NSString?
        
        while !scanner.isAtEnd {
            key = nil
            scanner.scanUpTo("=", into: &key)
            scanner.scanString("=", into: nil)
            
            value = nil
            scanner.scanUpTo("&", into: &value)
            scanner.scanString("&", into: nil)
            
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
    func split(_ s:String) -> [String]{
        if s.isEmpty{
            var x=[String]()
            for y in self.characters{
                x.append(String(y))
            }
            return x
        }
        return self.components(separatedBy: s)
    }
    //去掉左右空格
    func trim() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    //是否包含字符串
    func has(_ s:String) -> Bool{
        if (self.range(of: s) != nil) {
            return true
        }else{
            return false
        }
    }
    //是否包含前缀
    func hasBegin(_ s:String) -> Bool{
        if self.hasPrefix(s) {
            return true
        }else{
            return false
        }
    }
    //是否包含后缀
    func hasEnd(_ s:String) -> Bool{
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
    func `repeat`(_ times: Int) -> String{
        var result = ""
        for _ in 0..<times {
            result += self
        }
        return result
    }
    //反转
    func reverse() -> String{
        let s=Array(self.split("").reversed())
        var x=""
        for y in s{
            x+=y
        }
        return x
    }
    
}
