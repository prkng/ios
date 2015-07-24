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
        hugeButton.shadowAniEnabled = false
        
        hugeButton.layer.shadowColor = UIColor.blackColor().CGColor
        hugeButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        hugeButton.layer.shadowOpacity = 0.1
        hugeButton.layer.shadowRadius = 0.5
        
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
    
    static func exclamationButton () -> UIButton {
        let button = UIButton ()
        button.setImage(UIImage(named: "btn_report"), forState: .Normal)
        return button
    }

    static func infoButton () -> UIButton {
        let button = UIButton ()
        button.setImage(UIImage(named: "btn_info"), forState: .Normal)
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
    
    // MARK: Icons
    
    static func authorizedIcon(color: UIColor) -> UIImageView {
        let image = UIImage(named: "icon_authorized")
        let imageView = UIImageView(image: image)
        imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView.tintColor = color
        return imageView
    }
    
    static func forbiddenIcon(color: UIColor) -> UIImageView {
        let image = UIImage(named: "icon_forbidden")
        let imageView = UIImageView(image: image)
        imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView.tintColor = color
        return imageView
    }
    
    static func timeMaxIcon(minutes: Int, addMaxLabel: Bool, color: UIColor) -> UIImageView {
        
        var imageView = UIImageView()
        var timeLimitLabel = UILabel()
        var maxLabel = UILabel()
        var image = UIImage(named: "icon_timemax")

        if minutes > 0 {
            switch (minutes) {
            case 15:
                image = UIImage(named: "icon_timemax_15")
                break
            case 30:
                image = UIImage(named: "icon_timemax_30")
                break
            case 60:
                image = UIImage(named: "icon_timemax_60")
                break
            case 90:
                image = UIImage(named: "icon_timemax_90")
                break
            case 120:
                image = UIImage(named: "icon_timemax_120")
                break
            default:
                timeLimitLabel.text = String(minutes)
                timeLimitLabel.hidden = false
            }
        } else {
            timeLimitLabel.hidden = true
        }
        
        imageView.image = image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView.tintColor = color
        
        timeLimitLabel.font = Styles.FontFaces.regular(17)
        timeLimitLabel.textAlignment = NSTextAlignment.Center
        timeLimitLabel.textColor = color
        timeLimitLabel.adjustsFontSizeToFitWidth = true
        timeLimitLabel.numberOfLines = 1
        timeLimitLabel.sizeToFit()
        imageView.addSubview(timeLimitLabel)

        maxLabel.text = "max".localizedString.uppercaseString
        maxLabel.font = Styles.FontFaces.regular(12)
        maxLabel.textAlignment = NSTextAlignment.Center
        maxLabel.textColor = Styles.Colors.white
        maxLabel.adjustsFontSizeToFitWidth = true
        maxLabel.numberOfLines = 1
        maxLabel.sizeToFit()
        
        timeLimitLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(imageView)
            make.centerY.equalTo(imageView).with.offset(-1) //plus moves down, minus moves up
            make.size.equalTo(CGSize(width: 15, height: 17))
        }
        
        if addMaxLabel {
            imageView.addSubview(maxLabel)
            
            maxLabel.snp_makeConstraints({ (make) -> () in
                make.centerX.equalTo(imageView)
                make.centerY.equalTo(imageView).with.offset(25)
            })
            
        }

        return imageView
    }

    static func paidIcon(hourlyRateString: String, color: UIColor) -> UIImageView {
        
        var imageView = UIImageView()
        var maxLabel = UILabel()
        var image = UIImage(named: "icon_paid")
        
        imageView.image = image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView.tintColor = color
        
        maxLabel.text = hourlyRateString + "/H"
        maxLabel.font = Styles.FontFaces.regular(12)
        maxLabel.textAlignment = NSTextAlignment.Center
        maxLabel.textColor = color
        maxLabel.adjustsFontSizeToFitWidth = true
        maxLabel.numberOfLines = 1
        maxLabel.sizeToFit()
        
        imageView.addSubview(maxLabel)
        
        maxLabel.snp_makeConstraints({ (make) -> () in
            make.centerX.equalTo(imageView)
            make.top.equalTo(imageView.snp_bottom).with.offset(2)
        })
        
        return imageView
    }

    
    
}
