//
//  ChoiceViewController.swift
//  ChoiScene
//
//  Created by joseph mckee on 8/10/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//

import UIKit

class ChoiceViewController: UIViewController {

    @IBOutlet var eatButton: UIButton!
    @IBOutlet var drinkButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    var eatBool: Bool!
    var drinkBool: Bool!
    var playBool: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func eatTouch(sender: AnyObject) {
        eatBool = true
        print("EAT button was selected")
    }

    @IBAction func drinkTouch(sender: AnyObject) {
        drinkBool = true
        print("DRINK button was selected")
    }
    
    
    @IBAction func playTouch(sender: AnyObject) {
        playBool = true
        print("PLAY button was selected")
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
