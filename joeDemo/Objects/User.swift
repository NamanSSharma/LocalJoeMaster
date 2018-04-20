//
//  User.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-19.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation

class User {
    let id:         String
    let checkedOut: String
    let email:      String
    let joeType:    String
    let name:       String
    let numPhotos:  Int
    
    init (id:String, checkedOut:String, email:String, joeType:String, name:String, numPhotos:Int) {
        self.id         = id
        self.checkedOut = checkedOut
        self.email      = email
        self.joeType    = joeType
        self.name       = name
        self.numPhotos  = numPhotos
    }
}
