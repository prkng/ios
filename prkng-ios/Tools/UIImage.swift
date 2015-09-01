//
//  ImageUtil.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func getRoundedRectImageFromImage(image: UIImage, rect:CGRect, cornerRadius:CGFloat) -> UIImage {
        
        let screenScale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(rect.size, false, screenScale)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.drawInRect(rect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }

    class func imageFromView(view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage

    }
    
    class func screenshot(viewController: UIViewController?) -> UIImage {

        let screenHeight = UIScreen.mainScreen().bounds.height
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let root = viewController ?? delegate.window?.rootViewController
        let bounds = CGRect(x: 0, y: 0, width: root!.view.bounds.width, height: root!.view.bounds.height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: root!.view.bounds.width, height: root!.view.bounds.height),
            true, 1)
        root!.view.drawViewHierarchyInRect(bounds,
            afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    func addText(text: String, color: UIColor, font: UIFont) -> UIImage {
        
        let drawRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let label = UILabel(frame: drawRect)
        label.text = text
        label.font = font
        
        UIGraphicsBeginImageContext(self.size)
        self.drawInRect(drawRect)
        label.drawTextInRect(drawRect)
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }

    func addText(attributedText: NSAttributedString) -> UIImage {
        
        let drawRect = CGRectMake(0, 0, self.size.width, self.size.height)
        UIGraphicsBeginImageContext(self.size)
        self.drawInRect(drawRect)
        attributedText.drawInRect(drawRect)
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }

    
}

