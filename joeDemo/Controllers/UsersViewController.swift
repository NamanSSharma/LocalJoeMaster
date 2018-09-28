//
//  UsersController.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-19.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import UIKit

import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UsersViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var table : UITableView!
    @IBOutlet var searchBar  : UISearchBar!
    
    let userID : String = (Auth.auth().currentUser?.uid)!
    let reuseCellIdentifier:String = "UserCell"
    
    var jobTypeId = ""
    
    //database
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    
    var usersArray        = [User]() // Full list
    var currentUsersArray = [User]() // Update Table
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        setupUsers     ()
        setupSearchBar ()
        alterLayout    ()
    }
    
    private func setupUsers () {
        print("setup users")
        ref = Database.database().reference ()
        let usersRef = ref.child (FirebaseDatabaseRefs.users)
        
        usersRef.observeSingleEvent (of: .value, with :
            {
                (snapshot) in
                for child in snapshot.children {
                    let snap  = child as! DataSnapshot
                    let key   = snap.key
                    let value = snap.value as? NSDictionary
                    print(key)
                    print(value)
                    if let joeType    = value?["joeType"]    as? String,
                       let joeStatus = value?["status"]   as? String,
                       let email      = value?["email"]      as? String,
                       let name       = value?["name"]       as? String,
                       let numPhotos  = value?["numPhotos"]  as? String {
                        
                        print (joeType + " " + self.jobTypeId)
                        
                        // numPhotos should be changed to int in database
                        if (joeType == self.jobTypeId && joeStatus == "approved") {
                            self.usersArray.append (User (id: key, email: email, joeType: joeType, name: name, numPhotos: Int (numPhotos)!))
                        }
                        
                    }
                    
                }
                
                self.currentUsersArray = self.usersArray
                self.table.reloadData ()
            }
        )
    }
    
    private func setupSearchBar () {
        searchBar.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer (target: self, action: #selector (self.dismissKeyboard))
        
        // Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        // tap.cancelsTouchesInView = false
        searchBar.addGestureRecognizer (tap)
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
    
    @objc func dismissKeyboard () {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        searchBar.endEditing (true)
        searchBar.resignFirstResponder ()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell (withIdentifier: reuseCellIdentifier) as? UserCell else {
            return UITableViewCell ()
        }
        
        let user: User = currentUsersArray [indexPath.row];
        cell.nameLabel.text = user.name
        
        let usersStorageRef = self.storage.child("users").child(user.id);
        let profile = usersStorageRef.child("profilePic")
        cell.imgView.image = #imageLiteral(resourceName: "profilePic")

        profile.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                cell.imgView.image  = UIImage(data:data!)
                cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
                cell.imgView.layer.cornerRadius  = cell.imgView.frame.height / 2
            }else{
                print(error?.localizedDescription ?? "")
                cell.imgView.image = #imageLiteral(resourceName: "profilePic")
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userAtIndexPath(indexPath: indexPath as NSIndexPath)
        let alert = UIAlertController(title: "Send a message", message: "Enter message", preferredStyle: .alert)
        alert.addTextField {
            (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Send Message", style: .default, handler:
            {
                [weak alert] (_) in
                let text = alert!.textFields![0].text // Force unwrapping because we know it exists.
                let joeID = user.id
                
                let messageId = UUID().uuidString
                let chatsRef = self.ref.child("chats");
                let usersRef = self.ref.child("users").child (self.userID);
                usersRef.observeSingleEvent (of: .value, with:
                    {
                        (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        
                        // Get user's name
                        // Get joeID from marker
                        let joeRef = self.ref.child (FirebaseDatabaseRefs.users).child (joeID);
                        let myName = value?["name"] as? String ?? ""
                        let myId   = value?["senderId"] as? String ?? ""
                        
                        joeRef.observeSingleEvent(of: .value, with:
                            {
                                (snapshot) in
                                let value = snapshot.value as? NSDictionary
                                // Get user's name
                                let joeName       = value?["name"]     as? String ?? ""
                                let joeId         = value?["senderId"] as? String ?? ""
                                
                                let chatId        = myId > joeId ? "\(myId)_\(joeId)" : "\(joeId)_\(myId)" // UUID().uuidString;
                                
                                if myId == joeId {
                                    return
                                }
                                
                                let userChatValues = [
                                    "userid"   : joeId,
                                    "username" : joeName,
                                    "firstID" : self.userID,
                                    "secondID" : joeID
                                ]
                                
                                let joeChatValues = [
                                    "userid"   : myId,
                                    "username" : myName,
                                    "firstID" : self.userID,
                                    "secondID" : joeID
                                ]
                                
                                let chatValues = [
                                    "chatid" : chatId,
                                    "userid" : myId,
                                    "joeid"  : joeId,
                                    "firstID" : self.userID,
                                    "secondID" : joeID
                                    ]
                                
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
                                
                                let chatRef = self.ref.child (FirebaseDatabaseRefs.chats).child (chatId).child ("messages")
                                let messageValues =
                                    [
                                        "senderId"    : myId,
                                        "displayName" : myName,
                                        "text"        : text,
                                        "date"        : String (Date().timeIntervalSince1970)
                                ]
                                chatRef.child (messageId).updateChildValues (messageValues)
                        }
                        ) {
                            (error) in
                            print(error.localizedDescription)
                        }
                        
                }
                )
            }
            )
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
            print("cancelled")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    // Search Bar in section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            currentUsersArray = usersArray
            table.reloadData ()
            return
        }
        
        currentUsersArray = usersArray.filter (
            {
                (jobType) -> Bool in
                jobType.name.lowercased ().contains (searchText.lowercased ())
            }
        )
        
        table.reloadData ()
    }
    
    func alterLayout () {
        table.tableHeaderView              = UIView ()
        // Search Bar in section header
        table.estimatedSectionHeaderHeight = 50
        
        // Search Bar in navigation bar
        // navigationItem.leftBarButtonItem = UIBarButtonItem (customView: searchBar)
        searchBar.showsScopeBar          = false
        searchBar.placeholder            = "Search Users"
    }
    
    private func userAtIndexPath (indexPath: NSIndexPath) -> User {
        return currentUsersArray [indexPath.row]
    }
    
}
