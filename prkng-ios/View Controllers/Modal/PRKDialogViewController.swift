//
//  Created by Antonino Urbano on 2015-09-15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum PRKDialogType {
    case yesNo
    case list
}

protocol PRKDialogViewControllerDelegate {
    func listButtonTapped(_ index: Int)
}

class PRKDialogViewController: AbstractViewController {

    var containerView = UIView()
    var centerContainerView = UIView()
    
    var headerImageView = UIImageView()
    var iconView = UIImageView()
    
    var titleContainer = UIView()
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    
    var textLabel = UILabel()
    
    var yesNoHorizontalSeparator = UIView()
    var yesNoVerticalSeparator = UIView()
    var yesNoContainer = UIView()
    var yesButton = ViewFactory.dialogChoiceButton()
    var noButton = ViewFactory.dialogChoiceButton()

    var listButtonsContainer = UIView()
    var listButtons = [UIButton]()
    var listButtonSeparators = [UIView]()
    
    var type: PRKDialogType
    
    var delegate: PRKDialogViewControllerDelegate?
    
    let X_TRANSFORM = CGFloat(100)
    let Y_TRANSFORM = UIScreen.main.bounds.size.height
    
    let cornerRadius: CGFloat = 8
    
    var titleIconName: String
    var headerImageName: String
    var titleText: String
    var subTitleText: String
    var messageText: String
    
    var yesNoContainerHeight: Int {
        
        if self.type == .yesNo {
            return 60
        } else {
            return 0
        }
    }
    
    var listButtonContainerHeight: Int {
        
        if self.type == .yesNo {
            return 0
        } else {
            return listButtons.count * 50
        }
    }
    
    var bottomContainerHeight: Int {

        if self.type == .yesNo {
            return 60
        } else {
            return listButtons.count * 50
        }

    }
    
    init(titleIconName: String, headerImageName: String, titleText: String, subTitleText: String, messageText: String) {

        self.titleIconName = titleIconName
        self.headerImageName = headerImageName
        self.titleText = titleText
        self.subTitleText = subTitleText
        self.messageText = messageText
        
        self.type = .yesNo
        
        super.init(nibName: nil, bundle: nil)
    }

