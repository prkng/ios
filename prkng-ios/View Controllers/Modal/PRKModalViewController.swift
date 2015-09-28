//
//  PRKModalViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-09.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKModalViewController: PRKModalDelegatedViewController, ModalHeaderViewDelegate, PRKVerticalGestureRecognizerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private var _delegate : PRKModalViewControllerDelegate?
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
    
    private var pageViewController : UIPageViewController
    private var viewControllers: [PRKModalViewControllerChild]
    private var verticalRec: PRKVerticalGestureRecognizer
    private var headerView : ModalHeaderView
    
    private var currentViewController: PRKModalViewControllerChild? {
        get {
            return self.pageViewController.viewControllers?.first as? PRKModalViewControllerChild
        }
    }
    private(set) var HEADER_HEIGHT : CGFloat = Styles.Sizes.modalViewHeaderHeight

    
    init(spot: ParkingSpot, view: UIView) {
        self.spot = spot
        self.parentView = view
        headerView = ModalHeaderView()
        pageViewController = UIPageViewController()
        viewControllers = []
        verticalRec = PRKVerticalGestureRecognizer()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        headerView.topText = spot.name
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if currentViewController is ScheduleViewController {
            NSUserDefaults.standardUserDefaults().setValue(0, forKey: "DEFAULT_MODAL_VIEW")
        } else {
            NSUserDefaults.standardUserDefaults().setValue(1, forKey: "DEFAULT_MODAL_VIEW")
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
        
        view.addSubview(headerView)
        headerView.delegate = self
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5

        let scheduleVC = ScheduleViewController(spot: spot, view: view)
        let agendaListVC = AgendaListViewController(spot: spot, view: view)
        
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        viewControllers = [scheduleVC, agendaListVC]
        pageViewController.willMoveToParentViewController(self)
        addChildViewController(pageViewController)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        view.addSubview(pageViewController.view)
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self
        
        view.bringSubviewToFront(headerView)
        
        if shouldShowSchedule() {
            headerView.makeRightButtonList(false)
            pageViewController.setViewControllers([viewControllers[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        } else {
            headerView.makeRightButtonColumns(false)
            pageViewController.setViewControllers([viewControllers[1]], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
        }
        
    }

    func setupConstraints() {
       
        pageViewController.view.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.HEADER_HEIGHT)
        }

    }
    
    //MARK: Helper methods
    
    func shouldShowSchedule() -> Bool {
        
        let defaultModalView = (NSUserDefaults.standardUserDefaults().valueForKey("DEFAULT_MODAL_VIEW") as? Int) ?? 0
        
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
    func getOtherViewController(viewController: PRKModalViewControllerChild?) -> PRKModalViewControllerChild? {
        
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
    
    func showViewController(viewController: PRKModalViewControllerChild) {
        
        if viewController is ScheduleViewController {
            self.pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
        } else {
            self.pageViewController.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
        updateHeader(viewController)

    }
    
    func updateHeader(viewController: PRKModalViewControllerChild) {
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
    
    func shouldIgnoreSwipe(beginTap: CGPoint) -> Bool {
        return false
    }
    
    func swipeDidBegin() {
        
    }
    
    func swipeInProgress(yDistanceFromBeginTap: CGFloat) {
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
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if let index = (viewControllers as [UIViewController]).indexOf(viewController) {
            if index <= 0 {
                return nil
            }
            let lastIndex = (index - 1) % viewControllers.count
            return viewControllers[lastIndex]
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let index = (viewControllers as [UIViewController]).indexOf(viewController) {
            if index >= viewControllers.count - 1 {
                return nil
            }
            let nextIndex = (index + 1) % viewControllers.count
            return viewControllers[nextIndex]
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {

        if let viewController = pendingViewControllers[0] as? PRKModalViewControllerChild {
            updateHeader(viewController)
        }

    }

    //NOTE: we use this to flip the icon between transitions. the method above will ensure we always end up with the right header icon
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let fromViewController = previousViewControllers[0] as? PRKModalViewControllerChild {
            if !completed {
                updateHeader(fromViewController)
            }
        }

    }
    
}

class PRKModalDelegatedViewController: AbstractViewController {
    
    var TOP_PARALLAX_HEIGHT: CGFloat = 0
    var FULL_HEIGHT: CGFloat = UIScreen.mainScreen().bounds.height - CGFloat(Styles.Sizes.tabbarHeight)
    var FULL_WIDTH: CGFloat = UIScreen.mainScreen().bounds.width

    var delegate: PRKModalViewControllerDelegate?
    var topParallaxView: UIView? { get { return nil } }
}

protocol PRKModalViewControllerDelegate {
    
    func hideModalView()
    func shouldAdjustTopConstraintWithOffset(distanceFromTop: CGFloat, animated: Bool)
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
