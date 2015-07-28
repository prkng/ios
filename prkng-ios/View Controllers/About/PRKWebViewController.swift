//
//  PRKWebViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 18/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKWebViewController: AbstractViewController, UIWebViewDelegate {
    
    let backgroundImageView = UIImageView(image: UIImage(named: "bg_login"))
    var statusBar = UIView()
    let webView = UIWebView()
    
    var englishUrl: String
    var frenchUrl: String
    
    let backButton = ViewFactory.hugeButton()
    
    init(englishUrl: String, frenchUrl: String) {
        self.englishUrl = englishUrl
        self.frenchUrl = frenchUrl
        super.init(nibName: nil, bundle: nil)

    }

    required init(coder aDecoder: NSCoder) {
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
        let lang = str.substringToIndex(advance(str.startIndex, 2))
        
        var url : NSURL
        if lang == "fr" {
            url = NSURL(string : frenchUrl)!
        } else {
            url = NSURL(string : englishUrl)!
        }
        SVProgressHUD.showWithMaskType(.Clear)
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
        
        backButton.setTitle("back".localizedString, forState: .Normal)
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
        
        backButton.layer.masksToBounds = false
        backButton.layer.shadowOffset = CGSizeMake(0, -1.0)
        backButton.layer.shadowRadius = 5
        backButton.layer.shadowColor = UIColor.blackColor().CGColor
        backButton.layer.shadowOpacity = 0.1
        view.addSubview(backButton)
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
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
    }
    
    // MARK: Button Handlers
    
    func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: UIWebViewDelegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    
}