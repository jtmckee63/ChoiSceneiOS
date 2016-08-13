//
//  SceneViewController.swift
//  ChoiScene
//
//  Created by Cameron Eubank on 8/13/16.
//  Copyright © 2016 ChoiScene. All rights reserved.
//

import UIKit
import MapKit
import Parse
import CoreLocation

class SceneViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var eatButtonOutlet: UIButton!
    @IBOutlet var drinkButtonOutlet: UIButton!
    @IBOutlet var playButtonOutlet: UIButton!
    
    @IBAction func eatButtonAction(sender: AnyObject) {
        
    }
    
    @IBAction func drinkButtonAction(sender: AnyObject) {
        
    }
    
    @IBAction func playButtonAction(sender: AnyObject) {
        
    }
    @IBAction func toggleTableView(sender: AnyObject) {
        if tableView.alpha > 0.0{
            Animations().fadeOut(tableView, time: 0.2)
        }else{
            Animations().fadeIn(tableView, time: 0.2)
        }
    }
    
    var locationManager = CLLocationManager()
    var menuView: BTNavigationDropdownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scene"
        
        let items = ["Eat", "Drink", "Play", "All"]
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: "MyScene", items: items)
        menuView.cellHeight = 50
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
        menuView.shouldKeepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Light", size: 18)
        menuView.cellTextLabelAlignment = .Center
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.blackColor()
        menuView.maskBackgroundOpacity = 0.3
        self.navigationItem.titleView = menuView
        
        
        
        //Register Nib for TableViewCell
        tableView.registerNib(UINib(nibName: "SceneTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //Table View
        tableView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.8)
        tableView.delegate = self
        tableView.dataSource = self
        
        //MapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //Permission for Location when In Use Authorization.
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        getUserLocationString(){
            (city, state) in self.loadData(self.createAndTrimClassName(city!, state: state!), category: 0)
        }
    }
    
    func loadData(className: String, category: Int){
        print(className, category)
    }
    
    //MARK: UI Methods
    func changeSceneChoice() -> Int{
        var index = Int()
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            index = indexPath
        }
        return index
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
        cell.postPlaceTitleLabel.text = "Kung fu Saloon"
        cell.postImage.image = UIImage(named: "kungfu.jpeg")
        cell.postAuthorImage.image = UIImage(named: "me.jpeg")
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
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

}
