//
//  TermsViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 18/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TermsViewController: AbstractViewController, UIWebViewDelegate {
    
    let backgroundImageView = UIImageView(image: UIImage(named: "bg_login"))
    var statusBar = UIView()
    let webView = UIWebView()
    
    let termsEnglishUrl = "http://prk.ng/terms/"
    let termsFrenchUrl = "http://prk.ng/fr/conditions/"
    
    let backButton = ViewFactory.redBackButton()
    
    
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
            url = NSURL(string : termsFrenchUrl)!
        } else {
            url = NSURL(string : termsEnglishUrl)!
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
        
        
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
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
            make.bottom.equalTo(self.view)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 80, height: 26))
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).with.offset(-20)
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
