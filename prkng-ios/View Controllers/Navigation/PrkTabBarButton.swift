//
//  PrkTabBarButton.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PrkTabBarButton: UIControl {
   
    var iconView : UIImageView
    var titleLabel : UILabel
    var badge : UIView
    
    var title : String?
    var defaultIcon : UIImage?
    var selectedIcon : UIImage?
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    private var BADGE_WIDTH: CGFloat = 8
    
    convenience init(title: String, icon : UIImage?, selectedIcon : UIImage?) {
        
        self.init(frame: CGRectZero)
        
        self.title = title
        self.defaultIcon = icon
        self.selectedIcon = selectedIcon
        
    }
    
    
    override init(frame: CGRect) {
        
        iconView = UIImageView()
        titleLabel = UILabel()
        badge = UIView()
        
        didSetupSubviews = false
        didSetupConstraints = true
        
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()        
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        backgroundColor = Styles.Colors.stone
        addSubview(iconView)
        
        titleLabel.text = title
        titleLabel.font = Styles.FontFaces.regular(9)
        titleLabel.textColor = Styles.Colors.anthracite1
        titleLabel.textAlignment = NSTextAlignment.Center
        addSubview(titleLabel)
        
        badge.hidden = true
        badge.backgroundColor = Styles.Colors.red2
        badge.layer.cornerRadius = BADGE_WIDTH / 2.0
        addSubview(badge)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        self.iconView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerX.equalTo(self)
            make.top.equalTo(self).with.offset(7)
        }
        
        self.titleLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self)
            make.top.equalTo(self.iconView.snp_bottom).with.offset(3)
        }        
        
        self.badge.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(self.BADGE_WIDTH, self.BADGE_WIDTH))
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.snp_bottom)
        }
        
        didSetupConstraints = true
    }
    
    
    
    override var selected: Bool {
        
        didSet {
            
            if(selected) {
                iconView.image  = self.selectedIcon
                titleLabel.textColor = Styles.Colors.red2
            } else {
                iconView.image  = self.defaultIcon
                titleLabel.textColor = Styles.Colors.anthracite1
            }
            
        }
    }
    
    
}
