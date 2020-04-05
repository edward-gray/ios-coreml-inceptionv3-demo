//
//  ViewController.swift
//  CoreML Inception v3 demo
//
//  Created by Edward Gray on 05.04.2020.
//  Copyright © 2020 Edward Gray. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        // use Library
        imagePicker.sourceType = .photoLibrary
        // use camera
        //imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Error converting UIImage to CIImage") }
            detec(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // CoreML and Vision
    func detec(image: CIImage) {
        
        // 1. create model with help of 'Vision' Library
        guard let inceptionModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Error getting Inception v3 model")
        }
        
        // 2. create new request
        let request = VNCoreMLRequest(model: inceptionModel) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error getting result from inception model")
            }
            
            // 3. Handle the result
            if let firstResult = results.first {
                let resultStrings = firstResult.identifier.split(separator: ",")
                self.navigationItem.title = "Result: " + String(resultStrings[0])
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        // 4. perform the result
        do {
            try handler.perform([request])
        } catch {
            print("Error")
        }
        
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

