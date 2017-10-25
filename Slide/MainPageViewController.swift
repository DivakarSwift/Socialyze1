//
//  MainPageViewController.swift
//  Slide
//
//  Created by bibek timalsina on 10/9/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var currentVCIndex = 1
    var pageViewController: UIPageViewController!
    
    var viewControllerArray: [UIViewController] = {
        let profile = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController()
        let main = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNav")
        let activity = UIStoryboard.init(name: "Activity", bundle: nil).instantiateViewController(withIdentifier: "ActivityViewController")
        
        return [profile!, main, activity]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeView(_:)), name: GlobalConstants.Notification.changePage.notification, object: nil)
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        if viewControllerArray.count > 0 {
            pageViewController.setViewControllers([viewControllerArray[currentVCIndex]], direction: .forward, animated: true, completion: nil)
        }
        
        pageViewController.view.frame = self.view.bounds
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = self.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = ""
    }
    
    func changeView(_ notification: Notification) {
        if let page = notification.object as? Int, self.viewControllerArray.count > page {
            self.changeViewControllerInPageVC(index: page)
        }
    }
    
    func changeViewControllerInPageVC(index: Int) {
        if currentVCIndex == index {
            return
        }
        let animationDirection: UIPageViewControllerNavigationDirection = currentVCIndex > index ? .reverse : .forward
        pageViewController.setViewControllers([viewControllerArray[index]], direction: animationDirection, animated: true, completion: nil)
        currentVCIndex = index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = viewControllerArray.index(of: viewController) {
            return self.viewControllerArray.elementAt(index: index + 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = viewControllerArray.index(of: viewController) {
            return self.viewControllerArray.elementAt(index: index - 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed == false {
            return
        }
        
        currentVCIndex = viewControllerArray.index(of: pageViewController.viewControllers!.last!) ?? 0
    }
    
}
