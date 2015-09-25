//
//  PRKModeSlider.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 12/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//


//TODO: THIS NEEDS TO BE CLEANED UP!! We should only use PRKModeSlider and add a tap recognizer for tapping. Get rid of everything else.
import UIKit

class PRKModeSlider: UIControl {
    
    let trackTextColor = Styles.Colors.petrol2
    let thumbTextColor = Styles.Colors.cream1
    let thumbBackgroundColor = Styles.Colors.red2
    let font = Styles.FontFaces.regular(14)
    
    private(set) var titles = [String]()
    
    private var backgroundView = UIView()
    private var labels = [UILabel]()
    private var thumbView = PRKModeSliderThumbView()

    var selectedIndex: Int {
        return Int(self.value)
    }

    let height: CGFloat = 60
    var thumbWidth: CGFloat {
        return UIScreen.mainScreen().bounds.width/CGFloat(self.titles.count)
    }
    
    private let minimumValue: Double = 0
    private let maximumValue: Double = 2
    private var value: Double = 1 {
        didSet {
            //do this to update the frame after an animation, also good for
            updateThumb()
        }
    }
    private var previousLocation = CGPoint()

    init(titles: [String]) {
        
        super.init(frame: CGRectZero)
        
        if Settings.iOS8OrLater() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            backgroundView = UIVisualEffectView(effect: blurEffect)
        } else {
            backgroundView.backgroundColor = Styles.Colors.cream1
        }
        backgroundView.userInteractionEnabled = false
        self.addSubview(backgroundView)

        self.titles = titles
        
        //add text layers
        for i in 0..<titles.count {
            let title = titles[i]
            let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: trackTextColor])
            let labelRect = CGRect(x: (CGFloat(i)*thumbWidth), y: 0, width: thumbWidth, height: bounds.height)
            
            let label = UILabel(frame: labelRect)
            label.attributedText = attributedTitle
            label.textAlignment = NSTextAlignment.Center
            
            label.userInteractionEnabled = false
            self.addSubview(label)
            labels.append(label)
        }

        thumbView.prkModeSlider = self
        thumbView.userInteractionEnabled = false
        self.addSubview(thumbView)
        
        let tapRec = UITapGestureRecognizer(target: self, action: "sliderSelectionTapped:")
        self.addGestureRecognizer(tapRec)
        
        setValue(value, animated: true)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        backgroundView.snp_remakeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        for i in 0..<titles.count {
            let label = labels[i]
            label.snp_remakeConstraints({ (make) -> () in
                make.left.equalTo(self).with.offset(CGFloat(i)*self.thumbWidth)
                make.top.equalTo(self)
                make.height.equalTo(self.height)
                make.width.equalTo(self.thumbWidth)
            })
        }

    }
    
    //MARK: Helper functions
    
    func setValue(newValue: Double, animated: Bool) {
        let animationDuration = animated ? 0.4 : 0
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 7, initialSpringVelocity: 15, options: [], animations: { () -> Void in
            let thumbLeft = CGFloat(newValue) * self.thumbWidth
            self.thumbView.frame = CGRect(x: thumbLeft, y: 0, width: self.thumbWidth, height: self.bounds.height)
            self.thumbView.setNeedsLayout()
            self.thumbView.layoutIfNeeded()
            }) { (Bool) -> Void in
                let valueChanged = self.selectedIndex != Int(newValue)
                self.value = newValue
                if valueChanged {
                    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                }
                
        }
        
    }
    
    func updateThumb() {
        let thumbLeft = CGFloat(self.value) * self.thumbWidth
        self.thumbView.frame = CGRect(x: thumbLeft, y: 0 , width: self.thumbWidth, height: self.bounds.height)
        self.thumbView.setNeedsLayout()
    }
    
    //MARK: UIControl functions
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        
        if thumbView.frame.contains(previousLocation) {
            thumbView.touching = true
        }
        
        return thumbView.touching
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // Track how much user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbView.frame.width)
        
        previousLocation = location
        
        // update value
        if thumbView.touching {
            value += deltaValue
            value = clipValue(value)
        }
        
        return thumbView.touching
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        thumbView.touching = false
        self.setValue(round(self.value), animated: true)
    }
    
    func clipValue(value: Double) -> Double {
        return min(max(value, minimumValue ), maximumValue)
    }
    
    //MARK: UIGestureRecognizer function
    func sliderSelectionTapped(tapRec: UITapGestureRecognizer) {
        if tapRec.state == UIGestureRecognizerState.Ended {
            let tap = tapRec.locationInView(self)
            let newValue = (tap.x / self.bounds.width) * CGFloat(self.titles.count)
            setValue(Double(Int(newValue)), animated: true)
        }
    }

}

class PRKModeSliderThumbView: UIView {
    
    private weak var prkModeSlider : PRKModeSlider? {
        didSet {
            
            if let slider = prkModeSlider {
                
                self.backgroundColor = slider.thumbBackgroundColor
                
                //layers for all the text
                for i in 0..<slider.titles.count {
                    let title = slider.titles[i]
                    let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: slider.font, NSForegroundColorAttributeName: slider.thumbTextColor])
                    let labelRect = CGRect(x: (CGFloat(i)*slider.thumbWidth), y: 0, width: slider.thumbWidth, height: slider.bounds.height)
                    
                    let label = UILabel(frame: labelRect)
                    label.attributedText = attributedTitle
                    label.textAlignment = NSTextAlignment.Center
                    self.addSubview(label)
                }
            }
        }
    }
    
    var touching: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let slider = prkModeSlider {
            let value = self.frame.origin.x / self.bounds.width
            for i in 0..<self.subviews.count {
                let labelRect = CGRect(x: (CGFloat(i)*slider.thumbWidth) - (CGFloat(value) * slider.thumbWidth), y: 0, width: slider.thumbWidth, height: slider.bounds.height)
                let subview = self.subviews[i] 
                subview.frame = labelRect
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
