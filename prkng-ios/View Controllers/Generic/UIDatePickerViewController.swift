//
//  UIDatePickerViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-20.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import UIKit

class UIDatePickerViewController: AbstractViewController {
    
    private let toolBar = UIToolbar()
    private let datePicker = UIDatePicker()
    
    private var dateFormatter: NSDateFormatter
    
    private var completion: ((date: NSDate, dateString: String) -> Void)?
    
    var delegate: UIDatePickerViewControllerDelegate? {
        didSet {
            self.delegate?.didSelectDate(date, dateString: dateString)
        }
    }
    
    var date: NSDate { return datePicker.date }
    var dateString: String { return dateFormatter.stringFromDate(date) }
    
    //note: this must be added as a subview, otherwise it will crash on dismiss
    init(datePickerMode: UIDatePickerMode, minuteInterval: Int, minimumDate: NSDate, maximumDate: NSDate, dateFormatter: NSDateFormatter, completion: ((date: NSDate, dateString: String) -> Void)?) {
        self.datePicker.minimumDate = minimumDate
        self.datePicker.maximumDate = maximumDate
        self.datePicker.datePickerMode = datePickerMode
        self.datePicker.minuteInterval = minuteInterval
        self.dateFormatter = dateFormatter
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.datePicker.setDate(minimumDate, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Other - UI Date Picker View Controller"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupViews() {
        
        self.view.backgroundColor = Styles.Colors.transparentBlack

        datePicker.backgroundColor = UIColor.whiteColor()
        
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Styles.Colors.red2
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done".localizedString, style: UIBarButtonItemStyle.Bordered, target: self, action: "donePicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.view.addSubview(datePicker)
        self.view.addSubview(toolBar)
    }
    
    
    func setupConstraints() {
        
        datePicker.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        toolBar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.datePicker.snp_top)
        }
    }
    
    // MARK: Helper methods
    func donePicker() {
        self.completion?(date: date, dateString: dateString)
        self.delegate?.didSelectDate(date, dateString: dateString)
        self.dismissAsModalWithTransparency(nil)
    }
    
}

protocol UIDatePickerViewControllerDelegate {
    func didSelectDate(date: NSDate, dateString: String)
}