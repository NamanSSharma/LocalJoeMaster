//
//  Chat.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-22.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class Chat {
    let chatId   : String
    var messages = [JSQMessage]()
    
    init (chatId : String, messages : [JSQMessage]) {
        self.chatId   = chatId
        self.messages = messages
    }
    
}
