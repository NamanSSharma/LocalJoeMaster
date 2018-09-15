//
//  ChatLink.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-05-07.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation

class ChatLink {
 
    let chatId   : String
    let userId   : String
    let username : String
    
    init (chatId : String, userId : String, username : String) {
        self.chatId   = chatId
        self.userId   = userId
        self.username = username
    }
    
}
