//
//  GlobalValues.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import Foundation

class GlobalValues: NSObject {
    // API
    static let secretKey: String = "70dc9395c426e4d4f9997f966e37f0a5"
    static var baseUrl: String = "https://marlove.net/e/mock/v1/items"
    static var baseUrlAddDelete: String = "https://marlove.net/e/mock/v1/item"
    // Project
    static let catalogCellIdentifier: String = "catalogCell"
    static let newServiceViewController: String = "NewServiceViewController"
    static let cacheKey: String = "cachedServiceKey"
    // Error mesages
    static let incompleteData = "Incomplete data"
    static let descriptionError = "Please add a description."
    static let confidenceError = "Please add confidence value."
    static let imageError = "Please add image."
    static let error = "Error"
    static let errorMessage = "Something went wrong. Please try again."
}
