//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

var userLoggedOut = false

class ViewController: UIViewController, UITextFieldDelegate/*, UINavigationControllerDelegate, UIImagePickerControllerDelegate*/ {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    //true is signup, false is login
    var currentWelcomeScreen = true
    
    //adds a spinner to center of screen
    func addSpinner(){
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    //sets up an alert based on arguments
    func alertUser(alertTitle: NSString, msg:NSString, buttonTxt:NSString){
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
    
    func initLoginSegue(){
        performSegueWithIdentifier("login", sender: self)
    }
    
    func signupHandler(){
        //check to make sure a username and password were entered
        if enteredName.text == "" || enteredPass.text == ""{
            alertUser("Error", msg: "Please enter a username and password", buttonTxt: "Ok")
        }else{
            //add spinner animation
            addSpinner()
            let user = PFUser()
            user.username = enteredName.text
            user.password = enteredPass.text
            //store user info in background to parse
            user.signUpInBackgroundWithBlock({
                (success, error) -> Void in
                //stop spinner
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                //alert user of errors
                if error != nil{
                    if let errorString = error!.userInfo["error"] as? NSString{
                        self.alertUser("Error", msg: errorString, buttonTxt: "Ok")
                    }
                }
                else{
                    //succesful
                    userLoggedOut = false
                    print("signed up!")
                    self.initLoginSegue()
                }
            })
            
        }
    }
    
    func loginHandler(){
        //check to make sure a username and password were entered
        if enteredName.text == "" || enteredPass.text == ""{
            alertUser("Error", msg: "Please enter a username and password", buttonTxt: "Ok")
        }else{
            //add spinner animation
            addSpinner()
            let username = enteredName.text
            let password = enteredPass.text
            //store user info in background to parse
            PFUser.logInWithUsernameInBackground(username!, password: password!) {
                (success, error) -> Void in
                //stop spinner
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                //alert user of errors
                if error != nil{
                    if let errorString = error!.userInfo["error"] as? NSString{
                        self.alertUser("Error", msg: errorString, buttonTxt: "Ok")
                    }
                }
                else{
                    //succesful
                    print("logged in!")
                    userLoggedOut = false
                    self.initLoginSegue()
                }
            }
        }
    }

    @IBOutlet weak var enteredName: UITextField!
    
    @IBOutlet weak var enteredPass: UITextField!
    
    @IBOutlet weak var primaryButton: UIButton!
    
    @IBOutlet weak var switchButton: UIButton!
    
    //the button that actually has an action, whether signup or login
    @IBAction func primaryAction(sender: AnyObject) {
        if currentWelcomeScreen{
            signupHandler()
        }else{
            loginHandler()
        }
    }
    
    //switches the primary button to login or signup
    @IBAction func switchAction(sender: AnyObject) {
        currentWelcomeScreen = !currentWelcomeScreen
        if currentWelcomeScreen{
            primaryButton.setTitle("Signup", forState: .Normal)
            switchButton.setTitle("Login", forState: .Normal)
        }else{
            primaryButton.setTitle("Login", forState: .Normal)
            switchButton.setTitle("Signup", forState: .Normal)
        }
    }
    
    //Gets rid of keyboard if user touches outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            self.view.endEditing(true)
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    //gets rid of keyboard if user hits return
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //allows the keyboard to disapear for both user input fields
        self.enteredName.delegate = self
        self.enteredPass.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        //log the user out if they pressed the logout button
        if userLoggedOut{
            PFUser.logOut()
            alertUser("Logout", msg: "You have been logged out", buttonTxt: "Ok")
        }
            
        //if the user is already logged in, segue to main screen
        else if PFUser.currentUser() != nil{
            self.performSegueWithIdentifier("login", sender: self)
            userLoggedOut = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

