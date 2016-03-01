//
//  PPTransactionViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-25.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit

class PPTransactionViewController: UIViewController, PPTransactionViewDelegate {

    private var transactionView: PPTransactionView
    
    init(transaction: ParkingPandaTransaction, lot: Lot?) {
        transactionView = PPTransactionView(transaction: transaction, lot: nil)
        super.init(nibName: nil, bundle: nil)

        transactionView.viewController = self
        transactionView.delegate = self
        view.addSubview(transactionView)
        transactionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentWithVC(vc: UIViewController?) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let rootVC = vc ?? appDelegate.window?.rootViewController {
            if let navVC = rootVC.navigationController {
                navVC.pushViewController(self, animated: true)
            } else {
                rootVC.presentViewController(self, animated: true, completion: nil)
            }
        }
        
    }

    func tappedBackButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
