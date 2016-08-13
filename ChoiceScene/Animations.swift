//
//  Animations.swift
//  ChoiScene
//
//  Created by Cameron Eubank on 8/13/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//

import Foundation
import UIKit

class Animations{
    
    
    func fadeOut(view: UIView, time: Double){
        UIView.animateWithDuration(time, animations: {
            view.alpha = 0.0
        })
    }
    
    func fadeIn(view: UIView, time: Double){
        UIView.animateWithDuration(time, animations: {
            view.alpha = 1.0
        })
    }
    
}