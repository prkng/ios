//
//  TutorialContentViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 26/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TutorialContentViewController: GAITrackedViewController {
    
    var backgroundImageView : UIImageView
    var imageView : UIImageView
    var textLabel : UILabel
    var pageIndex : Int
    
    private var SMALL_SCREEN_IMAGE_HEIGHT_DIFFERENCE = UIScreen.mainScreen().bounds.height == 480 ? 30 : 0
    
    init(backgroundImage : UIImage, image : UIImage, text : String, index : Int) {
        backgroundImageView = UIImageView()
        imageView = UIImageView()
        textLabel = UILabel()
        pageIndex = index
        super.init(nibName: nil, bundle: nil)
        backgroundImageView.image = backgroundImage
        imageView.image = image
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.5
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        textLabel.attributedText = attrString


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Intro - Tutorial Single Page View"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupViews() {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(imageView)
        
        textLabel.textColor = Styles.Colors.cream1
        textLabel.font = Styles.FontFaces.light(17)
        textLabel.numberOfLines = 0
        textLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(textLabel)
    }
    
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.top.lessThanOrEqualTo(self.view).with.offset(60)
            make.left.equalTo(self.view).with.offset(35)
            make.right.equalTo(self.view).with.offset(-35)
            make.height.lessThanOrEqualTo(self.imageView.snp_width).with.offset(0 - self.SMALL_SCREEN_IMAGE_HEIGHT_DIFFERENCE)
        }
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.top.lessThanOrEqualTo(self.imageView.snp_bottom).with.offset(20)
            make.left.equalTo(self.view).with.offset(40)
            make.right.equalTo(self.view).with.offset(-40)
            make.bottom.lessThanOrEqualTo(self.view).with.offset(-40 - TutorialViewController.PAGE_CONTROL_BOTTOM_OFFSET)
        }
        
    }
    
}
