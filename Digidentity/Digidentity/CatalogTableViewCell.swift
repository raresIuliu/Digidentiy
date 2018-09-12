//
//  CatalogTableViewCell.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import UIKit

class CatalogTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var serviceConfidence: UILabel!
    @IBOutlet weak var serviceId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    func initializeCellWithData( catalogService: CatalogServiceEntity) {
        self.serviceImage.image = catalogService.decodedImage
        self.serviceDescription.text = "Description: \(catalogService.serviceDescription)"
        self.serviceConfidence.text = "Confidence: \(catalogService.confidenceValue)"
        self.serviceId.text = "ID: \(catalogService.id)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
