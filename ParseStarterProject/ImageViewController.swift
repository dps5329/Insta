//
//  ImageViewController.swift
//  ParseStarterProject
//
//  Created by Daniel Schartner on 7/19/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var currentPhoto:UIImage!
    
    var activityIndicator = UIActivityIndicatorView()
    
    //sets up an alert based on arguments
    func alertUser(alertTitle: NSString, msg:NSString, buttonTxt:NSString){
        //make sure the alert can execute
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: alertTitle as String, message: msg as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: buttonTxt as String, style: .Default, handler: {(action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    //adds a spinner to center of screen
    func addSpinner(){
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    //What happens after the user picks a photo
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        print("image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //save the image
        imageView.image = image
        currentPhoto = image
    }

    //tells ios to show the user the image picking interface
    @IBAction func imagePicker(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        //change PhotoLibrary to Camera to get images from camera instead
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    @IBOutlet weak var userInput: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //save the image to the database
    @IBAction func postImage(sender: AnyObject) {
        //Make sure the user has selected an image and typed a caption
        if(currentPhoto != nil && userInput.text != ""){
            addSpinner()
            let imageData = UIImagePNGRepresentation(currentPhoto)
            let imageFile = PFFile(name:"photo.png", data:imageData!)
            
            //setup the necessary data to be able to save the image
            let post = PFObject(className:"Posts")
            post["desc"] = userInput.text
            post["user"] = PFUser.currentUser()!.objectId
            post["imageFile"] = imageFile
            post.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if error != nil{
                    self.imageView.image = nil
                    self.alertUser("Error", msg: "The image could not be posted", buttonTxt: "OK")
                }else{
                    //success
                }
            })
            
            currentPhoto = nil
            userInput.text = ""
        }else{
            alertUser("Error", msg: "Please select an image and enter a caption", buttonTxt: "OK")
        }
    }
    
    //handles the keyboard so it can get out of the way
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInput.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
