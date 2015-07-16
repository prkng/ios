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
    
    private var FIELD_HEIGHT : Int = 60
    
    convenience init(list: [String: PRKTextFieldType]) {
        self.init(frame: CGRectZero)
        
        for item in list {
            let cell = PRKTextField(placeHolder: item.0, fieldType: item.1)
            if item.1 == .PasswordWithForgotButton {
                cell.delegate = self
            }
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
    
    //MARK: PRKTextFieldDelegate
    
    func didTapForgotPasswordButton(field: PRKTextField) {
        self.delegate?.didTapForgotPasswordButton()
    }

    
}

protocol PRKInputFormDelegate {
    func didTapForgotPasswordButton()
}