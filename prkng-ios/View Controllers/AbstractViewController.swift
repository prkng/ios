//
//  AbstractViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 05/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AbstractViewController: GAITrackedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var transitionView: UIView?
    func removeTransitionView() {
        //remove the transition view if it exists
        transitionView?.removeFromSuperview()
        transitionView = nil
    }
    
    func addTransitionView() {
        //create and add the transition view: A screenshot of the current UIScreen
        removeTransitionView()
        transitionView = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(true)
        self.view.addSubview(transitionView!)
    }

}
