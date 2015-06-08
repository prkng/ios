//
//  StyleSheet.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 24/03/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct Styles {

    struct Colors {
        
        static let cream1 = UIColor(rgba: "#F9F8F7")
        static let cream2 = UIColor(rgba: "#F4F1EF")
        
        static let stone = UIColor(rgba: "#EAE9E5")
        
        static let beige1 = UIColor(rgba: "#E5E0DA")
        static let beige2 = UIColor(rgba: "#DBD4CE")
        
        static let red1 = UIColor(rgba: "#EA7875")
        static let red2 = UIColor(rgba: "#D8534C")
        
        static let berry1 = UIColor(rgba: "#A63A3A")
        static let berry2 = UIColor(rgba: "#802D2D")
        
        static let petrol1 = UIColor(rgba: "#5B717F")
        static let petrol2 = UIColor(rgba: "#485966")
        
        static let midnight1 = UIColor(rgba: "#435059")
        static let midnight2 = UIColor(rgba: "#3A4249")
        
        static let anthracite1 = UIColor(rgba: "#979797")
        static let anthracite2 = UIColor(rgba: "#929292")
        
        static let white = UIColor(rgba: "#FFFFFF")
        
        static let grey = UIColor(rgba: "#D9D7D4")
        
        static let lightfx = UIColor(rgba: "#141719")
        
        static let redTransparent = UIColor(rgba: "#A63A3A")
        
        static let statusBar = UIColor(rgba: "#D1CCC980")
        
        static let transparentBackground = UIColor(red: 48.0/255.0, green: 58/255.0, blue: 66/255.0, alpha: 0.9)
    }
    
    struct FontFaces {
        
        static let regular = "Intro-Normal"
        static let light = "Intro-Light"
        
        static func regular (size : CGFloat) -> UIFont {
            return UIFont(name: regular, size: size)!
        }
        
        static func light (size : CGFloat) -> UIFont {
            return UIFont(name: light, size: size)!
        }
        
    }
    
    struct Fonts {
        static let h1 =  FontFaces.light(31)
        static let h2 =  FontFaces.light(25)
        static let h3 =  FontFaces.light(20)
    }
    
    struct Sizes {
        static let hugeButtonHeight = 90
        static let bigButtonHeight = 80
        static let searchTextFieldHeight = 46
    }
    
}
