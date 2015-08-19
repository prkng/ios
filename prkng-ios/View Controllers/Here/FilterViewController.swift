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
    private var backgroundView: UIVisualEffectView
    var searchFilterView: SearchFilterView
    var timeFilterView: TimeFilterView

    var showingFilters: Bool
    var autocompleteVC: SearchResultsTableViewController?

    var delegate: FilterViewControllerDelegate?
    
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
        showingFilters = false

        if Settings.iOS8OrLater() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            backgroundView = UIVisualEffectView(effect: blurEffect)
            //            backgroundView.backgroundColor = Styles.Colors.cream1
            //            backgroundView.alpha = 0.9
        } else {
            backgroundView = UIVisualEffectView()
            backgroundView.backgroundColor = Styles.Colors.cream1
            backgroundView.alpha = 0.9
        }

        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
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

    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(12)
            make.right.equalTo(self.view).with.offset(-12)
            make.top.equalTo(self.view).with.offset(Styles.Sizes.statusBarHeight + 10)
            make.height.equalTo(40)
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

    }

    //MARK: Helper methods

    func makeActive() {
        
        self.searchFilterView.makeActive()
    }

    func showFilters(#resettingTimeFilterValue: Bool) {
        
        //whenever it's shown, reset the filter
        if resettingTimeFilterValue {
            timeFilterView.resetValue()
        }
        
        //make the constraints to match the search bar
        containerView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(SearchFilterView.TOTAL_HEIGHT + TimeFilterView.TOTAL_HEIGHT)
        }
        
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                //                //also, make the status bar not transparent anymore
                //                self.statusBar.alpha = 1
                
                self.containerView.layoutIfNeeded()
                self.searchFilterView.changeAppearance(small: false)
            },
            completion: { (completed:Bool) -> Void in
        })

        
        showingFilters = true
        
    }
    
    func hideFilters(#completely: Bool) {
        
        let height = completely ? 0 : 40
        
        timeFilterView.update()
        
        //make the constraints to match the search bar
        containerView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(12)
            make.right.equalTo(self.view).with.offset(-12)
            make.top.equalTo(self.view).with.offset(Styles.Sizes.statusBarHeight + 10)
            make.height.equalTo(height)
        }
        
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
//                //also, make the status bar not transparent anymore
//                self.statusBar.alpha = 1
                
                self.containerView.layoutIfNeeded()
                self.searchFilterView.changeAppearance(small: true)
            },
            completion: { (completed:Bool) -> Void in
        })
        
        searchFilterView.makeInactive()
        
        showingFilters = false
        
    }
    
    // MARK: TimeFilterViewDelegate
    
    func filterValueWasChanged(#hours:Float?, selectedLabelText: String, permit: Bool) {
        self.delegate?.filterValueWasChanged(hours: hours, selectedLabelText: selectedLabelText, permit: permit)
        hideFilters(completely: false)
    }
    
    func filterLabelUpdate(labelText: String) {
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
                make.bottom.equalTo(self.view).with.offset(-height)
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
    
    //these functions match SearchResultsTableViewControllerDelegate
    
    //these functions match TimeViewControllerDelegate
    func filterValueWasChanged(#hours:Float?, selectedLabelText: String, permit: Bool)
    
}

