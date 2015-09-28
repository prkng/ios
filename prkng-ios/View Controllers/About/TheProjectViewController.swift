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
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        view.addSubview(logoView)
        view.addSubview(scrollView)
        
        container.backgroundColor = Styles.Colors.stone
        scrollView.addSubview(container)
        
        titleLabel.font = Styles.FontFaces.light(12)
        titleLabel.textColor = Styles.Colors.midnight1
        titleLabel.textAlignment = .Center
        titleLabel.text = "the_project".localizedString.uppercaseString
        container.addSubview(titleLabel)
        
        textLabel1.font = Styles.FontFaces.light(17)
        textLabel1.textColor = Styles.Colors.red2
        textLabel1.textAlignment = .Justified
        textLabel1.text = "the_project_part_one".localizedString
        textLabel1.numberOfLines = 0
        container.addSubview(textLabel1)
        
        textLabel2.font = Styles.FontFaces.light(14)
        textLabel2.textColor = Styles.Colors.midnight2
        textLabel2.textAlignment = .Justified
        textLabel2.text = "the_project_part_two".localizedString
        textLabel2.numberOfLines = 0
        container.addSubview(textLabel2)
        
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
    }
    
    
    func setupConstraints() {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(90)
        }
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view).offset(UIEdgeInsetsMake(202, 0, 0, 0))
        }
        
        container.snp_makeConstraints { (make) -> () in
             make.edges.equalTo(self.scrollView)
             make.width.equalTo(UIScreen.mainScreen().bounds.size.width)
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.container).offset(20)
            make.left.equalTo(self.container)
            make.right.equalTo(self.container)
        }
        
        textLabel1.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).offset(14)
            make.left.equalTo(self.container).offset(40)
            make.right.equalTo(self.container).offset(-40)
        }
        
        textLabel2.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textLabel1.snp_bottom).offset(10)
            make.left.equalTo(self.container).offset(40)
            make.right.equalTo(self.container).offset(-40)
            make.bottom.equalTo(self.container).offset(-51)
        }
        
        
        backButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 80, height: 26))
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-20)
        }
        
    }
    
    func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
