//
//  PRKWebViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 18/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKWebViewController: AbstractViewController, UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    fileprivate let backgroundImageView = UIImageView(image: UIImage(named: "bg_login"))
    fileprivate var statusBar = UIView()
    fileprivate let webView = UIWebView()
    
    fileprivate var englishUrl: String
    fileprivate var frenchUrl: String
    
    var didFinishLoadingCallback: ((PRKWebViewController, UIWebView) -> ())?
    var willLoadRequestCallback: ((PRKWebViewController, URLRequest) -> ())?
    
    fileprivate let backButton = ViewFactory.rectangularBackButton()
    fileprivate let backLabel = UILabel()
    fileprivate let backArrow = UIImageView()

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let pre: AnyObject = Locale.preferredLanguages[0] as AnyObject
        let str = "\(pre)"
        let lang = str.substring(to: str.characters.index(str.startIndex, offsetBy: 2))
        
        var url : URL
        if lang == "fr" {
            url = URL(string : frenchUrl)!
        } else {
            url = URL(string : englishUrl)!
        }
        SVProgressHUD.show()
        webView.loadRequest(URLRequest(url: url))
        
    }
    
    func setupViews() {
        
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        
        statusBar.backgroundColor = Styles.Colors.midnight2
        view.addSubview(statusBar)
        
        webView.delegate = self
        webView.backgroundColor = UIColor.clear
        view.addSubview(webView)
        
        backButton.addTarget(self, action: #selector(PRKWebViewController.backButtonTapped), for: .touchUpInside)
        backButton.layer.masksToBounds = false
        backButton.layer.shadowOffset = CGSize(width: 0, height: -1.0)
        backButton.layer.shadowRadius = 5
        backButton.layer.shadowColor = UIColor.black.cgColor
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
            navVC.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: UIWebViewDelegate
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
        didFinishLoadingCallback?(self, webView)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        willLoadRequestCallback?(self, request)
        return true
    }
    
    
}
