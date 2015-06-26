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
    
    var searchFilterView: SearchFilterView
    var timeFilterView: TimeFilterView
    var showingFilters: Bool
    
    var statusBar : UIView
    var filterButton : PRKTextButton

    var activeSpot : ParkingSpot?
    var forceShowSpotDetails: Bool

    private var filterButtonImageName: String
    private var filterButtonText: String
    
    var delegate : HereViewControllerDelegate?

    init() {
        detailView = SpotDetailView()
        timeFilterView = TimeFilterView()
        searchFilterView = SearchFilterView()
        showingFilters = false
        statusBar = UIView()
        filterButton = PRKTextButton(image: nil, imageSize: CGSizeMake(36, 36), labelText: "")
        filterButtonImageName = "icon_filter"
        filterButtonText = ""
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Here - General View"
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
        
        view.addSubview(searchFilterView)

        timeFilterView.delegate = self
        view.addSubview(timeFilterView)
        
        statusBar.backgroundColor = Styles.Colors.statusBar
        view.addSubview(statusBar)
        
        filterButton.setImage(UIImage(named: filterButtonImageName))
        filterButton.addTarget(self, action: "toggleFilterButton", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(filterButton)
        
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

        searchFilterView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(0)
        }

        timeFilterView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.searchFilterView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(0)
        }
        
        filterButton.snp_makeConstraints{ (make) -> () in
            make.size.greaterThanOrEqualTo(CGSizeMake(36, 36))
            make.right.equalTo(self.view.snp_centerX).multipliedBy(1.66).with.offset(18)
            make.bottom.equalTo(self.view).with.offset(-30)
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
    
    func topContainerTapped() {
        checkin()
    }
    
    func bottomContainerTapped() {
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
    
    func checkin() {
        
        //OLD RULE FOR WHETHER WE COULD/COULDN'T CHECK-IN:
        //            let checkedInSpotID = Settings.checkedInSpotId()
        //            if (activeSpot != nil && checkedInSpotID != nil) {
        //                checkinButton.enabled = checkedInSpotID != activeSpot?.identifier
        //            } else {
        //                checkinButton.enabled = true
        //            }

        
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
            
            let interval = activeSpot?.availableTimeInterval()
            if (interval > 2*3600) { // greater than 2 hours = show available until... by default
                detailView.availableTextLabel.text = NSLocalizedString("until", comment: "").uppercaseString
                detailView.availableTimeLabel.attributedText = ParkingSpot.availableUntilAttributed(interval!, firstPartFont: Styles.Fonts.h2r, secondPartFont: Styles.FontFaces.light(16))
            } else {
                detailView.availableTextLabel.text = NSLocalizedString("for", comment: "").uppercaseString
                detailView.availableTimeLabel.attributedText = ParkingSpot.availableMinutesStringAttributed(interval!, font: Styles.Fonts.h2r)
            }
            
            detailView.checkinImageView.layer.wigglewigglewiggle()

            hideFilters(alsoHideFilterButton: true)
            
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
            make.height.equalTo(Styles.Sizes.spotDetailViewHeight)
        }
        
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
                make.height.equalTo(Styles.Sizes.spotDetailViewHeight)
            }
            
            UIView.animateWithDuration(0.2,
                animations: { () -> Void in
                    self.detailView.layoutIfNeeded()
                },
                completion: { (completed: Bool) -> Void in
                    self.showFilterButton(false)
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
    
    func toggleFilterButton() {
        
        if showingFilters {
            hideFilters(alsoHideFilterButton: false)
        } else {
            showFilters()
        }
    }
    
    func showFilters() {
        
        //whenever it's shown, reset the filter
        timeFilterView.resetValue()
        
        searchFilterView.snp_updateConstraints { (make) -> () in
            make.height.equalTo(SearchFilterView.TOTAL_HEIGHT)
        }

        timeFilterView.snp_updateConstraints { (make) -> () in
            make.height.equalTo(TimeFilterView.TOTAL_HEIGHT)
        }

        timeFilterView.setNeedsLayout()
        searchFilterView.setNeedsLayout()
        
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                //also, make the status bar transparent
                self.statusBar.alpha = 0

                self.filterButtonText = ""
                self.filterButton.setLabelText(self.filterButtonText)
                
                self.filterButtonImageName = "icon_filter_close"
                self.filterButton.setImage(UIImage(named: self.filterButtonImageName))

                self.timeFilterView.layoutIfNeeded()
                self.searchFilterView.layoutIfNeeded()
            },
            completion: { (completed:Bool) -> Void in
        })
        
        showingFilters = true
        
    }

    func hideFilters(#alsoHideFilterButton: Bool) {
        
        if alsoHideFilterButton {
            self.hideFilterButton()
        } else {
            self.showFilterButton(true)
        }

        searchFilterView.snp_updateConstraints { (make) -> () in
            make.height.equalTo(0)
        }
        
        timeFilterView.snp_updateConstraints { (make) -> () in
            make.height.equalTo(0)
        }
        
        timeFilterView.setNeedsLayout()
        searchFilterView.setNeedsLayout()

        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                //also, make the status bar not transparent anymore
                self.statusBar.alpha = 1

                self.timeFilterView.layoutIfNeeded()
                self.searchFilterView.layoutIfNeeded()
            },
            completion: { (completed:Bool) -> Void in
        })
        
        showingFilters = false
        
    }

    
    // MARK: Helper Methods
    
    func hideFilterButton() {

        filterButton.snp_remakeConstraints{ (make) -> () in
            make.size.equalTo(CGSizeMake(0, 0))
            make.centerX.equalTo(self.view).multipliedBy(1.66)
            make.bottom.equalTo(self.view).with.offset(-48)
        }
        animatefilterButton()
    }
    
    func showFilterButton(forceShow: Bool) {

        //only shows the button if the searchField is 'hidden'
        if !forceShow
            && (showingFilters
                || !self.isSpotDetailsHidden()) {
                    return
        }

        //if we have an active filter...
        if filterButtonText == "" {
            filterButtonImageName = "icon_filter"
        } else {
            filterButtonImageName = "icon_time"

        }
        
        filterButton.setImage(UIImage(named: filterButtonImageName))

        filterButton.snp_remakeConstraints{ (make) -> () in
            make.size.greaterThanOrEqualTo(CGSizeMake(36, 36))
            make.right.equalTo(self.view.snp_centerX).multipliedBy(1.66).with.offset(18)
            make.bottom.equalTo(self.view).with.offset(-30)
        }
        animatefilterButton()
    }
    
    func animatefilterButton() {
        filterButton.setNeedsLayout()
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.filterButton.layoutIfNeeded()
            },
            completion: { (completed:Bool) -> Void in
        })
    }

    
    // MARK:TimeFilterViewDelegate
    func filterValueWasChanged(#hours:Float?, selectedLabelText: String) {
        self.delegate?.updateMapAnnotations()
        filterButtonText = selectedLabelText
        filterButton.setLabelText(selectedLabelText)
        hideFilters(alsoHideFilterButton: false)
    }
    
}


protocol HereViewControllerDelegate {
    func loadMyCarTab()
    func updateMapAnnotations()
}
