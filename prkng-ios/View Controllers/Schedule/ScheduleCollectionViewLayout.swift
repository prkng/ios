//
//  ScheduleCollectionViewLayout.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 05/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleCollectionViewLayout: UICollectionViewLayout {
    
    var delegate : ScheduleCollectionViewLayoutDelegate?
    
    override func prepareLayout() {
        super.prepareLayout()
        
    }
   
    
    override func collectionViewContentSize() -> CGSize {
        return self.delegate!.contentSizeForCollectionView()
        
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        var elementsInRect : [AnyObject] = []
        
        var collectionViewContentSize : CGSize =  self.delegate!.contentSizeForCollectionView()
        var yIncrement : Double = (Double(collectionViewContentSize.height) / 24.0)
        var xIncrement : Double = (Double(collectionViewContentSize.width / 7.0))
        
        for var i = 0; i < self.collectionView?.numberOfSections(); ++i {
            
            for var j = 0; j < self.collectionView?.numberOfItemsInSection(i); ++j {
                
                var indexPath : NSIndexPath = NSIndexPath(forRow: j, inSection: i)
                var model : ScheduleCellModel = self.delegate!.modelForItemAtIndexPath(indexPath)
                
                var x : Double = xIncrement * Double(i)
                var y : Double = yIncrement * model.yIndexMultiplier!
                var w : Double = xIncrement
                var h : Double = yIncrement * model.heightMultiplier!
                
                if (model.heightMultiplier < 2.0) {
                    h = yIncrement * 2.0;
                }
    
                
                var cellFrame = CGRect(x: x, y: y, width: w, height: h)
                
                
                if(CGRectIntersectsRect(cellFrame, rect)) {
                    var attr : UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                    attr.frame = cellFrame
                    elementsInRect.append(attr)
                }
            }
            
            
        }
        
        return elementsInRect
    }
    
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        
        var attributes = UICollectionViewLayoutAttributes()
//        attributes.frame = delegate!.frameForItemAtIndexPath(indexPath)
        
        return attributes
    }
}


protocol ScheduleCollectionViewLayoutDelegate {
    
    func modelForItemAtIndexPath(indexpath : NSIndexPath) -> ScheduleCellModel
    func contentSizeForCollectionView () -> CGSize
}

