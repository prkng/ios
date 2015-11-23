//
//  PRKWebViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 18/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKWebViewController: AbstractViewController, UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    private let backgroundImageView = UIImageView(image: UIImage(named: "bg_login"))
    private var statusBar = UIView()
    private let webView = UIWebView()
    
    private var englishUrl: String
    private var frenchUrl: String
    
    var didFinishLoadingCallback: ((PRKWebViewController, UIWebView) -> ())?
    
    private let backButton = ViewFactory.rectangularBackButton()
    private let backLabel = UILabel()
    private let backArrow = UIImageView()

    init(url: String) {
        self.englishUrl = url
        self.frenchUrl = url
        super.init(nibName: nil, bundle: nil)
    }

    init(englishUrl: String, frenchUrl: String) {
        self.englishUrl = englishUrl
        self.frenchUrl = frenchUrl
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let pre: AnyObject = NSLocale.preferredLanguages()[0]
        let str = "\(pre)"
        let lang = str.substringToIndex(str.startIndex.advancedBy(2))
        
        var url : NSURL
        if lang == "fr" {
            url = NSURL(string : frenchUrl)!
        } else {
            url = NSURL(string : englishUrl)!
        }
        SVProgressHUD.show()
        webView.loadRequest(NSURLRequest(URL: url))
        
    }
    
    func setupViews() {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        statusBar.backgroundColor = Styles.Colors.midnight2
        view.addSubview(statusBar)
        
        webView.delegate = self
        webView.backgroundColor = UIColor.clearColor()
        view.addSubview(webView)
        
        backButton.addTarget(self, action: "backButtonTapped", forControlEvents: .TouchUpInside)
        backButton.layer.masksToBounds = false
        backButton.layer.shadowOffset = CGSizeMake(0, -1.0)
        backButton.layer.shadowRadius = 5
        backButton.layer.shadowColor = UIColor.blackColor().CGColor
        backButton.layer.shadowOpacity = 0.1
        view.addSubview(backButton)
        
        backLabel.textColor = Styles.Colors.cream1
        backLabel.font = Styles.FontFaces.regular(14)
        backLabel.text = "back".localizedString
        backButton.addSubview(backLabel)
        
        backArrow.image = UIImage(named: "btn_back_outline")
        backButton.addSubview(backArrow)
    }
    
    
    func setupConstraints() {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        statusBar.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        webView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.statusBar.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.backButton.snp_top)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(48)
        }
        
        backArrow.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 8, height: 8))
            make.left.equalTo(self.backButton).offset(40)
            make.centerY.equalTo(self.backButton)
        }

        backLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.backArrow).offset(12)
            make.centerY.equalTo(self.backButton)
        }

    }
    
    // MARK: Button Handlers
    
    func backButtonTapped() {
        if let navVC = self.navigationController {
            navVC.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: UIWebViewDelegate
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
        didFinishLoadingCallback?(self, webView)
    }
    
    
}
