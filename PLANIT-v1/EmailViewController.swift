//
//  SignUpViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/10/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import DrawerController
import FBSDKLoginKit
import FBSDKCoreKit
import FacebookCore
import FacebookLogin


class EmailViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var pleaseEnterEmail: UILabel!
    
    var hamburgerArrowButton: Icomation?

    //FB Login
    var loginButton: FBSDKLoginButton?
    var loginDict: [String:Any]?

    func hamburgerArrowButtonTouchedUpInside(sender:Icomation){
        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.toggleLeftDrawerSide(animated: true, completion: nil)
        self.view.endEditing(true)
        hamburgerArrowButton?.close()
    }
    
    func leftViewControllerViewWillDisappear() {
        if hamburgerArrowButton?.toggleState == false {
            hamburgerArrowButton?.close()
            self.view.endEditing(true)
        }
    }
    func leftViewControllerViewWillAppear() {
        if hamburgerArrowButton?.toggleState == true {
            hamburgerArrowButton?.close()
            self.view.endEditing(true)
        }
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
        
        //When you call the logOut, the user is logged out of your app. it will not logout you from your fb account. if you want to do so, go into the safari app, you can go Facebook.com and logout of your account.
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
        } else {
            fetchProfile()
        }
    }
    // Once the button is clicked, show the login dialog
    @objc func loginButtonClicked() {
        
        if FBSDKAccessToken.current() != nil {
            fetchProfile()
        } else {
        
            let loginManager = FBSDKLoginManager()
            loginManager.logIn(withReadPermissions: ["email","public_profile","user_friends"], from: self, handler: { (loginResult: FBSDKLoginManagerLoginResult?, error: Error?) -> Void in
                if (loginResult?.isCancelled)! {
                    print("User cancelled login.")
                } else {
                    if error != nil {
                        print(error!)
                        return
                    } else {
                        self.loginDict = ["grantedPermissions":loginResult?.grantedPermissions!,"declinedPermissions": loginResult?.declinedPermissions!,"accesToken": loginResult?.token!]
                    }
                }
            })
        }
    }
    
    func fetchProfile() {
        let parameters = ["fields": "email,picture.type(large),name,gender,age_range,cover,timezone,verified,updated_time,education,religion,friends"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start{ (connection,result,error)-> Void in
            
            if error != nil {   // Error occured while logging in
                print(error!)
                return
            }
            
            // Details received successfully
            let dictionary = result as! [String: AnyObject]
            // pass this dictionary object into your model class initialiser
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FB Login
        loginButton = { () -> FBSDKLoginButton in 
            let button = FBSDKLoginButton()
            button.readPermissions = ["email", "user_friends"]
            return button
        }()
        loginButton?.center = view.center
        loginButton?.addTarget(self, action: #selector(self.loginButtonClicked), for: UIControlEvents.touchUpInside)
        loginButton?.delegate = self
        view.addSubview(loginButton!)
        
        
        // MARK: Register notifications
        //Drawer
        NotificationCenter.default.addObserver(self, selector: #selector(leftViewControllerViewWillAppear), name: NSNotification.Name(rawValue: "leftViewControllerViewWillAppear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftViewControllerViewWillDisappear), name: NSNotification.Name(rawValue: "leftViewControllerViewWillDisappear"), object: nil)
        
        hamburgerArrowButton = Icomation(frame: CGRect(x: 15, y: 28, width: 24, height: 24))
        self.view.addSubview(hamburgerArrowButton!)
        hamburgerArrowButton?.type = IconType.close
        hamburgerArrowButton?.topShape.strokeColor = UIColor.white.cgColor
        hamburgerArrowButton?.middleShape.strokeColor = UIColor.white.cgColor
        hamburgerArrowButton?.bottomShape.strokeColor = UIColor.white.cgColor
        hamburgerArrowButton?.animationDuration = 0.7
        hamburgerArrowButton?.numberOfRotations = 2
        hamburgerArrowButton?.addTarget(self, action: #selector(self.hamburgerArrowButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)

        self.emailAddress.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        emailAddress.becomeFirstResponder()
        emailAddress.setBottomBorder(borderColor: UIColor.white)

//        emailAddress.layer.borderWidth = 1
//        emailAddress.layer.cornerRadius = 5
//        emailAddress.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        emailAddress.layer.masksToBounds = true
        let emailAddressLabelPlaceholder = emailAddress!.value(forKey: "placeholderLabel") as? UILabel
        emailAddressLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
//        let clearButton = emailAddress?.value(forKey: "clearButton") as! UIButton
//        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
//        clearButton.tintColor = UIColor.white
//        clearButton.alpha = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Load the values from our shared data container singleton
        let emailAddressValue = DataContainerSingleton.sharedDataContainer.emailAddress ?? ""
        emailAddress.becomeFirstResponder()
        
        //Install the value into the text field.
        self.emailAddress.text =  "\(emailAddressValue)"
        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.openDrawerGestureModeMask = OpenDrawerGestureMode.panningCenterView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.4) {
            self.emailAddress.frame.origin.y = 408
            self.pleaseEnterEmail.frame.origin.y = 372
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        if (emailAddress.text?.contains("@"))! {
            emailAddress.resignFirstResponder()
            super.performSegue(withIdentifier: "emailToPassword", sender: self)
        } else {
            UIView.animate(withDuration: 0.5) {
                self.pleaseEnterEmail.text = "Please enter a valid email address"
                self.emailAddress.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func EmailFieldEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.emailAddress = emailAddress.text
        
    }
    
}
