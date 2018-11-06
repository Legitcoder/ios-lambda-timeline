//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controlsStackView.isHidden = true
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        guard let originalImage = originalImage else {
            title = "New Post"
            return
        }
        
        
        title = post?.title
        
        setImageViewHeight(with: originalImage.ratio)
        
        imageView.image = image(byFiltering: originalImage)
        
        chooseImageButton.setTitle("", for: [])
    }
    
    @IBAction func changeBrightness(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func changeContrast(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func changeSaturation(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func changeHue(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func changeExposure(_ sender: Any) {
        updateViews()
    }
    
    @IBOutlet weak var brightnessSlider: UISlider!
    
    @IBOutlet weak var contrastSlider: UISlider!
    
    @IBOutlet weak var saturationSlider: UISlider!
    
    @IBOutlet weak var hueSlider: UISlider!
    
    @IBOutlet weak var exposureSlider: UISlider!
    
    @IBOutlet weak var controlsStackView: UIStackView!
    
    private func image(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        filter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
        filter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)
        filterTwo.setValue(filter.outputImage, forKey: kCIInputImageKey)
        filterTwo.setValue(hueSlider.value, forKey: kCIInputAngleKey)
        filterThree.setValue(filterTwo.outputImage, forKey: kCIInputImageKey)
        filterThree.setValue(exposureSlider.value, forKey: kCIInputEVKey)
        guard let outputCIImage = filterTwo.outputImage else { return image }
        
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        
        return UIImage(cgImage: outputCGImage)
        
    }
    
    private let filter = CIFilter(name: "CIColorControls")!
    private let filterTwo = CIFilter(name: "CIHueAdjust")!
    private let filterThree = CIFilter(name: "CIExposureAdjust")!
    private let context = CIContext(options: nil)
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    var originalImage: UIImage? {
        didSet {
            controlsStackView.isHidden = false
            updateViews()
        }
    }
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
