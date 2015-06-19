//
//  HereViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HereViewController: AbstractViewController, SpotDetailViewDelegate, ScheduleViewControllerDelegate, TimeFilterViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    var scheduleViewController : ScheduleViewController?
    var firstUseMessageVC : HereFirstUseViewController?
    var detailView: SpotDetailView
    var timeFilterView: TimeFilterView
    
    var statusBar : UIView
    var checkinButton : UIButton
    var searchButton : UIButton
    var searchFieldView : UIView
    var searchField : UITextField

    var activeSpot : ParkingSpot?
    var forceShowSpotDetails: Bool

    var delegate : HereViewControllerDelegate?
    var searchDelegate : SearchViewControllerDelegate?

    init() {
        detailView = SpotDetailView()
        timeFilterView = TimeFilterView()
        statusBar = UIView()
        checkinButton = UIButton()
        searchButton = UIButton()
        searchFieldView = UIView()
        searchField = UITextField()
        forceShowSpotDetails = false
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (Settings.firstMapUse()) {
            showFirstUseMessage()
            Settings.setFirstMapUsePassed(true)
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("HereViewController disappeared")
        hideScheduleView()
        hideSpotDetails()
    }
    
    func setupViews () {

        detailView.delegate = self
        view.addSubview(detailView)
        
        timeFilterView.delegate = self
        view.addSubview(timeFilterView)
        
        statusBar.backgroundColor = Styles.Colors.statusBar
        view.addSubview(statusBar)
        
        checkinButton.setImage(UIImage(named: "btn_checkin_active"), forState: UIControlState.Normal)
        checkinButton.setImage(UIImage(named: "btn_checkin"), forState: UIControlState.Disabled)
        checkinButton.addTarget(self, action: "checkinButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        checkinButton.enabled = false
        view.addSubview(checkinButton)

        searchButton.setImage(UIImage(named: "tabbar_search_active"), forState: UIControlState.Normal)
        searchButton.addTarget(self, action: "transformSearchButtonIntoField", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(searchButton)
        
        searchField.clearButtonMode = UITextFieldViewMode.Always
        searchField.backgroundColor = Styles.Colors.cream1
        searchField.font = Styles.FontFaces.light(16)
        searchField.textColor = Styles.Colors.midnight2
        searchField.textAlignment = NSTextAlignment.Natural
        searchField.delegate = self
        searchField.keyboardAppearance = UIKeyboardAppearance.Default
        searchField.keyboardType = UIKeyboardType.Default
        searchField.autocorrectionType = UITextAutocorrectionType.No
        searchField.returnKeyType = UIReturnKeyType.Search
        searchFieldView.addSubview(searchField)

        searchFieldView.clipsToBounds = false
        searchFieldView.layer.masksToBounds = false
        searchFieldView.backgroundColor = Styles.Colors.cream1
        searchFieldView.layer.borderWidth = 0
        searchFieldView.layer.borderColor = Styles.Colors.beige1.CGColor
        searchFieldView.layer.shadowColor = Styles.Colors.beige2.CGColor
        searchFieldView.layer.shadowOffset = CGSize(width: 0, height: 1)
        searchFieldView.layer.shadowRadius = CGFloat(Styles.Sizes.blurRadius)
        searchFieldView.layer.shadowOpacity = 1

        view.addSubview(searchFieldView)

    }
    
    func setupConstraints() {
        
        statusBar.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        detailView.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.view).with.offset(180)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.spotDetailViewHeight)
        }

        timeFilterView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(100)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(0)
        }
        
        checkinButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.view).with.offset(-Styles.Sizes.spotDetailViewHeight+30)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(0, 0))
        }
        
        searchButton.snp_makeConstraints{ (make) -> () in
            make.size.equalTo(CGSizeMake(36, 36))
            make.centerX.equalTo(self.view).multipliedBy(1.66)
            make.bottom.equalTo(self.view).with.offset(-30)
        }
        
        searchFieldView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(32)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.centerX.equalTo(self.view)
            make.width.equalTo(0)
        }

    }
    
    
    func showFirstUseMessage() {
        
        firstUseMessageVC = HereFirstUseViewController()
        
        self.addChildViewController(firstUseMessageVC!)
        self.view.addSubview(firstUseMessageVC!.view)
        firstUseMessageVC!.didMoveToParentViewController(self)
        
        firstUseMessageVC!.view.snp_makeConstraints({ (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissFirstUseMessage")
        firstUseMessageVC!.view.addGestureRecognizer(tap)
        
        firstUseMessageVC!.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.firstUseMessageVC!.view.alpha = 1.0
        })
    }
    
    func dismissFirstUseMessage() {
        
        if let firstUseMessageVC = self.firstUseMessageVC {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                firstUseMessageVC.view.alpha = 0.0
                }, completion: { (finished) -> Void in
                    firstUseMessageVC.removeFromParentViewController()
                    firstUseMessageVC.view.removeFromSuperview()
                    firstUseMessageVC.didMoveToParentViewController(nil)
                    self.firstUseMessageVC = nil
            })
            
        }
        
        
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
                make.top.equalTo(self.view.snp_bottom)
                make.size.equalTo(self.view)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
            })
            
            self.scheduleViewController!.view.layoutIfNeeded()
            
            
            self.scheduleViewController!.view.hidden = false
            self.scheduleViewController!.view.snp_remakeConstraints({ (make) -> () in
                make.edges.equalTo(self.view)
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
            return
        }
        
        self.scheduleViewController!.view.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.view.snp_bottom)
            make.size.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.scheduleViewController!.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                
                self.scheduleViewController!.view.removeFromSuperview()
                self.scheduleViewController!.willMoveToParentViewController(nil)
                self.scheduleViewController!.removeFromParentViewController()
                self.scheduleViewController = nil
        })
        
    }
    
    func checkinButtonTapped() {
        
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
        
        Settings.checkOut()
        
        SpotOperations.checkin(activeSpot!.identifier, completion: { (completed) -> Void in
            
            Settings.saveCheckInData(self.activeSpot!, time: NSDate())
            
            if (Settings.notificationTime() > 0) {
                Settings.cancelAlarm()
                Settings.scheduleAlarm(NSDate(timeIntervalSinceNow: self.activeSpot!.availableTimeInterval() - NSTimeInterval(Settings.notificationTime() * 60)))
            }
            
            SVProgressHUD.dismiss()
            self.delegate?.loadMyCarTab()
            
        })
        
        
    }
    
    func updateSpotDetails(spot: ParkingSpot?) {

        self.activeSpot = spot

        if spot != nil {
            
            forceShowSpotDetails = true
            
            if (activeSpot != nil) {
                println("selected spot : " + activeSpot!.identifier)
            }
            
            detailView.titleLabel.text = activeSpot?.name
            
            detailView.availableTimeLabel.text = activeSpot?.availableHourString(true)
            
            let checkedInSpotID = Settings.checkedInSpotId()
            if (activeSpot != nil && checkedInSpotID != nil) {
                checkinButton.enabled = checkedInSpotID != activeSpot?.identifier
            } else {
                checkinButton.enabled = true
            }
            
            hideSearchButton()
            
            showSpotDetails()
            
        } else {
            self.activeSpot = nil
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), {
                self.hideSpotDetails()
            })
        }
        
    }
    
    private func showSpotDetails (completed : ()) {
        
        detailView.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.view).with.offset(0)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        checkinButton.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.view).with.offset(-Styles.Sizes.spotDetailViewHeight+30)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }

        var animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.08, 0.93, 1]
        animation.duration = 0.3
        var timingFunctions: Array<CAMediaTimingFunction> = []
        for i in 0...animation.values.count {
            timingFunctions.append(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        animation.timingFunctions = timingFunctions
        animation.removedOnCompletion = true
        
        UIView.animateWithDuration(0.1,
            delay: 0.1,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.checkinButton.layoutIfNeeded()
            },
            completion: { (completed: Bool) -> Void in
                self.checkinButton.layer.addAnimation(animation, forKey: "scale")
        })
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.detailView.layoutIfNeeded()
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(20 * NSEC_PER_MSEC)), dispatch_get_main_queue(), {
            self.forceShowSpotDetails = false
        })

    }
    
    
    private func hideSpotDetails (completed : () ) {
        
        if (!forceShowSpotDetails) {
            detailView.snp_remakeConstraints {
                (make) -> () in
                make.bottom.equalTo(self.view).with.offset(180)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.height.equalTo(150)
            }
            
            checkinButton.snp_remakeConstraints { (make) -> () in
                make.bottom.equalTo(self.view).with.offset(-30)
                make.centerX.equalTo(self.view)
                make.size.equalTo(CGSizeMake(0, 0))
            }
            
            UIView.animateWithDuration(0.2,
                animations: { () -> Void in
                    self.checkinButton.layoutIfNeeded()
                    self.detailView.layoutIfNeeded()
                },
                completion: { (completed: Bool) -> Void in
                    self.checkinButton.snp_remakeConstraints { (make) -> () in
                        make.bottom.equalTo(self.view).with.offset(-Styles.Sizes.spotDetailViewHeight+30)
                        make.centerX.equalTo(self.view)
                        make.size.equalTo(CGSizeMake(0, 0))
                    }
                    self.showSearchButton(false)
            })
        }

    }
    
    func isSpotDetailsHidden() -> Bool {
        //we know if the view is hidden based on the bottom offset, as can be seen in the two methods above
        //make.bottom.equalTo(self.view).with.offset(180) is to hide it and 
        //make.bottom.equalTo(self.view).with.offset(0) is to show it

        for constraint: LayoutConstraint in detailView.snp_installedLayoutConstraints {
            if constraint.firstItem.isEqual(self.detailView)
            && (constraint.secondItem != nil && constraint.secondItem!.isEqual(self.view))
                && Float(constraint.constant) == 180 {
                    return true
            }
        }

        return false
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    func transformSearchButtonIntoField() {
        
        hideSearchButton()
        
        searchFieldView.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(32)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.view).with.offset(12)
            make.right.equalTo(self.view).with.offset(-12)
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.searchFieldView).with.offset(20)
            make.right.equalTo(self.searchFieldView)
            make.top.equalTo(self.searchFieldView)
            make.bottom.equalTo(self.searchFieldView)
        }
        