    init(titleIconName: String, headerImageName: String, titleText: String, subTitleText: String, messageText: String, buttonLabels: [String]) {
        
        self.titleIconName = titleIconName
        self.headerImageName = headerImageName
        self.titleText = titleText
        self.subTitleText = subTitleText
        self.messageText = messageText
        
        for i in 0..<buttonLabels.count {
            let title = buttonLabels[i]
            let button = ViewFactory.dialogChoiceButton()
            button.setTitle(title, for: UIControlState())
            
            if i == 0 {
                button.setTitleColor(Styles.Colors.petrol1, for: UIControlState())
                button.titleLabel?.font = Styles.FontFaces.regular(15)
            } else {
                button.setTitleColor(Styles.Colors.petrol2, for: UIControlState())
                button.titleLabel?.font = Styles.FontFaces.light(15)
            }
            
            listButtons.append(button)
        }
        
        //button height should be 50 points
        self.type = .list
        
        super.init(nibName: nil, bundle: nil)
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
        self.screenName = "Geofence Notification View"
        
        if #available(iOS 8.0, *) {
            let translateTransform = CATransform3DMakeTranslation(X_TRANSFORM, Y_TRANSFORM, 0)
            let rotateTransform = CATransform3DMakeRotation(CGFloat(-M_PI_4), 0, 0, 1)
            let scaleTransform = CATransform3DMakeScale(0.5, 0.5, 1)            
            containerView.layer.transform = CATransform3DConcat(CATransform3DConcat(rotateTransform, translateTransform), scaleTransform)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 8.0, *) {
            animate()
        }
    }
    
    func setupSubviews() {
        
        view.backgroundColor = Styles.Colors.transparentBackground
        
        self.view.addSubview(containerView)
        
        centerContainerView.layer.cornerRadius = cornerRadius
        centerContainerView.backgroundColor = Styles.Colors.cream2
        containerView.addSubview(centerContainerView)
        
        titleContainer.layer.cornerRadius = cornerRadius
        titleContainer.backgroundColor = Styles.Colors.cream2
        titleContainer.clipsToBounds = true
        centerContainerView.addSubview(titleContainer)
        
        headerImageView.image = UIImage(named: headerImageName)
        centerContainerView.addSubview(headerImageView)
        
        iconView.image = UIImage(named: titleIconName)
        centerContainerView.addSubview(iconView)

        titleLabel.font = Styles.Fonts.h2Variable
        titleLabel.textColor = Styles.Colors.petrol2
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = titleText
        titleLabel.numberOfLines = 0
        centerContainerView.addSubview(titleLabel)
        
        subtitleLabel.font = Styles.FontFaces.regular(15)
        subtitleLabel.textColor = Styles.Colors.red2
        subtitleLabel.textAlignment = NSTextAlignment.center
        subtitleLabel.text = subTitleText
        subtitleLabel.numberOfLines = 0
        centerContainerView.addSubview(subtitleLabel)
        
        textLabel.font = Styles.FontFaces.light(15)
        textLabel.textColor = Styles.Colors.petrol2
        textLabel.numberOfLines = 0
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.text = messageText
        centerContainerView.addSubview(textLabel)
        
        //yes/no container
        yesButton.addTarget(self, action: #selector(PRKDialogViewController.yesButtonTapped), for: UIControlEvents.touchUpInside)
        yesButton.setTitle("yes".localizedString, for: UIControlState())
        noButton.setTitle("no".localizedString, for: UIControlState())
        noButton.setTitleColor(Styles.Colors.red2, for: UIControlState())
        noButton.addTarget(self, action: #selector(PRKDialogViewController.noButtonTapped), for: UIControlEvents.touchUpInside)

        yesNoContainer.addSubview(yesButton)
        yesNoContainer.addSubview(noButton)
        yesNoContainer.layer.cornerRadius = cornerRadius
        yesNoContainer.clipsToBounds = true
        containerView.addSubview(yesNoContainer)
        
        yesNoHorizontalSeparator.backgroundColor = Styles.Colors.beige1
        containerView.addSubview(yesNoHorizontalSeparator)
        yesNoVerticalSeparator.backgroundColor = Styles.Colors.beige1
        containerView.addSubview(yesNoVerticalSeparator)
        
        //other buttons container
        listButtonsContainer.layer.cornerRadius = cornerRadius
        listButtonsContainer.clipsToBounds = true
        containerView.addSubview(listButtonsContainer)
        for button in listButtons {
            button.addTarget(self, action: #selector(PRKDialogViewController.listButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            listButtonsContainer.addSubview(button)
            let sep = UIView()
            sep.backgroundColor = Styles.Colors.beige1
            listButtonSeparators.append(sep)
            containerView.addSubview(sep)
        }
        
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        centerContainerView.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self.view).offset(-self.bottomContainerHeight/2)
            make.left.equalTo(self.view).offset(24)
            make.right.equalTo(self.view).offset(-24)
        }
        
        iconView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.centerContainerView)
            make.centerY.equalTo(self.centerContainerView.snp_top)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        if self.type == .yesNo {
            titleContainer.snp_makeConstraints { (make) -> () in
                make.top.equalTo(self.centerContainerView)
                make.left.equalTo(self.centerContainerView)
                make.right.equalTo(self.centerContainerView)
                make.bottom.equalTo(self.yesNoContainer)            }
        } else {
            titleContainer.snp_makeConstraints { (make) -> () in
                make.top.equalTo(self.centerContainerView)
                make.left.equalTo(self.centerContainerView)
                make.right.equalTo(self.centerContainerView)
                make.bottom.equalTo(self.listButtonsContainer)
            }
        }

        headerImageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainer)
            make.left.equalTo(self.centerContainerView)
            make.right.equalTo(self.centerContainerView)
            make.height.equalTo(108)
        }

        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerImageView.snp_bottom).offset(10)
            make.left.equalTo(self.centerContainerView)
            make.right.equalTo(self.centerContainerView)
        }
        
        subtitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).offset(7)
            make.left.equalTo(self.centerContainerView)
            make.right.equalTo(self.centerContainerView)
        }
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.subtitleLabel.snp_bottom).offset(7)
            make.left.equalTo(self.centerContainerView).offset(24)
            make.right.equalTo(self.centerContainerView).offset(-24)
            make.bottom.equalTo(self.centerContainerView).offset(-22)
        }
        
        // yes/no stuff
        
        yesNoContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.yesNoContainerHeight)
            make.top.equalTo(self.textLabel.snp_bottom).offset(14)
            make.left.equalTo(self.centerContainerView)
            make.right.equalTo(self.centerContainerView)
        }

        yesNoHorizontalSeparator.snp_makeConstraints { (make) -> () in
            make.height.equalTo(0.5)
            make.top.equalTo(self.yesNoContainer)
            make.left.equalTo(self.yesNoContainer)
            make.right.equalTo(self.yesNoContainer)
        }

        yesNoVerticalSeparator.snp_makeConstraints { (make) -> () in
            make.width.equalTo(0.5)
            make.top.equalTo(self.yesNoContainer)
            make.bottom.equalTo(self.yesNoContainer)
            make.left.equalTo(self.yesNoContainer.snp_centerX)
        }

        yesButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.yesNoContainer)
            make.bottom.equalTo(self.yesNoContainer)
            make.left.equalTo(self.yesNoContainer)
            make.right.equalTo(self.yesNoContainer.snp_centerX)
        }

        noButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.yesNoContainer)
            make.bottom.equalTo(self.yesNoContainer)
            make.left.equalTo(self.yesNoContainer.snp_centerX)
            make.right.equalTo(self.yesNoContainer)
        }
        
        // list stuff
        
        listButtonsContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.listButtonContainerHeight)
            make.top.equalTo(self.textLabel.snp_bottom).offset(14)
            make.left.equalTo(self.centerContainerView)
            make.right.equalTo(self.centerContainerView)
        }

        var topConstraint = listButtonsContainer.snp_top
        
        for i in 0..<listButtons.count {
            
            let button = listButtons[i]
            let sep = listButtonSeparators[i]
            
            button.snp_makeConstraints(closure: { (make) -> () in
                make.top.equalTo(topConstraint)
                make.left.equalTo(self.listButtonsContainer)
                make.right.equalTo(self.listButtonsContainer)
                make.height.equalTo(50)
            })
        
            sep.snp_makeConstraints(closure: { (make) -> () in
                make.top.equalTo(topConstraint)
                make.left.equalTo(self.listButtonsContainer)
                make.right.equalTo(self.listButtonsContainer)
                make.height.equalTo(0.5)
            })
            
            topConstraint = button.snp_bottom
        }

    }
    
    func animate() {
        
        let translateAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
        translateAnimation?.fromValue = NSValue(cgPoint: CGPoint(x: X_TRANSFORM, y: Y_TRANSFORM))
        translateAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
        translateAnimation?.springBounciness = 10
        translateAnimation?.springSpeed = 12
        
        let rotateAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
        rotateAnimation?.fromValue = NSNumber(value: -M_PI_4 as Double)
        rotateAnimation?.toValue = NSNumber(value: 0 as Float)
        rotateAnimation?.springBounciness = 10
        rotateAnimation?.springSpeed = 3
        
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation?.fromValue = NSValue(cgSize: CGSize(width: 0.5, height: 0.5))
        scaleAnimation?.toValue =  NSValue(cgSize: CGSize(width: 1, height: 1))
        scaleAnimation?.duration = 0.5
        
        containerView.layer.pop_add(translateAnimation, forKey: "translateAnimation")
        containerView.layer.pop_add(rotateAnimation, forKey: "rotateAnimation")
        containerView.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")

    }
    
    func showOnViewController(_ viewController: UIViewController) {
        
        viewController.addChildViewController(self)
        viewController.view.addSubview(self.view)
        self.didMove(toParentViewController: viewController)
        
        self.view.snp_makeConstraints(closure: { (make) -> () in
            make.edges.equalTo(viewController.view)
        })
        
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.alpha = 1.0
        })
        
    }

    func yesButtonTapped() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.geofencingNotificationResponse(true)
        dismissDialog()
    }
    
    func noButtonTapped() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.geofencingNotificationResponse(false)
        dismissDialog()
    }
    
    func listButtonTapped(_ sender: UIButton) {
        for i in 0..<listButtons.count {
            if listButtons[i] == sender {
                self.delegate?.listButtonTapped(i)
                dismissDialog()
            }
        }
    }
    
    func dismissDialog() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
                self.didMove(toParentViewController: nil)
        })
    }
    
}
