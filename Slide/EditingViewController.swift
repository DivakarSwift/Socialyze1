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
    var images:[(URL?,UIImage?)] = [] {
        didSet {
            self.assignImages()
        }
    }
    var imageToRemove:[URL] = []
    
    var pickerTag:Int = 111
    var user:User?
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.downloadImages(index: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func assignImages() {
        // set Image
        for (index,val) in self.images.enumerated() {
            let tag = 100 + (index+1)*10 + 1
            let imageButton = view.viewWithTag(tag) as! UIButton
            imageButton.kf.setImage(with: val.0, for: .normal, placeholder: val.1)
        }
        //remove Images
        if images.count+1 <= 5 {
            for index in (images.count+1)...5 {
                let tag = 101 + index*10
                let imageButton = view.viewWithTag(tag) as! UIButton
                imageButton.kf.setImage(with: nil, for: .normal, placeholder: nil)
            }
        }
    }
    
    func downloadImages(index: Int) {
        UserService().downloadProfileImage(userId: (Authenticator.shared.user?.id)!, index: "\(index)", completion: { (url, error) in
            if error == nil {
                self.images.append((url, nil))
                self.downloadImages(index: index+1)
            } else {
                if error == FirebaseManagerError.noDataFound {
                    if self.images.count == 0 {
                        if let images = self.user?.profile.images {
                            images.forEach { self.images.append(($0,nil)) }
                        }
                    }
                    return
                }
            }
        })
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        FIRDatabase.database().reference().child("user/\(FIRAuth.auth()!.currentUser!.uid)/profile/bio").setValue(bioText.text)
    }
    
    @IBAction func doneNavBtn(_ sender: Any) {
            self.removeFirebaseImage(0)
    }
    
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func removeFirebaseImage(_ index: Int) {
        if self.imageToRemove.count-1 >= index {
            UserService().removeFirebaseImage(image: self.imageToRemove[index], completion: { (error) in
                if error != nil {
                    print("unable to remove images")
                } else {
                    self.removeFirebaseImage(index+1)
                }
            })
        } else {
            if self.images.count-1 >= 0 {
                self.activityIndicator.startAnimating()
                self.uploadImage(index: 0)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func uploadImage(index: Int) {
        UserService().updateUserProfileImage(user: Authenticator.shared.user!, image: self.images[index],index: "\(index)", completion: { [weak self] (data, error) in
            if let me = self {
                if error != nil {
                    me.activityIndicator.stopAnimating()
                    print(error?.localizedDescription ?? "Upload error!!")
                    self?.alert(message: error?.localizedDescription)
                }
                else {
                    me.images.remove(at: index)
                    me.images.insert(data, at: index)
                    
                    let newIndex = index + 1
                    if me.images.count-1 >= newIndex {
                        me.uploadImage(index: newIndex)
                    } else {
                        me.activityIndicator.stopAnimating()
                        print("upload Complete")
                        me.updateSuccess()
                    }
                }
            }
        })
    }
    
    func updateSuccess() {
        
        let imagess = self.images.flatMap({
            return $0.0
        })
        
        self.user?.profile.images = imagess 
        
        self.user?.profile.bio  = self.bioText.text
        
        UserService().saveUser(user: self.user!, completion: { (success, error) in
            if error != nil {
                self.alert(message: "Successfully updated profile", title: "Success!", okAction: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        })
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
        if images.count != 0 {
            if self.images.count-1 >= index {
                if let url = self.images[index].0 {
                    self.imageToRemove.append(url)
                }
                self.images.remove(at: index)
            }
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
        
        let index = (self.pickerTag - 101)/10 - 1
        
        guard let image = info[UIImagePickerControllerEditedImage] as?  UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
       
        if self.images.count-1 >= index{
            self.images.remove(at: index)
            self.images.insert((nil,image), at: index)
        } else {
            self.images.append((nil,image))
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditingTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            // Policy row 5
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "http://socialyzeapp.com/privacy")!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/privacy")!)
            }
        }
            // Terms and condition row 6
        else if indexPath.row == 6 {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "http://socialyzeapp.com/terms-and-conditions")!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/terms-and-conditions")!)
            }
        }
        
            // Logout row 8
        else if indexPath.row == 8 {
            self.alertWithOkCancel(message: "Are you sure?", title: "Alert", okTitle: "Ok", cancelTitle: "Cancel", okAction: {
                Authenticator.shared.logout()
            }, cancelAction: nil)
        }
        
            // Delete Accont row 9
        else if indexPath.row == 9 {
            self.alertWithOkCancel(message: "Are you sure?", title: "Alert", okTitle: "Ok", cancelTitle: "Cancel", okAction: {
                Authenticator.shared.logout()
                // this has to actually delete the account
            }, cancelAction: nil)
        }
        
    }
}

extension EditingTableViewController: AuthenticatorDelegate {
    
    func shouldUserSignInIntoFirebase() -> Bool {
        
        return true
    }
    
    func didLogoutUser() {
        appDelegate.checkForLogin()
    }
    
    func didSignInUser() {
    }
    
    func didOccurAuthentication(error: AuthenticationError) {
        let alert = UIAlertController(title:"Error", message: error.localizedDescription , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension EditingTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    // For checking whether enter text can be taken or not.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == bioText && string != ""{
            let x = (textField.text ?? "").characters.count
            return x <= 9
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
