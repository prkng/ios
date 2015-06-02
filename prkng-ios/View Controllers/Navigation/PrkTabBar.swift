//
//  PrkTabBar.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PrkTabBar: UIView {
    
//    var searchButton : PrkTabBarButton
    var hereButton : PrkTabBarButton
    var myCarButton : PrkTabBarButton
    var settingsButton : PrkTabBarButton
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var delegate : PrkTabBarDelegate?
    
    override init(frame: CGRect) {
        
//        searchButton = PrkTabBarButton(title: NSLocalizedString("tabbar_search", comment : ""), icon: UIImage(named: "tabbar_search"), selectedIcon: UIImage(named: "tabbar_search_active"))
       
        myCarButton = PrkTabBarButton(title: NSLocalizedString("tabbar_mycar", comment : ""), icon: UIImage(named: "tabbar_mycar"), selectedIcon: UIImage(named: "tabbar_mycar_active"))
         hereButton = PrkTabBarButton(title: NSLocalizedString("tabbar_here", comment : ""), icon: UIImage(named: "tabbar_here"), selectedIcon: UIImage(named: "tabbar_here_active"))
        settingsButton = PrkTabBarButton(title: NSLocalizedString("tabbar_settings", comment : ""), icon: UIImage(named: "tabbar_settings"), selectedIcon: UIImage(named: "tabbar_settings_active"))
        
        didSetupSubviews = false
        didSetupConstraints = false
        
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func updateConstraints() {
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
//        searchButton.addTarget(self, action: "searchButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
//        searchButton.selected = false
//        addSubview(searchButton)
        
        myCarButton.addTarget(self, action: "myCarButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        myCarButton.selected = false
        addSubview(myCarButton)
        
        hereButton.addTarget(self, action: "hereButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        hereButton.selected = false
        addSubview(hereButton)
        
        settingsButton.addTarget(self, action: "settingsButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButton.selected = false
        addSubview(settingsButton)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
    
        
//        searchButton.snp_makeConstraints { (make) -> () in
//            make.left.equalTo(self)
//            make.top.equalTo(self)
//            make.bottom.equalTo(self)
//            make.width.equalTo(self).multipliedBy(0.25)
//        }
//        
//        hereButton.snp_makeConstraints { (make) -> () in
//            make.left.equalTo(self.searchButton.snp_right)
//            make.top.equalTo(self)
//            make.bottom.equalTo(self)
//            make.width.equalTo(self).multipliedBy(0.25)
//        }
//        
//        myCarButton.snp_makeConstraints { (make) -> () in
//            make.right.equalTo(self.settingsButton.snp_left)
//            make.top.equalTo(self)
//            make.bottom.equalTo(self)
//            make.width.equalTo(self).multipliedBy(0.25)
//        }
//        
//        settingsButton.snp_makeConstraints { (make) -> () in
//            make.right.equalTo(self)
//            make.top.equalTo(self)
//            make.bottom.equalTo(self)
//            make.width.equalTo(self).multipliedBy(0.25)
//        }
//        
        
        // uncomment above for search button
        
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
//        searchButton.selected = false
        hereButton.selected = false
        myCarButton.selected = false
        settingsButton.selected = false
    }
    
    func updateSelected () {
        
        deselectAll()
        
        switch(self.delegate!.activeTab()) {
            
//        case PrkTab.Search :
//            searchButton.selected = true
//            break
            
        case PrkTab.MyCar :
            myCarButton.selected = true
            break
            
        case PrkTab.Here :
            hereButton.selected = true
            break
            
        case PrkTab.Settings :
            settingsButton.selected = true
            break
            
        default:
            break
            
        }
        
    }
    
    
//    func searchButtonTapped(button : PrkTabBarButton) {
//        
//        if(self.delegate != nil) {
//            self.delegate!.loadSearchTab()
//        }
//    }
    
    func myCarButtonTapped(button : PrkTabBarButton) {
        
        if(self.delegate != nil) {
            self.delegate!.loadMyCarTab()
        }
    }
    
    
    func hereButtonTapped(button : PrkTabBarButton) {
        
        if(self.delegate != nil) {
            self.delegate!.loadHereTab()
        }
    }
    

    func settingsButtonTapped(button : PrkTabBarButton) {
        
        if(self.delegate != nil) {
            self.delegate!.loadSettingsTab()
        }
    }
    
    
}


protocol PrkTabBarDelegate {
    func activeTab() -> PrkTab
//    func loadSearchTab()
    func loadHereTab()
    func loadMyCarTab()
    func loadSettingsTab()
}