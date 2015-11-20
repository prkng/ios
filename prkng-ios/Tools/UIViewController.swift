//
//  UIViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentViewControllerFromRight(viewController: UIViewController, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.presentViewController(viewController, animated: false) { () -> Void in
            if completion != nil {
                completion!()
            }
        }

    }

    func dismissViewControllerFromLeft(completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.dismissViewControllerAnimated(false, completion: completion)
        
    }

    func presentViewControllerWithFade(viewController: UIViewController, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.presentViewController(viewController, animated: false) { () -> Void in
            if completion != nil {
                completion!()
            }
        }
        
    }
    
    func dismissViewControllerWithFade(completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.dismissViewControllerAnimated(false, completion: completion)
        
    }

}