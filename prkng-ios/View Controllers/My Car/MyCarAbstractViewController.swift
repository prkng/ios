//
//  MyCarAbstractViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 06/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarAbstractViewController: AbstractViewController, ReportViewControllerDelegate {

    var popupVC: PRKPopupViewController?

    func loadReportScreen(spotId : String?) {
        
        let reportViewController = ReportViewController()
        reportViewController.spotId = spotId
        reportViewController.delegate = self
        self.navigationController?.pushViewController(reportViewController, animated: true)
        
    }
    
    func reportDidEnd(success: Bool) {
        if success {
            showPopupForReportSuccess()
        }
    }
    
    func showPopupForReportSuccess() {
        
        popupVC = PRKPopupViewController(titleIconName: "icon_checkmark", titleText: "", subTitleText: "report_sent_thanks_title".localizedString, messageText: "report_sent_thanks_message".localizedString)
        
        self.addChildViewController(popupVC!)
        self.view.addSubview(popupVC!.view)
        popupVC!.didMoveToParentViewController(self)
        
        popupVC!.view.snp_makeConstraints(closure: { (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissPopup")
        popupVC!.view.addGestureRecognizer(tap)
        
        popupVC!.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.popupVC!.view.alpha = 1.0
        })
        
    }
    
    func dismissPopup() {
        
        if let popup = self.popupVC {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                popup.view.alpha = 0.0
                }, completion: { (finished) -> Void in
                    popup.removeFromParentViewController()
                    popup.view.removeFromSuperview()
                    popup.didMoveToParentViewController(nil)
                    self.popupVC = nil
            })
            
        }
        
        
    }
    
}
