//
//  UIImage.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import UIKit
import Foundation

extension UIImage {
    
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
//    func encodeImageBase64() -> String? {
//        let imageData = UIImagePNGRepresentation(self) //UIImageJPEGRepresentation(self, 1.0)
//        let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters)
//        return strBase64
//    }

    func encodeImageBase64() -> String {
        let imageData:NSData = UIImagePNGRepresentation(self)! as NSData //UIImagePNGRepresentation(img)
        let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
        return imgString
    }
}
