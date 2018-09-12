//
//  ApiRequests.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class ApiRequests: NSObject {
    
    static let afManager = Alamofire.SessionManager.default
    static var sessionManager: SessionManager?
    
    // MARK: Enable Certificate
    static func enableCertificatePinning() {
        let certificates = getCertificates()
        let trustPolicy = ServerTrustPolicy.pinCertificates( certificates: certificates, validateCertificateChain: true, validateHost: true)
        let trustPolicies = [ "marlove.net": trustPolicy ]
        let policyManager = ServerTrustPolicyManager(policies: trustPolicies)
        sessionManager = SessionManager(
            configuration: .default,
            serverTrustPolicyManager: policyManager
        )
    }
    
    static func getCertificates() -> [SecCertificate] {
        if let url = Bundle.main.url(forResource: "certificate", withExtension: "crt") {
            let localCertificate = try! Data(contentsOf: url) as CFData
            guard let certificate = SecCertificateCreateWithData(nil, localCertificate) else { return [] }
            return [certificate]
        }
        
        return []
    }
    
    // MARK: API Requests
    static func getServices( completion: @escaping ([CatalogServiceEntity], Int) -> Void) {
        
        self.enableCertificatePinning()
        
        let header = [
            "Authorization": GlobalValues.secretKey,
            ]
        
        var catalogServicesArray = [CatalogServiceEntity]()
        self.afManager.request(GlobalValues.baseUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseArray { (response: DataResponse<[CatalogServiceEntity]>) in
            if let data = response.result.value, let statusCode = response.response?.statusCode {
                catalogServicesArray = data
                completion(catalogServicesArray, statusCode)
            }
        }
    }
    
    static func getServicesPaginated( maxId: String, completion: @escaping ([CatalogServiceEntity], Int) -> Void) {
        
        let header = [
            "Authorization": GlobalValues.secretKey,
            ]
        
        let parameters: Parameters = [
            "max_id": maxId,
            ]
        
        var catalogServicesArray = [CatalogServiceEntity]()
        self.afManager.request(GlobalValues.baseUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: header).responseArray { (response: DataResponse<[CatalogServiceEntity]>) in
            if let data = response.result.value, let statusCode = response.response?.statusCode {
                catalogServicesArray = data
                completion(catalogServicesArray, statusCode)
            }
        }
    }
    
    static func addNewService( imageInBase64: String, text: String, confidence: Double, completion: @escaping (Int) -> Void) {
        
        let header = [
            "Authorization": GlobalValues.secretKey,
            ]
        
        let parameters: Parameters = [
            "img": imageInBase64,
            "text": text,
            "confidence": confidence,
            ]
        
        self.afManager.request(GlobalValues.baseUrlAddDelete, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON { (response: DataResponse<Any>) in
            if let statusCode = response.response?.statusCode {
                completion(statusCode)
            }
        }
    }
    
    static func deleteSpecficService( id: String, completion: @escaping (Int) -> Void) {
        
        let header = [
            "Authorization": GlobalValues.secretKey,
            ]
        
        self.afManager.request(GlobalValues.baseUrlAddDelete + "/\(id)", method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response: DataResponse<Any>) in
            if let statusCode = response.response?.statusCode {
                completion(statusCode)
            }
        }
    }
    
    static func deleteAllServices( completion: @escaping (Int) -> Void) {
        
        let header = [
            "Authorization": GlobalValues.secretKey,
            ]
        
        self.afManager.request(GlobalValues.baseUrlAddDelete, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response: DataResponse<Any>) in
            if let statusCode = response.response?.statusCode {
                completion(statusCode)
            }
        }
    }
}
