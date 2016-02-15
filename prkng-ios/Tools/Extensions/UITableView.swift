//
//  UITableView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-15.
//  Copyright © 2016 PRKNG. All rights reserved.
//

extension UITableView {

    func reloadDataAnimated(duration: NSTimeInterval = 0.35,
        options: UIViewAnimationOptions = UIViewAnimationOptions.TransitionCrossDissolve,
        completion: ((Bool) -> Void)? = nil) {

        UIView.transitionWithView(self,
            duration: duration,
            options: options,
            animations: { () -> Void in
                self.reloadData()
            },
            completion: completion)

    }
    
}