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
    var images:[(URL?,UIImage?)] = [] 
    var imageToRemove:[URL] = []
    @IBOutlet weak var bioTextView: UITextView!
    var pickerTag:Int = 111
    var user:User? {
        didSet {
            if let images = self.user?.profile.images{
                self.images = []
                images.forEach({ (url) in
                    self.images.append((url,nil))
                })
            }
            self.updateBio()
        }
    }
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        Authenticator.shared.delegate = self
        self.user = Authenticator.shared.user
        imagePicker.delegate = self
        self.view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.assignImages()
    }
    
    func assignImages() {
        // set Image
        for (index,val) in self.images.enumerated() {
            if index >= 5 {
                return
            }
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
    
    func updateBio() {
        let maxLength = 200 //char length
        if let orgText = user?.profile.bio {
            if orgText.characters.count > maxLength {
                let range =  orgText.rangeOfComposedCharacterSequences(for: orgText.startIndex..<orgText.index(orgText.startIndex, offsetBy: maxLength))
                let tmpValue = orgText.substring(with: range).appending("...")
                self.bioTextView.text = tmpValue
                //updateBio(bio: tmpValue)
            } else {
                self.bioTextView.text = user?.profile.bio
            }
        } 
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
                if data.0 == nil && error != nil{
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
        self.assignImages()
        UserService().saveUser(user: self.user!, completion: { (success, error) in
            if error == nil {
                //self.alert(message: "Successfully updated profile", title: "Success!", okAction: {
                    Authenticator.shared.user = self.user
                    _ = self.navigationController?.popViewController(animated: true)
                //})
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
            self.assignImages()
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
        UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/privacy")!)
    }
    
    @IBAction func termsAndConditionsBtn(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/terms-and-conditions")!)
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
        dismiss(animated: true, completion: {
            self.assignImages()
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            self.assignImages()
        })
    }
}

extension EditingTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            // Policy row 4
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "http://socialyzeapp.com/privacy")!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/privacy")!)
            }
        }
            // Terms and condition row 5
        else if indexPath.row == 5 {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: "http://socialyzeapp.com/terms-and-conditions")!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/terms-and-conditions")!)
            }
        }
        
            // Logout row 6
        else if indexPath.row == 6 {
            self.alertWithOkCancel(message: "Are you sure?", title: "Alert", okTitle: "Ok", cancelTitle: "Cancel", okAction: {
                Authenticator.shared.logout()
            }, cancelAction: nil)
        }
        
            // Delete Accont row 7
        else if indexPath.row == 7 {
            self.alertWithOkCancel(message: "Are you sure?", title: "Alert", okTitle: "Ok", cancelTitle: "Cancel", okAction: {
                
                self.activityIndicator.startAnimating()
                UserService().deleteUser(userId: (Authenticator.shared.user?.id)!, completion: { (success, error) in
                    self.activityIndicator.stopAnimating()
                    if let err = error {
                        self.alert(message: err.localizedDescription, title: "Alert", okAction: { 
                            Authenticator.shared.logout()
                        })
                    }
                    else {
                        self.alert(message: "Your account has been Deleted Successfully!", title: "Success", okAction: {
                            Authenticator.shared.logout()
                        })
                    }
                })
            }, cancelAction: nil)
        }
        
    }
}

extension EditingTableViewController: AuthenticatorDelegate {
    
    func shouldUserSignInIntoFirebase() -> Bool {
        
        return true
    }
    
    func didLogoutUser() {
        let identifier = "LoginViewController"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        appDelegate.window?.rootViewController = vc
    }
    
    func didSignInUser() {
    }
    
    func didOccurAuthentication(error: AuthenticationError) {
        self.alert(message: error.localizedDescription, title: "Error", okAction: {
            appDelegate.checkForLogin()
        })
    }
}

extension EditingTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    // For checking whether enter text can be taken or not.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == bioTextView && text != ""{
            let x = (textView.text ?? "").characters.count
            return x <= 199
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let id = Authenticator.shared.user?.id {
            FirebaseManager().reference.child("user/\(id)/profile/bio").setValue(textView.text)
            self.user?.profile.bio = textView.text
            Authenticator.shared.user = self.user
        }
    }
    
}
