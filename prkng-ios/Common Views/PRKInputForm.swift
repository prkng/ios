//
//  PRKInputForm.swift
//
//
//  Created by Antonino Urbano on 2015-07-15.
//
//

import UIKit

class PRKInputForm: UIView, PRKTextFieldDelegate {
    
    var delegate: PRKInputFormDelegate?
    
    private var containerView: UIView
    private var cells: [PRKTextField]
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool
    
    private var FIELD_HEIGHT : Int = 50
    
    private var placeholderAttributes = [NSFontAttributeName: Styles.Fonts.h3, NSForegroundColorAttributeName: Styles.Colors.anthracite1]
    private var textFont = Styles.Fonts.h3

    static func inputFormForRegister() -> PRKInputForm {
        
        let list = [
            ("name".localizedString, PRKTextFieldType.NormalNoAutocorrect),
            ("email".localizedString, PRKTextFieldType.Email),
            ("password".localizedString, PRKTextFieldType.Password),
            ("password_confirm".localizedString, PRKTextFieldType.Password),
        ]
        
        let inputForm = PRKInputForm(list: list)
        
        return inputForm
    }
    
    static func inputFormForEditProfile(nameText: String, emailText: String) -> PRKInputForm {
        
        let list = [
            ("name".localizedString, PRKTextFieldType.NormalNoAutocorrect),
            ("email".localizedString, PRKTextFieldType.Email),
            ("password".localizedString, PRKTextFieldType.Password),
            ("password_confirm".localizedString, PRKTextFieldType.Password),
        ]
        
        var placeholderAttributes = [NSFontAttributeName: Styles.FontFaces.light(17), NSForegroundColorAttributeName: Styles.Colors.petrol1]
        var textFont = Styles.FontFaces.light(17)
        
        let inputForm = PRKInputForm(list: list, placeholderAttributes: placeholderAttributes, textFont: textFont)

        inputForm.cells[0].text = nameText
        inputForm.cells[1].text = emailText
        
        inputForm.FIELD_HEIGHT = 40
        
        return inputForm
    }

    convenience init(list: [(String, PRKTextFieldType)]) {
        self.init(list: list, placeholderAttributes: nil, textFont: nil)
    }
    
    //NOTE: List of tuples is used instead of dictionary because we need the data structure used to be ordered. An ordered dictionary could be used (not built-in to swift), but would not yield any benefits in this case. 
    convenience init(list: [(String, PRKTextFieldType)], placeholderAttributes: [String: NSObject]?, textFont: UIFont?) {
        self.init(frame: CGRectZero)
        
        self.placeholderAttributes = placeholderAttributes ?? self.placeholderAttributes
        self.textFont = textFont ?? self.textFont
        
        for item in list {
            let cell = PRKTextField(placeHolder: item.0, fieldType: item.1)
            if item.1 == .PasswordWithForgotButton {
                cell.delegate = self
            }
            cell.placeholderAttributes = self.placeholderAttributes
            cell.textFont = self.textFont
            
            cells.append(cell)
        }
    }
    
    override init(frame: CGRect) {
        
        cells = []
        containerView = UIView()
        
        didsetupSubviews = false
        didSetupConstraints = true
        
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
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
        
        self.addSubview(containerView)
        for cell in cells {
            containerView.addSubview(cell)
        }
        
        didsetupSubviews = true
        didSetupConstraints = false
        
    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        var aboveView = self.containerView.snp_top
        
        for i in 0..<cells.count {
            
            let cell = cells[i]
            cell.snp_makeConstraints({ (make) -> () in
                make.left.equalTo(self.containerView)
                make.right.equalTo(self.containerView)
                make.height.equalTo(self.FIELD_HEIGHT)
                make.top.equalTo(aboveView)
            })
            aboveView = cell.snp_bottom
        }

    }
    
    func textForFieldNamed(placeholderText: String) -> String {
        
        if let cell = (self.cells.filter { (cell) -> Bool in
            return cell.placeholderText == placeholderText
            }.first) {
                return cell.text
        }
        return ""
    }
    
    func height() -> Int {
        return cells.count * self.FIELD_HEIGHT
    }
    
    func makeActive() {
        if self.cells.first != nil {
                self.cells[0].makeActive()
        }
    }
    
    //MARK: PRKTextFieldDelegate
    
    func didTapForgotPasswordButton(field: PRKTextField) {
        self.delegate?.didTapForgotPasswordButton()
    }

    
}

protocol PRKInputFormDelegate {
    func didTapForgotPasswordButton()
}