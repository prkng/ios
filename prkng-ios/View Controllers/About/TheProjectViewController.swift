//
//  TheProjectViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 18/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TheProjectViewController: AbstractViewController {
    let backgroundImageView = UIImageView(image: UIImage(named: "bg_login"))
    let logoView = UIImageView(image: UIImage(named: "logo_opening"))
    let scrollView = UIScrollView()
    let container = UIView()
    let titleLabel = UILabel()
    let textLabel1 = UILabel()
    let textLabel2 = UILabel()
    let backButton = ViewFactory.redBackButton()
    
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        
        view.addSubview(backgroundImageView)
        view.addSubview(logoView)
        view.addSubview(scrollView)
        
        container.backgroundColor = Styles.Colors.stone
        view.addSubview(container)
        
        titleLabel.font = Styles.FontFaces.light(12)
        titleLabel.textColor = Styles.Colors.midnight1
        titleLabel.textAlignment = .Center
        titleLabel.text = "the_project".localizedString.uppercaseString
        view.addSubview(titleLabel)
        
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
    }
    
    
    func setupConstraints() {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).with.offset(90)
        }
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view).with.offset(UIEdgeInsetsMake(202, 0, 0, 0))
        }
        
        container.snp_makeConstraints { (make) -> () in
             make.edges.equalTo(self.scrollView)
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width)
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.container).width.offset(20)
            make.left.equalTo(self.container)
            make.right.equalTo(self.container)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 80, height: 26))
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).with.offset(-20)
        }
        
    }
    
    func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
