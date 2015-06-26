//
//  CALayer.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-19.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

extension CALayer {

    func addScaleAnimation() {
        var animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        animation.values = [0,1]
        
        animation.duration = 0.6
        var timingFunctions: Array<CAMediaTimingFunction> = []
        
        for i in 0...animation.values.count {
            timingFunctions.append(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        
        animation.timingFunctions = timingFunctions
        animation.removedOnCompletion = true
        
        self.addAnimation(animation, forKey: "scale")
        
        //        NSLog("Added a scale animation")
    }
    
    func wigglewigglewiggle() {
        
        if let animation = self.animationForKey("wigglewigglewiggle") {
            self.removeAnimationForKey("wigglewigglewiggle")
        }
        
        var animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = M_PI / 75.0
        animation.toValue = -M_PI / 75.0
        animation.duration = 0.2
        animation.autoreverses = true
        animation.repeatCount = MAXFLOAT
        self.addAnimation(animation, forKey: "wigglewigglewiggle")
        
    }

}
