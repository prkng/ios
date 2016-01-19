//
//  AvailableCitiesViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-11-06.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import UIKit

class CityPickerViewController: AbstractViewController {
    
    var parent: TabController
    var containerView = UIView()
    var scrollView = UIScrollView()
    var topIcon = UIImageView(image: UIImage(named: "icon_city_picker"))
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var cityButtons = [UIButton]()
    
    var didSetupSubviews = false
    var didSetupConstraints = false
    
    init(parent: TabController) {
        self.parent = parent
        super.init(nibName: nil, bundle: nil)

        var cities = CityOperations.sharedInstance.availableCities
        cities.sortInPlace { (left, right) -> Bool in
            left.displayName < right.displayName
        }
        for city in cities {
            let cityButton = ViewFactory.roundedButtonWithHeight(36,
                backgroundColor: Styles.Colors.white.colorWithAlphaComponent(0.95),
                font: Styles.FontFaces.regular(14),
                text: city.displayName,
                textColor: Styles.Colors.red2,
                highlightedTextColor: Styles.Colors.red1)
            cityButton.addTarget(self, action: "didTapCityButton:", forControlEvents: .TouchUpInside)
            cityButtons.append(cityButton)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        view = TouchForwardingView()
        setupSubviews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "City Picker View"
    }
    
    func setupSubviews() {
        
        self.view.backgroundColor = Styles.Colors.lightGrey.colorWithAlphaComponent(0.9)
        
        self.view.addSubview(containerView)
        
        containerView.addSubview(scrollView)
        
        scrollView.addSubview(topIcon)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.petrol2
        titleLabel.textAlignment = .Center
        titleLabel.text = "city_picker_title".localizedString
        scrollView.addSubview(titleLabel)
        
        subtitleLabel.font = Styles.FontFaces.regular(15)
        subtitleLabel.textColor = Styles.Colors.petrol2
        subtitleLabel.textAlignment = .Center
        subtitleLabel.text = "city_picker_subtitle".localizedString
        scrollView.addSubview(subtitleLabel)
        
        for button in cityButtons {
            self.scrollView.addSubview(button)
        }

        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        scrollView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.containerView)
        }
        
        let topIconTopMargin = UIScreen.mainScreen().bounds.height * 0.18
        topIcon.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topIconTopMargin)
            make.height.equalTo(36)
            make.width.equalTo(36)
            make.centerX.equalTo(self.scrollView)
        }

        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topIcon.snp_bottom).offset(12)
            make.left.equalTo(self.containerView).offset(50)
            make.right.equalTo(self.containerView).offset(-50)
            make.centerX.equalTo(self.scrollView)
        }

        subtitleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom).offset(12)
            make.left.equalTo(self.containerView).offset(50)
            make.right.equalTo(self.containerView).offset(-50)
            make.centerX.equalTo(self.scrollView)
        }

        var topConstraint = self.subtitleLabel.snp_bottom
        var topConstraintOffset = 24
        for button in cityButtons {
            button.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo(topConstraint).offset(topConstraintOffset)
                make.left.equalTo(self.containerView).offset(50)
                make.right.equalTo(self.containerView).offset(-50)
                make.height.equalTo(36)
            })
            topConstraint = button.snp_bottom
            topConstraintOffset = 12
        }
        
        didSetupConstraints = true
    }
    
    func showOnViewController(viewController: UIViewController) {
        
        let existingCityPickerVCs = viewController.childViewControllers.filter { (vc) -> Bool in
            return vc is CityPickerViewController
        }
        
        if existingCityPickerVCs.count > 0 {
            return
        }
        
        viewController.addChildViewController(self)
        viewController.view.addSubview(self.view)
        self.didMoveToParentViewController(viewController)
        
        self.view.snp_makeConstraints(closure: { (make) -> () in
            make.edges.equalTo(viewController.view)
        })
        
        self.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.alpha = 1.0
        })
        
    }

    func dismissMeOKIJustCantTakeItAndIWannaStayRightWhereIAm() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
                self.didMoveToParentViewController(nil)
        })
    }

    func didTapCityButton(sender: UIButton) {
        parent.mapViewController.dontTrackUser()
        let cities = CityOperations.sharedInstance.availableCities
        let city = cities.filter { (city) -> Bool in
            city.displayName == sender.titleLabel?.text
            }.first
        let currentCity = Settings.selectedCity()
        if city != nil {
            parent.cityDidChange(fromCity: currentCity, toCity: city!)
        }
        dismissMeOKIJustCantTakeItAndIWannaStayRightWhereIAm()
    }

    
}
