//
//  ImageUtil.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension UIImage {
    
    func resizeImage(_ targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, Settings.screenScale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, Settings.screenScale)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    class func getRoundedRectImageFromImage(_ image: UIImage, rect:CGRect, cornerRadius:CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, Settings.screenScale)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.draw(in: rect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!
    }
    
    class func transparentImageWithSize(_ size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, Settings.screenScale)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage!
        
    }

    class func imageFromView(_ view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, Settings.screenScale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage!

    }
    
    class func screenshot(_ viewController: UIViewController?) -> UIImage {

        let delegate = UIApplication.shared.delegate as! AppDelegate
        let root = viewController ?? delegate.window?.rootViewController
        let bounds = CGRect(x: 0, y: 0, width: root!.view.bounds.width, height: root!.view.bounds.height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: root!.view.bounds.width, height: root!.view.bounds.height),
            true, Settings.screenScale)
        root!.view.drawHierarchy(in: bounds,
            afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot!
    }
    
    func addText(_ text: String, color: UIColor, font: UIFont) -> UIImage {
        
        let drawRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let label = UILabel(frame: drawRect)
        label.text = text
        label.font = font
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, Settings.screenScale)
        self.draw(in: drawRect)
        label.drawText(in: drawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
    }

    func addText(_ attributedText: NSAttributedString, labelRect: CGRect?) -> UIImage {
        
        let drawRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let labelDrawRect = labelRect ?? CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let label = UILabel(frame: drawRect)
        label.attributedText = attributedText
        label.textAlignment = NSTextAlignment.center
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, Settings.screenScale)
        self.draw(in: drawRect)
        label.drawText(in: labelDrawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    func addText(_ attributedText: NSAttributedString, color: UIColor?, bottomOffset: CGFloat = 0) -> UIImage {
        
        let drawRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let labelDrawRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height - bottomOffset)
        let label = UILabel(frame: drawRect)
        label.attributedText = attributedText
        if color != nil {
            label.textColor = color!
        }
        label.textAlignment = NSTextAlignment.center

        UIGraphicsBeginImageContextWithOptions(self.size, false, Settings.screenScale)
        self.draw(in: drawRect)
        label.drawText(in: labelDrawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    static func imageFromGradient(_ size: CGSize, fromColor: UIColor, toColor: UIColor) -> UIImage {
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        layer.colors = [fromColor.cgColor, toColor.cgColor]
        
        UIGraphicsBeginImageContext(size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image!
    }

    func redrawImageInRect(_ drawRect: CGRect) -> UIImage {

        let scale = UIScreen.main.scale
        let scaledDrawRect = CGRect(x: drawRect.origin.x * scale, y: drawRect.origin.y * scale, width: drawRect.size.width * scale, height: drawRect.size.height * scale)
        let croppedImage = (self.cgImage)?.cropping(to: scaledDrawRect)
        return UIImage(CGImage: croppedImage!, scale: scale, orientation: self.imageOrientation) ?? UIImage()
    }
    
//percentToMoveIntoImage is how much you wish it to be overlayed. so 0 means that you would have 2 boxes, where one's upper right corner touches the other's bottom left corner.
    func addImageToTopRight(_ imageToAdd: UIImage, valueToMoveIntoImage: CGFloat) -> UIImage {
        let denominator = 1/(valueToMoveIntoImage == 0 ? 0.001 : valueToMoveIntoImage)
        let bigDrawRect = CGRect(x: 0, y: 0, width: self.size.width+imageToAdd.size.width/denominator, height: self.size.height+imageToAdd.size.height/denominator)
        let imageDrawRect = CGRect(x: 0, y: imageToAdd.size.height/denominator, width: self.size.width, height: self.size.height)
        let imageToAddDrawRect = CGRect(x: bigDrawRect.width-imageToAdd.size.width, y: 0, width: imageToAdd.size.width, height: imageToAdd.size.height)
        
        UIGraphicsBeginImageContextWithOptions(bigDrawRect.size, false, Settings.screenScale)
        self.draw(in: imageDrawRect)
        imageToAdd.draw(in: imageToAddDrawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    func extendHeight(_ heightExtension: CGFloat, andWidth widthExtension: CGFloat) -> UIImage {
        let extendedSize = CGSize(width: self.size.width + widthExtension, height: self.size.height + heightExtension)
        UIGraphicsBeginImageContextWithOptions(extendedSize, false, Settings.screenScale)
        self.draw(in: CGRect(x: 0, y: heightExtension, width: self.size.width, height: self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    

    //tints white to the given color (CGBlendMode.Multiply)
    func imageTintedWithColor(_ color: UIColor, blendMode: CGBlendMode) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        
        //tint the image
        self.draw(in: rect)
        color.set()
        UIRectFillUsingBlendMode(rect, blendMode)
        
        //restore alpha channel
        self.draw(in: rect, blendMode: CGBlendMode.destinationIn, alpha: 1)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

    fileprivate func convertToGrayScaleNoAlpha() -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceGray();
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(size.width*scale), height: Int(size.height*scale), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width*scale, height: size.height*scale))
        return context!.makeImage()!
    }
    
    func convertToGrayScale() -> UIImage {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue)
        let context = CGContext(data: nil, width: Int(size.width*scale), height: Int(size.height*scale), bitsPerComponent: 8, bytesPerRow: 0, space: nil, bitmapInfo: bitmapInfo.rawValue)
        context.draw(self.CGImage, in: CGRect(x: 0, y: 0, width: size.width*scale, height: size.height*scale));
        let mask = context.makeImage()
        return UIImage(CGImage: convertToGrayScaleNoAlpha().masking(mask)!, scale: scale, orientation:imageOrientation)
    }

}

