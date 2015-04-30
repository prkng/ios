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
    var markerIcon : UIImageView
    var textLabel : UILabel
    var searchField : UITextField
    var dateSelectionView : DateSelectionView
    var downButton : UIButton
    
    var searchStep : SearchStep
    
    init() {
        
//        var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        effectView = UIVisualEffectView (effect: blur)
        containerView = TouchForwardingView()
        markerIcon = UIImageView()
        textLabel = UILabel()
        searchField = UITextField()
        downButton = UIButton()
        dateSelectionView = DateSelectionView()
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

        // Do any additional setup after loading the view.
    }
    
    
    
    func setupViews () {
        
        view.backgroundColor = UIColor.clearColor()
        
//        effectView.userInteractionEnabled = false
//        view.addSubview(effectView)
        
        var midnight1 = UIColor(rgba: "#435059E6")
        containerView.backgroundColor = midnight1
        view.addSubview(containerView)
        
        markerIcon.image = UIImage(named: "btn_pin_search")
        containerView.addSubview(markerIcon)
        
        textLabel.font = Styles.FontFaces.light(27)
        textLabel.textColor = Styles.Colors.anthracite1
        textLabel.numberOfLines = 0
        textLabel.text = NSLocalizedString("search_step1_copy",comment:"")
        textLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(textLabel)
        
        
        searchField.backgroundColor = Styles.Colors.cream2
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = Styles.Colors.beige1.CGColor
        searchField.font = Styles.FontFaces.light(22)
        searchField.textColor = Styles.Colors.midnight2
        searchField.textAlignment = NSTextAlignment.Center
        searchField.delegate = self
        searchField.keyboardAppearance = UIKeyboardAppearance.Dark
        searchField.keyboardType = UIKeyboardType.WebSearch
        containerView.addSubview(searchField)
        
        dateSelectionView.hidden = true
        containerView.addSubview(dateSelectionView)
        
        downButton.setImage(UIImage(named: "btn_next"), forState: UIControlState.Normal)
        downButton.addTarget(self, action: "transformToStepThree", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(downButton)
    }
    
    func setupConstraints () {
        
//        effectView.snp_makeConstraints { (make) -> () in
//            make.edges.equalTo(self.view)
//        }
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
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
            make.height.equalTo(60)
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
        
        downButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(60, 60))
            make.bottom.equalTo(self.containerView).with.offset(-20)
            make.centerX.equalTo(self.containerView)

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
        
        transformToStepTwo()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.endEditing(false)
        SearchOperations.searchByStreetName(textField.text, completion: { (results) -> Void in
            
            self.markerIcon.hidden = true
            self.delegate!.displaySearchResults(results)
            
        })
        
        return true        
    }
    

    
    func transformToStepTwo () {
        
        if (searchStep == SearchStep.TWO) {
            return
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.containerView).with.offset(40)
            make.height.equalTo(60)
            make.left.equalTo(self.containerView).with.offset(12)
            make.right.equalTo(self.containerView).with.offset(-12)
        }
        
        markerIcon.snp_remakeConstraints { (make) -> () in
            make.center.equalTo(self.containerView)
            make.size.equalTo(CGSizeMake(49, 60))
        }
        
        
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.containerView.backgroundColor = UIColor.clearColor()
            self.searchField.layoutIfNeeded()
            self.markerIcon.layoutIfNeeded()
            self.textLabel.alpha = 0
            self.dateSelectionView.alpha = 0
            
            }) { (complete) -> Void in
                self.searchStep = SearchStep.TWO
                self.dateSelectionView.hidden = true
        }
        
    }
    
    func transformToStepThree () {
     
        if (searchStep == SearchStep.THREE) {
            return
        }
        
        searchField.snp_remakeConstraints { (make) -> () in
            make.centerY.equalTo(self.containerView)
            make.height.equalTo(60)
            make.left.equalTo(self.containerView).with.offset(12)
            make.right.equalTo(self.containerView).with.offset(-12)
        }
        
        markerIcon.snp_remakeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.bottom.equalTo(self.searchField.snp_top).with.offset(-34)
            make.size.equalTo(CGSizeMake(49, 60))
        }
        
        dateSelectionView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(110)
            make.top.equalTo(self.searchField.snp_bottom).with.offset(12)
        }
        
        
        dateSelectionView.alpha = 0.0
        dateSelectionView.hidden = false
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.searchField.layoutIfNeeded()
            self.markerIcon.layoutIfNeeded()
            self.dateSelectionView.layoutIfNeeded()
            self.dateSelectionView.alpha = 1.0
            
            }) { (complete) -> Void in
                self.searchStep = SearchStep.THREE
        }
        
        
    }
    
    
    func transformToStepFour () {
        
    }



    
}

protocol SearchViewControllerDelegate {
    
    func displaySearchResults(results : Array<SearchResult>)
    
}


enum SearchStep {
    case ONE
    case TWO
    case THREE
    case FOUR
}
