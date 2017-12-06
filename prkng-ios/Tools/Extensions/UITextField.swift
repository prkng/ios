//
//  UITextField.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-11.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension UITextField {

    func modifyClearButtonWithImageNamed(_ imageName: String, color: UIColor) {
        let image = UIImage(named: imageName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(image, for: UIControlState())
        button.tintColor = color
        button.frame = CGRect(x: 0, y: 0, width: 35, height: SearchFilterView.FIELD_HEIGHT)
        button.contentMode = UIViewContentMode.left
        button.addTarget(self, action: #selector(UITextField.textFieldClear(_:)), for: UIControlEvents.touchUpInside)
        button.backgroundColor = Styles.Colors.cream1
        self.rightView = button
        self.rightViewMode = UITextFieldViewMode.always
    }
    
    func textFieldClear(_ sender: AnyObject) {
        self.delegate?.textFieldShouldClear!(self)
    }
    
}
