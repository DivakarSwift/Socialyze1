//
//  LoginViewController.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let authenticator = Authenticator()

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticator.delegate = self
    }

    @IBAction func login(_ sender: Any) {
        authenticator.authenticateWith(provider: .facebook)
    }
}

extension LoginViewController: AuthenticatorDelegate {
    
    func shouldUserSignInIntoFirebase() -> Bool {
        return true
    }

    func didLogoutUser() {
        
    }
    
    func didSignInUser() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainNav")
        self.view.window?.rootViewController = vc
    }
    
    func didOccurAuthentication(error: AuthenticationError) {
        let alert = UIAlertController(title:"Error", message: error.localizedDescription , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
