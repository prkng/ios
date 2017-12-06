//
//  PRKModalViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-09.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKModalViewController: PRKModalDelegatedViewController, ModalHeaderViewDelegate, PRKVerticalGestureRecognizerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    fileprivate var _delegate : PRKModalViewControllerDelegate?
    override var delegate : PRKModalViewControllerDelegate? {
        set(value) {
            _delegate = value
            for VC in viewControllers {
                VC.delegate = value
            }
        }
        get {
            return _delegate
        }
    }

    var spot : ParkingSpot
    var parentView: UIView
    
    fileprivate var pageViewController : UIPageViewController
    fileprivate var viewControllers: [PRKModalViewControllerChild]
    fileprivate var verticalRec: PRKVerticalGestureRecognizer
    fileprivate var topView : UIView
    fileprivate var headerView : ModalHeaderView
    
    fileprivate var currentViewController: PRKModalViewControllerChild? {
        get {
            return self.pageViewController.viewControllers?.first as? PRKModalViewControllerChild
        }
    }
    fileprivate(set) var HEADER_HEIGHT = Int(Styles.Sizes.modalViewHeaderHeight)

    
    init(spot: ParkingSpot, view: UIView) {
        self.spot = spot
        self.parentView = view
        topView = UIView()
        headerView = ModalHeaderView()
        pageViewController = UIPageViewController()
        viewControllers = []
        verticalRec = PRKVerticalGestureRecognizer()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerView.topText = spot.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if currentViewController is ScheduleViewController {
            UserDefaults.standard.setValue(0, forKey: "DEFAULT_MODAL_VIEW")
        } else {
            UserDefaults.standard.setValue(1, forKey: "DEFAULT_MODAL_VIEW")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView() {
        self.view = UIView()
        view.backgroundColor = Styles.Colors.stone
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        
        topView.backgroundColor = Styles.Colors.red2
        view.addSubview(topView)
        
        view.addSubview(headerView)
        headerView.delegate = self
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5

        let scheduleVC = ScheduleViewController(spot: spot, view: view)
        let agendaListVC = AgendaListViewController(spot: spot, view: view)
        
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
        viewControllers = [scheduleVC, agendaListVC]
        pageViewController.willMove(toParentViewController: self)
        addChildViewController(pageViewController)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        view.addSubview(pageViewController.view)
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self
        
        view.bringSubview(toFront: headerView)
        view.bringSubview(toFront: topView)
        
        if shouldShowSchedule() {
            headerView.makeRightButtonList(false)
            pageViewController.setViewControllers([viewControllers[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        } else {
            headerView.makeRightButtonColumns(false)
            pageViewController.setViewControllers([viewControllers[1]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
        }
        
    }

    func setupConstraints() {
       
        pageViewController.view.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        topView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.statusBarHeight)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.HEADER_HEIGHT-Styles.Sizes.statusBarHeight)
        }

    }
    
    //MARK: Helper methods
    
    func shouldShowSchedule() -> Bool {
        
        let defaultModalView = (UserDefaults.standard.value(forKey: "DEFAULT_MODAL_VIEW") as? Int) ?? 0
        
        switch defaultModalView {
        case 0:
            return true
        case 1:
            return false
        default:
            return true
        }
        
    }
    
    //swaps viewcontroller and updates the button in the header
    func getOtherViewController(_ viewController: PRKModalViewControllerChild?) -> PRKModalViewControllerChild? {
        
        if let currentVC = viewController ?? currentViewController {
            let isSchedule = currentVC is ScheduleViewController
            if isSchedule {
                return viewControllers[1]
            } else {
                return viewControllers[0]
            }
        }
        return nil

    }
    
    func showViewController(_ viewController: PRKModalViewControllerChild) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        
        if viewController is ScheduleViewController {
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Schedule/Agenda View", action: "Column/List Mode Changed", label: "Columns", value: nil).build() as! [AnyHashable: Any])
            self.pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
        } else {
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Schedule/Agenda View", action: "Column/List Mode Changed", label: "List", value: nil).build() as! [AnyHashable: Any])
            self.pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        }
        updateHeader(viewController)

    }
    
    func updateHeader(_ viewController: PRKModalViewControllerChild) {
        let isSchedule = viewController is ScheduleViewController
        if isSchedule {
            headerView.makeRightButtonList(true)
        } else {
            headerView.makeRightButtonColumns(true)
        }
    }
    
    
    //MARK: ModalHeaderViewDelegate
    
    func tappedBackButton() {
        self.delegate?.hideModalView()
    }
    
    func tappedRightButton() {
        if let otherVC = getOtherViewController(nil) {
            showViewController(otherVC)
        }
    }

    
    //MARK: PRKVerticalGestureRecognizerDelegate methods
    
    func shouldIgnoreSwipe(_ beginTap: CGPoint) -> Bool {
        return false
    }
    
    func swipeDidBegin() {
        
    }
    
    func swipeInProgress(_ yDistanceFromBeginTap: CGFloat) {
        if yDistanceFromBeginTap < 0 {
            self.delegate?.shouldAdjustTopConstraintWithOffset(-yDistanceFromBeginTap, animated: false)
        }
    }
    
    func swipeDidEndUp() {
        self.delegate?.shouldAdjustTopConstraintWithOffset(0, animated: true)
    }
    
    func swipeDidEndDown() {
        self.delegate?.hideModalView()
    }

    
    //MARK: PageViewController dataSource and delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let index = (viewControllers as [UIViewController]).index(of: viewController) {
            if index <= 0 {
                return nil
            }
            let lastIndex = (index - 1) % viewControllers.count
            return viewControllers[lastIndex]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let index = (viewControllers as [UIViewController]).index(of: viewController) {
            if index >= viewControllers.count - 1 {
                return nil
            }
            let nextIndex = (index + 1) % viewControllers.count
            return viewControllers[nextIndex]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        if let viewController = pendingViewControllers[0] as? PRKModalViewControllerChild {
            updateHeader(viewController)
        }

    }

    //NOTE: we use this to flip the icon between transitions. the method above will ensure we always end up with the right header icon
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let fromViewController = previousViewControllers[0] as? PRKModalViewControllerChild {
            if !completed {
                updateHeader(fromViewController)
            }
        }

    }
    
}

class PRKModalDelegatedViewController: AbstractViewController {
    
    var TOP_PARALLAX_HEIGHT: CGFloat = 0
    var FULL_HEIGHT: CGFloat = UIScreen.main.bounds.height - CGFloat(Styles.Sizes.tabbarHeight)
    var FULL_WIDTH: CGFloat = UIScreen.main.bounds.width

    var delegate: PRKModalViewControllerDelegate?
    var topParallaxView: UIView? { get { return nil } }
}

protocol PRKModalViewControllerDelegate {
    
    func hideModalView()
    func shouldAdjustTopConstraintWithOffset(_ distanceFromTop: CGFloat, animated: Bool)
}

class PRKModalViewControllerChild: AbstractViewController {
    
    var delegate : PRKModalViewControllerDelegate?
    
    var spot : ParkingSpot
    var parentView: UIView
    
    init(spot: ParkingSpot, view: UIView) {
        self.spot = spot
        self.parentView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
