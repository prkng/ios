//
//  HereViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HereViewController: AbstractViewController, SpotDetailViewDelegate, PRKModalViewControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate, PRKVerticalGestureRecognizerDelegate, MapMessageViewDelegate, FilterViewControllerDelegate {

    var showFiltersOnAppear: Bool = false
    
    var mapMessageView: MapMessageView
    var canShowMapMessage: Bool = false

    var prkModalViewController: PRKModalViewController?
    var firstUseMessageVC: HereFirstUseViewController?
    var detailView: SpotDetailView
    
    var filterVC: FilterViewController
    
    var statusBar: UIView
    var modeSelection: SliderSelectionControl

    var activeSpot: ParkingSpot?
    var forceShowSpotDetails: Bool
    
    let viewHeight = UIScreen.mainScreen().bounds.height - CGFloat(Styles.Sizes.tabbarHeight)

    private var filterButtonImageName: String
    private var filterButtonText: String
    private var verticalRec: PRKVerticalGestureRecognizer
    private var isShowingSchedule: Bool
    private var timer: NSTimer?
    
    var delegate : HereViewControllerDelegate?

    init() {
        detailView = SpotDetailView()
        filterVC = FilterViewController()
        mapMessageView = MapMessageView()
        statusBar = UIView()
        filterButtonImageName = "icon_filter"
        filterButtonText = ""
        modeSelection = SliderSelectionControl(titles: ["garages".localizedString, "on-street".localizedString, "car_sharing".localizedString])
        forceShowSpotDetails = false
        verticalRec = PRKVerticalGestureRecognizer()
        isShowingSchedule = false
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

        modeSelection.selectOption(modeSelection.buttons[1], animated: false)
        
        if (Settings.firstMapUse()) {
            Settings.setFirstMapUsePassed(true)
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("showFirstUseMessage"), userInfo: nil, repeats: false)
        } else {
            if showFiltersOnAppear {
                self.filterVC.showFilters(resettingTimeFilterValue: true)
                self.filterVC.makeActive()
                showFiltersOnAppear = false
            } else {
                self.filterVC.hideFilters(completely: false)
                self.delegate?.updateMapAnnotations()
            }
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

        verticalRec = PRKVerticalGestureRecognizer(view: detailView, superViewOfView: self.view)
        verticalRec.delegate = self
        
        detailView.delegate = self
        view.addSubview(detailView)
        
        statusBar.backgroundColor = Styles.Colors.statusBar
        view.addSubview(statusBar)
        
        self.filterVC.delegate = self
        self.view.addSubview(self.filterVC.view)
        self.filterVC.willMoveToParentViewController(self)

        mapMessageView.delegate = self
        view.addSubview(mapMessageView)
        
        modeSelection.addTarget(self, action: "modeSelectionValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(modeSelection)
    
    }
    
    func setupConstraints() {
        
        mapMessageView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view.snp_top)
        }

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

        self.filterVC.view.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.mapMessageView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        modeSelection.snp_makeConstraints { (make) -> () in
            make.height.equalTo(SliderSelectionControl.HEIGHT)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
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
        
        if let firstUse = self.firstUseMessageVC {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                firstUse.view.alpha = 0.0
                }, completion: { (finished) -> Void in
                    firstUse.removeFromParentViewController()
                    firstUse.view.removeFromSuperview()
                    firstUse.didMoveToParentViewController(nil)
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
    
    //MARK: PRKVerticalGestureRecognizerDelegate methods
    func swipeDidBegin() {
        setupScheduleView(activeSpot)
    }
    
    func swipeInProgress(yDistanceFromBeginTap: CGFloat) {
        adjustSpotDetailsWithDistanceFromBottom(-yDistanceFromBeginTap, animated: false)
    }
    
    func swipeDidEndUp() {
        animateScheduleView()
    }
    
    func swipeDidEndDown() {
        showSpotDetails()
    }
    
    // MARK: Schedule/Agenda methods
    func showScheduleView(spot : ParkingSpot?) {
        setupScheduleView(spot)
        animateScheduleView()
    }
    
    func setupScheduleView(spot : ParkingSpot?) {
        
        if spot != nil {
            self.prkModalViewController = PRKModalViewController(spot: spot!, view: self.view)
            self.view.addSubview(self.prkModalViewController!.view)
            self.prkModalViewController!.willMoveToParentViewController(self)
            self.prkModalViewController!.delegate = self
            
            self.prkModalViewController!.view.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(self.detailView.snp_bottom)
                make.size.equalTo(self.view)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
            })
            
            self.prkModalViewController!.view.layoutIfNeeded()
            
        }
    }
    
    func animateScheduleView() {
        
        adjustSpotDetailsWithDistanceFromBottom(-viewHeight, animated: true)
        isShowingSchedule = true
    }
    
    
    func hideScheduleView () {
        
        if(self.prkModalViewController == nil) {
            return
        }
        
        detailView.snp_updateConstraints {
            (make) -> () in
            make.bottom.equalTo(self.view).with.offset(0)
        }
        
        self.prkModalViewController?.view.snp_updateConstraints({ (make) -> () in
            make.top.equalTo(self.detailView.snp_bottom).with.offset(0)
        })
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.detailView.alpha = 1
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                
                self.prkModalViewController!.view.removeFromSuperview()
                self.prkModalViewController!.willMoveToParentViewController(nil)
                self.prkModalViewController!.removeFromParentViewController()
                self.prkModalViewController = nil
                self.isShowingSchedule = false
        })
        
    }
    
    func shouldAdjustTopConstraintWithOffset(distanceFromTop: CGFloat, animated: Bool) {
        let height = UIScreen.mainScreen().bounds.height - CGFloat(Styles.Sizes.tabbarHeight)
        let distanceFromBottom = height - distanceFromTop
        adjustSpotDetailsWithDistanceFromBottom(-distanceFromBottom, animated: animated)

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
                Settings.cancelNotification()
                if self.activeSpot!.currentlyActiveRule.ruleType != .Paid {
                    Settings.scheduleNotification(NSDate(timeIntervalSinceNow: self.activeSpot!.availableTimeInterval() - NSTimeInterval(Settings.notificationTime() * 60)))
                }
            }
            
            SVProgressHUD.dismiss()
            self.delegate?.loadMyCarTab()
            
        })
        
    }
    
    func updateSpotDetailsTime() {
        
        if self.activeSpot != nil {
            switch self.activeSpot!.currentlyActiveRule.ruleType {
            case .Paid:
                let interval = self.activeSpot!.currentlyActiveRuleEndTime

                detailView.rightTopLabel.text = "metered".localizedString.uppercaseString
                
                var currencyString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: Styles.FontFaces.regular(16)])
                var numberString = NSMutableAttributedString(string: self.activeSpot!.currentlyActiveRule.paidHourlyRateString, attributes: [NSFontAttributeName: Styles.Fonts.h2rVariable])
                currencyString.appendAttributedString(numberString)

                detailView.leftBottomLabel.attributedText = currencyString

                detailView.rightBottomLabel.attributedText = interval.untilAttributedString(Styles.Fonts.h2rVariable, secondPartFont: Styles.FontFaces.light(16))
                break
            default:
                let interval = activeSpot!.availableTimeInterval()

                if (interval > 2*3600) { // greater than 2 hours = show available until... by default
                    detailView.rightTopLabel.text = "until".localizedString.uppercaseString
                    detailView.rightBottomLabel.attributedText = ParkingSpot.availableUntilAttributed(interval, firstPartFont: Styles.Fonts.h2rVariable, secondPartFont: Styles.FontFaces.light(16))
                } else {
                    detailView.rightTopLabel.text = "for".localizedString.uppercaseString
                    detailView.rightBottomLabel.attributedText = ParkingSpot.availableMinutesStringAttributed(interval, font: Styles.Fonts.h2rVariable)
                }
                break
                
            }
        }
    }
    
    func updateSpotDetails(spot: ParkingSpot?) {
        
        self.activeSpot = spot
        
        if spot != nil {
            
            forceShowSpotDetails = true
            
            if (activeSpot != nil) {
                println("selected spot : " + activeSpot!.identifier)
            }
            
            switch spot!.currentlyActiveRule.ruleType {
            case .Paid:
                detailView.bottomLeftContainer.snp_updateConstraints({ (make) -> () in
                    make.width.equalTo(SpotDetailView.BOTTOM_LEFT_CONTAINER_WIDTH)
                })
                detailView.checkinImageView.image = UIImage(named:"icon_checkin_pin_pay")
                detailView.checkinImageLabel.text = "check-in-pay".localizedString
                break
            default:
                detailView.bottomLeftContainer.snp_updateConstraints({ (make) -> () in
                    make.width.equalTo(0)
                })
                detailView.checkinImageView.image = UIImage(named:"icon_checkin_pin")
                detailView.checkinImageLabel.text = "check-in".localizedString
                break
            }

            detailView.titleLabel.text = activeSpot?.name
            updateSpotDetailsTime()
            detailView.checkinImageView.layer.wigglewigglewiggle()

            hideModeSelection()
            
            showSpotDetails()
            
            self.timer?.invalidate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "updateSpotDetailsTime", userInfo: nil, repeats: true)
            
        } else {
            self.activeSpot = nil
            self.timer?.invalidate()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), {
                self.hideSpotDetails()
            })
        }
        
    }
    
    private func showSpotDetails() {
        adjustSpotDetailsWithDistanceFromBottom(0, animated: true)
    }
    
    private func hideSpotDetails() {
        adjustSpotDetailsWithDistanceFromBottom(180, animated: true)
    }

    private func adjustSpotDetailsWithDistanceFromBottom(distance: CGFloat, animated: Bool) {
        
        let fullLayout = distance == 0 || distance == 180 || distance == viewHeight || distance == -viewHeight
        
        let alpha = abs(distance) / self.viewHeight
        
        let parallaxOffset = fullLayout ? 0 : alpha * CGFloat(Styles.Sizes.spotDetailViewHeight)
        
        if isShowingSchedule {
            
            detailView.snp_updateConstraints {
                (make) -> () in
                make.bottom.equalTo(self.view).with.offset(distance + parallaxOffset)
            }

            self.prkModalViewController?.view.snp_updateConstraints({ (make) -> () in
                make.top.equalTo(self.detailView.snp_bottom).with.offset(-parallaxOffset)
            })
        } else {
            
            detailView.snp_updateConstraints {
                (make) -> () in
                make.bottom.equalTo(self.view).with.offset(distance)
            }

            self.prkModalViewController?.view.snp_updateConstraints({ (make) -> () in
                make.top.equalTo(self.detailView.snp_bottom).with.offset(-2*parallaxOffset)
            })
        }

        let changeView = { () -> () in
            if fullLayout {
                self.view.layoutIfNeeded()
            } else {
                self.view.updateConstraints()
            }
            if self.isShowingSchedule {
                self.detailView.alpha = (self.viewHeight/2 - abs(distance)) / (self.viewHeight/2)
            } else {
                self.detailView.alpha = (self.viewHeight/3 - abs(distance)) / (self.viewHeight/3)
            }
        }
        
        if animated {
            UIView.animateWithDuration(0.2,
                animations: { () -> Void in
                    changeView()
                },
                completion: { (completed: Bool) -> Void in
                    self.showModeSelection(false)
            })
        } else {
            changeView()
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
    
    
    // MARK: Helper Methods
    
    func hideModeSelection() {
        modeSelection.hidden = true
    }
    
    func showModeSelection(forceShow: Bool) {
        
        //only shows the button if the searchField is 'hidden'
        if !forceShow
            && !self.isSpotDetailsHidden() {
                    return
        }

        modeSelection.hidden = false
    }
    
    func modeSelectionValueChanged() {

        switch(self.modeSelection.selectedIndex) {
        case 0:
            //oh em gee you wanna see garages!
            self.delegate?.didSelectMapMode(MapMode.Garage)
            break
        case 1:
            //oh. em. gee. you wanna see street parking!
            self.delegate?.didSelectMapMode(MapMode.StreetParking)
            break
        case 2:
            //oh. em. geeeeeeee you wanna see car sharing spots!
            self.delegate?.didSelectMapMode(MapMode.CarSharing)
        default:break
        }

    }
    
    // MARK: TimeFilterViewDelegate
    
    func filterValueWasChanged(#hours:Float?, selectedLabelText: String, permit: Bool, fromReset: Bool) {
        self.delegate?.updateMapAnnotations()
//        filterButtonText = selectedLabelText
//        filterButton.setLabelText(selectedLabelText)
//        hideFilters(alsoHideFilterButton: false)
    }
    
    func filterLabelUpdate(labelText: String) {
//        filterButtonText = labelText
//        filterButton.setLabelText(labelText)
    }
    
    func didTapCarSharing() {
        self.delegate?.loadSettingsTab()
    }
 
    // MARK: MapMessageViewDelegate
    
    func cityDidChange(#fromCity: Settings.City, toCity: Settings.City) {
        self.delegate?.cityDidChange(fromCity: fromCity, toCity: toCity)
    }

}


protocol HereViewControllerDelegate {
    func loadMyCarTab()
    func loadSettingsTab()
    func updateMapAnnotations()
    func cityDidChange(#fromCity: Settings.City, toCity: Settings.City)
    func didSelectMapMode(mapMode: MapMode)
}
