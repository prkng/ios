//
//  PRKModeSlider.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 12/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//


import UIKit

class PRKTopTabBar: UIControl {
    
    let trackTextColor = Styles.Colors.petrol2
    let indicatorTextColor = Styles.Colors.red2
    let indicatorBottomColor = Styles.Colors.red2
    let font = Styles.FontFaces.regular(16)
    
    fileprivate(set) var titles = [String]()
    
    fileprivate var backgroundView = UIView()
    fileprivate var labels = [UILabel]()
    fileprivate var indicatorView = PRKTopTabIndicatorView()

    var selectedIndex: Int {
        return Int(self.value)
    }

    var indicatorWidth: CGFloat {
        return UIScreen.main.bounds.width/CGFloat(self.titles.count)
    }
    
    fileprivate var minimumValue: Double
    fileprivate var maximumValue: Double
    fileprivate var value: Double {
        didSet {
            //do this to update the frame after an animation, also good for
            updateindicator()
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

        backgroundView.backgroundColor = Styles.Colors.cream1.withAlphaComponent(0.5)
        backgroundView.isUserInteractionEnabled = false
        self.addSubview(backgroundView)

        self.titles = titles
        
        //add text layers
        for i in 0..<titles.count {
            let title = titles[i]
            let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: trackTextColor])
            let labelRect = CGRect(x: (CGFloat(i)*indicatorWidth), y: 0, width: indicatorWidth, height: bounds.height)
            
            let label = UILabel(frame: labelRect)
            label.attributedText = attributedTitle
            label.textAlignment = NSTextAlignment.center
            
            label.isUserInteractionEnabled = false
            self.addSubview(label)
            labels.append(label)
        }

        indicatorView.prkModeSlider = self
        indicatorView.isUserInteractionEnabled = false
        self.addSubview(indicatorView)
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(PRKTopTabBar.sliderSelectionTapped(_:)))
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
                make.left.equalTo(self).offset(CGFloat(i)*self.indicatorWidth)
                make.top.equalTo(self)
                make.height.equalTo(self.snp_height)
                make.width.equalTo(self.indicatorWidth)
            })
        }

    }
    
    //MARK: Helper functions
    
    func refresh() {
        setValue(self.value, animated: false)
    }
    
    func setValue(_ newValue: Double, animated: Bool) {

        if self.animationInProgress {
            return
        }

        self.animationInProgress = true
        let animationDuration = animated ? 0.4 : 0
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 7, initialSpringVelocity: 15, options: [], animations: { () -> Void in
            let indicatorLeft = CGFloat(newValue) * self.indicatorWidth
            self.indicatorView.frame = CGRect(x: indicatorLeft, y: 0, width: self.indicatorWidth, height: self.bounds.height)
            self.indicatorView.setNeedsLayout()
            self.indicatorView.layoutIfNeeded()
            }) { (Bool) -> Void in
                let valueChanged = self.selectedIndex != Int(newValue)
                self.value = newValue
                if valueChanged {
                    self.sendActions(for: UIControlEvents.valueChanged)
                }
                self.animationInProgress = false
        }
        
    }
    
    func updateindicator() {
        let indicatorLeft = CGFloat(self.value) * self.indicatorWidth
        self.indicatorView.frame = CGRect(x: indicatorLeft, y: 0 , width: self.indicatorWidth, height: self.bounds.height)
        self.indicatorView.setNeedsLayout()
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

class PRKTopTabIndicatorView: UIView {
    
    fileprivate weak var prkModeSlider : PRKTopTabBar? {
        didSet {
            
            if let slider = prkModeSlider {
                
                //layers for all the text
                for i in 0..<slider.titles.count {
                    let title = slider.titles[i]
                    let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: slider.font, NSForegroundColorAttributeName: slider.indicatorTextColor])
                    let labelRect = CGRect(x: (CGFloat(i)*slider.indicatorWidth), y: 0, width: slider.indicatorWidth, height: slider.bounds.height)
                    
                    let label = UILabel(frame: labelRect)
                    label.attributedText = attributedTitle
                    label.textAlignment = NSTextAlignment.center
                    self.addSubview(label)
                }
                
                //add the bottom view
                let bottomView = UIView(frame: CGRect(x: 0, y: slider.bounds.height - 2, width: slider.indicatorWidth, height: 2))
                bottomView.backgroundColor = slider.indicatorBottomColor
                self.addSubview(bottomView)
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
            
            self.frame = CGRect(x: self.frame.origin.x, y: 0, width: slider.indicatorWidth, height: slider.bounds.height)

            let value = self.frame.origin.x / self.bounds.width
            for i in 0..<self.subviews.count {
                let subview = self.subviews[i]
                if subview is UILabel {
                    let labelRect = CGRect(x: (CGFloat(i)*slider.indicatorWidth) - (CGFloat(value) * slider.indicatorWidth), y: 0, width: slider.indicatorWidth, height: slider.bounds.height)
                    subview.frame = labelRect
                } else {
                    let bottomViewFrame = CGRect(x: 0, y: slider.bounds.height - 2, width: slider.indicatorWidth, height: 2)
                    subview.frame = bottomViewFrame
                }
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
