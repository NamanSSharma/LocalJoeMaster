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
    let image_url: String
    let displayID: String
    
    init (chatId : String, userId : String, username : String, image_url : String, displayID : String) {
        self.chatId   = chatId
        self.userId   = userId
        self.username = username
        self.image_url = image_url
        self.displayID = displayID
    }
    
}
