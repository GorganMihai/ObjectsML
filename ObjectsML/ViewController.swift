//
//  ViewController.swift
//  ObjectsML
//
//  Created by Mihai Gorgan on 12.07.2022.
//

import UIKit
import CoreML
import Vision



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var objectLabel: UILabel!
            
    let imagePicker = UIImagePickerController()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
      
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("*** Could not convert CiImage.")
            }
            
            detect(image: ciImage)
            
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    

    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("*** Loading CodeML Faild.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
        
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("*** Model failed to process image.")
            }
            
            if let firstResult = results.first {
                print("""
                    ===================
                    """)
                print("First Result with confidence= \(firstResult.confidence), object: \(firstResult.identifier)")
                
                self.confidenceLabel.text = "Confidence= \(String(format: "%.2f", (firstResult.confidence * 100)))% "
                self.objectLabel.text = "Identifier= \(firstResult.identifier)"
                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
         
        do {
            try! handler.perform([request])
        } catch {
            print("Error Handler === \(error)")
            
        }
        
            
        
        
    }
    
    
    
    @IBAction func CameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
    
}

