//
//  SelectionViewController.swift
//  Slide
//
//  Created by Salem Khan on 3/7/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
      var picker = UIImagePickerController()
  var eventsArray = Array<String>()
    @IBOutlet weak var objectToMove: UIView!
    @IBOutlet var userImg: UIButton!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var txtDescription: UITextView!
    @IBOutlet var lblCharacterLft: UILabel!
    var val : String!
    
    @IBOutlet var btnPost: UIButton!
    lazy fileprivate var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "ladybird.png")!
        return CustomActivityIndicatorView(image: image)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        picker.delegate = self
       
        self.title = "Create Event"
        // Do any additional setup after loading the view.
         eventsArray = ["Coffee","Dining","Party","Nightlife","Fitness","Gaming","Study Group","Causes","Chill","Others"]
        pickerView.delegate = self
        txtDescription.delegate = self
               
        
          addLoadingIndicator()
        self.navigationController?.navigationBar.topItem?.title = "Back"
        
        btnPost.layer.cornerRadius = 5; // this value vary as per your desire
        btnPost.clipsToBounds = true;
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
     

    @IBAction func btnPost(_ sender: Any) {
        activityIndicator.startAnimating()
    }
    
    // MARK: - Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         val = eventsArray[row]
        return val
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("chars \(textView.text.characters.count) \( text)")
        let nmbr = 100 - textView.text.characters.count
        lblCharacterLft.text = String( nmbr) + " " + "Characters Left"
        if(textView.text.characters.count > 99 && range.length == 0) {
            print("Please summarize in 20 characters or less")
            return false;
        }
        
        return true;
    }
    
    
    func moveImageInCircile() {
        let orbit = CAKeyframeAnimation(keyPath: "position")
        var affineTransform = CGAffineTransform(rotationAngle: 0.0)
        affineTransform = affineTransform.rotated(by: CGFloat(M_PI))
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 100 - (100/2),y: 100 - (100/2)), radius:  CGFloat(100), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        orbit.path = circlePath.cgPath
        orbit.duration = 4
        orbit.isAdditive = true
        orbit.repeatCount = 100
        orbit.calculationMode = kCAAnimationPaced
        orbit.rotationMode = kCAAnimationRotateAuto
        
        objectToMove.layer .add(orbit, forKey: "orbit")
    }
    @IBAction func btnImage(_ sender: Any) {
        print("btn pressed")
        let alert = UIAlertController(title:"Please Select an Option", message:nil , preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            print("User click Camera button")
            self.openCamera()
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default , handler:{ (UIAlertAction)in
            print("User click Photo button")
            self.openGallary()
            
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
            
            
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        // Add the actions

    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker, animated: true, completion: nil)
        }
        else
        {
           
        }
    }
    func openGallary()
    {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    //PickerView Delegate Methods
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        userImg.setImage(image, for: UIControlState.normal)
        userImg.setTitle("", for: UIControlState.normal)
        
     
        self.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
        
    }

    
    func addLoadingIndicator () {
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
    }
}
