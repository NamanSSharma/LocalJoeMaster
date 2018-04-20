//
//  Category.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-19.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation

class Category {
    
}

class Animal {
    let name: String
    let image: String
    let category: AnimalType
    
    init(name: String, category: AnimalType, image: String) {
        self.name     = name
        self.category = category
        self.image    = image
    }
}

enum AnimalType: String {
    case cat = "Cat"
    case dog = "Dog"
}
