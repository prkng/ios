//
//  DurationSelectionView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 30/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class DurationSelectionView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var topContainer : UIView
    var bottomContainer : UIView
    var selectionControl : SelectionControl
    var pickerView : UIPickerView
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var hours : Array<String>
    var minutes : Array<String>
    var amPm : Array<String>
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        didSetupSubviews = false
        didSetupConstraints = true
        
        topContainer = UIView()
        bottomContainer = UIView()
        pickerView = UIPickerView()
        
        hours = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        minutes = ["00", "10", "20", "30" , "40", "50"]
        amPm = ["AM", "PM"]
        
        selectionControl = SelectionControl(titles : [NSLocalizedString("arrival", comment : ""), NSLocalizedString("departure", comment : "") ])
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        backgroundColor = UIColor.clear
        topContainer.backgroundColor = UIColor.clear
        addSubview(topContainer)
        
        bottomContainer.backgroundColor = Styles.Colors.stone
        addSubview(bottomContainer)
        
        topContainer.addSubview(selectionControl)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        bottomContainer.addSubview(pickerView)

        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(55)
        }
        
        bottomContainer.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(130)
        }
        
        selectionControl.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topContainer)
            make.left.equalTo(self.topContainer)
            make.right.equalTo(self.topContainer)
            make.height.equalTo(55)
        }
        
        pickerView.snp_makeConstraints { (make) -> () in
            make.center.equalTo(bottomContainer)
        }
        
        didSetupConstraints = true
    }
    
    
    
    // UIPickerViewDataSource
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return hours.count
        } else if (component == 1){
            return minutes.count
        }
        
        return amPm.count
    }
    
    
    
    // returns width of column and height of row for each component.
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 38
    }
    //    optional func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pView = view as? UILabel
        
        if (pView == nil) {
            pView = pickerLabel ()
        }
        
        
        switch component {
        case 0 :
            pView?.text = hours[row]
        case 1:
            pView?.text = minutes[row]
        case 2:
            pView?.text = amPm[row]
            
        default:
            break
        }
        
        
        return pView!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    
    func pickerLabel () -> UILabel {
        
        let label = UILabel()
        
        label.font = Styles.FontFaces.regular(22)
        label.textColor = Styles.Colors.red2
        
        return label
        
    }
    
    
    
    func getHour() -> Int {
        var hour : Int = pickerView.selectedRow(inComponent: 0)
        let am : Bool = (pickerView.selectedRow(inComponent: 0) == 0)
        
        if (!am) {
            hour += 12
        }
        
        return hour
        
    }
    
    func getMinutes() -> Int {
        return (pickerView.selectedRow(inComponent: 0) * 10)
    }
    
}




