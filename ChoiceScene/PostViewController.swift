//
//  PostViewController.swift
//  ChoiScene
//
//  Created by Cameron Eubank on 8/13/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class PostViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var postImage: UIImageView!
    
    var image = UIImage()
    var locationManager = CLLocationManager()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"

        //Set ImageView Image from Segue
        postImage.image = image
        
        //Permission for Location when In Use Authorization.
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    @IBOutlet var postButtonOutlet: UIButton!
    
    
    @IBAction func postButtonAction(sender: AnyObject) {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: (geoPoint?.latitude)!, longitude: (geoPoint?.longitude)!), completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        print("Reverse geocoder failed with error")
                        return
                    }
                    
                    if placemarks!.count > 0 {
                        
                        let postGeoPoint = PFGeoPoint()
                        postGeoPoint.latitude = geoPoint!.latitude
                        postGeoPoint.longitude = geoPoint!.longitude
                        
                        var category = String()
                        var state = String()
                        var city = String()
                        var subAddress = String()
                        var address = String()


                        let placemark = placemarks![0]
                        if placemark.locality != nil {city = placemark.locality!}
                        if placemark.administrativeArea != nil {state = placemark.administrativeArea!}
                        if placemark.thoroughfare != nil {address = placemark.thoroughfare!}
                        if placemark.subThoroughfare != nil {subAddress = placemark.subThoroughfare!}
              
//                            let userName = self.userDefaults.valueForKey("user_name") as! String
//                            let userImage = self.userDefaults.valueForKey("user_image") as! UIImage
                        
                        let post = Post()
                        post.category = "Eat"
                        post.state = state
                        post.city = city
                        post.subAddress = subAddress
                        post.address = address
                        post.postImageData = UIImageJPEGRepresentation(self.image, 0.0)!
                        post.authorImageData = UIImageJPEGRepresentation(UIImage(named: "me.jpg")!, 0.0)!
                        post.authorName = "Cam"
                        
                        self.saveSpot(self.createAndTrimClassName(city, state: state), object: post)
                    }
                })
            }
        }
    }
    
    //MARK: Parse Save Method
    func saveSpot(className: String, object: Post){
        let spotObject = PFObject(className: className)
        spotObject["GeoPoint"] = object.geoPoint as PFGeoPoint
        spotObject["State"] = object.state as String
        spotObject["City"] = object.city as String
        spotObject["Address"] = object.address as String
        spotObject["SubAddress"] = object.subAddress as String
        spotObject["PostImageData"] = object.postImageData as NSData
        spotObject["AuthorImageData"] = object.authorImageData as NSData
        spotObject["AuthorName"] = object.authorName as String
        spotObject["Category"] = object.category as String
        
        spotObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            if (success == true){
                print("Saved a spot to parse!")
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SceneViewController") as! SceneViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }else{
                print(error?.localizedDescription)
            }
        }
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
                
    
    //MARK: CLLocationManagerDelegate Mthods
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if (status == CLAuthorizationStatus.Denied) {
            showAlertWithURL("Whoops!", message: "Location services must be enabled to use this app. Enable location services for this app in your device Settings.", urlMessage: "Open Settings", URL: UIApplicationOpenSettingsURLString)
        }
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


}
