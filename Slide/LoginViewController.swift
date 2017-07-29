//
//  LoginViewController.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {
    
    let authenticator = Authenticator.shared
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        let activityIndicator = CustomActivityIndicatorView(image: image)
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        authenticator.delegate = self
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.center = view.center
    }

    @IBAction func termsButton(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "http://socialyzeapp.com/terms-and-conditions")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/terms-and-conditions")!)
        }
    }
    
    @IBAction func privacyButton(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: "http://socialyzeapp.com/privacy")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "http://socialyzeapp.com/privacy")!)
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        self.activityIndicator.startAnimating()
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
        self.activityIndicator.stopAnimating()
        appDelegate.checkForLogin()
    }
    
    func didOccurAuthentication(error: AuthenticationError) {
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title:"Error", message: error.localizedDescription , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
