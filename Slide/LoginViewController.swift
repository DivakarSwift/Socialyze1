//
//  LoginViewController.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import TTTAttributedLabel
class LoginViewController: UIViewController,TTTAttributedLabelDelegate {
    
    @IBOutlet var lbl: TTTAttributedLabel!
    let authenticator = Authenticator.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticator.delegate = self
        let str : NSString = "Socialyze does not post on Facebook. By continuing you agree to our Terms of Service and Privacy Policy."
        lbl.delegate = self
        lbl.text = str as String
        let range : NSRange = str.range(of: "Terms of Service")
        let rangePrivacy : NSRange = str.range(of: "Privacy Policy")
        
        lbl.addLink(to: NSURL(string: "http://socialyzeapp.com/terms-and-conditions/")! as URL!, with: range)
        lbl.addLink(to: NSURL(string: "http://socialyzeapp.com/privacy/")! as URL!, with: rangePrivacy)

    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        print("Click On Line")
        do {
            let urlStr = try String(contentsOf: url)
            if urlStr == "http://socialyzeapp.com/terms-and-conditions/" {
                UIApplication.shared.openURL(url)
            }else{
                UIApplication.shared.openURL(url)
            }
        } catch {
            // handle error
        }
     
        
        
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
        appDelegate.checkForLogin()
    }
    
    func didOccurAuthentication(error: AuthenticationError) {
        let alert = UIAlertController(title:"Error", message: error.localizedDescription , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default , handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
