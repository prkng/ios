//
//  UITableView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-15.
//  Copyright © 2016 PRKNG. All rights reserved.
//

extension UITableView {

    func reloadDataAnimated(_ duration: TimeInterval = 0.35,
        options: UIViewAnimationOptions = UIViewAnimationOptions.transitionCrossDissolve,
        completion: ((Bool) -> Void)? = nil) {

        UIView.transition(with: self,
            duration: duration,
            options: options,
            animations: { () -> Void in
                self.reloadData()
            },
            completion: completion)

    }
    
}
