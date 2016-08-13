//
//  SceneViewController.swift
//  ChoiScene
//
//  Created by Cameron Eubank on 8/13/16.
//  Copyright © 2016 ChoiScene. All rights reserved.
//

import UIKit

class SceneViewController: UIViewController {
    
    var sceneID = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scene - \(sceneID)"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
