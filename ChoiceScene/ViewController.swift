//
//  ViewController.swift
//  ChoiScene
//
//  Created by joseph mckee on 8/5/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKMessengerShareKit
import FBSDKShareKit
import FBNotifications
import FBAudienceNetwork

import UIKit
class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var btnFacebook: FBSDKLoginButton!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var ivUserProfileImage: UIImageView!
    
    @IBOutlet var beginButton: UIButton!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
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
        self.beginButton.hidden = true
        ivUserProfileImage.image = UIImage(named: "fb-art.jpg")
        lblName.text = "Not Logged In"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivUserProfileImage = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        ivUserProfileImage.center = CGPoint(x: view.center.x, y: 200)
        ivUserProfileImage.image = UIImage(named: "fb-art.jpg")
        view.addSubview(ivUserProfileImage)
        
        lblName = UILabel(frame: CGRectMake(0,0,200,30))
        lblName.center = CGPoint(x: view.center.x, y: 300)
        lblName.text = "Not Logged In"
        lblName.textAlignment = NSTextAlignment.Center
        view.addSubview(lblName)
        
        
        self.beginButton.hidden = true
        
        if FBSDKAccessToken.currentAccessToken() != nil {
          self.beginButton.hidden = false
        }
        
        let btnFacebook = FBSDKLoginButton()
        btnFacebook.center = CGPoint(x: view.center.x, y: 400)
        btnFacebook.delegate = self
        view.addSubview(btnFacebook)
        
        getFacebookUserInfo()
        
        self.ivUserProfileImage.layer.cornerRadius = self.ivUserProfileImage.frame.size.width / 2;
        self.ivUserProfileImage.clipsToBounds = true;
        
        
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
                self.beginButton.hidden = false
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    
}


