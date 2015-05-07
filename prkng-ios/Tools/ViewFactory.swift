//
//  ViewFactory.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ViewFactory {

    class func scheduleButton () -> UIButton {
        var scheduleButton : UIButton =  UIButton()
        scheduleButton.setImage(UIImage(named: "btn_schedule"), forState: UIControlState.Normal)
        scheduleButton.setImage(UIImage(named: "btn_schedule_active"), forState: UIControlState.Highlighted)
        return scheduleButton
    }
    

    class func hugeButton () -> UIButton {
        
        let hugeButton = UIButton()
        hugeButton.titleLabel?.font = Styles.FontFaces.light(31)
        hugeButton.setTitleColor(Styles.Colors.red2, forState: UIControlState.Normal)
        hugeButton.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Highlighted)
        hugeButton.backgroundColor = Styles.Colors.cream1
        
        return hugeButton
    }
    
}
