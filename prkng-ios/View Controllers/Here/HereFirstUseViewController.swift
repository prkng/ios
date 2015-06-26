//
//  HereFirstUseViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 28/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HereFirstUseViewController: GAITrackedViewController {

    var containerView: UIView
    
    
    var iconView : UIImageView
    
    var titleContainer : UIView
    var titleLabel : UILabel
    var subtitleLabel : UILabel
    
    var imageView : UIImageView
    var imageTextLabel : UILabel
    
    var textContainer1 : UIView
    var textLabel1 : UILabel
    
    var icon2View : UIImageView
    
    var textContainer2 : UIView
    var textLabel2 : UILabel
    
    init() {

        containerView = UIView()
        
        iconView = UIImageView()
        
        imageView = UIImageView()
        
        titleContainer = UIView()
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        
        imageView = UIImageView()
        imageTextLabel = UILabel ()
        
        textContainer1 = UIView()
        textLabel1 = UILabel()
        
        icon2View = UIImageView()
        
        textContainer2 = UIView()
        textLabel2 = UILabel()
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
        self.screenName = "Here - First Use View"
    }
    
    func setupSubviews() {
        
        view.backgroundColor = UIColor(red: 48.0/255.0, green: 58/255.0, blue: 66/255.0, alpha: 0.9)
        
        view.addSubview(containerView)
        
        titleContainer.backgroundColor = Styles.Colors.cream2
        containerView.addSubview(titleContainer)
        
        iconView.image = UIImage(named: "icon_howto_compass")
        containerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.petrol2
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "here_firstuse_title".localizedString
        containerView.addSubview(titleLabel)
        
        subtitleLabel.font = Styles.FontFaces.regular(17)
        subtitleLabel.textColor = Styles.Colors.red2
        subtitleLabel.textAlignment = NSTextAlignment.Center
        subtitleLabel.text = "here_firstuse_subtitle".localizedString
        containerView.addSubview(subtitleLabel)
        
        textContainer1.backgroundColor = Styles.Colors.cream2
        textContainer1.layer.borderColor = Styles.Colors.beige1.CGColor
        textContainer1.layer.borderWidth = 0.5
        containerView.addSubview(textContainer1)
        
        imageView.image =  UIImage(named:"icon_howto_freespots")
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        textContainer1.addSubview(imageView)
        
        imageTextLabel.font = Styles.FontFaces.regular(11)
        imageTextLabel.textColor = Styles.Colors.anthracite1
        textContainer1.addSubview(imageTextLabel)
        
        imageTextLabel.font = Styles.FontFaces.regular(11)
        imageTextLabel.text = "free_spots".localizedString.uppercaseString
        textContainer1.addSubview(imageTextLabel)
        
        textLabel1.font = Styles.FontFaces.light(17)
        textLabel1.textColor = Styles.Colors.petrol2
        textLabel1.numberOfLines = 0
        textLabel1.textAlignment = NSTextAlignment.Center
        textLabel1.text = "here_firstuse_1".localizedString
        containerView.addSubview(textLabel1)
        
        textContainer2.backgroundColor = Styles.Colors.cream2
        containerView.addSubview(textContainer2)
        
        
        textLabel2.font = Styles.FontFaces.light(17)
        textLabel2.textColor = Styles.Colors.petrol2
        textLabel2.numberOfLines = 0
        textLabel2.textAlignment = NSTextAlignment.Center
        textLabel2.text = "here_firstuse_2".localizedString
        textContainer2.addSubview(textLabel2)
        
        icon2View.image = UIImage(named: "icon_howto_checkin")
        textContainer2.addSubview(icon2View)
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.view)
            make.left.equalTo(self.view).with.offset(24)
            make.right.equalTo(self.view).with.offset(-24)
        }
        
        titleContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.subtitleLabel).with.offset(10)
        }
        

        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainer).with.offset(25)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        
        subtitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).with.offset(7)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        iconView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.centerY.equalTo(self.containerView.snp_top)
            make.size.equalTo(CGSizeMake(36, 36))
        }
        
        textContainer1.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainer.snp_bottom)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.textLabel1).with.offset(29)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textContainer1).with.offset(21)
            make.left.equalTo(self.textContainer1)
            make.right.equalTo(self.textContainer1)
        }
        
        imageTextLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.imageView.snp_bottom).with.offset(3)
            make.centerX.equalTo(self.textContainer1)
        }
        
        textLabel1.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.imageTextLabel.snp_bottom).with.offset(9)
            make.left.equalTo(self.textContainer1).with.offset(24)
            make.right.equalTo(self.textContainer1).with.offset(-24)
        }
        
        
        textContainer2.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textContainer1.snp_bottom)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
        }
        
        icon2View.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.textContainer2)
            make.centerY.equalTo(self.textContainer2.snp_top)
            make.size.equalTo(CGSizeMake(36, 36))
        }
        
        textLabel2.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textContainer2).with.offset(29)
            make.left.equalTo(self.textContainer2).with.offset(24)
            make.right.equalTo(self.textContainer2).with.offset(-24)
            make.bottom.equalTo(self.textContainer2).with.offset(-22)
        }
        
        
    }
    
}
