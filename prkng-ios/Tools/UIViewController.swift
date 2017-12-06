//
//  UIViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentViewControllerFromRight(_ duration: CFTimeInterval = 0.2, viewController: UIViewController, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add(transition, forKey: nil)
        self.present(viewController, animated: false) { () -> Void in
            completion?()
        }

    }

    func dismissViewControllerFromLeft(_ duration: CFTimeInterval = 0.2, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: completion)
        
    }

    func presentViewControllerWithFade(_ duration: CFTimeInterval = 0.4, viewController: UIViewController, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: nil)
        self.present(viewController, animated: false) { () -> Void in
            completion?()
        }
        
    }
    
    func dismissViewControllerWithFade(_ duration: CFTimeInterval = 0.4, completion: (() -> Void)?) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: completion)
        
    }
    
    func presentAsModalWithTransparency(_ viewController: UIViewController, completion: (() -> Void)?) {
        viewController.willMove(toParentViewController: self)
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
        transition.isRemovedOnCompletion = true
        viewController.view.layer.add(transition, forKey: nil)

        completion?()
    }
    
    func dismissAsModalWithTransparency(_ completion: (() -> Void)?) {
        
        self.view.layer.removeAllAnimations()
        let height = UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.view.snp_remakeConstraints(closure: { (make) -> () in
                make.top.equalTo(self.parent!.view.snp_bottom)
                make.height.equalTo(height)
                make.left.equalTo(self.parent!.view)
                make.right.equalTo(self.parent!.view)
            })
            self.view.layoutIfNeeded()
            }, completion: { (completed) -> Void in
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
                self.willMove(toParentViewController: nil)
                completion?()

        }) 
        
    }


}
