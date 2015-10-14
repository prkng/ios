//
//  SearchResult.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchResult: NSObject, MKAnnotation, MGLAnnotation {
    
    var title : String?
    var subtitle: String?
    var location : CLLocation
    
    var userInfo: [String:AnyObject] //to maintain backwards compatibility with mapbox

    init(title: String, subtitle: String, location : CLLocation) {
        self.title = title
        self.subtitle = subtitle
        self.location = location
        self.userInfo = [String:AnyObject]()
    }

    init(title: String, location : CLLocation) {
        self.title = title
        self.location = location
        self.userInfo = [String:AnyObject]()
    }
    
    //MARK- MKAnnotation
    var coordinate: CLLocationCoordinate2D { get { return location.coordinate } }

    func calloutView() -> (UIView, UIView) {
        
        let maximumTotalWidth = Int(UIScreen.mainScreen().bounds.width) - 40
        let leftViewLabelBuffer = 10 //this is the size of the left view minus 10 points on the left of it
        let maxTitleWidth = maximumTotalWidth - 55 - leftViewLabelBuffer
        let minTitleWidth = 135 - leftViewLabelBuffer
        
        let rightView = UIButton()
        rightView.setImage(UIImage(named:"btn_directions_red"), forState: .Normal)
        rightView.bounds = CGRect(x: 0, y: 0, width: 55, height: 44) //actual width of image is 41.5 points
        rightView.imageView?.contentMode = .Left
        
        let leftView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Left
        titleLabel.font = Styles.FontFaces.regular(14)
        titleLabel.textColor = Styles.Colors.red2
        titleLabel.text = self.title
        leftView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .Left
        subtitleLabel.font = Styles.FontFaces.light(12)
        subtitleLabel.textColor = Styles.Colors.red2
        subtitleLabel.text = self.subtitle
        leftView.addSubview(subtitleLabel)
        
        let minLabelWidth = max(titleLabel.intrinsicContentSize().width, subtitleLabel.intrinsicContentSize().width, CGFloat(minTitleWidth))
        let labelWidth = min(minLabelWidth, CGFloat(maxTitleWidth))
        leftView.frame = CGRect(x: 0, y: 0, width: (labelWidth + CGFloat(leftViewLabelBuffer)), height: 44)
        titleLabel.frame = CGRect(x: 10, y: 0, width: labelWidth, height: 30)
        subtitleLabel.frame = CGRect(x: 10, y: 15, width: labelWidth, height: 30)
        
        //the separator was manually placed because for the mapbox callout, we don't know exactly how the left and right views are placed.
        let separator = UIView(frame: CGRect(x: leftView.bounds.width + 5, y: 0, width: 1, height: leftView.bounds.height))
        separator.backgroundColor = Styles.Colors.transparentBlack
        leftView.addSubview(separator)
        
        return (leftView, rightView)
    }

}
