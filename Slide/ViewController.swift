//
//  ViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/3/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var scrolView: UIScrollView!
    @IBOutlet var mainView: UIView!
    
    @IBAction func switchToCategoryFromButton(_ sender: Any) {
        let categoryDefaults = UserDefaults.standard
        switch (sender as AnyObject).tag {
        case 0:
            categoryDefaults.set("Coffee", forKey: "Category")
            break
        case 1:
            categoryDefaults.set("Dining", forKey: "Category")
            break
        case 2:
            categoryDefaults.set("Nightlife", forKey: "Category")
            break
        case 3:
            categoryDefaults.set("Party", forKey: "Category")
            break
        case 4:
            categoryDefaults.set("Fitness", forKey: "Category")
            break
        case 5:
            categoryDefaults.set("Gaming", forKey: "Category")
            break
        case 6:
            categoryDefaults.set("Study Group", forKey: "Category")
            break
        case 7:
            categoryDefaults.set("Causes", forKey: "Category")
            break
        case 8:
            categoryDefaults.set("Chill", forKey: "Category")
            break
        case 9:
            categoryDefaults.set("Others", forKey: "Category")
            break
        default:
            break
        }
        
        print("button press \(categoryDefaults.value(forKey: "Category") as! String)")
 
        performSegue(withIdentifier: "categoryDetail", sender: self)
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        scrolView.delegate = self
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Create Event",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(eventBtn)
        )
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Profile",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(profileBtn)
            
            
        )
        // Do any additional setup after loading the view, typically from a nib.
    

    
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Home"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func eventBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Events", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelectionViewController") as UIViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func profileBtn(_ sender: UIBarButtonItem) {
       
    }
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return mainView
//    }

}
