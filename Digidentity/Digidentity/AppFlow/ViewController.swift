//
//  ViewController.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import UIKit
import SimpleImageViewer
import DataCache
import SCLAlertView

class ViewController: UIViewController, NewServiceDelegate {

    @IBOutlet weak var catalogTableView: UITableView!
    @IBOutlet weak var addNewServiceBtn: UIButton!
    @IBOutlet weak var removeAllBtn: UIButton!
    
    var catalogServicesArray = [CatalogServiceEntity]()
    let cache = DataCache(name: "MyCustomCache")
    var firstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerTableViewCell()
        self.addPullToRefresh()
        self.loadData()
    }

    func registerTableViewCell() {
        let newsNib = UINib.init(nibName: "CatalogTableViewCell", bundle: nil)
        catalogTableView.register(newsNib, forCellReuseIdentifier: GlobalValues.catalogCellIdentifier)
        self.catalogTableView.separatorColor = GlobalColors.blueIceColor
    }
    
    func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            catalogTableView.refreshControl = refreshControl
        } else {
            catalogTableView.backgroundView = refreshControl
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        // add first 10 items
        self.refreshData()
    }
    
    func refreshData() {
        let customService = CustomService()
        ApiRequests.getServices( completion: { (catalogServices, statusCode) in
            if statusCode != 200 {
                self.showAlert()
                return
            }
            customService.serviceArray = catalogServices
            self.cache.write(object: customService, forKey: GlobalValues.cacheKey)
            self.catalogServicesArray = catalogServices
            DispatchQueue.main.async {
                self.catalogTableView.reloadData()
            }
        })
    }
    
    func loadData() {
        
        let customService = CustomService()
        
        guard let data = self.cache.readObject(forKey: GlobalValues.cacheKey) as? CustomService else {
            //Load data from api
            ApiRequests.getServices( completion: { (catalogServices, statusCode) in
                if statusCode != 200 {
                    self.showAlert()
                    return
                }
                customService.serviceArray = catalogServices
                self.cache.write(object: customService, forKey: GlobalValues.cacheKey)
                self.catalogServicesArray = catalogServices
                DispatchQueue.main.async {
                    self.catalogTableView.reloadData()
                }
            })
            return
        }
        
        if data.serviceArray.count > 0 {
            //Afisare elemente din service array
            self.catalogServicesArray = data.serviceArray
            DispatchQueue.main.async {
                self.catalogTableView.reloadData()
            }
        } else {
            //Load data from api
            ApiRequests.getServices( completion: { (catalogServices, statusCode) in
                if statusCode != 200 {
                    self.showAlert()
                    return
                }
                customService.serviceArray = catalogServices
                self.cache.write(object: customService, forKey: GlobalValues.cacheKey)
                DispatchQueue.main.async {
                    self.catalogTableView.reloadData()
                }
            })
        }
    }
    
    func loadMoreServices() {
        let serviceItem = self.catalogServicesArray.last
        if let serviceId = serviceItem?.id {
            ApiRequests.getServicesPaginated(maxId: serviceId) { (serviceList, statusCode) in
                if statusCode != 200 {
                    self.showAlert()
                    return
                }
                
                self.catalogServicesArray.append(contentsOf: serviceList)

                if serviceList.count > 0 {
                    DispatchQueue.main.async {
                        self.catalogTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func addNewServiceBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: GlobalValues.newServiceViewController) as! NewServiceViewController
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    @IBAction func removeAllServicesBtnTapped(_ sender: Any) {
        ApiRequests.deleteAllServices { (statusCode) in
            if statusCode != 200 {
                self.showAlert()
                return
            }
            DispatchQueue.main.async {
                self.catalogTableView.reloadData()
            }
            self.flushAllCachedData()
        }
    }
    
    func flushAllCachedData() {
        self.cache.cleanAll()
    }
    
    func showAlert() {
        SCLAlertView().showError("Error", subTitle: "Something went wrong. Please try again.")
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - tableview delegates and dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.catalogServicesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GlobalValues.catalogCellIdentifier, for: indexPath) as! CatalogTableViewCell
        
        let serviceItem = self.catalogServicesArray[indexPath.row]
        cell.initializeCellWithData(catalogService: serviceItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: CatalogTableViewCell = tableView.cellForRow(at: indexPath) as! CatalogTableViewCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cell.serviceImage
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = self.catalogServicesArray.count - 1
        if indexPath.row == lastItem {
            if firstLoad {
                firstLoad = false
                return
            }
            self.loadMoreServices()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let serviceItem = self.catalogServicesArray[indexPath.row]
            ApiRequests.deleteSpecficService(id: serviceItem.id) { (statusCode) in
                DispatchQueue.main.async {
                    self.catalogServicesArray.remove(at: indexPath.row)
                    self.catalogTableView.reloadData()
                }
            }
        }
    }
    
}
