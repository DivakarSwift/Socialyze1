//
//  TextMessageViewController.swift
//  Slide
//
//  Created by mdev on 5/22/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import MessageUI

class TextMessageViewController: MFMessageComposeViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendText(sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hey! Check out this app. Use google.com link as placeholder."
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}
