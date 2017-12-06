//
//  UIListPickerViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-12-01.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import UIKit

class UIListPickerViewController: AbstractViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    fileprivate let toolBar = UIToolbar()
    fileprivate let picker = UIPickerView()
    
    fileprivate var pickerValues: [String]
    fileprivate var completion: (_ selectedValue: String?) -> Void
    
    fileprivate var lastSelectedOption: String?
    
    //note: this must be added as a subview, otherwise it will crash on dismiss
    init(pickerValues: [String], completion: @escaping (_ selectedValue: String?) -> Void) {
        self.pickerValues = pickerValues
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
        self.screenName = "Other - UI List Picker View Controller"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func setupViews() {
        
        self.view.backgroundColor = UIColor.clear

        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.showsSelectionIndicator = true
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Styles.Colors.red2
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done".localizedString, style: UIBarButtonItemStyle.bordered, target: self, action: #selector(UIListPickerViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Clear".localizedString, style: UIBarButtonItemStyle.bordered, target: self, action: #selector(UIListPickerViewController.cancelPicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lastSelectedOption = pickerValues[row]
    }
    
    // MARK: Helper methods
    func donePicker() {
        if self.lastSelectedOption == "clear".localizedString {
            self.lastSelectedOption = nil
        } else if self.lastSelectedOption == nil {
            self.lastSelectedOption = pickerValues.first
        }

        self.completion(self.lastSelectedOption)
        self.dismissAsModalWithTransparency(nil)
    }
    
    func cancelPicker() {
        self.completion(nil)
        self.dismissAsModalWithTransparency(nil)
    }
    
}
