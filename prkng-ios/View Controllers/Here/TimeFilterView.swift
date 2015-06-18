//
//  TimeFilterView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-17.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TimeFilterView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var scrollView: UIScrollView
    var contentView: UIView
    var centerView: UIView
    var containerView: UIView
    var timeValues: [NSTimeInterval]
    var timeLabels: [PRKLabel]
    var selectedValue: NSTimeInterval?
    var lastSelectedValue: NSTimeInterval?
    
    var delegate: TimeFilterViewDelegate?
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool

    private(set) var SECONDS_PER_MINUTE : NSTimeInterval = 60
    private(set) var SECONDS_PER_HOUR : NSTimeInterval = 3600
    static var HEIGHT : CGFloat = 60
    private(set) var WIDTH : CGFloat = 800
    private(set) var CENTER_VIEW_HEIGHT : CGFloat = 30
    private(set) var CENTER_VIEW_WIDTH : CGFloat = 70
    private(set) var FONT : UIFont = Styles.FontFaces.regular(17)
    
    override init(frame: CGRect) {
        scrollView = UIScrollView()
        contentView = UIView()
        centerView = UIView()
        containerView = UIView()
        timeValues = [
            30 * SECONDS_PER_MINUTE,
            1 * SECONDS_PER_HOUR,
            2 * SECONDS_PER_HOUR,
            4 * SECONDS_PER_HOUR,
            8 * SECONDS_PER_HOUR,
            12 * SECONDS_PER_HOUR,
            24 * SECONDS_PER_HOUR
        ]
        timeLabels = []
        
        didsetupSubviews = false
        didSetupConstraints = true
     
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didsetupSubviews) {
            setupSubviews()
            self.setNeedsUpdateConstraints()
        }
        
        scrollToNearestLabel()
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if(!didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }

    func setupSubviews () {
        
        self.clipsToBounds = true
        var tapRec = UITapGestureRecognizer(target: self, action: Selector("toggleSelectFromTap:"))
        tapRec.delegate = self
        self.addGestureRecognizer(tapRec)

        self.addSubview(containerView)
        containerView.backgroundColor = Styles.Colors.midnight1
        containerView.clipsToBounds = true
        
        containerView.addSubview(centerView)
        centerView.backgroundColor = Styles.Colors.red2
        centerView.layer.cornerRadius = CENTER_VIEW_HEIGHT/2
        centerView.userInteractionEnabled = false
        centerView.alpha = 0
        
        containerView.addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.addSubview(contentView)
        
        var anyLabel = PRKLabel()
        anyLabel.text = "all".localizedString.uppercaseString
        anyLabel.font = FONT
        anyLabel.textColor = Styles.Colors.white
        anyLabel.valueTag = -1
        timeLabels.append(anyLabel)
        contentView.addSubview(anyLabel)

        for timeValue in timeValues {
            var label = PRKLabel()
            label.text = labelTextForTimeValue(timeValue)
            label.font = FONT
            label.textColor = Styles.Colors.white
            label.valueTag = timeValue
            
            timeLabels.append(label)
            contentView.addSubview(label)
        }
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }

        scrollView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: self.WIDTH, height: TimeFilterView.HEIGHT))
            make.edges.equalTo(self.scrollView)
        }
        
        centerView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: self.CENTER_VIEW_WIDTH, height: self.CENTER_VIEW_HEIGHT))
            make.center.equalTo(self.containerView)
        }
        
        var leftViewToLabel: UIView = timeLabels[0]
        timeLabels[0].snp_makeConstraints({ (make) -> () in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).with.offset(175)
        })
        for i in 1..<timeLabels.count {
            var label = timeLabels[i]
            label.snp_makeConstraints({ (make) -> () in
                make.centerY.equalTo(self.contentView)
                make.left.equalTo(leftViewToLabel.snp_right).with.offset(30)
            })
            leftViewToLabel = label
        }
        
    }
    
    func labelTextForTimeValue(interval: NSTimeInterval) -> String {
        if interval < SECONDS_PER_HOUR {
            return String(format: "%dMIN", Int(interval/SECONDS_PER_MINUTE))
        } else {
            return String(format: "%dH", Int(interval/SECONDS_PER_HOUR))
        }
    }
    
    //MARK- UIScrollViewDelegate
    var alreadySelected = false
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        recolorLabels()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollToNearestLabel()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollToNearestLabel()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestLabel()
        }
    }
    
    //MARK- helper functions
    
    func scrollToNearestLabel() {
        var centerPoint = getScrollViewCenter()
        scrollToNearestLabel(centerPoint)
    }
    
    func scrollToNearestLabel(centerPoint: CGPoint) -> PRKLabel {
        
        //get the label nearest to the centerPoint
        var nearestLabelDistanceFromPoint = CGFloat.max
        var nearestLabelDistanceFromCenter = CGFloat.max

        var nearestLabel: PRKLabel = getNearestLabel(centerPoint, nearestLabelDistanceFromPoint: &nearestLabelDistanceFromPoint, nearestLabelDistanceFromCenter: &nearestLabelDistanceFromCenter)
        
        //now scroll this label to the center
        if nearestLabelDistanceFromPoint > 1 {
            let point = CGPoint(x: scrollView.contentOffset.x + nearestLabelDistanceFromCenter, y: 0)
            scrollView.setContentOffset(point, animated: true)
        }
        
        recolorLabels()
        
        return nearestLabel
    }
    
    func getNearestLabel(fromPoint: CGPoint) -> PRKLabel  {
        
        var nearestLabelDistanceFromPoint = CGFloat.max
        var nearestLabelDistanceFromCenter = CGFloat.max
        
        return getNearestLabel(fromPoint, nearestLabelDistanceFromPoint: &nearestLabelDistanceFromPoint, nearestLabelDistanceFromCenter: &nearestLabelDistanceFromCenter)
    }
    
    func getNearestLabel(fromPoint: CGPoint, inout nearestLabelDistanceFromPoint: CGFloat, inout nearestLabelDistanceFromCenter: CGFloat) -> PRKLabel  {
        
        var contentViewCurrentCenterPoint = getScrollViewCenter()
        
        //get the label nearest to the centerPoint
        nearestLabelDistanceFromPoint = CGFloat.max
        nearestLabelDistanceFromCenter = CGFloat.max
        var nearestLabel = PRKLabel()
        
        for label in timeLabels {
            let distance = fromPoint.distanceToPoint(label.center)
            if distance < nearestLabelDistanceFromPoint {
                nearestLabelDistanceFromPoint = distance
                nearestLabelDistanceFromCenter = label.center.x - contentViewCurrentCenterPoint.x
                nearestLabel = label
            }
        }

        return nearestLabel
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        var containsPoint = true
        if selectedValue != nil {
            var frameWithMargin = CGRect(x: centerView.frame.origin.x - 10,
                                         y: centerView.frame.origin.y - 10,
                                         width: centerView.frame.width + 20,
                                         height: centerView.frame.height + 20)
            containsPoint = frameWithMargin.contains(touch.locationInView(centerView))
        }
        return containsPoint
    }
    
    //select or deselect a label and change the UI accordingly
    //gesture recognizer tap
    func toggleSelectFromTap(recognizer: UITapGestureRecognizer) {
        
        if selectedValue == nil {
            
            var tap = recognizer.locationInView(self.contentView)
            var label = scrollToNearestLabel(tap)
            
            selectedValue = label.valueTag
            
            containerView.userInteractionEnabled = false

            //make the view as large as the center view
            containerView.snp_remakeConstraints { (make) -> () in
                make.size.equalTo(CGSize(width: self.CENTER_VIEW_WIDTH, height: self.CENTER_VIEW_HEIGHT))
                make.center.equalTo(self)
            }
            
            let delay = lastSelectedValue == selectedValue ? 0 : 0.2
            let delayMsec = UInt64(delay*1000)
            
            UIView.animateWithDuration(0.3,
                delay: delay,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.centerView.alpha = 1
                    self.layoutIfNeeded()
                },
                completion: { (completed: Bool) -> Void in
            })
            
            var animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = 0
            animation.toValue = self.CENTER_VIEW_HEIGHT/2
            animation.duration = 0.3
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayMsec * NSEC_PER_MSEC)),
                dispatch_get_main_queue(), { () -> Void in
                    self.containerView.layer.addAnimation(animation, forKey: "cornerRadius")
                    self.containerView.layer.cornerRadius = self.CENTER_VIEW_HEIGHT/2
                    
            })
            
        } else {
            
            lastSelectedValue = selectedValue
            selectedValue = nil
            
            containerView.userInteractionEnabled = true
            
            //make the view as large as the center view
            containerView.snp_remakeConstraints { (make) -> () in
                make.edges.equalTo(self)
            }
            
            UIView.animateWithDuration(0.3,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.containerView.layer.cornerRadius = 0
                    self.centerView.alpha = 0
                    self.layoutIfNeeded()
                },
                completion: { (completed: Bool) -> Void in
            })
            
            var animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = self.CENTER_VIEW_HEIGHT/2
            animation.toValue = 0
            animation.duration = 0.3
            self.containerView.layer.addAnimation(animation, forKey: "cornerRadius")
            self.containerView.layer.cornerRadius = 0

        }
        
        delegate?.filterValueWasChanged(hours: selectedValueInHours())
        
    }
    
    func getScrollViewCenter() -> CGPoint {
        var visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height)
        var contentViewCurrentCenterPoint = CGPointMake(visibleRect.size.width/2 + scrollView.contentOffset.x, visibleRect.size.height/2 + scrollView.contentOffset.y);

        return contentViewCurrentCenterPoint
    }
    
    func recolorLabels() {
        
        //order the labels by proximity to the center
        var contentViewCurrentCenterPoint = getScrollViewCenter()
        
        //get the label nearest to the centerPoint
        var nearestLabelDistance = CGFloat.max
        var nearestLabelDifferenceFromCenter = CGFloat.max
        
        for label in timeLabels {
            let distance = contentViewCurrentCenterPoint.distanceToPoint(label.center)
            label.tag = Int(distance)
        }

        timeLabels.sort { (var left: PRKLabel, var right: PRKLabel) -> Bool in
            left.tag > right.tag
        }
        
        let maxDistance = timeLabels.first?.tag
        for i in 0..<timeLabels.count {
            let alpha = 1.1 - Float(timeLabels[i].tag) / Float(maxDistance!)
            timeLabels[i].textColor = Styles.Colors.white.colorWithAlphaComponent(CGFloat(alpha))
        }
    }
    
    func selectedValueInHours() -> Float? {
        var timeInterval = selectedValue
        timeInterval = timeInterval < 0 ? nil : timeInterval
        
        var hours: Float? = nil
        
        if timeInterval != nil {
            hours = Float(timeInterval! / 3600)
        }
        
        return hours
    }
    
}

protocol TimeFilterViewDelegate {
    
    func filterValueWasChanged(#hours:Float?)
    
}
