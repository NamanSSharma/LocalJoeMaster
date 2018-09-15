//
//  Message.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-21.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation

class Message {
    let senderId : String
    let text     : String
    
    init (senderId : String, text : String) {
        self.senderId = senderId
        self.text     = text
    }
}
