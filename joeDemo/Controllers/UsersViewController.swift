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

class UsersViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var table : UITableView!
    @IBOutlet var searchBar  : UISearchBar!
    
    let reuseCellIdentifier:String = "UserCell"
    
    var jobTypeId = ""
    
    var ref: DatabaseReference!
    
    var usersArray        = [User]() // Full list
    var currentUsersArray = [User]() // Update Table
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        setupUsers     ()
        setupSearchBar ()
        alterLayout    ()
    }
    
    private func setupUsers () {
        
        ref = Database.database().reference ()
        let usersRef = ref.child (FirebaseDatabaseRefs.users)
        
        usersRef.observeSingleEvent (of: .value, with :
            {
                (snapshot) in
                for child in snapshot.children {
                    let snap  = child as! DataSnapshot
                    let key   = snap.key
                    let value = snap.value as? NSDictionary
                    
                    if let joeType    = value?["joeType"] as? String,
                       let checkedOut = value?["checkedOut"] as? String,
                       let email      = value?["email"] as? String,
                       let name       = value?["name"] as? String,
                       let numPhotos  = value?["numPhotos"] as? String {
                        
                        // numPhotos should be changed to int in database
                        if (joeType == self.jobTypeId) {
                            self.usersArray.append (User (id: key, checkedOut: checkedOut, email: email, joeType: joeType, name: name, numPhotos: Int (numPhotos)!))
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
        
        cell.imgView.image  = #imageLiteral(resourceName: "profile")
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.imgView.layer.cornerRadius  = cell.imgView.frame.height / 2
        
        return cell
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
    
    
}
