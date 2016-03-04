//
//  PPHeaderView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-04.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class PPHeaderView: UIView, UIGestureRecognizerDelegate {
    
    var delegate: PPHeaderViewDelegate?
    
    private var container = UIView()
    private var backButtonImageView: UIButton
    private var nextButtonLabel = UILabel()
    private var headerButton = MKButton()
    private var headerLabel = UILabel()
    
    private(set) var BACKGROUND_COLOR = Styles.Colors.stone
    private(set) var BACKGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    private(set) var BACKGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.petrol2
    private(set) var FOREGROUND_COLOR = Styles.Colors.cream1
    private(set) var FOREGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    private(set) var FOREGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.red2
    
    private(set) var HEADER_HEIGHT = 80
    private(set) var HEADER_FONT = Styles.FontFaces.regular(12)
    
    private(set) var SMALL_CELL_HEIGHT: CGFloat = 48
    private(set) var BIG_CELL_HEIGHT: CGFloat = 61
    
    var showsLeftButton: Bool {
        didSet {
            backButtonImageView.hidden = !showsLeftButton
        }
    }

    var showsRightButton: Bool {
        didSet {
            nextButtonLabel.hidden = !showsRightButton
        }
    }
    
    var rightButtonText: String = "next".localizedString.uppercaseString {
        didSet {
            nextButtonLabel.text = rightButtonText
        }
    }
    
    var headerText: String? {
        didSet {
            headerLabel.text = headerText
        }
    }
    
    var enableRipple: Bool = true {
        didSet {
            configureRipple()
        }
    }
    
    var backButtonTapRadius: CGFloat?
    
    init() {
        showsLeftButton = true
        showsRightButton = true
        backButtonImageView = ViewFactory.outlineBackButton(BACKGROUND_TEXT_COLOR_EMPHASIZED)
        super.init(frame: CGRectZero)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func setupViews () {
        
        self.backgroundColor = BACKGROUND_COLOR
        self.addSubview(container)
        
        configureRipple()
        
        headerLabel.numberOfLines = 0
        headerLabel.font = HEADER_FONT
        headerLabel.textColor = BACKGROUND_TEXT_COLOR_EMPHASIZED
        headerLabel.textAlignment = .Center
        
        nextButtonLabel.text = rightButtonText
        nextButtonLabel.font = HEADER_FONT
        nextButtonLabel.textColor = FOREGROUND_TEXT_COLOR_EMPHASIZED //red2
        nextButtonLabel.textAlignment = .Right
        
        container.addSubview(headerLabel)
        container.addSubview(backButtonImageView)
        container.addSubview(nextButtonLabel)
        container.addSubview(headerButton)
        
        let tapRec = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapRec.delegate = self
        headerButton.addGestureRecognizer(tapRec)
        
    }
    
    override func updateConstraints() {
        
        container.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        backButtonImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(25)
            make.centerY.equalTo(container)
        }
        
        nextButtonLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(container).offset(-25)
            make.centerY.equalTo(container)
        }
        
        headerLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(25 + backButtonImageView.intrinsicContentSize().width + 10)
            make.right.equalTo(container).offset(-(10 + nextButtonLabel.intrinsicContentSize().width + 25))
            make.top.equalTo(container).offset(10)
            make.bottom.equalTo(container).offset(-10)
        }
        
        headerButton.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(container)
        }
        
        super.updateConstraints()
    }
    
    private func configureRipple() {
        if enableRipple {
            headerButton.rippleLayerColor = FOREGROUND_COLOR
            headerButton.rippleAniDuration = 0.35
            headerButton.ripplePercent = 0.9
            headerButton.cornerRadius = 0
            
            headerButton.shadowAniEnabled = false
            headerButton.backgroundAniEnabled = true
            headerButton.shadowAniEnabled = true

            headerButton.layer.shadowColor = UIColor.blackColor().CGColor
            headerButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            headerButton.layer.shadowOpacity = 0.1
            headerButton.layer.shadowRadius = 0.5
        } else {
            headerButton.rippleAniDuration = 0
            headerButton.ripplePercent = 0
            
            headerButton.shadowAniEnabled = false
            headerButton.backgroundAniEnabled = false
            headerButton.shadowAniEnabled = false
        }
    }
    
    func handleTap(tapRec: UITapGestureRecognizer) {
        let tap = tapRec.locationInView(self)
        let backCenterPoint = backButtonImageView.convertPoint(backButtonImageView.bounds.origin, toView: self)
        let nextCenterPoint = nextButtonLabel.convertPoint(nextButtonLabel.bounds.origin, toView: self)
        
        let backDistance = tap.distanceToPoint(backCenterPoint)
        let nextDistance = tap.distanceToPoint(nextCenterPoint)
        
        if backDistance > nextDistance && showsRightButton {
            self.delegate?.tappedNextButton()
        } else {
            let radius = backButtonTapRadius
            if radius == nil || radius >= CGFloat(backDistance) {
                self.delegate?.tappedBackButton()
            }
        }
    }
    
}

protocol PPHeaderViewDelegate {
    func tappedBackButton()
    func tappedNextButton()
}
