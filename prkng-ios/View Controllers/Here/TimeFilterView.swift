//
//  TimeFilterView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-17.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TimeFilterView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var containerView: UIView
    
    var timeImageView: UIImageView
    
    var scrollView: UIScrollView
    var contentView: UIView

    var timeValues: [NSTimeInterval]
    var timeLabels: [PRKLabel]
    var selectedValue: NSTimeInterval?
    var lastSelectedValue: NSTimeInterval?
    
    var topLine: UIView
    var bottomLine: UIView

    var delegate: TimeFilterViewDelegate?
    
    var enableSnapping : Bool
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool

    private(set) var SECONDS_PER_MINUTE : NSTimeInterval = 60
    private(set) var SECONDS_PER_HOUR : NSTimeInterval = 3600
    static var TOTAL_HEIGHT : CGFloat = 50
    static var SCROLL_HEIGHT: CGFloat = 50
    private(set) var WIDTH : CGFloat = 710
    private(set) var FONT : UIFont = Styles.FontFaces.regular(14)
    
    override init(frame: CGRect) {

        containerView = UIView()

        timeImageView = UIImageView(image: UIImage(named: "icon_time"))

        scrollView = UIScrollView()
        contentView = UIView()

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
        
        topLine = UIView()
        bottomLine = UIView()

        enableSnapping = false
        
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
        containerView.backgroundColor = Styles.Colors.petrol2
        containerView.clipsToBounds = true
        
        containerView.addSubview(scrollView)
        scrollView.backgroundColor = Styles.Colors.petrol2
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.addSubview(contentView)
        
        var anyLabel = PRKLabel()
        anyLabel.text = "all".localizedString.uppercaseString
        anyLabel.font = FONT
        anyLabel.textColor = Styles.Colors.cream1
        anyLabel.valueTag = -1
        timeLabels.append(anyLabel)
        contentView.addSubview(anyLabel)

        for timeValue in timeValues {
            var label = PRKLabel()
            label.text = labelTextForTimeValue(timeValue)
            label.font = FONT
            label.textColor = Styles.Colors.cream1
            label.valueTag = timeValue
            
            timeLabels.append(label)
            contentView.addSubview(label)
        }
        
        timeImageView.userInteractionEnabled = false
        containerView.addSubview(timeImageView)

        topLine.backgroundColor = Styles.Colors.petrol1
        self.addSubview(topLine)

        bottomLine.backgroundColor = Styles.Colors.midnight2
        self.addSubview(bottomLine)
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        timeImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(self.containerView)
            make.left.equalTo(self.containerView).with.offset(28.5)
        }
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView).with.offset(28.5 + 20 + 14)
            make.right.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.height.equalTo(TimeFilterView.SCROLL_HEIGHT)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: self.WIDTH, height: TimeFilterView.SCROLL_HEIGHT))
            make.edges.equalTo(self.scrollView)
        }
        
        var leftViewToLabel: UIView = timeLabels[0]
        timeLabels[0].snp_makeConstraints({ (make) -> () in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
        })
        for i in 1..<timeLabels.count {
            var label = timeLabels[i]
            label.snp_makeConstraints({ (make) -> () in
                make.centerY.equalTo(self.contentView)
                make.left.equalTo(leftViewToLabel.snp_right).with.offset(30)
            })
            leftViewToLabel = label
        }
        
        topLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(1)
        }
        
        bottomLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(1)
        }
        
    }
    
    func labelTextForTimeValue(interval: NSTimeInterval) -> String {
        if interval < 0 {
            return ""
        } else if interval < SECONDS_PER_HOUR {
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

        if enableSnapping {
            var centerPoint = getScrollViewCenter()
            scrollToNearestLabel(centerPoint)
        }
    }
    
    func scrollToNearestLabel(centerPoint: CGPoint) -> PRKLabel {
        
        //get the label nearest to the centerPoint
        var nearestLabelDistanceFromPoint = CGFloat.max
        var nearestLabelDistanceFromCenter = CGFloat.max

        var nearestLabel: PRKLabel = getNearestLabel(centerPoint, nearestLabelDistanceFromPoint: &nearestLabelDistanceFromPoint, nearestLabelDistanceFromCenter: &nearestLabelDistanceFromCenter)
        
        //now scroll this label to the center
        if enableSnapping {
            if nearestLabelDistanceFromPoint > 1 {
                let point = CGPoint(x: scrollView.contentOffset.x + nearestLabelDistanceFromCenter, y: 0)
                scrollView.setContentOffset(point, animated: true)
            }
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
    
    
    //select or deselect a label and change the UI accordingly
    //gesture recognizer tap
    func toggleSelectFromTap(recognizer: UITapGestureRecognizer) {
        
        var tap = recognizer.locationInView(self.contentView)
        toggleSelectFromPoint(tap)
    }

    func resetValue() {
        let point = CGPoint(x: 0, y: 0)
        scrollToNearestLabel(point)
        toggleSelectFromPoint(point)
    }
    
    func toggleSelectFromPoint(point: CGPoint) {
        
        var label = scrollToNearestLabel(point)
        
        selectedValue = label.valueTag
        
        let selectedLabelText = labelTextForTimeValue(selectedValue!)
        delegate?.filterValueWasChanged(hours: selectedValueInHours(), selectedLabelText: selectedLabelText)
        
    }
    
    func getScrollViewCenter() -> CGPoint {
        var visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height)
        var contentViewCurrentCenterPoint = CGPointMake(visibleRect.size.width/2 + scrollView.contentOffset.x, visibleRect.size.height/2 + scrollView.contentOffset.y);

        return contentViewCurrentCenterPoint
    }

    func getScrollViewLeft() -> CGPoint {
        var visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height)
        var contentViewCurrentLeftPoint = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y);
        
        return contentViewCurrentLeftPoint
    }

    func recolorLabels() {

//        //order the labels by proximity to the center
//        var contentViewCurrentCenterPoint = getScrollViewCenter()

        var contentViewCurrentCenterPoint = getScrollViewLeft()
        
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
            timeLabels[i].textColor = Styles.Colors.cream1.colorWithAlphaComponent(CGFloat(alpha))
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
    
    func filterValueWasChanged(#hours:Float?, selectedLabelText: String)
    
}
