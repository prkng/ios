//
//  AboutViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 17/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AboutViewController: AbstractViewController {

    let backgroundImageView = UIImageView(image: UIImage(named:"bg_blue_gradient"))
    
    let iconView = UIImageView(image: UIImage(named: "icon_about"))
    let titleLabel = UILabel()
    let faqButton = ViewFactory.bigTransparentButton()
    let termsButton = ViewFactory.bigTransparentButton()
    let shareButton = ViewFactory.bigTransparentButton()
    let backButton = ViewFactory.redBackButton()
    
    var groupedCheckins : Dictionary<String, Array<Checkin>>?
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
        
    func setupViews() {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        view.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .Center
        titleLabel.text = "about".localizedString
        view.addSubview(titleLabel)
        
        faqButton.setTitle("faq".localizedString, forState: .Normal)
        faqButton.addTarget(self, action: "faqButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(faqButton)

        termsButton.setTitle("terms_conditions".localizedString, forState: .Normal)
        termsButton.addTarget(self, action: "termsButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(termsButton)
        
        shareButton.setTitle("share".localizedString, forState: .Normal)
        shareButton.addTarget(self, action: "shareButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(shareButton)
        
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
    }
    
    
    func setupConstraints() {
        
        let viewHeight = UIScreen.mainScreen().bounds.size.height - CGFloat(Styles.Sizes.tabbarHeight)
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        iconView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(viewHeight * 0.14)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(68, 68))
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.iconView.snp_bottom).with.offset(12)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        faqButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).with.offset(viewHeight * 0.08)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        termsButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.faqButton.snp_bottom).with.offset(viewHeight * 0.05)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        shareButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.termsButton.snp_bottom).with.offset(viewHeight * 0.05)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 80, height: 26))
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).with.offset(-20)
        }
        
    }
    
    
    //MARK: Button Handlers
    func faqButtonTapped(sender: UIButton) {
        self.navigationController?.pushViewController(FAQViewController(), animated: true)
    }
    
    func termsButtonTapped(sender: UIButton) {
        self.navigationController?.pushViewController(TermsViewController(), animated: true)
    }
    
    func shareButtonTapped(sender: UIButton) {
        
        let text = "prkng_share_copy".localizedString
        let url = NSURL(string:"http://prk.ng/")!
        
        let activityViewController = UIActivityViewController( activityItems: [text, url], applicationActivities: nil)
        self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
