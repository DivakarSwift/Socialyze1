//
//  CustomSwipeUnwindSegue.swift
//  Slide
//
//  Created by Tyler Stohr on 5/17/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class CustomSwipeUnwindSegue: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views
        let profVC = self.source.view
        let homeVC = self.destination.view
        
        let screenWidth = UIScreen.main.bounds.size.width
        //let screenHeight = UIScreen.main.bounds.size.height
        
        // Specifiy init position
        //homeVC?.frame = CGRect(x: screenWidth, y: 0.0, width: screenWidth, height: screenHeight)
        
        // Access the app's key window and insert the views next to each other.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(homeVC!, at: 0)
        window?.insertSubview(profVC!, at: 1)
        
        // Animate
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            homeVC?.frame = homeVC!.frame.offsetBy(dx: -screenWidth, dy: 0.0)
            profVC?.frame = profVC!.frame.offsetBy(dx: -screenWidth, dy: 0.0)
            if self.source.navigationController?.isNavigationBarHidden == true {
            self.destination.navigationController?.setNavigationBarHidden(false, animated: true)
            
            //self.destination.navigationController?.setToolbarHidden(false, animated: true)
            }
        }) { (Finished) -> Void in
            _ = self.source.navigationController?.popViewController(animated: false)
            self.source.dismiss(animated: false, completion: nil)
        }
    }
}

class CustomSwipeLeftUnwindSegue: UIStoryboardSegue {
    override func perform() {
        
        let homeVC = self.source.view
        let profVC = self.destination.view
        
        // Get screen width and height
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Specify initial position of destination view
        profVC?.frame = CGRect(x: -screenWidth, y: 0.0, width: screenWidth, height: screenHeight)
        
        // Access the app's key window and insert the views next to each other.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(profVC!, at: 0)
        window?.insertSubview(homeVC!, at: 1)
        //window?.insertSubview(profVC!, aboveSubview: homeVC!)
        
        // Animate the transition
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            homeVC?.frame = homeVC!.frame.offsetBy(dx: -screenWidth, dy: 0.0)
            profVC?.frame = profVC!.frame.offsetBy(dx: -screenWidth, dy: 0.0)
            if self.source.navigationController?.isNavigationBarHidden == true {
                self.destination.navigationController?.setNavigationBarHidden(false, animated: true)
                
                //self.destination.navigationController?.setToolbarHidden(false, animated: true)
            }
        }) { (Finished) -> Void in
            _ = self.source.navigationController?.popViewController(animated: false)
            self.source.dismiss(animated: false, completion: nil)
        }
    }
}
