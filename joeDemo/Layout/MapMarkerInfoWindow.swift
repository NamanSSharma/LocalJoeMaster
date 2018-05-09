//
//  mapMarkerInfoWindow.swift
//  joeDemo
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import Firebase

class MapMarkerInfoWindow: UIView {
    
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var messages: UIButton!
    
    
    @IBAction func messagesAction(_ sender: Any) {
        //upload a new chat thread to database (userId + SecondUserId)
        
        ref = Database.database().reference()
        
        let userID : String = (Auth.auth().currentUser?.uid)!
        let chatsRef = self.ref.child("chats");
        let usersRef = self.ref.child("users").child (userID);
        
        usersRef.observeSingleEvent (of: .value, with:
            {
                (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                // Get user's name
                let joeID  = value?["checkedOut"] as? String ?? ""
                let joeRef = self.ref.child ("users").child (joeID);
                let myName = value?["name"] as? String ?? ""
                let myId   = value?["senderId"] as? String ?? ""
                
                joeRef.observeSingleEvent(of: .value, with:
                    {
                        (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            // Get user's name
                            let joeName       = value?["name"]     as? String ?? ""
                            let joeProfession = value?["joeType"]  as? String ?? ""
                            let joeId         = value?["senderId"] as? String ?? ""
                        
                            let chatId        = myId > joeId ? "\(myId)_\(joeId)" : "\(joeId)_\(myId)" // UUID().uuidString;
                        
                            if myId == joeId {
                                return
                            }
                        
                            let userChatValues = [
                                "userid"   : joeId,
                                "username" : joeName
                            ]
                        
                            let joeChatValues = [
                                "userid"   : myId,
                                "username" : myName
                            ]
                        
                            let chatValues = [
                                "chatid" : chatId,
                                "userid" : myId,
                                "joeid"  : joeId,
                            ]
                        
                            /*
     
                             "joe": "\(joeName) the \(joeProfession)",
                             "messageID": "\(userID)with\(joeID)",
                             "joeID": "\(joeID)",
                             "client": "\(myName)"*/
                        
                            usersRef.child ("chats").child (chatId).updateChildValues (userChatValues, withCompletionBlock: {
                                (err,ref) in
                                    if err != nil {
                                        print(err as Any)
                                        return
                                    }
                                }
                            )
                        
                            joeRef.child ("chats").child (chatId).updateChildValues (joeChatValues, withCompletionBlock: {
                                (err,ref) in
                                    if err != nil {
                                        print (err as Any)
                                        return
                                    }
                                }
                            )
                        
                            chatsRef.child (chatId).updateChildValues (chatValues, withCompletionBlock: {
                                (err,ref) in
                                    if err != nil {
                                        print(err as Any)
                                        return
                                    }
                                }
                            )
                        
                        // Add dismiss button to controller
                        let storyboard : UIStoryboard = UIStoryboard.init (name: "Main", bundle: nil)
                        
                            var messagesVC : MessagesViewController = storyboard.instantiateViewController (withIdentifier: "ChatView") as! MessagesViewController
                        
                            messagesVC.chatId           = chatId
                            messagesVC.currentUser      = UserObj (id : myId,  name : myName)
                            messagesVC.conversationUser = UserObj (id : joeId, name : joeName)
                            messagesVC.newChat          = true
                        
                            // let vc = UIStoryboard.init (name: "Main", bundle: nil).instantiateViewController (withIdentifier: "ChatView") as! UINavigationController
                        
                            UIApplication.topViewController()?.present (messagesVC, animated: true, completion: nil)
                
                    }
                ) {
                    (error) in
                        print(error.localizedDescription)
                }
         
            }
        )
    }
    
    @IBOutlet weak var profile: UIButton!
    @IBAction func profileAction(_ sender: Any) {
        print("profile")
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ViewJoeProfileController") as! ViewJoeProfileController
        UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
        
        
        /*   let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         
         let homeC = storyboard.instantiateViewController(withIdentifier: "ViewJoeProfileController") as? ViewJoeProfileController
         
         if homeC != nil {
         homeC!.view.frame = (self.window!.frame)
         self.window!.addSubview(homeC!.view)
         self.window!.bringSubview(toFront: homeC!.view)
         } */
        
        /*let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let homeC = storyboard.performSegue(withIdentifier: "messageSegue", sender: se)
         if homeC != nil {
         homeC!.view.frame = (self.window!.frame)
         self.window!.addSubview(homeC!.view)
         self.window!.bringSubview(toFront: homeC!.view)
         } */
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerInfoWindow", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}

extension UIApplication {
    
    static func topViewController() -> UIViewController? {
        guard var top = shared.keyWindow?.rootViewController else {
            return nil
        }
        while let next = top.presentedViewController {
            top = next
        }
        return top
    }
}

