//
//  Cell.swift
//  ParseStarterProject
//
//  Created by Daniel Schartner on 7/21/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

//A class for individual image posts
class Cell: UITableViewCell {
    
    @IBOutlet weak var feedImage: UIImageView!
    
    @IBOutlet weak var postUser: UILabel!

    @IBOutlet weak var postDesc: UILabel!
}
