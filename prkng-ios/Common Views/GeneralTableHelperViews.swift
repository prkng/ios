//
//  GeneralTableHelperViews.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-03-01.
//  Copyright © 2016 PRKNG. All rights reserved.
//

class GeneralTableHelperViews {
    
    static func sectionHeaderView(headerText: String) -> UIView? {
        
        if headerText == "" {
            return nil
        }
        
        let sectionHeader = UIView()
        sectionHeader.backgroundColor = Styles.Colors.stone
        let headerTitle = UILabel()
        headerTitle.font = Styles.FontFaces.bold(12)
        headerTitle.textColor = Styles.Colors.petrol2
        headerTitle.text = headerText
        sectionHeader.addSubview(headerTitle)
        headerTitle.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sectionHeader).offset(20)
            make.right.equalTo(sectionHeader).offset(-20)
            make.bottom.equalTo(sectionHeader).offset(-10)
        }
        return sectionHeader

    }

}
