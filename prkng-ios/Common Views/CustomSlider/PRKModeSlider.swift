//
//  TicksSlider.swift
//  SliderWithTicks
//
//  Created by Alexander Batalov on 2/27/15.
//  Copyright (c) 2015 Alexander Batalov. All rights reserved.
//

import UIKit

class PRKModeSlider: UIControl {
    
    var titles = [String]() {
        didSet {
            thumbLayer.setupWithSlider(self)
        }
    }

    var minimumValue: Double = 0.0 {
        didSet {
            updateFrames()
        }
    }
    var maximumValue: Double = 10.0 {
        didSet {
            updateFrames()
        }
    }
    var value: Double = 7.0 {
        didSet {
            updateFrames()
        }
    }
    var valueForAnimation: Double?
    var previousLocation = CGPoint()
    
    let trackLayer = PRKModeSliderTrackLayer()
    var trackHeight:CGFloat = 0.0 {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    var trackColor: CGColor = UIColor.blackColor().CGColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    let thumbLayer = PRKModeSliderThumbLayer()
    var thumbColor: CGColor = UIColor.blackColor().CGColor {
        didSet {
            thumbLayer.setNeedsLayout()
        }
    }
    var thumbMargin:CGFloat = 0.0 {
        didSet {
            thumbLayer.setNeedsLayout()
        }
    }
    
    var thumbWidth: CGFloat = 40.0 {
        didSet {
            thumbLayer.setNeedsLayout()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateFrames()
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.prkModeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        thumbLayer.prkModeSlider = self
        thumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(thumbLayer)
        
        updateFrames()
    }
    
    func setValue(newValue: Double, animationDuration: Double) {
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 7, initialSpringVelocity: 15, options: nil, animations: { () -> Void in
            let thumbLeft = CGFloat(newValue) * self.thumbWidth
            self.thumbLayer.frame = CGRect(x: thumbLeft, y: 0, width: self.thumbWidth, height: self.bounds.height)
            self.thumbLayer.setNeedsLayout()
            self.thumbLayer.layoutIfNeeded()
            }) { (Bool) -> Void in
                self.value = newValue
                self.sendActionsForControlEvents(.ValueChanged)
        }

    }
    
    func updateFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.trackHeight)
        trackLayer.setNeedsDisplay()
        
        let thumbLeft = CGFloat(self.value) * self.thumbWidth
        self.thumbLayer.frame = CGRect(x: thumbLeft, y: 0 , width: self.thumbWidth, height: self.bounds.height)
        self.thumbLayer.setNeedsLayout()
        
        CATransaction.commit()
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        previousLocation = touch.locationInView(self)
        
        if thumbLayer.frame.contains(previousLocation) {
            thumbLayer.highlighted = true
        }
        
        return thumbLayer.highlighted
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let location = touch.locationInView(self)
        
        // Track how much user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbLayer.frame.width)
        
        previousLocation = location
        
        // update value
        if thumbLayer.highlighted {
            value += deltaValue
            value = clipValue(value)
        }
        
        return thumbLayer.highlighted
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        thumbLayer.highlighted = false
        self.setValue(round(self.value), animationDuration: 0.4)
    }
    
    func clipValue(value: Double) -> Double {
        return min(max(value, minimumValue ), maximumValue)
    }
    
}







