//
//  ChatGroupViewController.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-22.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatGroupViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    typealias ChatId = String
    @IBOutlet weak var table : UITableView!
    @IBOutlet var searchBar  : UISearchBar!
    
    let reuseCellIdentifier : String = "ChatCell"
    
    //database
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    var displayID: String = ""
    
    var chatArray        = [ChatLink]() // Full list
    var currentChatArray = [ChatLink]() // Update Table
    
    var senderId    : String = ""
    var displayName : String = ""
    
    var userID: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupChats()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        setupChats        ()
        setupSearchBar    ()
        alterLayout       ()
    }
    
    private func resetCurrentChatArray() {
        self.currentChatArray = self.chatArray
    }
    
    private func setupChats () {
        ref = Database.database().reference ()
        self.userID = (Auth.auth ().currentUser?.uid)!
        
        let chatsRef    = self.ref.child (FirebaseDatabaseRefs.users).child (userID);
        
        chatsRef.observeSingleEvent (of: .value, with :
            {
                (snapshot) in
                    let key   = snapshot.key
                    let value = snapshot.value as! NSDictionary
                
                    self.senderId    = value["senderId"] as! String
                    self.displayName = value["name"]     as! String
                
                    guard let chats:NSDictionary = value["chats"] as? NSDictionary else {
                        return
                    }
                    self.chatArray.removeAll();
                    for chat in chats {
                        let chatObj = chat.value as! NSDictionary
                        
                        if let deleted: Bool = chatObj["deleted"] as? Bool {
                            if deleted {
                                continue
                            }
                        }
                        
                        let id:       String   = chat.key as! String
                        
                        let userid:   String   = chatObj["userid"] as! String
                        let username: String   = chatObj["username"] as! String
                        let image_url: String = ""
                        
                        let firstID: String = chatObj["firstID"] as! String
                        let secondID: String = chatObj["secondID"] as! String
                        
                        if (self.userID == firstID){
                            self.displayID = secondID;
                        }else {
                            self.displayID = firstID
                        }
                        
                        let chatLk: ChatLink = ChatLink (chatId: id, userId: userid, username: username, image_url : image_url, displayID: self.displayID)
                        
                        self.chatArray.append (chatLk)
                    }
                
                    print (self.chatArray)
                
                    self.resetCurrentChatArray()
                    self.table.reloadData ()
            }
        )
    }
    
    private func setupSearchBar () {
        searchBar.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentChatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell (withIdentifier: reuseCellIdentifier) as? ChatCell else {
            return UITableViewCell ()
        }
        
        let ct: ChatLink = currentChatArray [indexPath.row];
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        
        cell.nameLabel.text = ct.username // ct.chatId
        
        let usersStorageRef = self.storage.child("users").child(ct.displayID);
        let profile = usersStorageRef.child("profilePic")
        cell.imgView.image = #imageLiteral(resourceName: "profilePic")
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.imgView.layer.cornerRadius  = cell.imgView.frame.height / 2
        
        profile.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                cell.imgView.image  = UIImage(data:data!)
                cell.imgView.setRounded()

                cell.imgView.layer.borderWidth = 1
                cell.imgView.layer.masksToBounds = false
                cell.imgView.layer.borderColor = UIColor.black.cgColor
                cell.imgView.layer.cornerRadius = cell.imgView.frame.height/2 //This will change with corners of image and height/2 will make this circle shape
                cell.imgView.clipsToBounds = true
                
            }else{
                print(error?.localizedDescription ?? "")
                cell.imgView.image = #imageLiteral(resourceName: "profilePic")
            }
        }
        
        return cell
    }
    
    private func getImageFromUrl (image_url: String) -> UIImage {
        let url  = URL (string: image_url)
        let data = try? Data (contentsOf: url!)
        
        if let imageData = data {
            return UIImage (data: imageData)!
        }
        
        return #imageLiteral(resourceName: "star")
        
    }
    
    func tableView (_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView (_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    // Search Bar in section header
    func tableView (_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cl: ChatLink = self.chatTypeAtIndexPath(indexPath: indexPath as NSIndexPath)
            if userID.isEmpty {
                return
            }
            
            self.ref.child (FirebaseDatabaseRefs.users).child (self.userID).child(FirebaseDatabaseRefs.chats).child(cl.chatId).updateChildValues(
                [
                    "deleted" : true
                ],
                withCompletionBlock: {
                    (err,ref) in
                        if err != nil {
                            print(err as Any)
                            return
                        }
                        // remove data from array and update table
                        self.chatArray.remove(at: indexPath.row)
                        self.resetCurrentChatArray()
                        self.table.reloadData()
                }
            )
            
        }
    }
    
    // Search Bar
    func searchBar (_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            self.resetCurrentChatArray()
            self.table.reloadData ()
            return
        }
        
        currentChatArray = chatArray.filter (
            {
                (chatItem) -> Bool in
                chatItem.username.lowercased ().contains (searchText.lowercased ())
            }
        )
        
        table.reloadData ()
    }
    
    func searchBarTextDidEndEditing (_ searchBar: UISearchBar) {
        self.searchBar.endEditing (true)
    }
    
    func searchBarSearchButtonClicked (_ searchBar: UISearchBar) {
        self.searchBar.endEditing (true)
    }
    
    func searchBarCancelButtonClicked (_ searchBar: UISearchBar) {
        self.searchBar.endEditing (true)
    }
    
    @objc func back() {
        self.dismiss (animated: true, completion: nil)
    }
    
    func alterLayout () {
        
        // Search Bar in section header
        searchBar.placeholder = "Search Chats"
        searchBar.sizeToFit ()
        
        table.estimatedSectionHeaderHeight = 50
        table.tableHeaderView              = UIView ()
        searchBar.showsScopeBar          = false
    }
    
    // Mark: - Navigation
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Chat" :
                let messagesVC   = segue.destination as! MessagesViewController
                
                if let indexPath = self.table.indexPath (for: sender as! ChatCell) {
                    
                    let chatObj = chatTypeAtIndexPath (indexPath: indexPath as NSIndexPath)
                    
                    messagesVC.chatId = chatObj.chatId
                    messagesVC.currentUser      = UserObj (id : self.senderId, name : self.displayName)
                    messagesVC.conversationUser = UserObj (id: chatObj.userId, name : chatObj.username)
                    
                }
            default :
                break
            }
        }
        
    }
    
    // Mark: - Helper Method
    private func chatTypeAtIndexPath (indexPath: NSIndexPath) -> ChatLink {
        return currentChatArray [indexPath.row]
    }
    
}
