//
//  PRKVerticalGestureRecognizer.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-06.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

/*
NOTE: In order for this to work, a reference to it has to be kept.
Otherwise, the gesture recogizer's target, which is the instance of this class, 
will have nothing to call and an error about the 
"handleVerticalGestureRecongizerSwipe:" selector will be produced.
*/
class PRKVerticalGestureRecognizer: NSObject {
   
    fileprivate var panRec: UIPanGestureRecognizer
    fileprivate var appliedToView: UIView
    fileprivate var superView: UIView
    fileprivate var beginTap: CGPoint?
    fileprivate var lastPanTap: CGPoint?
    fileprivate var panDirectionIsUp: Bool

    fileprivate var _delegate: PRKVerticalGestureRecognizerDelegate?
    var delegate: PRKVerticalGestureRecognizerDelegate? {
        get {
            return _delegate
        }
        set(newDelegate) {
            _delegate = newDelegate
            panRec.delegate = _delegate
        }
    }
    
    override init() {
        
        panDirectionIsUp = false
        panRec = UIPanGestureRecognizer()
        appliedToView = UIView()
        superView = UIView()
        super.init()
        
    }
    
    convenience init(view: UIView, superViewOfView: UIView) {
        
        self.init()
        appliedToView = view
        superView = superViewOfView
        panRec = UIPanGestureRecognizer(target: self, action: #selector(PRKVerticalGestureRecognizer.handleVerticalGestureRecongizerSwipe(_:)))
        appliedToView.addGestureRecognizer(panRec)

    }

    func handleVerticalGestureRecongizerSwipe(_ panRec: UIPanGestureRecognizer) {
        
        let tap = panRec.location(in: self.superView)
        
        if panRec.state == UIGestureRecognizerState.began {
            
            if self.delegate != nil && !self.delegate!.shouldIgnoreSwipe(tap) {
                beginTap = tap
                self.delegate?.swipeDidBegin()
            } else {
                beginTap = nil
            }
            
        } else if panRec.state == UIGestureRecognizerState.changed {
            
            if beginTap != nil {
                let distance = tap.yDistanceToPointWithDirection(beginTap!)
                self.delegate?.swipeInProgress(distance)
                
                if lastPanTap != nil {
                    let distanceSinceLastTap = tap.yDistanceToPointWithDirection(lastPanTap!)
                    if distance != 0 {
                        lastPanTap = tap
                    }
                    panDirectionIsUp = distanceSinceLastTap > 0
                } else {
                    lastPanTap = tap
                    panDirectionIsUp = distance > 0
                }
            }
            
        } else if panRec.state == UIGestureRecognizerState.ended {
            
            if beginTap != nil {
                
                if panDirectionIsUp {
                    self.delegate?.swipeDidEndUp()
                    
                } else {
                    self.delegate?.swipeDidEndDown()
                }
            }
            
        } else {
            beginTap = nil
        }
        
    }

}

protocol PRKVerticalGestureRecognizerDelegate: UIGestureRecognizerDelegate {
    
    func shouldIgnoreSwipe(_ beginTap: CGPoint) -> Bool
    func swipeDidBegin()
    func swipeInProgress(_ yDistanceFromBeginTap: CGFloat)
    func swipeDidEndUp()
    func swipeDidEndDown()
}
