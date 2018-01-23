//
//  ComposeViewController.swift
//  Thred
//
//  Created by Thred. on 12/5/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var postButtonView: UIView!
    
    @IBOutlet var composeTextBackgroundView: UIView!
    
    @IBOutlet var composeTextView: UITextView!
    
    @IBOutlet var addPhotoButton: UIButton!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var addPhotoButtonView: UIView!
    
    @IBOutlet var cameraButtonView: UIView!
    
    @IBOutlet var removePhotoButton: UIButton!
    
    @IBOutlet var downloadPhotoButton: UIButton!
    
    @IBOutlet var characterLimitLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpViews()
        imagePicker.delegate = self
    }

    @IBAction func postButtonClicked(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if (helping.isValidCaption(caption: composeTextView.text!)){
            
            postServices.uploadPost(caption: composeTextView.text!, image: imageView.image, view: self) { (success:Bool) in
                //tell controller post updated
                print("success")
                UIApplication.shared.endIgnoringInteractionEvents()
                if(success){
                        controller?.load()
                        //self.navigationController?.popViewController(animated: true);
                }
            }
        } else {
            UIApplication.shared.endIgnoringInteractionEvents()
            helping.displayAlertOK("Invalid Caption", message: "Caption must be longer than one character.", view: self)
        }
    }
    
    
    
    
    @IBAction func removePhotoButtonClicked(_ sender: Any) {
        imageView.image = nil;
        imageView.isHidden = true;
        removePhotoButton.isHidden = true;
        downloadPhotoButton.isHidden = true;
    }
    @IBAction func addPhotoButtonClicked(_ sender: Any) {
        library()
    }
    @IBAction func takePhotoButtonClicked(_ sender: Any) {
        camera()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        imageView.image = image
        removePhotoButton.isHidden = false;
        downloadPhotoButton.isHidden = false;
        imageView.isHidden = false;
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print("Photo method canceled")
    }
    
    func camera(){
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("This device doesn't have a camera.")
            return
        }
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .rear
       // imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for:.camera)!//this allows videos
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    
    
    func library(){
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Compose..."
            textView.textColor = UIColor.lightGray
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.count > 120){
          
            textView.text = helping.substring(text: textView.text!, startIndex: 0, endIndex: 120)
            characterLimitLabel.isHidden = false;
        } else if(textView.text.count != 120){
            characterLimitLabel.isHidden = true;
        }
    }
    
    //keyboard dismissed on touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    func SetUpViews() {
        helping.putSquareBorderOnButton(buttonView: composeTextBackgroundView)
        helping.putSquareBorderOnButton(buttonView: addPhotoButtonView)
        helping.putSquareBorderOnButton(buttonView: postButtonView)
        helping.putSquareBorderOnButton(buttonView: cameraButtonView)
        removePhotoButton.isHidden = true;
        downloadPhotoButton.isHidden = true
        imageView.isHidden = true;
        composeTextView.textColor = UIColor.lightGray
        composeTextView.delegate = self;
        characterLimitLabel.isHidden = true;
    }
    
    @IBAction func downloadPhotoButtonClicked(_ sender: Any) {
        
        //TODO, download photo
        downloadPhotoButton.isHidden = true;
        UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil)
        helping.displayAlertOK("Photo Saved!", message: "Your photo has been saved to your camera roll", view: self)
    }
    
    
    

}
