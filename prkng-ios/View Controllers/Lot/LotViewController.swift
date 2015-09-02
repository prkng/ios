//
//  LotViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LotViewController: PRKModalDelegatedViewController, ModalHeaderViewDelegate, PRKVerticalGestureRecognizerDelegate {
    
//    var delegate : PRKModalViewControllerDelegate?
    var spot : ParkingSpot
    var parentView: UIView
    
    private var headerView : ModalHeaderView
    private var verticalRec: PRKVerticalGestureRecognizer
    private(set) var HEADER_HEIGHT : CGFloat = Styles.Sizes.modalViewHeaderHeight
    
    
    init(spot: ParkingSpot, view: UIView) {
        self.spot = spot
        self.parentView = view
        headerView = ModalHeaderView()
        verticalRec = PRKVerticalGestureRecognizer()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        headerView.titleLabel.text = spot.name
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView() {
        self.view = UIView()
        view.backgroundColor = Styles.Colors.stone
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        
        view.addSubview(headerView)
        headerView.delegate = self
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        
        let scheduleVC = ScheduleViewController(spot: spot, view: view)
        let agendaListVC = AgendaListViewController(spot: spot, view: view)
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self
        
        view.bringSubviewToFront(headerView)
        
    }
    
    func setupConstraints() {
        
//        pageViewController.view.snp_makeConstraints { (make) -> () in
//            make.edges.equalTo(self.view)
//        }
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.HEADER_HEIGHT)
        }
        
    }
    
    //MARK: Helper methods
    
    func shouldShowSchedule() -> Bool {
        
        let defaultModalView = (NSUserDefaults.standardUserDefaults().valueForKey("DEFAULT_MODAL_VIEW") as? Int) ?? 0
        
        switch defaultModalView {
        case 0:
            return true
        case 1:
            return false
        default:
            return true
        }
        
    }
    
    func updateHeader(viewController: PRKModalViewControllerChild) {
        let isSchedule = viewController is ScheduleViewController
        if isSchedule {
            headerView.makeRightButtonList(true)
        } else {
            headerView.makeRightButtonColumns(true)
        }
    }
    
    
    //MARK: ModalHeaderViewDelegate
    
    func tappedBackButton() {
        self.delegate?.hideModalView()
    }
    
    func tappedRightButton() {
        tappedBackButton()
    }
    
    
    //MARK: PRKVerticalGestureRecognizerDelegate methods
    
    func swipeDidBegin() {
        
    }
    
    func swipeInProgress(yDistanceFromBeginTap: CGFloat) {
        if yDistanceFromBeginTap < 0 {
            self.delegate?.shouldAdjustTopConstraintWithOffset(-yDistanceFromBeginTap, animated: false)
        }
    }
    
    func swipeDidEndUp() {
        self.delegate?.shouldAdjustTopConstraintWithOffset(0, animated: true)
    }
    
    func swipeDidEndDown() {
        self.delegate?.hideModalView()
    }
    
    
    //NOTE: we use this to flip the icon between transitions. the method above will ensure we always end up with the right header icon
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        
        if let fromViewController = previousViewControllers[0] as? PRKModalViewControllerChild {
            if !completed {
                updateHeader(fromViewController)
            }
        }
        
    }
    
}
