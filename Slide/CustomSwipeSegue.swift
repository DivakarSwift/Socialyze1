//
//  CustomSwipeSegue.swift
//  Slide
//
//  Created by Tyler Stohr on 5/17/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class CustomSwipeSegue: UIStoryboardSegue {
    
    override func perform() {
        // Assign the source and destination views
        var homeVC = self.source.view
        var profVC = self.destination.view
        
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
            
        }) { (Finished) -> Void in
            self.source.present(self.destination as UIViewController, animated: false, completion: nil)
        }
    }

}
