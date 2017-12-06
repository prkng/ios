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
        searchStep = SearchStep.one

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateSelectionView.selectToday()
    }
    
    
    
    func setupViews () {
        
        view.backgroundColor = UIColor.clear
        
//        effectView.userInteractionEnabled = false
//        view.addSubview(effectView)
        
        view.addSubview(containerView)
        
        let midnight1 = UIColor(rgba: "#435059E6")
        containerColorView.backgroundColor = midnight1
        containerColorView.isUserInteractionEnabled = false
        containerView.addSubview(containerColorView)
        
        markerIcon.image = UIImage(named: "btn_pin_search")
        markerIcon.contentMode = UIViewContentMode.center
        markerIcon.isUserInteractionEnabled = false
        containerView.addSubview(markerIcon)
        
        textLabel.font = Styles.Fonts.h1
        textLabel.textColor = Styles.Colors.anthracite1
        textLabel.numberOfLines = 0
        textLabel.text = NSLocalizedString("search_step1_copy",comment:"")
        textLabel.textAlignment = NSTextAlignment.center
        containerView.addSubview(textLabel)
        
        searchField.backgroundColor = Styles.Colors.cream2
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = Styles.Colors.beige1.cgColor
        searchField.font = Styles.Fonts.h3
        searchField.textColor = Styles.Colors.midnight2
        searchField.textAlignment = NSTextAlignment.center
        searchField.delegate = self
        searchField.keyboardAppearance = UIKeyboardAppearance.dark
        searchField.keyboardType = UIKeyboardType.webSearch
        containerView.addSubview(searchField)
        
        dateSelectionView.isHidden = true
        containerView.addSubview(dateSelectionView)
        
        durationSelectionView.isHidden = true
        containerView.addSubview(durationSelectionView)
        
        searchButton.addTarget(self, action: #selector(SearchViewController.searchButtonTapped), for: UIControlEvents.touchUpInside)
        searchButton.setTitle(NSLocalizedString("search", comment : ""), for: UIControlState())
        searchButton.isHidden = true
        containerView.addSubview(searchButton)
        
        downButton.setImage(UIImage(named: "btn_next"), for: UIControlState())
        downButton.addTarget(self, action: #selector(SearchViewController.nextStep), for: UIControlEvents.touchUpInside)
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
            make.size.equalTo(CGSize(width: 49, height: 60))
            make.bottom.equalTo(self.containerView).offset(-357)
            make.centerX.equalTo(self.containerView)
        }
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.containerView).offset(-262)
            make.centerX.equalTo(self.containerView)
        }
        
        searchField.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
            make.bottom.equalTo(self.containerView).offset(-160)
        }
        
        dateSelectionView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(110)
            make.top.equalTo(self.searchField.snp_bottom).offset(12)
        }
        
        durationSelectionView.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.searchButton.snp_top)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(185)
        }
        
        downButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.bottom.equalTo(self.containerView).offset(-20)
            make.centerX.equalTo(self.containerView)

        }
        
        searchButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
    }
    
    
    func showStreetName (_ streetName : String) {
        searchField.text = streetName
    }
    


    
    // UITextFieldDelegate
    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
