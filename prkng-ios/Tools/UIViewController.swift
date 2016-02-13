//
//  UIViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentViewControllerFromRight(duration: CFTimeInterval = 0.2, viewController: UIViewController, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.presentViewController(viewController, animated: false) { () -> Void in
            completion?()
        }

    }

    func dismissViewControllerFromLeft(duration: CFTimeInterval = 0.2, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.dismissViewControllerAnimated(false, completion: completion)
        
    }

    func presentViewControllerWithFade(duration: CFTimeInterval = 0.4, viewController: UIViewController, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.presentViewController(viewController, animated: false) { () -> Void in
            completion?()
        }
        
    }
    
    func dismissViewControllerWithFade(duration: CFTimeInterval = 0.4, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.window?.layer.addAnimation(transition, forKey: nil)
        self.dismissViewControllerAnimated(false, completion: completion)
        
    }
    
    func presentAsModalWithTransparency(viewController: UIViewController, completion: (() -> Void)?) {
        viewController.willMoveToParentViewController(self)
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.snp_remakeConstraints(closure: { (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        transition.removedOnCompletion = true
        viewController.view.layer.addAnimation(transition, forKey: nil)

        completion?()
    }
    
    func dismissAsModalWithTransparency(completion: (() -> Void)?) {
        
        self.view.layer.removeAllAnimations()
        let height = UIScreen.mainScreen().bounds.height
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.snp_remakeConstraints(closure: { (make) -> () in
                make.top.equalTo(self.parentViewController!.view.snp_bottom)
                make.height.equalTo(height)
                make.left.equalTo(self.parentViewController!.view)
                make.right.equalTo(self.parentViewController!.view)
            })
            self.view.layoutIfNeeded()
            }) { (completed) -> Void in
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
                self.willMoveToParentViewController(nil)
                completion?()

        }
        
    }


}