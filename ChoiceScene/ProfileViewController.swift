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
import Parse


import UIKit
class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var btnFacebook: FBSDKLoginButton!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var ivUserProfileImage: UIImageView!
    var posts:[Post] = []
    
    @IBOutlet var tableView: UITableView!
    
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
        ivUserProfileImage.image = UIImage(named: "fb-art.jpg")
        lblName.text = "Not Logged In"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivUserProfileImage = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        ivUserProfileImage.center = CGPoint(x: view.center.x, y: 100)
        ivUserProfileImage.image = UIImage(named: "fb-art.jpg")
        view.addSubview(ivUserProfileImage)
        
        lblName = UILabel(frame: CGRectMake(0,0,150,30))
        lblName.center = CGPoint(x: view.center.x, y: 200)
        lblName.text = "Not Logged In"
        lblName.textAlignment = NSTextAlignment.Center
        view.addSubview(lblName)
        
        let btnFacebook = FBSDKLoginButton()
        btnFacebook.center = CGPoint(x: view.center.x, y: 250)
        btnFacebook.delegate = self
        view.addSubview(btnFacebook)
        
        getFacebookUserInfo()
        
        self.ivUserProfileImage.layer.cornerRadius = self.ivUserProfileImage.frame.size.width / 2;
        self.ivUserProfileImage.clipsToBounds = true;
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //Register Nib for TableViewCell
        tableView.registerNib(UINib(nibName: "SceneTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //Table View
        tableView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.8)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        

        
        getUserLocationString(){
            (city, state) in self.loadData(self.createAndTrimClassName(city!, state: state!), category: 0)
        }
        
        print ("end of viewDidLoad()")
        
    }
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            //print permissions, such as public_profile
            print(FBSDKAccessToken.currentAccessToken().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                self.lblName.text = result.valueForKey("name") as? String
                
                let FBid = result.valueForKey("id") as? String
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                self.ivUserProfileImage.image = UIImage(data: NSData(contentsOfURL: url!)!)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    func loadData(className: String, category: Int){
        
        //Remove all posts from Posts
        posts.removeAll()
        
        let query = PFQuery(className: className)
        query.findObjectsInBackgroundWithBlock { (queryResults: [PFObject]?, error: NSError?) -> Void in
            
            if queryResults?.isEmpty == false{
                for object in queryResults! {
                    let post = Post()
                    post.geoPoint = object["GeoPoint"] as! PFGeoPoint
                    post.state = object["State"] as! String
                    post.city = object["City"] as! String
                    post.address = object["Address"] as! String
                    post.subAddress = object["SubAddress"] as! String
                    post.category = object["Category"] as! String
                    post.postImageData = object["PostImageData"] as! NSData
                    post.authorImageData = object["AuthorImageData"] as! NSData
                    post.authorName = object["AuthorName"] as! String
                    post.category = object["Category"] as! String
                    
                    self.posts.append(post)
                    self.tableView.reloadData()
                                   }
            }else{
                self.showAlert("Hmm..", message: "We couldn't find any posts in your area. Start checking in and spread the word about ChoiScene!")
            }
        }
        
    }
    
    //MARK: TableView Delegate Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SceneTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.postPlaceTitleLabel.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.8)
        cell.postAuthorImage.layer.cornerRadius = cell.postAuthorImage.bounds.width / 2
        cell.postAuthorImage.layer.borderColor = UIColor.whiteColor().CGColor
        cell.postAuthorImage.layer.borderWidth = 2.5
        cell.postAuthorImage.clipsToBounds = true
        
        cell.postPlaceTitleLabel.text = "\(posts[indexPath.row].subAddress), \(posts[indexPath.row].address)"
        cell.postImage.image = UIImage(data: posts[indexPath.row].postImageData)
        cell.postAuthorImage.image = UIImage(data: posts[indexPath.row].authorImageData)
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //Cell height is 320.
        return 370
    }
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAlertWithURL(title: String, message: String, urlMessage: String, URL: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { action in }))
        alert.addAction(UIAlertAction(title: urlMessage, style: UIAlertActionStyle.Cancel, handler: { action in
            let settingsUrl = NSURL(string: URL)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Helper Methods
    func createAndTrimClassName(city: String, state: String) -> String{
        var trimmedClass = String()
        let cityNoHiphen = city.stringByReplacingOccurrencesOfString("-", withString: "")
        let cityNoSpace = cityNoHiphen.stringByReplacingOccurrencesOfString(" ", withString: "")
        let stateNoHiphen = state.stringByReplacingOccurrencesOfString("-", withString: "")
        let stateNoSpace = stateNoHiphen.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        trimmedClass = cityNoSpace + stateNoSpace
        return trimmedClass
    }

    //Get User Location and return City,State ie... "Austin, TX"
    func getUserLocationString(completion: (city: String?, state: String?) -> ()){
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: (geoPoint?.latitude)!, longitude: (geoPoint?.longitude)!), completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        print("Reverse geocoder failed with error")
                        return
                    }
                    
                    if placemarks!.count > 0 {
                        var city = String()
                        var state = String()
                        let placemark = placemarks![0]
                        if placemark.administrativeArea != nil {state = placemark.administrativeArea!}
                        if placemark.locality != nil {city = placemark.locality!}
                        completion(city: city, state: state)
                    }
                })
            }
        }
    }
    
}


