//
//  UIViewControllerExtension.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(message: String?, title: String? = "Error", okAction: (()->())? = nil ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            okAction?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}
