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
        scheduleButton.setImage(UIImage(named: "btn_schedule"), forState: UIControlState.Normal)
        scheduleButton.setImage(UIImage(named: "btn_schedule_active"), forState: UIControlState.Highlighted)
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
    

    static func hugeButton () -> UIButton {
        
        let hugeButton = UIButton()
        hugeButton.titleLabel?.font = Styles.FontFaces.light(31)
        hugeButton.setTitleColor(Styles.Colors.red2, forState: UIControlState.Normal)
        hugeButton.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Highlighted)
        hugeButton.backgroundColor = Styles.Colors.cream1
        
        return hugeButton
    }
    
    static func bigButton () -> UIButton {
        
        let hugeButton = UIButton()
        hugeButton.titleLabel?.font = Styles.FontFaces.light(31)
        hugeButton.setTitleColor(Styles.Colors.red2, forState: UIControlState.Normal)
        hugeButton.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Highlighted)
        hugeButton.backgroundColor = Styles.Colors.stone
        
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
        label.font = Styles.FontFaces.light(31)
        label.textColor = Styles.Colors.cream1
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        return label
    }
    
    // MARK: TextFields
    
    static func formTextField() -> UITextField {
        let textField = UITextField()
        textField.font = Styles.Fonts.h2
        textField.backgroundColor = UIColor.clearColor()
        textField.textColor = Styles.Colors.anthracite1
        textField.textAlignment = NSTextAlignment.Center
        textField.autocorrectionType = UITextAutocorrectionType.No
        return textField
    }
    
    
}
