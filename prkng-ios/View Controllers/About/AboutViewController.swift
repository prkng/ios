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
    let backButton = ViewFactory.roundedRedBackButton()
    
    var groupedCheckins : Dictionary<String, Array<Checkin>>?
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
        
    func setupViews() {
        
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        
        view.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .center
        titleLabel.text = "about".localizedString
        view.addSubview(titleLabel)
        
        faqButton.setTitle("faq".localizedString, for: UIControlState())
        faqButton.addTarget(self, action: #selector(AboutViewController.faqButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(faqButton)

        termsButton.setTitle("terms_conditions".localizedString, for: UIControlState())
        termsButton.addTarget(self, action: #selector(AboutViewController.termsButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(termsButton)

        shareButton.setTitle("share".localizedString, for: UIControlState())
        shareButton.addTarget(self, action: #selector(AboutViewController.shareButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(shareButton)

        backButton.addTarget(self, action: #selector(AboutViewController.backButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    
    func setupConstraints() {
        
        let viewHeight = UIScreen.main.bounds.size.height - CGFloat(Styles.Sizes.tabbarHeight)
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        iconView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(viewHeight * 0.14)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 68, height: 68))
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.iconView.snp_bottom).offset(12)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        faqButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).offset(viewHeight * 0.08)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        termsButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.faqButton.snp_bottom).offset(viewHeight * 0.05)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        shareButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.termsButton.snp_bottom).offset(viewHeight * 0.05)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 80, height: 26))
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-20)
        }
        
    }
    
    
    //MARK: Button Handlers
    func faqButtonTapped(_ sender: UIButton) {
        let webViewController = PRKWebViewController(englishUrl: "https://prk.ng/faq/", frenchUrl: "https://prk.ng/fr/faq/")
        self.navigationController?.pushViewController(webViewController, animated: true)
        
    }
    
    func termsButtonTapped(_ sender: UIButton) {
        let webViewController = PRKWebViewController(englishUrl: "https://prk.ng/terms/", frenchUrl: "https://prk.ng/fr/conditions/")
        self.navigationController?.pushViewController(webViewController, animated: true)
        
    }
    
    func privacyButtonTapped(_ sender: UIButton) {
        let webViewController = PRKWebViewController(englishUrl: "https://prk.ng/privacypolicy", frenchUrl: "https://prk.ng/fr/politique")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func shareButtonTapped(_ sender: UIButton) {
        
        let text = "prkng_share_copy".localizedString
        let url = URL(string:"https://prk.ng/")!
        
        let activityViewController = UIActivityViewController( activityItems: [text, url], applicationActivities: nil)
        self.navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
