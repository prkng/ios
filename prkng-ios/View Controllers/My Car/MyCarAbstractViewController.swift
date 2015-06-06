//
//  MyCarAbstractViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 06/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarAbstractViewController: AbstractViewController {


    func loadReportScreen(spotId : String?) {
        
        let reportViewController = ReportViewController()
        reportViewController.spotId = spotId
        self.navigationController?.pushViewController(reportViewController, animated: true)
        
    }
    
}
