//
//  PPSettingsCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-01-21.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import Foundation
import SVProgressHUD

//MARK: This class is THE instantiation of the ParkingPanda settings cell, so that we can change it independently of the SettingsViewController.

class PPSettingsCell: SettingsCell {
    
    override var switchValue: Bool? {
        get {
            let ppCreds = Settings.getParkingPandaCredentials()
            return ppCreds.0 != nil && ppCreds.1 != nil
        }
        set(value) {
            //do nothing! Muahaha! Converting a get/set property to a get-only property!
        }
    }
    
    init() {
        super.init()
        self.switchValue = false
        self.titleTexts.append("parking_panda".localizedString)
        self.subtitleText.append("pp_cell_text".localizedString)
        self.selectorsTarget = self
        self.canSelect = true
        self.cellSelector = "wasSelected"
        let ppCreds = Settings.getParkingPandaCredentials()
        self.switchValue = ppCreds.0 != nil && ppCreds.1 != nil
    }
    
    var tableViewCell: UITableViewCell {
        let cell = SettingsSwitchCell(rightSideText: nil, selectorsTarget: self, selector: "ppSwitched", buttonSelector: nil, reuseIdentifier: "parking_panda_cell")

        cell.titleText = self.titleText
        cell.subtitleText = self.subtitleText
        cell.switchOn = self.switchValue ?? false
        
        //add a right accessory
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    func ppSwitched() {
        if switchValue == true {
            //if we're switching OFF then log out
            ParkingPandaOperations.logout()
        } else {
            //if we're switching ON then do the same thing as a selection
            wasSelected()
        }
    }
        
    func wasSelected() {
        
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.show()
        
        ParkingPandaOperations.login(username: nil, password: nil, includeCreditCards: true) { (user, error) -> Void in
            
            if user != nil {
              
                ParkingPandaOperations.getCreditCards(user!) { (creditCards, error) -> Void in
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        SVProgressHUD.dismiss()
                        let ppSettingsVC = PPSettingsViewController(user: user!, creditCards: creditCards)
                        ppSettingsVC.presentWithVC(nil)
                    })
                }
                
            } else {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    SVProgressHUD.dismiss()
                })

                if let ppError = error {
                    switch (ppError.errorType) {
                    case .api, .internal:
                        ParkingPandaOperations.logout()
                        let ppIntroVC = PPIntroViewController()
                        ppIntroVC.presentWithVC(nil)
                    case .noError, .network:
                        break
                    }
                }
            }
            
        }
        
    }
    
}
