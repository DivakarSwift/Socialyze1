//
//  CustomSwipeSegue.swift
//  Slide
//
//  Created by Tyler Stohr on 5/17/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class CustomRightSwipeSegue: UIStoryboardSegue {
    
    override func perform() {
        // Assign the source and destination views
        let homeVC = self.source.view
        let profVC = self.destination.view
        
        
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer: )))
//        homeVC?.addGestureRecognizer(gesture)
        
        
        
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
            homeVC?.frame = homeVC!.frame.offsetBy(dx: screenWidth, dy: 0.0)
            profVC?.frame = profVC!.frame.offsetBy(dx: screenWidth, dy: 0.0)
            if self.source.navigationController?.isNavigationBarHidden == false {
                self.source.navigationController?.setNavigationBarHidden(true, animated: true)
            }
            //self.source.navigationController?.setToolbarHidden(true, animated: true)
            
            
            
        }) { (Finished) -> Void in
            if let nav = self.source.navigationController {
                nav.pushViewController(self.destination as UIViewController, animated: false)
            } else {
                self.source.present(self.destination as UIViewController, animated: false, completion: nil)
            }
        }
    }
    
//    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
//        let translation = gestureRecognizer.translation(in: self.source.view)
//        let label = gestureRecognizer.view!
//        label.center = CGPoint(x: self.source.view.bounds.width / 2 + translation.x, y: self.source.view.bounds.height / 2 + translation.y)
//        
//        
//    }

}

class CustomLeftSwipeSegue: UIStoryboardSegue {
    
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
            
        }) { (Finished) -> Void in
            if let nav = self.source.navigationController {
                nav.pushViewController(self.destination as UIViewController, animated: false)
            } else {
                self.source.present(self.destination as UIViewController, animated: false, completion: nil)
            }
        }
    }
    
}

class CustomUpSwipeSegue: UIStoryboardSegue {
    
    override func perform() {
        // Assign the source and destination views
        let profVC = self.source.view
        let homeVC = self.destination.view
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Specifiy init position
        homeVC?.frame = CGRect(x: 0.0, y: screenHeight, width: screenWidth, height: screenHeight)
        
        // Access the app's key window and insert the views next to each other.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(homeVC!, at: 0)
        window?.insertSubview(profVC!, at: 1)
        
        // Animate
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            homeVC?.frame = homeVC!.frame.offsetBy(dx: 0.0 , dy: -screenHeight)
            profVC?.frame = profVC!.frame.offsetBy(dx: 0.0, dy: -screenHeight)
            
        }) { (Finished) -> Void in
            if let nav = self.source.navigationController {
                nav.pushViewController(self.destination as UIViewController, animated: false)
            } else {
                self.source.present(self.destination as UIViewController, animated: false, completion: nil)
            }
        }
    }
    
}
