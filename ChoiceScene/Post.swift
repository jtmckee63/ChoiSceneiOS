//
//  Post.swift
//  ChoiScene
//
//  Created by Cameron Eubank on 8/13/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//

import Foundation
import Parse

class Post{
    var geoPoint = PFGeoPoint()
    var category = String()
    var state = String()
    var city = String()
    var address = String()
    var subAddress = String()
    var postImageData = NSData()
    var authorImageData = NSData()
    var authorName = String()
}