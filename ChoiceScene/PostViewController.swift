//
//  PostViewController.swift
//  ChoiScene
//
//  Created by Cameron Eubank on 8/13/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet var postImage: UIImageView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        postImage.image = image
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
