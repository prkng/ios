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
    

}
