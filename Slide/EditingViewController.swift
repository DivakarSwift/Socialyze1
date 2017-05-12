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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        FIRDatabase.database().reference().child("user/\(FIRAuth.auth()!.currentUser!.uid)/profile/bio").setValue(bioText.text)
    }
    
    @IBAction func doneNavBtn(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
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
