//
//  TimeFilterView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-17.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TimeFilterView: UIView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView
    var contentView: UIView
    var centerView: UIView
    var timeValues: [NSTimeInterval]
    var timeLabels: [UILabel]
    
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
        self.backgroundColor = Styles.Colors.midnight1
        
        var tapRec = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.addGestureRecognizer(tapRec)

        self.addSubview(centerView)
        centerView.backgroundColor = Styles.Colors.red2
        centerView.layer.cornerRadius = CENTER_VIEW_HEIGHT/2
        centerView.userInteractionEnabled = false

        self.addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.addSubview(contentView)
        
        var anyLabel = UILabel()
        anyLabel.text = "all".localizedString.uppercaseString
        anyLabel.font = FONT
        anyLabel.textColor = Styles.Colors.white
        timeLabels.append(anyLabel)
        contentView.addSubview(anyLabel)

        for timeValue in timeValues {
            var label = UILabel()
            label.text = labelTextForTimeValue(timeValue)
            label.font = FONT
            label.textColor = Styles.Colors.white
            
            timeLabels.append(label)
            contentView.addSubview(label)
        }
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: self.WIDTH, height: TimeFilterView.HEIGHT))
//            make.center.equalTo(self)
            make.edges.equalTo(self.scrollView)

        }
        
        centerView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: self.CENTER_VIEW_WIDTH, height: self.CENTER_VIEW_HEIGHT))
            make.center.equalTo(self)
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
        var visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height)
        var centerPoint = CGPointMake(visibleRect.size.width/2 + scrollView.contentOffset.x, visibleRect.size.height/2 + scrollView.contentOffset.y);

        scrollToNearestLabel(centerPoint)
    }
    
    
    func scrollToNearestLabel(centerPoint: CGPoint) {
        
        var visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height)
        var contentViewCurrentCenterPoint = CGPointMake(visibleRect.size.width/2 + scrollView.contentOffset.x, visibleRect.size.height/2 + scrollView.contentOffset.y);

        //get the label nearest to the centerPoint
        var nearestLabelDistance = CGFloat.max
        var nearestLabelDifferenceFromCenter = CGFloat.max
        
        for label in timeLabels {
            let distance = centerPoint.distanceToPoint(label.center)
            if distance < nearestLabelDistance {
                nearestLabelDistance = distance
                nearestLabelDifferenceFromCenter = label.center.x - contentViewCurrentCenterPoint.x
            }
        }
        
        //now scroll this label to the center
        if nearestLabelDistance > 1 {
            let point = CGPoint(x: scrollView.contentOffset.x + nearestLabelDifferenceFromCenter, y: 0)
            scrollView.setContentOffset(point, animated: true)
        }
        
        recolorLabels()
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        var tap = recognizer.locationInView(self.contentView)
        scrollToNearestLabel(tap)
    }
    
    func recolorLabels() {
        //order the labels by proximity to the center
        var visibleRect = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height)
        var contentViewCurrentCenterPoint = CGPointMake(visibleRect.size.width/2 + scrollView.contentOffset.x, visibleRect.size.height/2 + scrollView.contentOffset.y);
        
        //get the label nearest to the centerPoint
        var nearestLabelDistance = CGFloat.max
        var nearestLabelDifferenceFromCenter = CGFloat.max
        
        
        for label in timeLabels {
            let distance = contentViewCurrentCenterPoint.distanceToPoint(label.center)
            label.tag = Int(distance)
        }

        timeLabels.sort { (var left: UILabel, var right: UILabel) -> Bool in
            left.tag > right.tag
        }
        
//        NSLog("\ndistance: " )
//        for label in timeLabels {
//            NSLog(String(label.tag))
//            if label.tag < 100 {
//                label.textColor = Styles.Colors.white
//            } else {
//                label.textColor = Styles.Colors.white.colorWithAlphaComponent(0.5)
//            }
//        }
        
        let maxDistance = timeLabels.first?.tag
        for i in 0..<timeLabels.count {
            let alpha = 1.1 - Float(timeLabels[i].tag) / Float(maxDistance!)
            timeLabels[i].textColor = Styles.Colors.white.colorWithAlphaComponent(CGFloat(alpha))
        }

    }
    
}
