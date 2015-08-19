//
//  UITextField.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-11.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension UITextField {

    func modifyClearButtonWithImageNamed(imageName: String, color: UIColor) {
        let image = UIImage(named: imageName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.setImage(image, forState: UIControlState.Normal)
        button.tintColor = color
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 15)
        button.contentMode = UIViewContentMode.Left
        button.addTarget(self, action: "textFieldClear:", forControlEvents: UIControlEvents.TouchUpInside)
        self.rightView = button
        self.rightViewMode = UITextFieldViewMode.WhileEditing
    }
    
    func textFieldClear(sender: AnyObject) {
        self.delegate?.textFieldShouldClear!(self)
    }
    
}
