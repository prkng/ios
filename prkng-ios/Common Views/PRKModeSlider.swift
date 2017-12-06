//
//  PRKModeSlider.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 12/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//


import UIKit

class PRKModeSlider: UIControl {
    
    let trackTextColor = Styles.Colors.petrol2
    let thumbTextColor = Styles.Colors.cream1
    let thumbBackgroundColor = Styles.Colors.red2
    let font = Styles.FontFaces.regular(14)
    
    fileprivate(set) var titles = [String]()
    
    fileprivate var backgroundView = UIView()
    fileprivate var labels = [UILabel]()
    fileprivate var thumbView = PRKModeSliderThumbView()

    var selectedIndex: Int {
        return Int(self.value)
    }

    var thumbWidth: CGFloat {
        return UIScreen.main.bounds.width/CGFloat(self.titles.count)
    }
    
    fileprivate var minimumValue: Double
    fileprivate var maximumValue: Double
    fileprivate var value: Double {
        didSet {
            //do this to update the frame after an animation, also good for
            updateThumb()
        }
    }
    fileprivate var previousLocation = CGPoint()
    fileprivate var animationInProgress: Bool = false
    
    init(titles: [String]) {
        
        value = 0
        minimumValue = 0
        maximumValue = Double(titles.count - 1)
        
        super.init(frame: CGRect.zero)
        
        value = floor(maximumValue/2)
        
        if #available(iOS 8.0, *) {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            backgroundView = UIVisualEffectView(effect: blurEffect)
        } else {
            backgroundView.backgroundColor = Styles.Colors.cream1
        }
        backgroundView.isUserInteractionEnabled = false
        self.addSubview(backgroundView)

        self.titles = titles
        
        //add text layers
        for i in 0..<titles.count {
            let title = titles[i]
            let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: trackTextColor])
            let labelRect = CGRect(x: (CGFloat(i)*thumbWidth), y: 0, width: thumbWidth, height: bounds.height)
            
            let label = UILabel(frame: labelRect)
            label.attributedText = attributedTitle
            label.textAlignment = NSTextAlignment.center
            
            label.isUserInteractionEnabled = false
            self.addSubview(label)
            labels.append(label)
        }

        thumbView.prkModeSlider = self
        thumbView.isUserInteractionEnabled = false
        self.addSubview(thumbView)
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(PRKModeSlider.sliderSelectionTapped(_:)))
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
            label.snp_remakeConstraints(closure: { (make) -> () in
                make.left.equalTo(self).offset(CGFloat(i)*self.thumbWidth)
                make.top.equalTo(self)
                make.height.equalTo(self.snp_height)
                make.width.equalTo(self.thumbWidth)
            })
        }

    }
    
    //MARK: Helper functions
    
    func setValue(_ newValue: Double, animated: Bool) {

        if self.animationInProgress {
            return
        }
        
        self.animationInProgress = true
        let animationDuration = animated ? 0.4 : 0
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 7, initialSpringVelocity: 15, options: [], animations: { () -> Void in
            let thumbLeft = CGFloat(newValue) * self.thumbWidth
            self.thumbView.frame = CGRect(x: thumbLeft, y: 0, width: self.thumbWidth, height: self.bounds.height)
            self.thumbView.setNeedsLayout()
            self.thumbView.layoutIfNeeded()
            }) { (Bool) -> Void in
                let valueChanged = self.selectedIndex != Int(newValue)
                self.value = newValue
                if valueChanged {
                    self.sendActions(for: UIControlEvents.valueChanged)
                }
                self.animationInProgress = false
        }
        
    }
    
    func updateThumb() {
        let thumbLeft = CGFloat(self.value) * self.thumbWidth
        self.thumbView.frame = CGRect(x: thumbLeft, y: 0 , width: self.thumbWidth, height: self.bounds.height)
        self.thumbView.setNeedsLayout()
    }
    
    //MARK: UIControl functions
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if thumbView.frame.contains(previousLocation) {
            thumbView.touching = true
        }
        
        return thumbView.touching
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
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
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbView.touching = false
        self.setValue(round(self.value), animated: true)
    }
    
    func clipValue(_ value: Double) -> Double {
        return min(max(value, minimumValue ), maximumValue)
    }
    
    //MARK: UIGestureRecognizer function
    func sliderSelectionTapped(_ tapRec: UITapGestureRecognizer) {
        if tapRec.state == UIGestureRecognizerState.ended {
            let tap = tapRec.location(in: self)
            let newValue = (tap.x / self.bounds.width) * CGFloat(self.titles.count)
            setValue(Double(Int(newValue)), animated: true)
        }
    }

}

class PRKModeSliderThumbView: UIView {
    
    fileprivate weak var prkModeSlider : PRKModeSlider? {
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
                    label.textAlignment = NSTextAlignment.center
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
            self.frame = CGRect(x: self.frame.origin.x, y: 0, width: slider.thumbWidth, height: slider.bounds.height)
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
