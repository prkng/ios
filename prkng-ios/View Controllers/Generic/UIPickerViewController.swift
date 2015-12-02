//
//  UIPickerViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-12-01.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import UIKit

class UIPickerViewController: AbstractViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let toolBar = UIToolbar()
    private let picker = UIPickerView()
    
    private var pickerValues: [String]
    private var completion: (selectedValue: String?) -> Void
    
    private var lastSelectedOption: String?
    
    //note: this must be added as a subview, otherwise it will crash on dismiss
    init(pickerValues: [String], completion: (selectedValue: String?) -> Void) {
        self.pickerValues = ["clear".localizedString] + pickerValues
        self.completion = completion
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Other - UI Picker View Controller"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func setupViews() {
        
        self.view.backgroundColor = UIColor.clearColor()

        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .whiteColor()
        picker.showsSelectionIndicator = true
        
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = Styles.Colors.red2
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done".localizedString, style: UIBarButtonItemStyle.Bordered, target: self, action: "donePicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Clear".localizedString, style: UIBarButtonItemStyle.Bordered, target: self, action: "cancelPicker")

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
    }
    
    
    func setupConstraints() {
        
        picker.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        toolBar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.picker.snp_top)
        }
    }
    
    // MARK: UIPickerViewDataSource, UIPickerViewDelegate methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lastSelectedOption = pickerValues[row]
    }
    
    // MARK: Helper methods
    func donePicker() {
        if self.lastSelectedOption == "clear".localizedString {
            self.lastSelectedOption = nil
        }
        self.completion(selectedValue: self.lastSelectedOption)
        self.dismissAsModalWithTransparency(nil)
    }
    
    func cancelPicker() {
        self.completion(selectedValue: nil)
        self.dismissAsModalWithTransparency(nil)
    }
    
}
