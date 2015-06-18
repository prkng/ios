//
//  AboutViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 17/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AboutViewController: AbstractViewController {
    
    let iconView = UIImageView(image: UIImage(named: "icon_history"))
    let titleLabel = UILabel()
    let projectButton = UIButton()
    let termsButton = UIButton()
    let shareButton = UIButton()
    let backButton = UIButton()
    
    var groupedCheckins : Dictionary<String, Array<Checkin>>?
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
        
    func setupViews() {
        
        view.backgroundColor = Styles.Colors.midnight2
        
        view.addSubview(iconView)
        
        titleLabel.font = Styles.FontFaces.light(29)
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .Center
        titleLabel.text = "about".localizedString
        view.addSubview(titleLabel)
        
        
        projectButton.setTitle("the_project".localizedString, forState: .Normal)
        
    }
    
    
    func setupConstraints() {
        
        iconView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(48)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(68, 68))
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.iconView.snp_bottom).with.offset(12)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
    }
    
    
    //MARK: Button Handlers
    
    func backButtonTapped(sender: UIButton) {
        
    }
    
}
