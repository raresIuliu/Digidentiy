//
//  NewServiceViewController.swift
//  Digidentity
//
//  Created by Rares Tamas on 9/11/18.
//  Copyright © 2018 Rares Tamas. All rights reserved.
//

import UIKit
import Foundation
import TesseractOCR
import APESuperHUD
import SCLAlertView

protocol NewServiceDelegate {
    func refreshData()
}

class NewServiceViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var takenImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var confidenceTextField: UITextField!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var ocrBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    
    var delegate: NewServiceDelegate?
    var imageInBase64: String = ""
    let imagePicker = UIImagePickerController()
    var onOcr: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.backView.layer.cornerRadius = 2.0
        self.backView.layer.borderColor = UIColor.white.cgColor
        self.backView.layer.borderWidth = 1.0
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func photoBtnTapped(_ sender: Any) {
        self.onOcr = false
        self.presentImagePicker()
    }
    
    @IBAction func ocrBtnTapped(_ sender: Any) {
        self.onOcr = true
        self.presentImagePicker()
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        
        if takenImageView.image == nil {
            self.showAlert(title: GlobalValues.incompleteData, message: GlobalValues.imageError)
            return
        }
        
        if descriptionTextField.text == "" {
            self.showAlert(title: GlobalValues.incompleteData, message: GlobalValues.descriptionError)
            return
        }
        if confidenceTextField.text == "" {
            self.showAlert(title: GlobalValues.incompleteData, message: GlobalValues.confidenceError)
            return
        }
        
        APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "Adding new service...")
        if let description = descriptionTextField.text, let confidenceReplaced = confidenceTextField.text?.replacingOccurrences(of: ",", with: ".") {
            if let confidenceAsDouble = Double(confidenceReplaced) {
                ApiRequests.addNewService(imageInBase64: self.imageInBase64, text: description, confidence: confidenceAsDouble) { (statusCode) in
                    if statusCode != 200 {
                        self.showAlert(title: GlobalValues.error, message: GlobalValues.errorMessage)
                        return
                    }
                                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        APESuperHUD.dismissAll(animated: true)
                    })
                    
                    self.delegate?.refreshData()
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //MARK: - Dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func performImageRecognition(_ image: UIImage) {
        APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "Analyzing Image...")
        let tesseract = G8Tesseract(language: "eng")
        DispatchQueue.global(qos: .background).async {
            // Background Thread
            if let tesseractInstance = tesseract {
                tesseractInstance.engineMode = .tesseractCubeCombined
                tesseractInstance.pageSegmentationMode = .auto
                tesseractInstance.image = image.g8_blackAndWhite()
                tesseractInstance.recognize()
                DispatchQueue.main.async {
                    // Run UI Updates or call completion block
                    self.descriptionTextField.text = tesseractInstance.recognizedText
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        APESuperHUD.dismissAll(animated: true)
                    })
                }
            }
        }
    }
    
    func showAlert( title: String, message: String) {
        SCLAlertView().showError(title, subTitle: message)
    }
}

extension NewServiceViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func presentImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let capturedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let image = capturedImage.scaleImage(512.0)
            
            if let tmpImageInBase54 = image?.encodeImageBase64() {
                self.imageInBase64 = tmpImageInBase54
            }
            
            DispatchQueue.main.async {
                self.takenImageView.image = image
            }
            
            if self.onOcr {
                self.performImageRecognition(image!)
            }
        }
    }
    
}
