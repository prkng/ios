//
//  PrkTabBar.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PrkTabBar: UIView {
    
    var hereButton : PrkTabBarButton
    var myCarButton : PrkTabBarButton
    var settingsButton : PrkTabBarButton
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var delegate : PrkTabBarDelegate?
    
    override init(frame: CGRect) {
        
        myCarButton = PrkTabBarButton(title: NSLocalizedString("tabbar_mycar", comment : ""), icon: UIImage(named: "tabbar_mycar"), selectedIcon: UIImage(named: "tabbar_mycar_active"))
         hereButton = PrkTabBarButton(title: NSLocalizedString("tabbar_here", comment : ""), icon: UIImage(named: "tabbar_here"), selectedIcon: UIImage(named: "tabbar_here_active"))
        settingsButton = PrkTabBarButton(title: NSLocalizedString("tabbar_settings", comment : ""), icon: UIImage(named: "tabbar_settings"), selectedIcon: UIImage(named: "tabbar_settings_active"))
        
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
        
        myCarButton.addTarget(self, action: #selector(PrkTabBar.myCarButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        myCarButton.isSelected = false
        addSubview(myCarButton)
        
        hereButton.addTarget(self, action: #selector(PrkTabBar.hereButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        hereButton.isSelected = false
        addSubview(hereButton)
        
        settingsButton.addTarget(self, action: #selector(PrkTabBar.settingsButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        settingsButton.isSelected = false
        addSubview(settingsButton)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        myCarButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(1.0/3.0)
        }

        hereButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.settingsButton.snp_left)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(1.0/3.0)
        }

        settingsButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(1.0/3.0)
        }
        
        
        didSetupConstraints = true
    }
    
    
    func deselectAll() {
        hereButton.isSelected = false
        myCarButton.isSelected = false
        settingsButton.isSelected = false
    }
    
    func updateSelected () {
        
        deselectAll()
        
        switch(self.delegate!.activeTab()) {
            
        case PrkTab.myCar :
            myCarButton.isSelected = true
            break
            
        case PrkTab.here :
            hereButton.isSelected = true
            break
            
        case PrkTab.settings :
            settingsButton.isSelected = true
            break
            
        default:
            break
            
        }
        
    }
    
    func myCarButtonTapped(_ button : PrkTabBarButton) {
        
        if(self.delegate != nil) {
            self.delegate!.loadMyCarTab()
        }
    }
    
    
    func hereButtonTapped(_ button : PrkTabBarButton) {
        
        if(self.delegate != nil) {
            self.delegate!.loadHereTab()
        }
    }
    

    func settingsButtonTapped(_ button : PrkTabBarButton) {
        
        if(self.delegate != nil) {
            self.delegate!.loadSettingsTab()
        }
    }
    
    
}


protocol PrkTabBarDelegate {
    func activeTab() -> PrkTab
    func loadHereTab()
    func loadMyCarTab()
    func loadSettingsTab()
}
