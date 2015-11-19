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
        
        static let curry = UIColor(rgba: "#E6AE5C")
        static let sand = UIColor(rgba: "#E0AF65")
        
        static let stone = UIColor(rgba: "#EAE9E5")
        
        static let facebookBlue = UIColor(red: 69/255, green: 99/255, blue: 151/255, alpha: 1)
        
        static let turtleGreen = UIColor(rgba: "#81b347")
        static let azuro = UIColor(rgba: "#09adf1")
        
        static let beige1 = UIColor(rgba: "#E5E0DA")
        static let beige2 = UIColor(rgba: "#DBD4CE")
        
        static let red1 = UIColor(rgba: "#EA7875")
        static let red2 = UIColor(rgba: "#D8534C")
        
        static let berry1 = UIColor(rgba: "#A63A3A")
        static let berry2 = UIColor(rgba: "#802D2D")
        
        static let lipstick = UIColor(rgba: "#CF4F48")
        
        static let petrol1 = UIColor(rgba: "#5B717F")
        static let petrol2 = UIColor(rgba: "#485966")
        static let lineBlue = UIColor(rgba: "#5B717F")
        
        static let midnight1 = UIColor(rgba: "#435059")
        static let midnight2 = UIColor(rgba: "#3A4249")
        
        static let anthracite1 = UIColor(rgba: "#979797")
        static let anthracite2 = UIColor(rgba: "#929292")
        
        static let white = UIColor(rgba: "#FFFFFF")
        
        static let grey = UIColor(rgba: "#D9D7D4")
        static let greyish = UIColor(rgba: "#BFBEBB")

        static let dark30 = UIColor(rgba: "#13171A30")
        static let dark15 = UIColor(rgba: "#13171A15")
        
        static let lightfx = UIColor(rgba: "#141719")
        static let lightGrey = UIColor(rgba: "#e5e1dc")
        static let pinGrey = UIColor(rgba: "#B3B2AF95")
        
        static let redTransparent = UIColor(rgba: "#A63A3A")
        
        static let statusBar = UIColor(rgba: "#D1CCC980")
        
        static let transparentBackground = UIColor(red: 48.0/255.0, green: 58/255.0, blue: 66/255.0, alpha: 0.9)
        static let transparentWhite = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        static let transparentBlack = UIColor.blackColor().colorWithAlphaComponent(0.1)
        
    }
    
    struct FontFaces {
        
        static let regular = "Intro-Normal"
        static let light = "Intro-Light"
        static let bold = "Intro-Regular"
        
        static func regular (size : CGFloat) -> UIFont {
            return UIFont(name: regular, size: size)!
        }
        
        static func light (size : CGFloat) -> UIFont {
            return UIFont(name: light, size: size)!
        }

        static func bold (size : CGFloat) -> UIFont {
            return UIFont(name: bold, size: size)!
        }
        
    }
    
    struct Fonts {
        
        static let h1 =  FontFaces.light(25)
        static let h2 =  FontFaces.light(25)
        static let h3 =  FontFaces.light(20)
        
        static let h2Variable = UIScreen.mainScreen().bounds.width == 320 ? h3 : h2
        
        static let s1 =  FontFaces.light(17)
        static let s2 =  FontFaces.regular(14)
        static let s3 =  FontFaces.regular(12)
        
        
        static let h1r =  FontFaces.regular(25)
        static let h2r =  FontFaces.regular(25)
        static let h3r =  FontFaces.regular(20)
        
        static let h4rVariable = UIScreen.mainScreen().bounds.width == 320 ? FontFaces.regular(12) : FontFaces.regular(16) //used with "$" superscripts
        static let h2rVariable = UIScreen.mainScreen().bounds.width == 320 ? h3r : h2r

        static let s1r =  FontFaces.regular(17)
        static let s2r =  FontFaces.regular(14)
        static let s3r =  FontFaces.regular(12)

        
        static let h1b =  FontFaces.bold(25)
        static let h2b =  FontFaces.bold(20)
        
        static let h1bVariable = UIScreen.mainScreen().bounds.width == 320 ? h2b : h1b
        
        static let s1b =  FontFaces.bold(17)
        static let s2b =  FontFaces.bold(14)
        static let s3b =  FontFaces.bold(12)
        
    }
    
    struct Sizes {
        static let tabbarHeight = 58
        static let bigRoundedButtonHeight = 36
        static let bigRoundedButtonSideMargin = UIScreen.mainScreen().bounds.width == 320 ? 23 : 50
        static let hugeButtonHeight = UIScreen.mainScreen().bounds.width == 320 ? 54 : 70
        static let formTextFieldHeight = 71
        static let formLabelHeight = 17
        static let searchTextFieldHeight = 46
        static let blurRadius = 3
        static let avatarSize = CGSizeMake(68,68)
        static let spotDetailViewHeight = 140
        static let spotDetailViewTopPortionHeight = 70
        static let spotDetailViewBottomPortionHeight = spotDetailViewHeight - spotDetailViewTopPortionHeight
        static let modalViewHeaderHeight : CGFloat = 90
        static let statusBarHeight = Int(UIApplication.sharedApplication().statusBarFrame.size.height)

    }
    
}
