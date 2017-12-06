//
//  PRKTextField.swift
//  
//
//  Created by Antonino Urbano on 2015-07-15.
//
//

import UIKit

class PRKTextField: UIView, UITextFieldDelegate {

    fileprivate var containerView: UIView
    fileprivate var topLine: UIView
    fileprivate var bottomLine: UIView
    fileprivate var textField: UITextField
    fileprivate var forgotButton: UIButton
    
    fileprivate var fieldType: PRKTextFieldType
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
    
    fileprivate var didsetupSubviews : Bool
    fileprivate var didSetupConstraints : Bool

    internal let background_color = Styles.Colors.midnight2
    internal let text_color = Styles.Colors.cream2
    var placeholderAttributes = [NSFontAttributeName: Styles.Fonts.h3r, NSForegroundColorAttributeName: Styles.Colors.petrol1]
    var textFont = Styles.Fonts.h3r
    
    convenience init(placeHolder: String, fieldType: PRKTextFieldType) {
        
        self.init()
        self.fieldType = fieldType
        
        self.textField.textAlignment = NSTextAlignment.natural
        self.textField.clearButtonMode = UITextFieldViewMode.always
        self.textField.keyboardType = UIKeyboardType.default

        switch fieldType {
        case .normal:
            break
        case .normalNoAutocorrect:
            textField.autocorrectionType = UITextAutocorrectionType.no
            break
        case .email:
            textField.autocorrectionType = UITextAutocorrectionType.no
            self.textField.keyboardType = UIKeyboardType.emailAddress
            break
        case .password:
            self.textField.isSecureTextEntry = true
            break
        case .passwordWithForgotButton:
            self.textField.isSecureTextEntry = true
            self.forgotButton.isHidden = false
            break
        case .notEditable:
            self.textField.isEnabled = false
            self.textField.textAlignment = NSTextAlignment.center
            textField.clearButtonMode = UITextFieldViewMode.never
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
        
        fieldType = .normal
        
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
        textField.keyboardAppearance = UIKeyboardAppearance.default

        forgotButton.setTitle("forgot_password_text".localizedString, for: UIControlState())
        forgotButton.isHidden = fieldType != .passwordWithForgotButton
        forgotButton.addTarget(self, action: #selector(PRKTextField.forgotButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
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

        
        if fieldType != .passwordWithForgotButton {
            
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
    
    func forgotButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapForgotPasswordButton(self)
    }
    
    func makeActive() {
        self.textField.becomeFirstResponder()
    }
    
}

protocol PRKTextFieldDelegate {
    func didTapForgotPasswordButton(_ field: PRKTextField)
}

enum PRKTextFieldType {
    case normal
    case normalNoAutocorrect
    case email
    case password
    case passwordWithForgotButton
    case notEditable
}
