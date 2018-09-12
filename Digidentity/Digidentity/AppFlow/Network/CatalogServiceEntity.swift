//
//  CatalogServiceEntity.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import Foundation
import ObjectMapper

class CatalogServiceEntity: NSObject, Mappable, NSCoding {
    
    var serviceDescription: String = ""
    var confidenceValue: Double = 0.0
    var imageEncoded: String = ""
    var id: String = ""
    var decodedImage = UIImage()
    
    required init?(map: Map) {
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.serviceDescription = aDecoder.decodeObject(forKey: "description") as? String ?? ""
        self.confidenceValue = aDecoder.decodeDouble(forKey: "confidence")
        self.decodedImage = aDecoder.decodeObject(forKey: "image") as? UIImage ?? UIImage()
        self.id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        self.imageEncoded = aDecoder.decodeObject(forKey: "imageEncoded") as? String ?? ""
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.serviceDescription, forKey: "description")
        aCoder.encode(self.confidenceValue, forKey: "confidence")
        aCoder.encode(self.decodedImage, forKey: "image")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.imageEncoded, forKey: "imageEncoded")
    }
    
    func mapping(map: Map) {
        serviceDescription <- map["text"]
        confidenceValue <- map["confidence"]
        imageEncoded <- map["img"]
        id <- map["_id"]
        
        if let imageDecoded = getDecodedImage(baseString: imageEncoded) {
            decodedImage = imageDecoded
        }
    }
    
    func getDecodedImage(baseString: String) -> UIImage? {
        let imageData = Data.init(base64Encoded: baseString, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image
    }
    
}
