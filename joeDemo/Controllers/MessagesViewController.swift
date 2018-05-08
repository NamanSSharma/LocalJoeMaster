//
//  MessagesViewController.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-21.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import JSQMessagesViewController

import FirebaseDatabase
import FirebaseStorage

struct UserObj {
    let id   : String
    let name : String
}

class MessagesViewController : JSQMessagesViewController {
    
    // let user1 = UserObj (id: "1", name: "Yudhvir Raj")
    // let user2 = UserObj (id: "2", name: "Naman Sharma")
    
    var chatId : String = ""
    
    var ref : DatabaseReference!
    
    /* var currentUser : UserObj {
        return user1
    } */
    
    var currentUser      : UserObj = UserObj (id : "1", name : "")
    var conversationUser : UserObj = UserObj (id : "", name : "")
    
    // All the messages of user1, user2
    var messages = [JSQMessage]()
    
}

extension MessagesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        
        
        ref = Database.database().reference ()
        
        chatId = "6KBziET3C3hzL3t4WI0VqCy6lQW2witho27gTVcU0WOecTMvTPCKBMi4xFe2"
        
        self.senderId          = currentUser.id
        self.senderDisplayName = currentUser.name
        
        let chatRef = ref.child (FirebaseDatabaseRefs.chats).child (chatId).child ("messages")
        
        print ("CHATS REF")
        
        chatRef.observe (.childAdded) {
            (snapshot) in
            
            let key   = snapshot.key
            let value = snapshot.value
            
            // let messages = value
            
            print (key)
            print (value)
            
            // for child in
        
        }
        
        var messages = [JSQMessage]()
        
        /* messages.append (
            JSQMessage (senderId: "2", displayName: "Naman Sharma", text: "Yudhvir you're so cool")
        )
        
        messages.append (
            JSQMessage (senderId: "1", displayName: "Yudhvir Raj", text: "Damm it feels good to be a gangsta")
        ) */
        
        // tell JSQMessagesViewController
        // who is the current user
        
        
        // self.messages = getMessages ()
    }
}

extension MessagesViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage (senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages.append (message!)
        
        finishSendingMessage ()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message         = messages[indexPath.row]
        let messageUsername =  message.senderDisplayName
        
        return NSAttributedString (string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory =  JSQMessagesBubbleImageFactory ()
        
        let message       = messages[indexPath.row]
        
        print (currentUser.id + " " + message.senderId)
        
        if currentUser.id == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage (with: .green)
        }
        
        return bubbleFactory?.incomingMessagesBubbleImage (with: .blue)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages [indexPath.row]
    }
}

extension MessagesViewController {
    
    func getMessages () -> [JSQMessage] {
        // chatId
        
        var messages = [JSQMessage]()
        
        messages.append (
            JSQMessage (senderId: "2", displayName: "Naman Sharma", text: "Yudhvir you're so cool")
        )
        
        messages.append (
            JSQMessage (senderId: "1", displayName: "Yudhvir Raj", text: "Damm it feels good to be a gangsta")
        )
        
        return messages
    }
    
}
