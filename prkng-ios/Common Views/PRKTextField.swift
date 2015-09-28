//
//  PRKTextField.swift
//  
//
//  Created by Antonino Urbano on 2015-07-15.
//
//

import UIKit

class PRKTextField: UIView, UITextFieldDelegate {

    private var containerView: UIView
    private var topLine: UIView
    private var bottomLine: UIView
    private var textField: UITextField
    private var forgotButton: UIButton
    
    private var fieldType: PRKTextFieldType
    var delegate: PRKTextFieldDelegate?
    
    var placeholderText: String {
        return textField.placeholder ?? ""
    }
    var text: String {
        get {
            return textField.text ?? ""
        }
        set(newValue) {
            textField.text = newValue
        }
    }
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool

    internal let background_color = Styles.Colors.midnight2
    internal let text_color = Styles.Colors.cream2
    var placeholderAttributes = [NSFontAttributeName: Styles.Fonts.h3r, NSForegroundColorAttributeName: Styles.Colors.petrol1]
    var textFont = Styles.Fonts.h3r
    
    convenience init(placeHolder: String, fieldType: PRKTextFieldType) {
        
        self.init()
        self.fieldType = fieldType
        
        self.textField.textAlignment = NSTextAlignment.Natural
        self.textField.clearButtonMode = UITextFieldViewMode.Always
        self.textField.keyboardType = UIKeyboardType.Default

        switch fieldType {
        case .Normal:
            break
        case .NormalNoAutocorrect:
            textField.autocorrectionType = UITextAutocorrectionType.No
            break
        case .Email:
            textField.autocorrectionType = UITextAutocorrectionType.No
            self.textField.keyboardType = UIKeyboardType.EmailAddress
            break
        case .Password:
            self.textField.secureTextEntry = true
            break
        case .PasswordWithForgotButton:
            self.textField.secureTextEntry = true
            self.forgotButton.hidden = false
            break
        case .NotEditable:
            self.textField.enabled = false
            self.textField.textAlignment = NSTextAlignment.Center
            textField.clearButtonMode = UITextFieldViewMode.Never
            break
        }

        textField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: placeholderAttributes)

    }
    
    override init(frame: CGRect) {
        containerView = UIView()
        topLine = UIView()
        bottomLine = UIView()
        textField = UITextField()
        forgotButton = ViewFactory.redRoundedButton()
        
        fieldType = .Normal
        
        didsetupSubviews = false
        didSetupConstraints = true

        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didsetupSubviews) {
            setupSubviews()
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }

    override func updateConstraints() {
        if(!didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }

    func setupSubviews() {

        containerView.backgroundColor = background_color
        self.addSubview(containerView)
        
        textField.textColor = text_color
        textField.delegate = self
        textField.font = textFont
        textField.textColor = Styles.Colors.cream1
        textField.keyboardAppearance = UIKeyboardAppearance.Default

        forgotButton.setTitle("forgot_password_text".localizedString, forState: UIControlState.Normal)
        forgotButton.hidden = fieldType != .PasswordWithForgotButton
        forgotButton.addTarget(self, action: "forgotButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        topLine.backgroundColor = Styles.Colors.transparentWhite
        bottomLine.backgroundColor = Styles.Colors.transparentBlack
        
        containerView.addSubview(textField)
        containerView.addSubview(topLine)
        containerView.addSubview(bottomLine)
        containerView.addSubview(forgotButton)

        didsetupSubviews = true
        didSetupConstraints = false

    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }

        
        if fieldType != .PasswordWithForgotButton {
            
            textField.snp_makeConstraints { (make) -> () in
                make.left.equalTo(self.containerView).offset(40)
                make.right.equalTo(self.containerView).offset(-40)
                make.centerY.equalTo(self.containerView)
            }

        } else {
            
            textField.snp_makeConstraints { (make) -> () in
                make.left.equalTo(self.containerView).offset(40)
                make.right.equalTo(self.forgotButton.snp_left).offset(-15)
                make.centerY.equalTo(self.containerView)
            }
            
            forgotButton.snp_makeConstraints { (make) -> () in
                make.centerY.equalTo(self.containerView)
                make.right.equalTo(self.containerView).offset(-25)
                make.width.equalTo(82)
            }

        }
        
        topLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.height.equalTo(0.5)
        }
        
        bottomLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
            make.height.equalTo(0.5)
        }
    }
    
    func forgotButtonTapped(sender: UIButton) {
        self.delegate?.didTapForgotPasswordButton(self)
    }
    
    func makeActive() {
        self.textField.becomeFirstResponder()
    }
    
}

protocol PRKTextFieldDelegate {
    func didTapForgotPasswordButton(field: PRKTextField)
}

enum PRKTextFieldType {
    case Normal
    case NormalNoAutocorrect
    case Email
    case Password
    case PasswordWithForgotButton
    case NotEditable
}