//
//  FilterViewController.swift
//  
//
//  Created by Antonino Urbano on 2015-08-18.
//
//

import UIKit

class FilterViewController: GAITrackedViewController, TimeFilterViewDelegate, SearchResultsTableViewControllerDelegate {

    private var containerView: UIView
    private var backgroundView: UIView
    var searchFilterView: SearchFilterView
    var timeFilterView: TimeFilterView
    private var carSharingFilterView = PRKTopTabBar(titles: ["find_a_car".localizedString, "find_a_spot".localizedString])
    
    var trackUserButton = UIButton()

    var shouldShowTimeFilter: Bool = true {
        didSet {
            timeFilterView.snp_remakeConstraints { (make) -> () in
                make.top.equalTo(self.searchFilterView.snp_bottom)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.height.equalTo(shouldShowTimeFilter ? TimeFilterView.TOTAL_HEIGHT : 0)
            }
            timeFilterView.hidden = !shouldShowTimeFilter
        }
    }
    var showingCarSharingTabBar: Bool = false {
        didSet {
            carSharingFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.searchFilterView.snp_bottom)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.height.equalTo(showingCarSharingTabBar ? 40 : 0)
            })
            carSharingFilterView.refresh()
            carSharingFilterView.hidden = !showingCarSharingTabBar
        }
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
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
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
        carSharingFilterView.clipsToBounds = true
        
        trackUserButton.backgroundColor = Styles.Colors.cream2
        trackUserButton.setImage(UIImage(named:"btn_geo_on"), forState: UIControlState.Normal)
        trackUserButton.addTarget(self, action: "didTapTrackUserButton", forControlEvents: UIControlEvents.TouchUpInside)
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
            make.height.equalTo(showingCarSharingTabBar ? 40 : 0)
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

    func showFilters(resettingTimeFilterValue resettingTimeFilterValue: Bool) {
        
        //whenever it's shown, reset the filter
        if resettingTimeFilterValue {
            timeFilterView.resetValue()
        }
        
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.trackUserButton.alpha = 0
                self.showBigHeader()
                self.containerView.layoutIfNeeded()
                self.searchFilterView.showingSmall = false
            },
            completion: { (completed:Bool) -> Void in
        })
        
    }
    
    func hideFilters(completely completely: Bool, resettingTimeFilterValue: Bool = false) {
        
        if resettingTimeFilterValue {
            timeFilterView.resetValue()
        } else {
            timeFilterView.update()
        }
        
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
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
    
    private func showBigHeader() {
       
        var height: CGFloat = shouldShowTimeFilter ? TimeFilterView.TOTAL_HEIGHT : 0
        height += showingCarSharingTabBar ? 40 : 0
        
        containerView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(SearchFilterView.TOTAL_HEIGHT + height)
        }
    }

    private func showSmallHeader(completely: Bool) {
        
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
    
    
    // MARK: TimeFilterViewDelegate
    
    func filterValueWasChanged(hours hours:Float?, selectedLabelText: String, permit: Bool, fromReset: Bool) {
        self.delegate?.filterValueWasChanged(hours: hours, selectedLabelText: selectedLabelText, permit: permit, fromReset: fromReset)
        self.searchFilterView.indicatorText = selectedLabelText
        if !fromReset {
            hideFilters(completely: false)
        }
    }
    
    func filterLabelUpdate(labelText: String) {
        self.searchFilterView.indicatorText = labelText
    }
    
    func showCarSharingInfo() {
        self.delegate?.showCarSharingInfo()
    }
    
    //MARK: Autocomplete methods and SearchResultsTableViewControllerDelegate methods
    
    func updateAutocompleteWithValues(results: [SearchResult]) {
        
        if results.count == 0 {
            
            if self.autocompleteVC != nil {
                
                UIView.animateWithDuration(0.15,
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: { () -> Void in
                        self.autocompleteVC?.view.alpha = 0
                    },
                    completion: { (completed:Bool) -> Void in
                        
                        self.autocompleteVC?.view.removeFromSuperview()
                        self.autocompleteVC?.willMoveToParentViewController(nil)
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
            self.autocompleteVC?.willMoveToParentViewController(self)
            
            let lastKeyboardHeight = NSUserDefaults.standardUserDefaults().valueForKey("last_keyboard_height") as? CGFloat ?? 216
            let height = lastKeyboardHeight - CGFloat(Styles.Sizes.tabbarHeight)
            
            self.autocompleteVC?.view.snp_makeConstraints { (make) -> () in
                make.top.equalTo(self.searchFilterView.snp_bottom)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-height)
            }
            
            self.autocompleteVC?.view.alpha = 0
            
            self.autocompleteVC?.view.layoutIfNeeded()
            
            UIView.animateWithDuration(0.15,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.autocompleteVC?.view.alpha = 1
                },
                completion: { (completed:Bool) -> Void in
            })
            
        }
        
    }
    
    func didSelectSearchResult(result: SearchResult) {
        self.searchFilterView.setSearchResult(result)
    }

    
}


protocol FilterViewControllerDelegate {
    
    //these functions match TimeViewControllerDelegate
    func filterValueWasChanged(hours hours:Float?, selectedLabelText: String, permit: Bool, fromReset: Bool)
    func showCarSharingInfo()
    func didTapTrackUserButton()
}

