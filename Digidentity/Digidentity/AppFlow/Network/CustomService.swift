//
//  CustomService.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import UIKit
import Foundation

open class CustomService: NSObject, NSCoding {
    
    open var serviceDescription: String = ""
    open var confidence: Float = 0.0
    open var image: UIImage = UIImage()
    open var id: String = ""
    
    var serviceArray = [CatalogServiceEntity]()
    
    override init() {
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.serviceDescription = aDecoder.decodeObject(forKey: "description") as! String
        self.confidence = aDecoder.decodeFloat(forKey: "confidence")
        self.image = aDecoder.decodeObject(forKey: "image") as! UIImage
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        
        self.serviceArray = aDecoder.decodeObject(forKey: "serviceArray") as! [CatalogServiceEntity]
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.serviceDescription, forKey: "description")
        aCoder.encode(self.confidence, forKey: "confidence")
        aCoder.encode(self.image, forKey: "image")
        aCoder.encode(self.id, forKey: "id")
        
        aCoder.encode(self.serviceArray, forKey: "serviceArray")
    }
}
