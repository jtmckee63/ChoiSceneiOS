//
//  ViewController.swift
//  ChoiScene
//
//  Created by joseph mckee on 8/5/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//
import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKMessengerShareKit
import FBSDKShareKit
import FBNotifications
import FBAudienceNetwork

import UIKit

extension UIView {
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.5, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.5, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var btnFacebook: FBSDKLoginButton!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var ivUserProfileImage: UIImageView!
    
    @IBOutlet var beginButton: UIButton!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var lightBlue = UIColor(red:0.42, green:0.93, blue:1.00, alpha:1.0)
    
    func configureFacebook()
    {
        btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        btnFacebook.delegate = self
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            
            self.getFacebookUserInfo()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.beginButton.fadeOut()
        self.beginButton.hidden = true
        ivUserProfileImage.fadeOut()
        ivUserProfileImage.image = UIImage(named: "ChoiScene-Pic.png")
        ivUserProfileImage.fadeIn()
        lblName.text = "Not Logged In"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user profile pic
        ivUserProfileImage = UIImageView(frame: CGRectMake(0, 0, 200, 200))
        ivUserProfileImage.center = CGPoint(x: view.center.x, y: 150)
        ivUserProfileImage.image = UIImage(named: "ChoiScene-Pic.png")
        ivUserProfileImage.layer.borderWidth = 3.0
        self.ivUserProfileImage.layer.borderColor = lightBlue.CGColor
        self.ivUserProfileImage.layer.cornerRadius = self.ivUserProfileImage.frame.size.width / 2;
        self.ivUserProfileImage.clipsToBounds = true;
        view.addSubview(ivUserProfileImage)
        
        //user name
        lblName = UILabel(frame: CGRectMake(0,0,200,30))
        lblName.center = CGPoint(x: view.center.x, y: 300)
        lblName.text = "Please Login"
        lblName.textAlignment = NSTextAlignment.Center
        view.addSubview(lblName)


        //begin button
        let goButtonImage = UIImage(named: "goButton.jpg")
        self.beginButton.setImage(goButtonImage, forState: .Normal)
        self.beginButton.layer.cornerRadius = self.beginButton.frame.size.width / 2;
        self.beginButton.clipsToBounds = true;
        beginButton.layer.borderWidth = 3.0
        self.beginButton.layer.borderColor = lightBlue.CGColor
        //default begin butto hidden until login
        self.beginButton.fadeOut()
        self.beginButton.hidden = true
        
        
        //FB token
        if FBSDKAccessToken.currentAccessToken() != nil {
          self.beginButton.hidden = false
            self.beginButton.fadeIn()
            
        }
        
        let btnFacebook = FBSDKLoginButton()
        btnFacebook.center = CGPoint(x: view.center.x, y: 400)
        btnFacebook.delegate = self
        view.addSubview(btnFacebook)
        
        getFacebookUserInfo()
        
//        self.ivUserProfileImage.layer.cornerRadius = self.ivUserProfileImage.frame.size.width / 2;
//        self.ivUserProfileImage.clipsToBounds = true;
        
        
        print ("end of viewDidLoad()")
        
    }
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            //print permissions, such as public_profile
            print(FBSDKAccessToken.currentAccessToken().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                let userName = result.valueForKey("name") as? String
                self.lblName.text = userName
                
                let FBid = result.valueForKey("id") as? String
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                let userImage = UIImage(data: NSData(contentsOfURL: url!)!)
                
//                //Save user image to k/v pair
//                self.userDefaults.setValue(userImage, forKey: "user_image")
//                //Save UserName to k/v pair
//                self.userDefaults.setValue(userName, forKey: "user_name")
                
                self.ivUserProfileImage.image = userImage
                self.ivUserProfileImage.fadeIn()
                
                self.beginButton.fadeIn()
                self.beginButton.hidden = false
                
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        ivUserProfileImage.fadeIn()
        return true
    }
    
    
}


