//
//  SearchViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 07/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchViewController: AbstractViewController, UITextFieldDelegate {
    
    var delegate : SearchViewControllerDelegate?
    
//    var effectView : UIVisualEffectView
    var containerView : UIView
    var containerColorView : UIView
    var markerIcon : UIImageView
    var textLabel : UILabel
    var searchField : UITextField
    var dateSelectionView : DateSelectionView
    var durationSelectionView : DurationSelectionView
    var downButton : UIButton
    var searchButton : UIButton
    
    var searchStep : SearchStep
    
    init() {
        
//        var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        effectView = UIVisualEffectView (effect: blur)
        containerView = TouchForwardingView()
        containerColorView = UIView()
        markerIcon = UIImageView()
        textLabel = UILabel()
        searchField = UITextField()
        downButton = UIButton()
        dateSelectionView = DateSelectionView()
        durationSelectionView = DurationSelectionView()
        searchButton = ViewFactory.hugeButton()
        searchStep = SearchStep.ONE

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
        super.viewDidLoad()
        self.screenName = "Search - General View"
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.dateSelectionView.selectToday()
    }
    
    
    
    func setupViews () {
        
        view.backgroundColor = UIColor.clearColor()
        
//        effectView.userInteractionEnabled = false
//        view.addSubview(effectView)
        
        view.addSubview(containerView)
        
        var midnight1 = UIColor(rgba: "#435059E6")
        containerColorView.backgroundColor = midnight1
        containerColorView.userInteractionEnabled = false
        containerView.addSubview(containerColorView)
        
        markerIcon.image = UIImage(named: "btn_pin_search")
        markerIcon.contentMode = UIViewContentMode.Center
        markerIcon.userInteractionEnabled = false
        containerView.addSubview(markerIcon)
        
        textLabel.font = Styles.Fonts.h1
        textLabel.textColor = Styles.Colors.anthracite1
        textLabel.numberOfLines = 0
        textLabel.text = NSLocalizedString("search_step1_copy",comment:"")
        textLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(textLabel)
        
        searchField.backgroundColor = Styles.Colors.cream2
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = Styles.Colors.beige1.CGColor
        searchField.font = Styles.Fonts.h3
        searchField.textColor = Styles.Colors.midnight2
        searchField.textAlignment = NSTextAlignment.Center
        searchField.delegate = self
        searchField.keyboardAppearance = UIKeyboardAppearance.Dark
        searchField.keyboardType = UIKeyboardType.WebSearch
        containerView.addSubview(searchField)
        
        dateSelectionView.hidden = true
        containerView.addSubview(dateSelectionView)
        
        durationSelectionView.hidden = true
        containerView.addSubview(durationSelectionView)
        
        searchButton.addTarget(self, action: "searchButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        searchButton.setTitle(NSLocalizedString("search", comment : ""), forState: UIControlState.Normal)
        searchButton.hidden = true
        containerView.addSubview(searchButton)
        
        downButton.setImage(UIImage(named: "btn_next"), forState: UIControlState.Normal)
        downButton.addTarget(self, action: "nextStep", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(downButton)
    }
    
    func setupConstraints () {
        
//        effectView.snp_makeConstraints { (make) -> () in
//            make.edges.equalTo(self.view)
//        }
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        containerColorView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.containerView)
        }
        
        markerIcon.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(49, 60))
            make.bottom.equalTo(self.containerView).with.offset(-357)
            make.centerX.equalTo(self.containerView)
        }
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.containerView).with.offset(-262)
            make.centerX.equalTo(self.containerView)
        }
        
        searchField.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).with.offset(12)
            make.right.equalTo(self.containerView).with.offset(-12)
            make.bottom.equalTo(self.containerView).with.offset(-160)
        }
        
        dateSelectionView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(110)
            make.top.equalTo(self.searchField.snp_bottom).with.offset(12)
        }
        
        durationSelectionView.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.searchButton.snp_top)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(185)
        }
        
        downButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(60, 60))
            make.bottom.equalTo(self.containerView).with.offset(-20)
            make.centerX.equalTo(self.containerView)

        }
        
        searchButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
    }
    
    
    func showStreetName (streetName : String) {
        searchField.text = streetName
    }
    


    
    // UITextFieldDelegate
    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
