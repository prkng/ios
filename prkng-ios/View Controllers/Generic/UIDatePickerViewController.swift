//
//  UIDatePickerViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-20.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import UIKit

class UIDatePickerViewController: AbstractViewController {
    
    fileprivate let toolBar = UIToolbar()
    fileprivate let datePicker = UIDatePicker()
    
    fileprivate var dateFormatter: DateFormatter
    
    fileprivate var completion: ((_ date: Date, _ dateString: String) -> Void)?
    
    var delegate: UIDatePickerViewControllerDelegate? {
        didSet {
            self.delegate?.didSelectDate(date, dateString: dateString)
        }
    }
    
    var date: Date { return datePicker.date }
    var dateString: String { return dateFormatter.string(from: date) }
    
    //note: this must be added as a subview, otherwise it will crash on dismiss
    init(datePickerMode: UIDatePickerMode, minuteInterval: Int, minimumDate: Date, maximumDate: Date, dateFormatter: DateFormatter, completion: ((_ date: Date, _ dateString: String) -> Void)?) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupViews() {
        
        datePicker.backgroundColor = UIColor.white
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Styles.Colors.red2
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done".localizedString, style: UIBarButtonItemStyle.bordered, target: self, action: #selector(UIDatePickerViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
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
        self.completion?(date, dateString)
        self.delegate?.didSelectDate(date, dateString: dateString)
        self.dismissAsModalWithTransparency(nil)
    }
    
}

protocol UIDatePickerViewControllerDelegate {
    func didSelectDate(_ date: Date, dateString: String)
}
