//
//  FilterViewController.swift
//  
//
//  Created by Antonino Urbano on 2015-08-18.
//
//

import UIKit

enum CarSharingMode: Int {
    case none = 0
    case findCar
    case findSpot
}

class FilterViewController: GAITrackedViewController, TimeFilterViewDelegate, SearchResultsTableViewControllerDelegate {

    fileprivate var containerView: UIView
    fileprivate var backgroundView: UIView
    var searchFilterView: SearchFilterView
    var timeFilterView: TimeFilterView
    fileprivate var carSharingFilterView = PRKTopTabBar(titles: ["find_a_car".localizedString, "find_a_spot".localizedString])
    fileprivate var lastCarSharingMode: CarSharingMode = .findCar
    
    var trackUserButton = UIButton()

    var shouldShowTimeFilter: Bool = true
    func updateTimeFilterDisplay() {
        self.timeFilterView.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.searchFilterView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.shouldShowTimeFilter ? TimeFilterView.TOTAL_HEIGHT : 0)
        }
        self.timeFilterView.isHidden = !self.shouldShowTimeFilter
    }
    var showingCarSharingTabBar: Bool = false
    func updateCarSharingTabBarDisplay() {
        self.carSharingFilterView.snp_remakeConstraints(closure: { (make) -> Void in
            make.top.equalTo(self.searchFilterView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.showingCarSharingTabBar ? 45 : 0)
        })
        self.carSharingFilterView.setNeedsLayout()
        self.carSharingFilterView.layoutIfNeeded()
        self.carSharingFilterView.refresh()
        self.carSharingFilterView.isHidden = !self.showingCarSharingTabBar
    }

    var autocompleteVC: SearchResultsTableViewController?

    var delegate: FilterViewControllerDelegate?
    
    var small = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Filters - General View"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    init() {
        
        containerView = TouchForwardingView()
        timeFilterView = TimeFilterView()
        searchFilterView = SearchFilterView()

        if #available(iOS 8.0, *) {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            backgroundView = UIVisualEffectView(effect: blurEffect)
            //            backgroundView.backgroundColor = Styles.Colors.cream1
            //            backgroundView.alpha = 0.9
        } else {
            backgroundView = UIView()
            backgroundView.backgroundColor = Styles.Colors.cream1
            backgroundView.alpha = 0.9
        }

        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = TouchForwardingView()
        setupViews()
        setupConstraints()
    }

    func setupViews () {

        containerView.clipsToBounds = true
        view.addSubview(containerView)
        containerView.addSubview(backgroundView)
        containerView.addSubview(searchFilterView)
        timeFilterView.delegate = self
        containerView.addSubview(timeFilterView)
        timeFilterView.clipsToBounds = true
        containerView.addSubview(carSharingFilterView)
        carSharingFilterView.addTarget(self, action: #selector(FilterViewController.didChangeCarSharingMode), for: UIControlEvents.valueChanged)
        carSharingFilterView.clipsToBounds = true
        
        trackUserButton.backgroundColor = Styles.Colors.cream2
        trackUserButton.setImage(UIImage(named:"btn_geo_on"), for: UIControlState())
        trackUserButton.addTarget(self, action: #selector(FilterViewController.didTapTrackUserButton), for: UIControlEvents.touchUpInside)
        containerView.addSubview(trackUserButton)

    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).offset(12)
            make.right.equalTo(self.view).offset(-12-46)
            make.top.equalTo(self.view).offset(Styles.Sizes.statusBarHeight + 10)
            make.height.equalTo(SearchFilterView.FIELD_HEIGHT)
        }
        
        backgroundView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.containerView)
        }

        searchFilterView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(SearchFilterView.TOTAL_HEIGHT)
        }
        
        timeFilterView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.searchFilterView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(TimeFilterView.TOTAL_HEIGHT)
        }
        
        carSharingFilterView.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(self.searchFilterView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(showingCarSharingTabBar ? 45 : 0)
        })
        
        trackUserButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.view).offset(-12)
            make.top.equalTo(self.view).offset(Styles.Sizes.statusBarHeight + 10)
            make.height.equalTo(SearchFilterView.FIELD_HEIGHT)
            make.width.equalTo(46)
        }

    }
    
    func didTapTrackUserButton () {
        self.delegate?.didTapTrackUserButton()
    }

    //MARK: Helper methods

    func makeActive() {
        
        self.searchFilterView.makeActive()
    }

    func showFilters(resettingTimeFilterValue: Bool) {
        
        //whenever it's shown, reset the filter
        if resettingTimeFilterValue {
            timeFilterView.resetValue()
        }
        
        UIView.animate(withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.trackUserButton.alpha = 0
                self.showBigHeader()
                self.containerView.layoutIfNeeded()
                self.searchFilterView.showingSmall = false
            },
            completion: { (completed:Bool) -> Void in
                self.updateTimeFilterDisplay()
                self.updateCarSharingTabBarDisplay()
        })
        
    }
    
    func hideFilters(completely: Bool, resettingTimeFilterValue: Bool = false) {
        
        if resettingTimeFilterValue {
            timeFilterView.resetValue()
        } else {
            timeFilterView.update()
        }
        
        self.updateTimeFilterDisplay()
        self.updateCarSharingTabBarDisplay()

        UIView.animate(withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.trackUserButton.alpha = 1
                self.showSmallHeader(completely)
                self.containerView.layoutIfNeeded()
                self.searchFilterView.showingSmall = true
            },
            completion: { (completed:Bool) -> Void in
        })
        
        searchFilterView.makeInactive(closeFilters: false)
        
    }
    
    fileprivate func showBigHeader() {
       
        var height: CGFloat = shouldShowTimeFilter ? TimeFilterView.TOTAL_HEIGHT : 0
        height += showingCarSharingTabBar ? 45 : 0
        
        containerView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(SearchFilterView.TOTAL_HEIGHT + height)
        }
    }

    fileprivate func showSmallHeader(_ completely: Bool) {
        
        if showingCarSharingTabBar && !completely {
            showBigHeader()
            return
        }
        
        let height = completely ? 0 : 40

        containerView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view).offset(12)
            make.right.equalTo(self.view).offset(-12)
            make.top.equalTo(self.view).offset(Styles.Sizes.statusBarHeight + 10)
            make.height.equalTo(height)
        }
    }
    
    func carSharingMode() -> CarSharingMode {
        return lastCarSharingMode
    }
    
    func didChangeCarSharingMode() {
        
        let tracker = GAI.sharedInstance().defaultTracker

        switch(self.carSharingFilterView.selectedIndex) {
        case 0:
            lastCarSharingMode = .findCar
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Filter View", action: "Car Sharing Mode Switched", label: "Find Car", value: nil).build() as! [AnyHashable: Any])
            break
        default:
            lastCarSharingMode = .findSpot
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Filter View", action: "Car Sharing Mode Switched", label: "Find Spot", value: nil).build() as! [AnyHashable: Any])
            break
        }
        self.delegate?.didChangeCarSharingMode(lastCarSharingMode)
    }
    
    // MARK: TimeFilterViewDelegate
    
    func filterValueWasChanged(hours:Float?, selectedLabelText: String, permit: Bool, fromReset: Bool) {
        self.delegate?.filterValueWasChanged(hours: hours, selectedLabelText: selectedLabelText, permit: permit, fromReset: fromReset)
        self.searchFilterView.indicatorText = selectedLabelText
        if !fromReset {
            hideFilters(completely: false)
        }
    }
    
    func filterLabelUpdate(_ labelText: String) {
        self.searchFilterView.indicatorText = labelText
    }
    
    func showCarSharingInfo() {
        self.delegate?.showCarSharingInfo()
    }
    
    //MARK: Autocomplete methods and SearchResultsTableViewControllerDelegate methods
    
    func updateAutocompleteWithValues(_ results: [SearchResult]) {
        
        if results.count == 0 {
            
            if self.autocompleteVC != nil {
                
                UIView.animate(withDuration: 0.15,
                    delay: 0,
                    options: UIViewAnimationOptions(),
                    animations: { () -> Void in
                        self.autocompleteVC?.view.alpha = 0
                    },
                    completion: { (completed:Bool) -> Void in
                        
                        self.autocompleteVC?.view.removeFromSuperview()
                        self.autocompleteVC?.willMove(toParentViewController: nil)
                        self.autocompleteVC?.removeFromParentViewController()
                        self.autocompleteVC = nil
                })
                
            }
            
        } else {
            
            if self.autocompleteVC != nil {
                self.autocompleteVC?.updateSearchResultValues(results)
                return
            }
            
            self.autocompleteVC = SearchResultsTableViewController(searchResultValues: results)
            self.autocompleteVC?.delegate = self
            self.view.addSubview(self.autocompleteVC!.view)
            self.autocompleteVC?.willMove(toParentViewController: self)
            
            let lastKeyboardHeight = UserDefaults.standard.value(forKey: "last_keyboard_height") as? CGFloat ?? 216
            let height = lastKeyboardHeight - CGFloat(Styles.Sizes.tabbarHeight)
            
            self.autocompleteVC?.view.snp_makeConstraints { (make) -> () in
                make.top.equalTo(self.searchFilterView.snp_bottom)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-height)
            }
            
            self.autocompleteVC?.view.alpha = 0
            
            self.autocompleteVC?.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.15,
                delay: 0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.autocompleteVC?.view.alpha = 1
                },
                completion: { (completed:Bool) -> Void in
            })
            
        }
        
    }
    
    func didSelectSearchResult(_ result: SearchResult) {
        self.searchFilterView.setSearchResult(result)
    }

    
}


protocol FilterViewControllerDelegate {
    
    //these functions match TimeViewControllerDelegate
    func filterValueWasChanged(hours:Float?, selectedLabelText: String, permit: Bool, fromReset: Bool)
    func showCarSharingInfo()
    func didTapTrackUserButton()
    func didChangeCarSharingMode(_ mode: CarSharingMode)
}

