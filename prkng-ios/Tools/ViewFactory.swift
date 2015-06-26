//
//  ViewFactory.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct ViewFactory {
    
    
    // MARK: Buttons

    static func scheduleButton () -> UIButton {
        var scheduleButton : UIButton =  UIButton()
        scheduleButton.setImage(UIImage(named: "btn_schedule_active"), forState: UIControlState.Normal)
        scheduleButton.setImage(UIImage(named: "btn_schedule"), forState: UIControlState.Highlighted)
        return scheduleButton
    }
    
    static func mapReturnButton () -> UIButton {
        var scheduleButton : UIButton =  UIButton()
        scheduleButton.setImage(UIImage(named: "btn_map_return"), forState: UIControlState.Normal)
        return scheduleButton
    }
    
    static func redRoundedButton () -> UIButton {
        
        let button = UIButton ()
        button.titleLabel?.font = Styles.FontFaces.light(12)
        button.setTitleColor(Styles.Colors.beige1, forState: UIControlState.Normal)
        button.setTitleColor(Styles.Colors.beige2, forState: UIControlState.Highlighted)
        button.layer.cornerRadius = 14
        button.backgroundColor = Styles.Colors.red2
        button.clipsToBounds = true
        return button
    }
    

    static func hugeButton () -> MKButton {
        
        let hugeButton = MKButton()
        hugeButton.titleLabel?.font = Styles.Fonts.h1
        hugeButton.setTitleColor(Styles.Colors.red2, forState: UIControlState.Normal)
        hugeButton.backgroundColor = Styles.Colors.stone
        hugeButton.backgroundLayerColor = Styles.Colors.stone
        hugeButton.rippleLayerColor = Styles.Colors.cream1
        hugeButton.rippleAniDuration = 0.35
        hugeButton.cornerRadius = 0
        
        
        return hugeButton
    }
    
    static func hugeCreamButton () -> MKButton {
        
        let hugeCreamButton = hugeButton()
        hugeCreamButton.backgroundColor = Styles.Colors.cream2
        hugeCreamButton.backgroundLayerColor = Styles.Colors.cream2
        
        return hugeCreamButton
    }
    
    static func checkInButton() -> MKButton {
     
        let hugeButton = ViewFactory.hugeButton()
        hugeButton.backgroundColor = Styles.Colors.red2
        hugeButton.backgroundLayerColor = Styles.Colors.red2
        hugeButton.rippleLayerColor = Styles.Colors.red1
        return hugeButton
    }
    
    static func openScheduleButton() -> MKButton {
        
        let hugeButton = ViewFactory.hugeButton()
        return hugeButton
    }
    
    static func transparentRoundedButton () -> UIButton {
        let button = UIButton ()
        button.titleLabel?.font = Styles.FontFaces.light(12)
        button.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        button.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Highlighted)
        button.layer.cornerRadius = 14
        button.layer.borderColor = Styles.Colors.beige1.CGColor
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.clearColor()
        button.clipsToBounds = true
        return button
    }
    
    
    static func reportButton () -> UIButton {
        let button = UIButton ()
        button.setImage(UIImage(named: "btn_report"), forState: .Normal)
        return button
    }
    
    static func bigTransparentButton () -> UIButton {
        let button = UIButton ()
        button.titleLabel?.font = Styles.Fonts.h1
        button.setTitleColor(Styles.Colors.cream1, forState: .Normal)
        button.setTitleColor(Styles.Colors.anthracite1, forState: .Highlighted)
        return button
    }
    
    static func redBackButton() -> UIButton {
        let button = UIButton ()
        button.backgroundColor = Styles.Colors.red2
        button.layer.cornerRadius = 13
        button.clipsToBounds = true
        button.titleLabel?.font = Styles.FontFaces.light(12)
        button.setTitleColor(Styles.Colors.cream1, forState: .Normal)
        button.setTitleColor(Styles.Colors.anthracite1, forState: .Highlighted)
        button.setTitle("<  " + "back".localizedString.uppercaseString, forState: .Normal)
        return button
    }
    
    // MARK: Labels
    
    static func formLabel() -> UILabel {
        let label = UILabel()
        label.font = Styles.FontFaces.light(12)
        label.textColor = Styles.Colors.stone
        label.textAlignment = NSTextAlignment.Center
        return label
    }
    
    static func bigMessageLabel() -> UILabel {
        let label = UILabel()
        label.font = Styles.Fonts.h1
        label.textColor = Styles.Colors.cream1
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        return label
    }
    
    // MARK: TextFields
    
    static func formTextField() -> UITextField {
        let textField = UITextField()
        textField.font = Styles.Fonts.h3
        textField.backgroundColor = UIColor.clearColor()
        textField.textColor = Styles.Colors.anthracite1
        textField.textAlignment = NSTextAlignment.Center
        textField.autocorrectionType = UITextAutocorrectionType.No
        return textField
    }
    
    
}
