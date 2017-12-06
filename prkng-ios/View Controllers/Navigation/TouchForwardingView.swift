//
//  TouchForwardingView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TouchForwardingView: UIView {


    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
//        if !(hitView is UITextField) {
//            UIApplication.sharedApplication().keyWindow?.endEditing(false)
//        }
        
        if(hitView == self || hitView is UILabel || hitView is UIImageView) {
            return nil;
        }
        
        
        return hitView;
    }
    

}
