//
//  HereViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HereViewController: AbstractViewController, SpotDetailViewDelegate, ScheduleViewControllerDelegate, CLLocationManagerDelegate {

    var scheduleViewController : ScheduleViewController?
    var detailView: SpotDetailView
    
    var checkinButton : UIButton
    
    var checkinMessageVC : CheckinMessageViewController?
    
    var activeSpot : ParkingSpot?
    
    var locationManager : CLLocationManager
    
    init() {
        detailView = SpotDetailView()
        checkinButton = UIButton()
        locationManager = CLLocationManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = TouchForwardingView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("HereViewController disappeared")
        hideScheduleView()
        hideSpotDetails()
    }
    
    func setupViews () {

        detailView.delegate = self
        self.view.addSubview(detailView)
        
        checkinButton.setImage(UIImage(named: "btn_checkin_active"), forState: UIControlState.Normal)
        checkinButton.setImage(UIImage(named: "btn_checkin"), forState: UIControlState.Disabled)
        checkinButton.addTarget(self, action: "checkinButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        checkinButton.enabled = false
        self.view.addSubview(checkinButton)
        
        detailView.snp_makeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(180)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        checkinButton.snp_makeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(-20)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }
    }
    
    func setupConstraints() {
        
    }
    
    
    func scheduleButtonTapped() {
        showScheduleView(activeSpot)
    }
    
    func showScheduleView(spot : ParkingSpot?) {
        
        if spot != nil {
            self.scheduleViewController = ScheduleViewController(spot: spot!)
            self.view.addSubview(self.scheduleViewController!.view)
            self.scheduleViewController!.willMoveToParentViewController(self)
            self.scheduleViewController!.delegate = self
            self.scheduleViewController!.view.hidden = true
            
            self.scheduleViewController!.view.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(self.view.snp_bottom);
                make.size.equalTo(self.view);
                make.left.equalTo(self.view);
                make.right.equalTo(self.view);
            })
            
            self.scheduleViewController!.view.layoutIfNeeded()
            
            
            self.scheduleViewController!.view.hidden = false
            self.scheduleViewController!.view.snp_remakeConstraints({ (make) -> () in
                make.edges.equalTo(self.view);
            })
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.scheduleViewController!.view.layoutIfNeeded()
                }, completion: { (Bool) -> Void in
                    //
            })
            
            
        }
    }
    
    
    func hideScheduleView () {
        
        if(self.scheduleViewController == nil) {
            return;
        }
        
        self.scheduleViewController!.view.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.view.snp_bottom);
            make.size.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.scheduleViewController!.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                
                self.scheduleViewController!.removeFromParentViewController()
                self.scheduleViewController = nil
        })
        
    }
    
    func checkinButtonTapped() {
        
        if (Settings.firstCheckin()) {
            showFirstCheckinMessage()
            return
        }
        
    }
    
    
    func showFirstCheckinMessage() {
    
        checkinMessageVC = CheckinMessageViewController()
        
        self.addChildViewController(checkinMessageVC!)
        self.view.addSubview(checkinMessageVC!.view)
        checkinMessageVC!.didMoveToParentViewController(self)
        
        checkinMessageVC!.view.snp_makeConstraints({ (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: "hideFirstCheckinMessage")
        checkinMessageVC!.view.addGestureRecognizer(tap)
        
        checkinMessageVC!.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.checkinMessageVC!.view.alpha = 1.0
        })
        
    }
    
    
    func hideFirstCheckinMessage () {
        
        if let checkinMessageVC = self.checkinMessageVC {
         
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                checkinMessageVC.view.alpha = 0.0
            }, completion: { (finished) -> Void in
                checkinMessageVC.removeFromParentViewController()
                checkinMessageVC.view.removeFromSuperview()
                checkinMessageVC.didMoveToParentViewController(nil)
                self.checkinMessageVC = nil
            })
            
        }
        
        
    }
    
    
    func showSpotDetails (completed : ()) {
        
        detailView.titleLabel.text = activeSpot?.name
        
        detailView.availableTimeLabel.text = activeSpot?.availableHourString()
        
        
        detailView.snp_remakeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(0)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        checkinButton.snp_remakeConstraints {
            (make) -> () in
            make.centerY.equalTo(self.detailView.snp_top)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }
        
        
        checkinButton.enabled = true
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        });
        
    }
    
    
    func hideSpotDetails (completed : () ) {
        
        detailView.snp_remakeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(180)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        checkinButton.snp_remakeConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(-20)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }
        
        checkinButton.enabled = false
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        });
        
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    
}
