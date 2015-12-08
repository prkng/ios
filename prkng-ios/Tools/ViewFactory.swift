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

    static func shareButton() -> UIButton {
        let button = UIButton()
        let buttonImage = UIImage(named: "btn_share")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setImage(buttonImage, forState: .Normal)
        button.tintColor = Styles.Colors.stone.colorWithAlphaComponent(0.5)
        return button
    }
    
    static func scheduleButton() -> UIButton {
        let scheduleButton : UIButton =  UIButton()
        scheduleButton.setImage(UIImage(named: "btn_schedule_active"), forState: UIControlState.Normal)
        scheduleButton.setImage(UIImage(named: "btn_schedule"), forState: UIControlState.Highlighted)
        return scheduleButton
    }
    
    static func mapReturnButton() -> UIButton {
        let scheduleButton : UIButton =  UIButton()
        scheduleButton.setImage(UIImage(named: "btn_map_return"), forState: UIControlState.Normal)
        return scheduleButton
    }
    
    static func bigRedRoundedButton() -> UIButton {
        let button = redRoundedButtonWithHeight(CGFloat(Styles.Sizes.bigRoundedButtonHeight), font: Styles.FontFaces.regular(12), text: "")
        return button
    }
    
    static func redRoundedButton() -> UIButton {
        
        return redRoundedButtonWithHeight(28, font: Styles.FontFaces.light(12), text: "")
    }

    static func redRoundedButtonWithHeight(height: CGFloat, font: UIFont, text: String) -> UIButton {
        
        let button = roundedButtonWithHeight(height, backgroundColor: Styles.Colors.red2, font: font, text: text, textColor: Styles.Colors.beige1, highlightedTextColor: Styles.Colors.beige2)
        return button
    }

    static func roundedButtonWithHeight(height: CGFloat, backgroundColor: UIColor, font: UIFont, text: String, textColor: UIColor, highlightedTextColor: UIColor) -> UIButton {
        
        let button = UIButton()
        button.titleLabel?.font = font
        button.setTitle(text, forState: UIControlState.Normal)
        button.setTitleColor(textColor, forState: UIControlState.Normal)
        button.setTitleColor(highlightedTextColor, forState: UIControlState.Highlighted)
        button.layer.cornerRadius = height/2
        button.backgroundColor = backgroundColor
        button.clipsToBounds = true
        return button
    }


    static func hugeButton() -> MKButton {
        
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
    
    static func hugeCreamButton() -> MKButton {
        
        let hugeCreamButton = hugeButton()
        hugeCreamButton.backgroundColor = Styles.Colors.cream2
        hugeCreamButton.backgroundLayerColor = Styles.Colors.cream2
        
        return hugeCreamButton
    }
    
    static func dialogChoiceButton() -> MKButton {
        
        let button = MKButton()
        button.titleLabel?.font = Styles.FontFaces.regular(15)
        button.setTitleColor(Styles.Colors.petrol2, forState: UIControlState.Normal)
        button.backgroundColor = Styles.Colors.cream2
        button.backgroundLayerColor = Styles.Colors.cream2
        button.rippleLayerColor = Styles.Colors.cream1
        button.rippleAniDuration = 0.35
        button.cornerRadius = 0
        button.shadowAniEnabled = false
        
        button.layer.shadowColor = UIColor.blackColor().CGColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 0.5
        
        return button
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
    
    static func smallAccessoryPlusButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_accessory_plus"), forState: UIControlState.Normal)
        return button
    }

    static func smallAccessoryCloseButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_accessory_close"), forState: UIControlState.Normal)
        return button
    }

    static func transparentRoundedButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = Styles.FontFaces.light(12)
        button.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        button.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Highlighted)
        button.layer.cornerRadius = 13
        button.layer.borderColor = Styles.Colors.beige1.CGColor
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor.clearColor()
        button.clipsToBounds = true
        return button
    }
    
    static func exclamationButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_report"), forState: .Normal)
        return button
    }

    static func infoButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_info_outline"), forState: .Normal)
        return button
    }
    
    static func directionsButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named:"btn_directions"), forState: .Normal)
        return button
    }

    static func bigTransparentButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = Styles.Fonts.h1
        button.setTitleColor(Styles.Colors.cream1, forState: .Normal)
        button.setTitleColor(Styles.Colors.anthracite1, forState: .Highlighted)
        return button
    }
    
    static func outlineBackButton() -> UIButton {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "btn_back_outline"), forState: .Normal)
        return button
    }
    
    static func roundedRedBackButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = Styles.Colors.red2
        button.layer.cornerRadius = 13
        button.clipsToBounds = true
        button.titleLabel?.font = Styles.FontFaces.light(12)
        button.setTitleColor(Styles.Colors.cream1, forState: .Normal)
        button.setTitleColor(Styles.Colors.anthracite1, forState: .Highlighted)
        button.setTitle("<  " + "back".localizedString.uppercaseString, forState: .Normal)
        return button
    }
    
    static func rectangularBackButton() -> UIButton {
        
        let hugeButton = MKButton()
        hugeButton.titleLabel?.font = Styles.Fonts.h1
        hugeButton.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        hugeButton.backgroundColor = Styles.Colors.red2
        hugeButton.backgroundLayerColor = Styles.Colors.red2
        hugeButton.rippleLayerColor = Styles.Colors.red1
        hugeButton.rippleAniDuration = 0.35
        hugeButton.cornerRadius = 0
        hugeButton.shadowAniEnabled = false
        
        hugeButton.layer.shadowColor = UIColor.blackColor().CGColor
        hugeButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        hugeButton.layer.shadowOpacity = 0.1
        hugeButton.layer.shadowRadius = 0.5
        
        return hugeButton
        
    }
    
    // MARK: Segmented Controls
    
    static func nowOrHistorySwitch() -> DVSwitch {
        let segmentedControl = DVSwitch(stringsArray: ["now".localizedString.uppercaseString, "history".localizedString.uppercaseString])
        segmentedControl.backgroundView.layer.borderWidth = 1
        segmentedControl.backgroundView.layer.borderColor = Styles.Colors.stone.colorWithAlphaComponent(0.5).CGColor
        segmentedControl.sliderColor = Styles.Colors.red2
        segmentedControl.backgroundColor = UIColor.clearColor()
        segmentedControl.labelTextColorInsideSlider = Styles.Colors.white
        segmentedControl.labelTextColorOutsideSlider = Styles.Colors.stone
        segmentedControl.font = Styles.FontFaces.regular(9)
        segmentedControl.cornerRadius = 12
        return segmentedControl
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
        label.font = Styles.Fonts.h3
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

    static func snowflakeIcon(color: UIColor? = nil) -> UIImageView {
        let image = UIImage(named: "icon_snowflake")
        let imageView = UIImageView(image: image)
        if color != nil {
            imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            imageView.tintColor = color
        }
        return imageView
    }

    static func timeMaxIcon(minutes: Int, addMaxLabel: Bool, color: UIColor, secondLineString: String? = nil) -> UIImageView {
        
        let imageView = UIImageView()
        let timeLimitLabel = UILabel()
        let maxLabel = UILabel()
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
                image = UIImage(named: "icon_timemax_2")
                break
            case 180:
                image = UIImage(named: "icon_timemax_3")
                break
            case 240:
                image = UIImage(named: "icon_timemax_4")
                break
            case 300:
                image = UIImage(named: "icon_timemax_5")
                break
            case 360:
                image = UIImage(named: "icon_timemax_6")
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

        if secondLineString != nil {
            maxLabel.text = "max".localizedString.uppercaseString + "\n" + secondLineString!
            maxLabel.numberOfLines = 2
        } else {
            maxLabel.text = "max".localizedString.uppercaseString
            maxLabel.numberOfLines = 1
        }
        maxLabel.font = Styles.FontFaces.regular(12)
        maxLabel.textAlignment = NSTextAlignment.Center
        maxLabel.textColor = color
        maxLabel.adjustsFontSizeToFitWidth = true
        maxLabel.sizeToFit()
        
        timeLimitLabel.snp_makeConstraints { (make) ->() in
            make.centerX.equalTo(imageView)
            make.centerY.equalTo(imageView).offset(-1) //plus moves down, minus moves up
            make.size.equalTo(CGSize(width: 15, height: 17))
        }
        
        if addMaxLabel {
            imageView.addSubview(maxLabel)
            
            maxLabel.snp_makeConstraints(closure: { (make) ->() in
                make.centerX.equalTo(imageView)
                make.centerY.equalTo(imageView).offset(maxLabel.numberOfLines == 1 ? 25 : 30)
            })
            
        }

        return imageView
    }

    static func paidIcon(hourlyRateString: String, color: UIColor) -> UIImageView {
        
        let imageView = UIImageView()
        let maxLabel = UILabel()
        let image = UIImage(named: "icon_paid")
        
        imageView.image = image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView.tintColor = color
        
        maxLabel.text = hourlyRateString == "" ? "" : hourlyRateString + "/H"
        maxLabel.font = Styles.FontFaces.regular(12)
        maxLabel.textAlignment = NSTextAlignment.Center
        maxLabel.textColor = color
        maxLabel.adjustsFontSizeToFitWidth = true
        maxLabel.numberOfLines = 1
        maxLabel.sizeToFit()
        
        imageView.addSubview(maxLabel)
        
        maxLabel.snp_makeConstraints(closure: { (make) ->() in
            make.centerX.equalTo(imageView)
            make.top.equalTo(imageView.snp_bottom).offset(2)
        })
        
        return imageView
    }

    
    
}