//        timeFilterView.snp_updateConstraints { (make) -> () in
//            make.height.equalTo(TimeFilterView.HEIGHT)
//        }
        
        searchFieldView.setNeedsLayout()
        searchField.setNeedsLayout()
        timeFilterView.setNeedsLayout()
        
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.searchFieldView.layoutIfNeeded()
                self.searchField.layoutIfNeeded()
                self.timeFilterView.layoutIfNeeded()
            },
            completion: { (completed:Bool) -> Void in
                self.searchField.becomeFirstResponder()
        })
        
    }

    func transformSearchFieldIntoButton() {
        
        searchField.snp_removeConstraints()

        searchFieldView.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(32)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.centerX.equalTo(self.view)
            make.width.equalTo(0)
        }

        searchField.snp_remakeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(0, 0))
            make.top.equalTo(self.searchFieldView)
            make.left.equalTo(self.searchFieldView)
        }
        
        timeFilterView.snp_updateConstraints { (make) -> () in
            make.height.equalTo(0)
        }
        
        searchFieldView.setNeedsLayout()
        searchField.setNeedsLayout()
        timeFilterView.setNeedsLayout()

        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.searchFieldView.layoutIfNeeded()
                self.searchField.layoutIfNeeded()
                self.timeFilterView.layoutIfNeeded()
            },
            completion: { (completed:Bool) -> Void in
                self.showSearchButton(false)
        })
        
    }

    
    // UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return self.searchFieldView.frame.size.width > 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        SearchOperations.searchByStreetName(textField.text, completion: { (results) -> Void in
            
            let today = DateUtil.dayIndexOfTheWeek()
            var date : NSDate = NSDate()
            
            self.searchDelegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text.isEmpty {
            endSearch(textField)
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        endSearch(textField)
        return true
    }
    
    func endSearch(textField: UITextField) {
        searchDelegate?.clearSearchResults()
        transformSearchFieldIntoButton()
        textField.endEditing(true)
    }
    
    // MARK: Helper Methods
    
    func hideSearchButton() {
        
        searchButton.snp_updateConstraints{ (make) -> () in
            make.size.equalTo(CGSizeMake(0, 0))
            make.centerX.equalTo(self.view).multipliedBy(1.66)
            make.bottom.equalTo(self.view).with.offset(-48)
        }
        animateSearchButton()
    }
    
    func showSearchButton(forceShow: Bool) {

        //only shows the button if the searchField is closed
        
        if !forceShow
            && (self.searchFieldView.frame.size.width > 0
                || !self.isSpotDetailsHidden()) {
                    return
        }
        
        searchButton.snp_updateConstraints{ (make) -> () in
            make.size.equalTo(CGSizeMake(36, 36))
            make.centerX.equalTo(self.view).multipliedBy(1.66)
            make.bottom.equalTo(self.view).with.offset(-30)
        }
        animateSearchButton()
    }
    
    func animateSearchButton() {
        searchButton.setNeedsLayout()
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.searchButton.layoutIfNeeded()
            },
            completion: { (completed:Bool) -> Void in
        })
    }

    
    // MARK:TimeFilterViewDelegate
    func filterValueWasChanged(#hours:Float?) {
        self.delegate?.updateMapAnnotations()
    }
    
}


protocol HereViewControllerDelegate {
    func loadMyCarTab()
    func updateMapAnnotations()
}
