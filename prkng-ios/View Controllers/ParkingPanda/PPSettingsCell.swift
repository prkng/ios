//
//  PPSettingsCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-01-21.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import Foundation

//MARK: This class is THE instantiation of the ParkingPanda settings cell, so that we can change it independently of the SettingsViewController.

class PPSettingsCell: SettingsCell {
    
    init() {
        //TODO: the text below should be localized
        super.init(cellType: .Switch, switchValue: false, titleText: "Parking Panda", subtitleText: "Use ParkingPanda to reserve and pay for a parking spot in a garage or lot.")
        self.selectorsTarget = self
        self.canSelect = true
        self.cellSelector = "wasSelected"
    }
    
    var tableViewCell: UITableViewCell {
        let cell = SettingsSwitchCell()

        cell.titleText = self.titleText
        cell.subtitleText = self.subtitleText
        cell.switchOn = self.switchValue ?? false
        cell.selector = "ppSwitched"
        cell.selectorsTarget = self
        
        //add a right accessory
        cell.accessoryType = .DisclosureIndicator

        return cell
    }
    
    func ppSwitched() {
        //TODO: switching this should probably toggle something in actualy device Settings
        print("SWITCHEDDDD")
    }
        
    func wasSelected() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let rootVC = appDelegate.window?.rootViewController {
            let ppSettingsVC = PPSettingsViewController()
            if let navVC = rootVC.navigationController {
                navVC.pushViewController(ppSettingsVC, animated: true)
            } else {
                rootVC.presentViewController(ppSettingsVC, animated: true, completion: nil)
            }
        }
    }
    
}
