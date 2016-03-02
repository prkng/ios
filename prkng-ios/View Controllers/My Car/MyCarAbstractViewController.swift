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
    
    //MARK: common view-based code

    var segmentedControl = ViewFactory.nowOrHistorySwitch()
    
    var activeVC: UIViewController?
    var historyVC = HistoryViewController()
    var ppTransactionsVC = PPTransactionsViewController()
    
    func segmentedControlTapped(index: UInt) {
        
        let removeActiveVC = {
            if self.activeVC != nil {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.activeVC!.view.alpha = 0.0
                    }, completion: { (completed) -> Void in
                        self.activeVC!.removeFromParentViewController()
                        self.activeVC!.view.removeFromSuperview()
                        self.activeVC!.willMoveToParentViewController(nil)
                        self.activeVC = nil
                })
            }
        }
        
        let attachActiveVC = {
            if self.activeVC != nil {
                self.activeVC!.view.alpha = 0.0
                self.activeVC!.willMoveToParentViewController(self)
                self.addChildViewController(self.activeVC!)
                self.view.addSubview(self.activeVC!.view)
                
                self.activeVC!.view.snp_remakeConstraints(closure: { (make) -> () in
                    make.edges.equalTo(self.view)
                })
                
                self.view.bringSubviewToFront(self.segmentedControl)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.activeVC!.view.alpha = 1.0
                })
            }
        }
        
        if index == 0 {
            //transition to NOW
            if activeVC != nil {
                removeActiveVC()
                let tracker = GAI.sharedInstance().defaultTracker
                tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Checked In", action: "Top Slider Value Changed", label: "Now", value: nil).build() as [NSObject: AnyObject])
            }
        } else if index == 1 {
            //transition to HISTORY
            if activeVC != historyVC {
                removeActiveVC()
                activeVC = historyVC
                attachActiveVC()
                let tracker = GAI.sharedInstance().defaultTracker
                tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Checked In", action: "Top Slider Value Changed", label: "History", value: nil).build() as [NSObject: AnyObject])

            }
        } else if index == 2 {
            //transition to TRANSACTIONS
            if activeVC != ppTransactionsVC {
                ppTransactionsVC = PPTransactionsViewController()
                removeActiveVC()
                activeVC = ppTransactionsVC
                attachActiveVC()
                let tracker = GAI.sharedInstance().defaultTracker
                tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Checked In", action: "Top Slider Value Changed", label: "Reservations", value: nil).build() as [NSObject: AnyObject])
                
            }
        }
    }
    
}

protocol MyCarAbstractViewControllerDelegate {
    func loadHereTab()
    func loadSearchInHereTab()
    func reloadMyCarTab()
    func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, showing: Bool)
}
