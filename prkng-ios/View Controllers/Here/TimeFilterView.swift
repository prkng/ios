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

    var messageLabel: UILabel
    
    var times: [TimeFilter]
    var selectedPermitValue: Bool
    var selectedValue: NSTimeInterval?
    var lastSelectedValue: NSTimeInterval?
    
    var topLine: UIView
    var bottomLine: UIView

    var delegate: TimeFilterViewDelegate?
    
    var enableSnapping : Bool
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool

    static var TOTAL_HEIGHT : CGFloat = 50
    static var SCROLL_HEIGHT: CGFloat = 50
    
    override init(frame: CGRect) {

        containerView = UIView()
        
        messageLabel = UILabel()
        timeImageView = UIImageView()

        scrollView = UIScrollView()
        contentView = UIView()

        selectedPermitValue = false
        times = [
            TimeFilter(interval: -1, labelText: "all".localizedString.uppercaseString),
            TimeFilter(interval: 30 * TimeFilter.SECONDS_PER_MINUTE),
            TimeFilter(interval: 1 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 2 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 4 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 8 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 12 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 24 * TimeFilter.SECONDS_PER_HOUR),
//            TimeFilter(interval: 24 * TimeFilter.SECONDS_PER_HOUR, labelText: "car_sharing".localizedString.uppercaseString, permit: true),
        ]
        
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
        
        resizeContentViewWidth()
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
        
        for time in times {
            contentView.addSubview(time.label)
        }
        
        timeImageView.userInteractionEnabled = false
        containerView.addSubview(timeImageView)

        messageLabel.textColor = Styles.Colors.cream1
        messageLabel.font = Styles.FontFaces.light(17)
        containerView.addSubview(messageLabel)
        
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
        
        messageLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.timeImageView.snp_right).with.offset(15)
            make.right.equalTo(self.containerView)
            make.centerY.equalTo(self.containerView)
        }
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView).with.offset(28.5 + 20 + 14)
            make.right.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.height.equalTo(TimeFilterView.SCROLL_HEIGHT)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.width.greaterThanOrEqualTo(self.scrollView).multipliedBy(2).with.offset(70)
            make.height.equalTo(self.scrollView)
            make.edges.equalTo(self.scrollView)
        }
        
        times[0].label.snp_makeConstraints({ (make) -> () in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
        })
        
        var leftViewToLabel: UIView = times[0].label
        for i in 1..<times.count {
            var label = times[i].label
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
            make.height.equalTo(0.5)
        }
        
        bottomLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }
        
    }
    
    func resizeContentViewWidth() {
        
        var contentViewWidth = 30 * (times.count - 2)
        var lastAddedWidth = 0
        for time in times {
            let label = time.label
            lastAddedWidth = Int(label.bounds.width)
            contentViewWidth += lastAddedWidth
        }
        contentViewWidth += Int(scrollView.bounds.width)
        
        contentView.snp_remakeConstraints { (make) -> () in
            make.width.greaterThanOrEqualTo(contentViewWidth)
            make.height.equalTo(self.scrollView)
            make.edges.equalTo(self.scrollView)
        }

    }
    
    func update() {
        
        if Settings.shouldFilterForCarSharing() {
            timeImageView.image = UIImage(named: "icon_exclamation")
            messageLabel.text = "car_sharing_enabled_text".localizedString
            contentView.hidden = true
            self.userInteractionEnabled = false
            self.delegate?.filterLabelUpdate("")
        } else {
            timeImageView.image = UIImage(named: "icon_time")
            messageLabel.text = ""
            contentView.hidden = false
            self.userInteractionEnabled = true
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
        
        for time in times {
            let label = time.label
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
        update()
    }
    
    func toggleSelectFromPoint(point: CGPoint) {
        
        var label = scrollToNearestLabel(point)
        
        let time = times.filter { (time) -> Bool in
            time.label == label
        }.first!
        
        selectedValue = label.valueTag
        selectedPermitValue = time.permit
        
        delegate?.filterValueWasChanged(hours: selectedValueInHours(), selectedLabelText: time.labelText(), permit: time.permit)
        
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
        
        var timeLabels = times.map { (time) -> PRKLabel in
            time.label
        }
        
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
    
    func filterValueWasChanged(#hours:Float?, selectedLabelText: String, permit: Bool)
    func filterLabelUpdate(labelText: String)
}

class TimeFilter {
    
    var interval: NSTimeInterval
    var label: PRKLabel
    var permit: Bool
    private var overriddenLabelText: String?
    
    static var SECONDS_PER_MINUTE : NSTimeInterval = 60
    static var SECONDS_PER_HOUR : NSTimeInterval = 3600
    static var FONT : UIFont = Styles.FontFaces.regular(14)

    convenience init(interval: NSTimeInterval) {
        self.init(interval: interval, labelText: nil)
    }

    convenience init(interval: NSTimeInterval, labelText: String?) {
        self.init(interval: interval, labelText: nil, permit: nil)
    }

    init(interval: NSTimeInterval, labelText: String?, permit: Bool?) {
        
        self.interval = interval
        self.label = PRKLabel()

        if labelText != nil {
            self.overriddenLabelText = labelText!
        }
        
        if permit != nil {
            self.permit = permit!
        } else {
            self.permit = false
        }
        
        label.font = TimeFilter.FONT
        label.textColor = Styles.Colors.cream1
        label.valueTag = interval
        label.text = self.labelText()
        
    }
    
    func labelText() -> String {
        
        if overriddenLabelText != nil {
            return overriddenLabelText!
        }
        
        if interval < 0 {
            return ""
        } else if interval < TimeFilter.SECONDS_PER_HOUR {
            return String(format: "%dMIN", Int(interval/TimeFilter.SECONDS_PER_MINUTE))
        } else {
            return String(format: "%dH", Int(interval/TimeFilter.SECONDS_PER_HOUR))
        }
    }
}