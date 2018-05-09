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

struct FirebaseJSQMessage {
    let id   : String
    let date : String
    let msg  : JSQMessage
}

class MessagesViewController : JSQMessagesViewController {
    
    // let user1 = UserObj (id: "1", name: "Yudhvir Raj")
    // let user2 = UserObj (id: "2", name: "Naman Sharma")
    
    var chatId : String = ""
    
    var ref : DatabaseReference!
    
    /* var currentUser : UserObj {
        return user1
    } */
    
    var currentUser      : UserObj = UserObj (id : "", name : "")
    var conversationUser : UserObj = UserObj (id : "", name : "")
    
    var newChat : Bool = false
    
    // All the messages of user1, user2
    var messages = [FirebaseJSQMessage]()
    
}

extension MessagesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        
        self.edgesForExtendedLayout = []
        
        ref = Database.database().reference ()
        
        self.senderId          = currentUser.id
        self.senderDisplayName = currentUser.name
        
        let chatRef = ref.child (FirebaseDatabaseRefs.chats).child (chatId).child ("messages")
        
        print ("CHATS REF")
        
        chatRef.observe (.value) {
            (snapshot) in
            
                self.messages = []
            
                let key   = snapshot.key
            
                guard let value = snapshot.value as? NSDictionary else {
                    return
                }
            
                // Use external call to get date perhaps, such as server
                for (key, msg) in value {
                    // print ("\(key) --> \(msg)")
                    
                    guard let msgValues = msg as? [String:String] else {
                        break
                    }
                    
                    let message:JSQMessage = JSQMessage (senderId: msgValues["senderId"], displayName: msgValues["displayName"], text: msgValues["text"])
                    
                    self.messages.append (FirebaseJSQMessage (id: key as! String, date: msgValues["date"]!, msg: message))
                }
            
                self.messages.sort (by:
                    {
                        (lhs, rhs) -> Bool in
                            return lhs.date < rhs.date
                    }
                )
            
                self.collectionView.reloadData ()
            
                print (self.messages)
            
            // for child in
        
        }
        
        /* messages.append (
            JSQMessage (senderId: "2", displayName: "Naman Sharma", text: "Yudhvir you're so cool")
        ) */
    }
}

extension MessagesViewController {
    // newChat button to go back
    private func goBack () {
        // Last view controller
        _ = navigationController?.popViewController (animated: true)
        
        // Root view controller
        // _ = navigationController?.popToRootViewController (animated: true)
    }
}

extension MessagesViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let messageId = UUID().uuidString
        let message   = JSQMessage (senderId: senderId, displayName: senderDisplayName, text: text)
        
        let fbMessage = FirebaseJSQMessage (id: messageId, date: String (date.timeIntervalSince1970), msg: message!)
        
        self.messages.append (fbMessage)
        
        print ("ID \(currentUser.id)")
        print ("SID \(senderId)")
        
        let chatRef = ref.child (FirebaseDatabaseRefs.chats).child (self.chatId).child ("messages")
        let messageValues =
            [
                "senderId"    : senderId,
                "displayName" : senderDisplayName,
                "text"        : text,
                "date"        : String (date.timeIntervalSince1970)
            ]
        
        chatRef.child (messageId).updateChildValues (messageValues)
        
        finishSendingMessage ()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message         = messages[indexPath.row]
        let messageUsername =  message.msg.senderDisplayName
        
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
        
        print (currentUser.id + " " + message.msg.senderId)
        
        if currentUser.id == message.msg.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage (with: .green)
        }
        
        return bubbleFactory?.incomingMessagesBubbleImage (with: .blue)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages [indexPath.row].msg
    }
}