//        return true;
//    }
    

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (self.searchStep == SearchStep.one) {
            transformToStepTwo()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(false)
        SearchOperations.searchWithInput(textField.text ?? "", forAutocomplete: false, completion: { (results) -> Void in
            
            self.markerIcon.isHidden = true
            
            let date : Date = Date()
            
            self.delegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
        return true        
    }
    

    
    func transformToStepTwo () {
        
        if (searchStep == SearchStep.two) {
            return
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.containerView).offset(40)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
        }
        
        markerIcon.snp_remakeConstraints { (make) -> () in
            make.center.equalTo(self.containerView)
            make.size.equalTo(CGSize(width: 49, height: 60))
        }
        
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.searchField.layoutIfNeeded()
            self.markerIcon.layoutIfNeeded()
            self.textLabel.alpha = 0
            self.dateSelectionView.alpha = 0
            self.containerColorView.alpha = 1.0
            self.downButton.alpha = 1.0
            
            }, completion: { (complete) -> Void in
                self.searchStep = SearchStep.two
                self.dateSelectionView.isHidden = true
                self.durationSelectionView.isHidden = true
                self.searchButton.isHidden = true
                self.containerColorView.isHidden = true
                self.downButton.isHidden = false
                self.textLabel.isHidden = true
        }) 
        
    }
    
    func transformToStepThree () {
     
        if (searchStep == SearchStep.three) {
            return
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.centerY.equalTo(self.containerView)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
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
            make.top.equalTo(self.searchField.snp_bottom).offset(12)
        }
        
        
        dateSelectionView.alpha = 0.0
        dateSelectionView.isHidden = false
        self.containerColorView.isHidden = false

        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.searchField.layoutIfNeeded()
            self.markerIcon.layoutIfNeeded()
            self.dateSelectionView.layoutIfNeeded()
            self.dateSelectionView.alpha = 1.0
            self.containerColorView.alpha = 1.0
            
            }, completion: { (complete) -> Void in
                self.searchStep = SearchStep.three
                self.textLabel.isHidden = true
                self.downButton.isHidden = false

        }) 
        
        
    }
    
    
    func transformToStepFour () {
        
        if (searchStep == SearchStep.four) {
            return
        }
    
        dateSelectionView.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.durationSelectionView.snp_top)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(110)
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.dateSelectionView.snp_top).offset(-12)
            make.height.equalTo(Styles.Sizes.searchTextFieldHeight)
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
        }
        
        markerIcon.snp_remakeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.bottom.equalTo(self.searchField.snp_top)
        }
        
        self.durationSelectionView.alpha = 0.0
        self.searchButton.alpha = 0.0
        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
           
            self.containerView.layoutIfNeeded()
            self.durationSelectionView.alpha = 1.0
            self.downButton.alpha = 0.0
            self.searchButton.alpha = 1.0
            
            }, completion: { (complete) -> Void in
                self.searchStep = SearchStep.four
                self.downButton.isHidden = true
                self.searchButton.isHidden = false
                self.durationSelectionView.isHidden = false
        }) 
        
        
        
    }
    
    
    func nextStep() {
        
        switch(searchStep) {
            
        case SearchStep.one, SearchStep.two:
            transformToStepThree()
            break
            
            
        case SearchStep.three:
            transformToStepFour()
            break
            
        default:
            break
            
        }
        
    }

    
    func searchButtonTapped() {
        
        transformToStepTwo()
        
        delegate?.setSearchParameters(Date(), duration: 1)
        searchField.endEditing(false)
        
        SearchOperations.searchWithInput(searchField.text ?? "", forAutocomplete: false, completion: { (results) -> Void in
            
            self.markerIcon.isHidden = true
            
            var date : Date = Date()
            
            let gregorian:Calendar = Calendar(identifier: .gregorian)
            let unit : NSCalendar.Unit = ([NSCalendar.Unit.NSYearCalendarUnit, NSCalendar.Unit.NSMonthCalendarUnit, NSCalendar.Unit.NSDayCalendarUnit, NSCalendar.Unit.NSHourCalendarUnit, NSCalendar.Unit.NSMinuteCalendarUnit]);
            
            var comps:DateComponents = (gregorian as NSCalendar).components(unit, from: date);
            
            if #available(iOS 8.0, *) {
                (comps as NSDateComponents).setValue(self.durationSelectionView.getHour(), forComponent: NSCalendar.Unit.NSHourCalendarUnit)
                (comps as NSDateComponents).setValue(self.durationSelectionView.getMinutes(), forComponent: NSCalendar.Unit.NSMinuteCalendarUnit);
                (comps as NSDateComponents).setValue(self.dateSelectionView.selectedDay, forComponent: NSCalendar.Unit.NSWeekdayCalendarUnit)
            } else {
                comps.hour = self.durationSelectionView.getHour()
                comps.minute = self.durationSelectionView.getMinutes()
                comps.day = self.dateSelectionView.selectedDay
            };
            
            date = gregorian.date(from: comps)!;
                        
            self.delegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
    }
    
}

protocol SearchViewControllerDelegate {
    
    func setSearchParameters(_ time : Date?, duration : Float?)
    func displaySearchResults(_ results : Array<SearchResult>, checkinTime : Date?)
    func clearSearchResults()
    func didGetAutocompleteResults(_ results: [SearchResult])
    func startSearching()
    func endSearchingAndFiltering()

}


enum SearchStep {
    case one
    case two
    case three
    case four
}
