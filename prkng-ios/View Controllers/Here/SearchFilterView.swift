//
//  SearchFilterView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchFilterView: UIView, UITextFieldDelegate {

    private var searchFieldView : UIView
    private var searchField : UITextField
    
    private var searchImageView: UIImageView
    
    private var topLine: UIView
    private var bottomLine: UIView
    
    var indicatorText: String = "" {
        didSet {
            
        }
    }
    var delegate : SearchViewControllerDelegate?

    private var shouldCloseFilters: Bool
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool

    static var TOTAL_HEIGHT : CGFloat = 80
    static var FIELD_HEIGHT : CGFloat = 40

    override init(frame: CGRect) {
        
        searchFieldView = UIView()
        searchField = UITextField()
        
        searchImageView = UIImageView()
        searchImageView.image = UIImage(named: "icon_searchfield")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        searchImageView.tintColor = Styles.Colors.petrol2

        topLine = UIView()
        bottomLine = UIView()
        
        shouldCloseFilters = true
        
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
    
    func setupSubviews () {
        
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clearColor() //stone if no blur?
        
        self.searchFieldView.layer.borderWidth = 0.5
        self.searchFieldView.layer.borderColor = Styles.Colors.cream1.CGColor
        searchFieldView.backgroundColor = UIColor.clearColor() //stone if no blur?
        self.addSubview(searchFieldView)

        let attributes = [NSFontAttributeName: Styles.FontFaces.light(14), NSForegroundColorAttributeName: Styles.Colors.petrol2]
        
        searchField.clearButtonMode = UITextFieldViewMode.Never
        searchField.font = Styles.FontFaces.bold(14)
        searchField.textColor = Styles.Colors.petrol2
        searchField.textAlignment = NSTextAlignment.Natural
        searchField.attributedPlaceholder = NSAttributedString(string: "search_bar_text".localizedString, attributes: attributes)
        searchField.delegate = self
        searchField.keyboardAppearance = UIKeyboardAppearance.Default
        searchField.keyboardType = UIKeyboardType.Default
        searchField.autocorrectionType = UITextAutocorrectionType.No
        searchField.returnKeyType = UIReturnKeyType.Search
        self.addSubview(searchField)
        
        searchImageView.contentMode = UIViewContentMode.Center
        self.addSubview(searchImageView)
        
        topLine.backgroundColor = Styles.Colors.transparentWhite
        self.addSubview(topLine)
        
        bottomLine.backgroundColor = Styles.Colors.transparentBlack
        self.addSubview(bottomLine)

        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        searchFieldView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self).with.offset(12)
            make.right.equalTo(self).with.offset(-12)
            make.bottom.equalTo(self).with.offset(-10)
            make.height.equalTo(SearchFilterView.FIELD_HEIGHT)
        }
        
        searchField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.searchImageView.snp_right).with.offset(14)
            make.right.equalTo(self).with.offset(-12)
            make.bottom.equalTo(self).with.offset(-10)
            make.height.equalTo(SearchFilterView.FIELD_HEIGHT)
        }
        
        searchImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(self.searchField)
            make.left.equalTo(self).with.offset(17 + 12)
        }
        
        topLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(0.5)
        }

        bottomLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }
        
    }

    
    // UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if self.searchFieldView.frame.size.width > 0 {
            self.delegate?.startSearching()
            searchField.modifyClearButtonWithImageNamed("icon_close", color: Styles.Colors.petrol2)
            return true
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let resultString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if count(resultString) >= 2 {
            SearchOperations.searchWithInput(resultString, forAutocomplete: true, completion: { (results) -> Void in
                self.delegate?.didGetAutocompleteResults(results)
            })
        } else {
            self.delegate?.didGetAutocompleteResults([])
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        SearchOperations.searchWithInput(textField.text, forAutocomplete: false, completion: { (results) -> Void in
            
            let today = DateUtil.dayIndexOfTheWeek()
            var date : NSDate = NSDate()
            
            self.delegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.searchField.text.isEmpty {
            endSearch()
        } else {
            delegate?.didGetAutocompleteResults([])
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField.text == "" {
            if shouldCloseFilters {
                //this happens the last time you press the x, to close the filters
                makeInactive(closeFilters: true)
            } else {
                //this happens the second time you press the x, to dismiss the keyboard
                endSearch()
            }
        } else {
            //this happens the first time you press the x, to clear the text
            clearSearch()
        }
        return true
    }
    
    func clearSearch() {
        delegate?.clearSearchResults()
        delegate?.didGetAutocompleteResults([])
        self.searchField.text = ""
        shouldCloseFilters = false
    }

    func endSearch() {
        clearSearch()
        self.searchField.endEditing(true)
        self.searchField.rightViewMode = UITextFieldViewMode.Always
        shouldCloseFilters = true
    }

    //MARK- helper functions
    
    func makeActive() {
        searchField.becomeFirstResponder()
    }
    
    func makeInactive(#closeFilters: Bool) {
        searchField.resignFirstResponder()
        delegate?.didGetAutocompleteResults([])
        self.searchField.rightViewMode = UITextFieldViewMode.WhileEditing
        if closeFilters {
            self.delegate?.endSearchingAndFiltering()
        }
        shouldCloseFilters = false
        
        //this is where we change the right view!
        var rightViewWidth: CGFloat = 130
        let locationButtonWidth: CGFloat = 46
        
        let indicatorButton = ViewFactory.redRoundedButtonWithHeight(20, font: Styles.FontFaces.regular(12), text: indicatorText)
        let attrs = [NSFontAttributeName: indicatorButton.titleLabel!.font]
        let maximumLabelSize = CGSize(width: rightViewWidth - locationButtonWidth - 10, height: 20)
        let rect = (indicatorText as NSString).boundingRectWithSize(maximumLabelSize, options: NSStringDrawingOptions.allZeros, attributes: attrs, context: nil)
        indicatorButton.frame = indicatorText == "" ? CGRectZero : CGRect(x: 10, y: 10, width: rect.width+20, height: 20)
        indicatorButton.addTarget(self, action: "textFieldShouldBeginEditing:", forControlEvents: UIControlEvents.TouchUpInside)

        rightViewWidth = 10 + locationButtonWidth + 10 + indicatorButton.frame.width
        
        //this is a placeholder, the actual button should be on the mapview.
        let locationButton = UIButton(frame: CGRect(x: rightViewWidth - locationButtonWidth, y: 0, width: locationButtonWidth, height: SearchFilterView.FIELD_HEIGHT))
        
        let rightView = UIView()
        rightView.clipsToBounds = false
        rightView.frame = CGRect(x: 0, y: 0, width: rightViewWidth, height: SearchFilterView.FIELD_HEIGHT)
        rightView.backgroundColor = UIColor.clearColor()
        rightView.addSubview(locationButton)
        rightView.addSubview(indicatorButton)
        searchField.rightView = rightView
        searchField.rightViewMode = UITextFieldViewMode.Always
        
    }
    
    func setSearchResult(result: SearchResult) {
        makeInactive(closeFilters: false)
        self.searchField.text = result.title
        self.delegate!.displaySearchResults([result], checkinTime : NSDate())
    }
    
    func changeAppearance(#small: Bool) {
        if small {
            self.searchFieldView.backgroundColor = UIColor.clearColor()
        } else {
            self.searchFieldView.backgroundColor = Styles.Colors.cream1
        }
    }


}
