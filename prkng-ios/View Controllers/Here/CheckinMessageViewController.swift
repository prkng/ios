//
//  CheckinMessageViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 11/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class CheckinMessageViewController: GAITrackedViewController {
    
    var containerView: UIView
    var imageView : UIImageView
    var titleContainer : UIView
    var titleLabel : UILabel
    var subtitleLabel : UILabel
    var textContainer : UIView
    var textLabel : UILabel
    
    init() {
        
        containerView = UIView()
        imageView = UIImageView()
        titleContainer = UIView()
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        textContainer = UIView()
        textLabel = UILabel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func loadView() {
        view = UIView()
        setupSubviews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Here - Checkin Message"
    }
    
    
    
    func setupSubviews() {
        
        view.backgroundColor = Styles.Colors.transparentBackground
        
        view.addSubview(containerView)
        
        imageView.image =  UIImage(named:"first_checkin_header")
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        containerView.addSubview(imageView)
        
        titleContainer.backgroundColor = Styles.Colors.cream2
        containerView.addSubview(titleContainer)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.petrol2
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "first_checkin_title".localizedString
        containerView.addSubview(titleLabel)
        
        subtitleLabel.font = Styles.FontFaces.regular(17)
        subtitleLabel.textColor = Styles.Colors.red2
        subtitleLabel.textAlignment = NSTextAlignment.Center
        subtitleLabel.text = "first_checkin_subtitle".localizedString
        containerView.addSubview(subtitleLabel)
        
        textContainer.backgroundColor = Styles.Colors.cream2
        textContainer.layer.borderColor = Styles.Colors.beige1.CGColor
        textContainer.layer.borderWidth = 0.5
        containerView.addSubview(textContainer)
        
        textLabel.font = Styles.FontFaces.light(17)
        textLabel.textColor = Styles.Colors.petrol2
        textLabel.numberOfLines = 0
        textLabel.textAlignment = NSTextAlignment.Left
        textLabel.text = "first_checkin_text".localizedString
        containerView.addSubview(textLabel)
        
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.view)
            make.left.equalTo(self.view).with.offset(24)
            make.right.equalTo(self.view).with.offset(-24)
        }
        
        titleContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.imageView.snp_bottom)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.textContainer.snp_top)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.imageView.snp_bottom).with.offset(17)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        
        subtitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).with.offset(7)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        textContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textLabel).with.offset(-14)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.textLabel).with.offset(14)
        }
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.subtitleLabel.snp_bottom).with.offset(25)
            make.left.equalTo(self.containerView).with.offset(24)
            make.right.equalTo(self.containerView).with.offset(-24)
            make.bottom.equalTo(self.containerView).with.offset(-14)
        }
        
        
        
    }
    
}