//        return true;
//    }
    

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (self.searchStep == SearchStep.ONE) {
            transformToStepTwo()
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.endEditing(false)
        SearchOperations.searchWithInput(textField.text, forAutocomplete: false, completion: { (results) -> Void in
            
            self.markerIcon.hidden = true
            
            
            let weekDay = self.dateSelectionView.selectedDay
            
            let today = DateUtil.dayIndexOfTheWeek()
            
            var date : NSDate = NSDate()
            
            self.delegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
        return true        
    }
    

    
    func transformToStepTwo () {
        
        if (searchStep == SearchStep.TWO) {
            return
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.containerView).with.offset(40)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).with.offset(12)
            make.right.equalTo(self.containerView).with.offset(-12)
        }
        
        markerIcon.snp_remakeConstraints { (make) -> () in
            make.center.equalTo(self.containerView)
            make.size.equalTo(CGSizeMake(49, 60))
        }
        
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.searchField.layoutIfNeeded()
            self.markerIcon.layoutIfNeeded()
            self.textLabel.alpha = 0
            self.dateSelectionView.alpha = 0
            self.containerColorView.alpha = 1.0
            self.downButton.alpha = 1.0
            
            }) { (complete) -> Void in
                self.searchStep = SearchStep.TWO
                self.dateSelectionView.hidden = true
                self.durationSelectionView.hidden = true
                self.searchButton.hidden = true
                self.containerColorView.hidden = true
                self.downButton.hidden = false
                self.textLabel.hidden = true
        }
        
    }
    
    func transformToStepThree () {
     
        if (searchStep == SearchStep.THREE) {
            return
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.centerY.equalTo(self.containerView)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).with.offset(12)
            make.right.equalTo(self.containerView).with.offset(-12)
        }
        
        markerIcon.snp_remakeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.bottom.equalTo(self.searchField.snp_top)
        }
        
        dateSelectionView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(110)
            make.top.equalTo(self.searchField.snp_bottom).with.offset(12)
        }
        
        
        dateSelectionView.alpha = 0.0
        dateSelectionView.hidden = false
        self.containerColorView.hidden = false

        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.searchField.layoutIfNeeded()
            self.markerIcon.layoutIfNeeded()
            self.dateSelectionView.layoutIfNeeded()
            self.dateSelectionView.alpha = 1.0
            self.containerColorView.alpha = 1.0
            
            }) { (complete) -> Void in
                self.searchStep = SearchStep.THREE
                self.textLabel.hidden = true
                self.downButton.hidden = false

        }
        
        
    }
    
    
    func transformToStepFour () {
        
        if (searchStep == SearchStep.FOUR) {
            return
        }
    
        dateSelectionView.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.durationSelectionView.snp_top)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(110)
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.dateSelectionView.snp_top).with.offset(-12)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).with.offset(12)
            make.right.equalTo(self.containerView).with.offset(-12)
        }
        
        markerIcon.snp_remakeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.bottom.equalTo(self.searchField.snp_top)
        }
        
        self.durationSelectionView.alpha = 0.0
        self.searchButton.alpha = 0.0
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
           
            self.containerView.layoutIfNeeded()
            self.durationSelectionView.alpha = 1.0
            self.downButton.alpha = 0.0
            self.searchButton.alpha = 1.0
            
            }) { (complete) -> Void in
                self.searchStep = SearchStep.FOUR
                self.downButton.hidden = true
                self.searchButton.hidden = false
                self.durationSelectionView.hidden = false
        }
        
        
        
    }
    
    
    func nextStep() {
        
        switch(searchStep) {
            
        case SearchStep.ONE, SearchStep.TWO:
            transformToStepThree()
            break
            
            
        case SearchStep.THREE:
            transformToStepFour()
            break
            
        default:
            break
            
        }
        
    }

    
    func searchButtonTapped() {
        
        transformToStepTwo()
        
        delegate?.setSearchParameters(NSDate(), duration: 1)
        searchField.endEditing(false)
        
        SearchOperations.searchWithInput(searchField.text, forAutocomplete: false, completion: { (results) -> Void in
            
            self.markerIcon.hidden = true
            
            var date : NSDate = NSDate()
            
            var gregorian:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!;
            var unit : NSCalendarUnit = (NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit);
            
            var comps:NSDateComponents = gregorian.components(unit, fromDate: date);
            
            comps.setValue(self.durationSelectionView.getHour(), forComponent: NSCalendarUnit.HourCalendarUnit);
            comps.setValue(self.durationSelectionView.getMinutes(), forComponent: NSCalendarUnit.MinuteCalendarUnit);
            comps.setValue(self.dateSelectionView.selectedDay, forComponent: NSCalendarUnit.WeekdayCalendarUnit)
            
            date = gregorian.dateFromComponents(comps)!;
                        
            self.delegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
    }
    
}

protocol SearchViewControllerDelegate {
    
    func setSearchParameters(time : NSDate?, duration : Float?)
    func displaySearchResults(results : Array<SearchResult>, checkinTime : NSDate?)
    func clearSearchResults()
    func didGetAutocompleteResults(results: [SearchResult])
    
}


enum SearchStep {
    case ONE
    case TWO
    case THREE
    case FOUR
}
