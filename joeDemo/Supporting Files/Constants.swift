//
//  Constants.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2017-11-26.
//  Copyright © 2017 User. All rights reserved.
//

import Firebase

struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}
