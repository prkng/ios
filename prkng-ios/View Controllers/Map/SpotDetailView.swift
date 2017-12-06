//
//  SpotDetailView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 26/03/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SpotDetailView: UIView {

    var topContainer: UIView
    var topContainerButton: UIButton
    fileprivate var headerTitleLabel: MarqueeLabel
    fileprivate var titleLabel: MarqueeLabel
    var topContainerRightView: UIView
    var checkinImageView: UIImageView
    var checkinImageLabel: UILabel

    var bottomContainer: UIView
    var bottomContainerButton: UIButton
    var bottomLeftContainer: UIView
    var bottomRightContainer: UIView
    var leftTopLabel: UILabel
    var leftBottomLabel: UILabel
    var rightTopLabel: UILabel
    var rightBottomLabel: UILabel
    var scheduleImageView: UIImageView
    var bottomLeftImageView: UIImageView

    var topText: String {
        didSet {
            let splitAddressString = topText.splitAddressString
            headerTitleLabel.text = splitAddressString.0
            titleLabel.text = splitAddressString.1
            
            if (headerTitleLabel.text ?? "") == "" {
                
                titleLabel.snp_remakeConstraints { (make) -> () in
                    make.centerY.equalTo(self.topContainer)
                    make.left.equalTo(self.topContainer).offset(24)
                    make.right.lessThanOrEqualTo(self.topContainerRightView.snp_left).offset(-15)
                }

            } else {
                
                titleLabel.snp_remakeConstraints { (make) -> () in
                    make.bottom.equalTo(self.topContainer.snp_bottom).offset(self.TITLE_LABEL_BOTTOM_OFFSET)
                    make.left.equalTo(self.topContainer).offset(24)
                    make.right.lessThanOrEqualTo(self.topContainerRightView.snp_left).offset(-15)
                }

            }
        }
    }
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var delegate : SpotDetailViewDelegate?
    
    let VERTICAL_LABEL_SPACING = UIScreen.main.bounds.width == 320 ? 18 : 14
    fileprivate(set) var TITLE_LABEL_BOTTOM_OFFSET = UIScreen.main.bounds.width == 320 ? -15 : -13

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {

        topContainer = UIView()
        topContainerButton = ViewFactory.checkInButton()

        headerTitleLabel = MarqueeLabel()
        titleLabel = MarqueeLabel()
        topContainerRightView = UIView()
        checkinImageView = UIImageView()
        checkinImageLabel = UILabel()
        
        bottomContainer = UIView()
        bottomContainerButton = ViewFactory.openScheduleButton()
        bottomLeftContainer = UIView()
        bottomRightContainer = UIView()
        leftTopLabel = UILabel()
        leftBottomLabel = UILabel()
        rightTopLabel = UILabel()
        rightBottomLabel = UILabel()
        scheduleImageView = UIImageView()
        bottomLeftImageView = UIImageView()

        topText = ""
        
        didSetupSubviews = false
        didSetupConstraints = false
        
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func updateConstraints() {
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }

    func setupSubviews() {
        
        topContainer.isUserInteractionEnabled = false
        addSubview(topContainer)

        topContainerButton.addTarget(self, action: #selector(SpotDetailView.topContainerTapped(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(topContainerButton)

        headerTitleLabel.animationDelay = 2
        headerTitleLabel.font = Styles.FontFaces.light(11)
        headerTitleLabel.textColor = Styles.Colors.cream2
        headerTitleLabel.textAlignment = NSTextAlignment.left
        topContainer.addSubview(headerTitleLabel)
        
        titleLabel.animationDelay = 2
        titleLabel.font = Styles.Fonts.h2Variable
        titleLabel.textColor = Styles.Colors.cream2
        titleLabel.textAlignment = NSTextAlignment.left
        topContainer.addSubview(titleLabel)
        
        topContainer.addSubview(topContainerRightView)

        checkinImageView.contentMode = UIViewContentMode.scaleAspectFit
        topContainerRightView.addSubview(checkinImageView)
        checkinImageView.layer.anchorPoint = CGPoint(x: 0.5,y: 1.0);
        checkinImageView.layer.wigglewigglewiggle()
        
        checkinImageLabel.font = Styles.FontFaces.bold(10)
        checkinImageLabel.textColor = Styles.Colors.cream1
        checkinImageLabel.textAlignment = NSTextAlignment.center
        topContainerRightView.addSubview(checkinImageLabel)
        
        bottomContainer.isUserInteractionEnabled = false
        addSubview(bottomContainer)

        bottomLeftContainer.backgroundColor = Styles.Colors.cream1
        bottomLeftContainer.clipsToBounds = true
        bottomContainer.addSubview(bottomLeftContainer)
        bottomContainer.addSubview(bottomRightContainer)
        
        bottomContainerButton.addTarget(self, action: #selector(SpotDetailView.bottomContainerTapped(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(bottomContainerButton)
        
        leftTopLabel.font = Styles.FontFaces.light(11)
        leftTopLabel.textColor = Styles.Colors.petrol2
        leftTopLabel.textAlignment = NSTextAlignment.left
        leftTopLabel.numberOfLines = 1
        bottomLeftContainer.addSubview(leftTopLabel)
        
        leftBottomLabel.font = Styles.Fonts.h2rVariable
        leftBottomLabel.adjustsFontSizeToFitWidth = true
        leftBottomLabel.textColor = Styles.Colors.red2
        leftBottomLabel.textAlignment = NSTextAlignment.left
        leftBottomLabel.text = "$"
        bottomLeftContainer.addSubview(leftBottomLabel)

        rightTopLabel.font = Styles.FontFaces.light(11)
        rightTopLabel.textColor = Styles.Colors.petrol2
        rightTopLabel.textAlignment = NSTextAlignment.left
        rightTopLabel.numberOfLines = 1
        bottomRightContainer.addSubview(rightTopLabel)

        rightBottomLabel.font = Styles.Fonts.h2rVariable
        rightBottomLabel.adjustsFontSizeToFitWidth = true
        rightBottomLabel.textColor = Styles.Colors.petrol2
        rightBottomLabel.textAlignment = NSTextAlignment.left
        rightBottomLabel.text = "00:00"
        bottomRightContainer.addSubview(rightBottomLabel)
        
        scheduleImageView.contentMode = UIViewContentMode.center
        bottomRightContainer.addSubview(scheduleImageView)

        bottomLeftImageView.contentMode = UIViewContentMode.center
        bottomLeftContainer.addSubview(bottomLeftImageView)

        self.sendSubview(toBack: topContainerButton)
        self.sendSubview(toBack: bottomContainerButton)
        
        didSetupSubviews = true
    }

    func setupConstraints() {

        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(Styles.Sizes.spotDetailViewTopPortionHeight)
        }
        
        topContainerButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.topContainer)
        }

        headerTitleLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.topContainer).offset(25)
            make.right.lessThanOrEqualTo(self.topContainerRightView.snp_left).offset(-15)
            make.bottom.equalTo(self.titleLabel.snp_top).offset(1)
        }

        titleLabel.snp_makeConstraints { (make) -> () in
//            make.bottom.equalTo(self.topContainer.snp_bottom).offset(self.TITLE_LABEL_BOTTOM_OFFSET)
            make.left.equalTo(self.topContainer).offset(24)
            make.right.lessThanOrEqualTo(self.topContainerRightView.snp_left).offset(-15)
        }
        
        topContainerRightView.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.topContainer)
            make.right.equalTo(self.topContainer.snp_centerX).multipliedBy(1.66).offset(28)
            make.height.equalTo(Styles.Sizes.spotDetailViewTopPortionHeight)
            make.width.equalTo(56)
        }
        
        checkinImageView.snp_makeConstraints { (make) -> () in
            make.height.equalTo(24)
            make.centerX.equalTo(self.topContainerRightView)
            make.top.equalTo(self.topContainerRightView).offset(27)
        }

        checkinImageLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.topContainerRightView)
            make.bottom.equalTo(self.topContainerRightView).offset(-14)
        }
        
        bottomContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topContainer.snp_bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
        }

        bottomContainerButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.bottomContainer)
        }
        
        bottomLeftContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomContainer)
            make.top.equalTo(self.bottomContainer)
            make.bottom.equalTo(self.bottomContainer)
            make.width.equalTo(0)
        }
        
        leftTopLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomLeftContainer).offset(24)
            make.top.equalTo(self.bottomLeftContainer).offset(self.VERTICAL_LABEL_SPACING)
        }
        
        leftBottomLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomLeftContainer).offset(24)
            make.bottom.equalTo(self.bottomLeftContainer).offset(-self.VERTICAL_LABEL_SPACING)
        }
        
        bottomRightContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomLeftContainer.snp_right)
            make.right.equalTo(self.bottomContainer)
            make.top.equalTo(self.bottomContainer)
            make.bottom.equalTo(self.bottomContainer)
        }
        
        rightTopLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomRightContainer).offset(24)
            make.top.equalTo(self.bottomRightContainer).offset(self.VERTICAL_LABEL_SPACING)
        }
        
        rightBottomLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomRightContainer).offset(24)
            make.bottom.equalTo(self.bottomRightContainer).offset(-self.VERTICAL_LABEL_SPACING)
            make.right.lessThanOrEqualTo(self.scheduleImageView.snp_left)
        }
        
        scheduleImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 22, height: Styles.Sizes.spotDetailViewBottomPortionHeight))// + 22))
            make.centerY.equalTo(self.bottomContainer)
            make.right.equalTo(self.bottomContainer.snp_centerX).multipliedBy(1.66).offset(11)
        }
        
        bottomLeftImageView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.bottomLeftContainer)
        }

        didSetupConstraints = true
    }
    
    
    func topContainerTapped (_ sender : AnyObject?) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Spot Details", action: "Check In Button Tapped", label: nil, value: nil).build() as! [AnyHashable: Any])

        if(delegate != nil) {
            delegate!.topContainerTapped()
        }
    }

    func bottomContainerTapped (_ sender : AnyObject?) {

        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Spot Details", action: "Agenda/Schedule Button Tapped", label: nil, value: nil).build() as! [AnyHashable: Any])

        if(delegate != nil) {
            delegate!.bottomContainerTapped()
        }
    }
    
}



protocol SpotDetailViewDelegate {
    
    func topContainerTapped()
    func bottomContainerTapped()
    
}
