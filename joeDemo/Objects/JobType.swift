//
//  Category.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-19.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation

class JobType {
    let id        : String
    let name      : String
    let image_url : String
    
    init (id : String, name : String, image_url : String) {
        self.id        = id
        self.name      = name
        self.image_url = image_url
    }
}
