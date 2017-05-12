//
//  EditingViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import Kingfisher
import FacebookCore
import SwiftyJSON
import Firebase

class EditingTableViewController: UITableViewController {
        
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var images:[UIImage] = [] {
        didSet {
            self.assignImages()
        }
    }
    var pickerTag:Int = 111

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func assignImages() {
        for (index,val) in self.images.enumerated() {
            let tag = 100 + (index+1)*10 + 1
            let imageButton = view.viewWithTag(tag) as! UIButton
            imageButton.setImage(val, for: .normal)
        }
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        FIRDatabase.database().reference().child("user/\(FIRAuth.auth()!.currentUser!.uid)/profile/bio").setValue(bioText.text)
    }
    
    @IBAction func doneNavBtn(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeImage(_ sender: UIButton) {
        pickerTag = sender.tag
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.openCamera()
        })
        let photoLibraryAction = UIAlertAction(title: "PhotoLibrary", style: .default, handler: { action in
            self.openGallary()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Cancel Action Touched")
        })
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func removeImage(_ sender: UIButton) {
        let index = (sender.tag - 201)/10 - 1
        if self.images.count >= index {
            self.images.remove(at: index)
        }
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var bioText: UITextField!
    
    @IBAction func ageSlider(_ sender: Any) {
    }
    
    @IBAction func distanceSlider(_ sender: Any) {
    }
    
    @IBAction func deleteAccountBtn(_ sender: Any) {
    }
    
    @IBAction func logout(_ sender: Any) {
        Authenticator.shared.logout()
        appDelegate.checkForLogin()
    }
     
    @IBAction func privacyPolicyBtn(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.google.com")!)
    }
    
    @IBAction func termsAndConditionsBtn(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.google.com")!)
    }
}

extension EditingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as?  UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        let index = (self.pickerTag - 101)/10 - 1
        if self.images.count-1 >= index{
            self.images.remove(at: index)
            self.images.insert(image, at: index)
        } else {
            self.images.append(image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
