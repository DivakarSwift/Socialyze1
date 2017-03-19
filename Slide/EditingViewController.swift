//
//  EditingViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/8/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class EditingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func doneNavBtn(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ageSlider(_ sender: Any) {
    }
    
    @IBAction func distanceSlider(_ sender: Any) {
    }
    
    @IBAction func deleteAccountBtn(_ sender: Any) {
    }
    
    @IBAction func logout(_ sender: Any) {
    }
     
    @IBAction func privacyPolicyBtn(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.google.com")!)
    }
    
    @IBAction func termsAndConditionsBtn(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.google.com")!)
    }
}
