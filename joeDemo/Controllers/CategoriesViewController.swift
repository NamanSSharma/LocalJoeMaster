//
//  CategoriesController.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-15.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import UIKit

import FirebaseDatabase
import FirebaseStorage

class CategoriesViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var table : UITableView!
    @IBOutlet var searchBar  : UISearchBar!
    
    let reuseCellIdentifier : String = "JobTypeCell"
    
    var ref: DatabaseReference!
    
    var jobTypeArray        = [JobType]() // Full list
    var currentJobTypeArray = [JobType]() // Update Table
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        setupJobTypes  ()
        setupSearchBar ()
        alterLayout    ()
    }
    
    private func setupJobTypes () {
        
        ref = Database.database().reference ()
        let jobTypesRef = ref.child (FirebaseDatabaseRefs.jobTypes)
        
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        jobTypesRef.observeSingleEvent (of: .value, with :
            {
                (snapshot) in
                for child in snapshot.children {
                    let snap  = child as! DataSnapshot
                    let key   = snap.key
                    let value = snap.value as? NSDictionary
                    
                    if let name = value?["name"] as? String,
                       let image_url = value?["image_url"] as? String {
                        self.jobTypeArray.append (JobType (id: key, name : name, image_url : image_url))
                    }
                }
                
                self.jobTypeArray.sort(by:
                    {
                        (lhs, rhs) -> Bool in
                            return lhs.name < rhs.name
                    }
                )
                self.currentJobTypeArray = self.jobTypeArray
                self.table.reloadData ()
            }
        )
        dismiss(animated: false, completion: nil)
    }
    
    private func setupSearchBar () {
        searchBar.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentJobTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell (withIdentifier: reuseCellIdentifier) as? JobTypeCell else {
            return UITableViewCell ()
        }
        
        let jt: JobType = currentJobTypeArray [indexPath.row];
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        
        cell.nameLabel.text = jt.name
        
        cell.imgView.image  = getImageFromUrl (image_url: jt.image_url)
        cell.imgView.layer.cornerRadius = cell.imgView.frame.height / 2
        
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
    
    // Search Bar
    func searchBar (_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            currentJobTypeArray = jobTypeArray
            table.reloadData ()
            return
        }
        
        currentJobTypeArray = jobTypeArray.filter (
            {
                (jobType) -> Bool in
                jobType.name.lowercased ().contains (searchText.lowercased ())
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
        searchBar.placeholder = "Search Categories"
        searchBar.sizeToFit ()
        
        table.estimatedSectionHeaderHeight = 50
        table.tableHeaderView              = UIView ()
        
        searchBar.showsScopeBar          = false
    }
    
    // Mark: - Navigation
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
    
        if let identifier = segue.identifier {
            switch identifier {
                case "Show Users" :
                    let usersVC   = segue.destination as! UsersViewController
                    if let indexPath = self.table.indexPath (for: sender as! JobTypeCell) {
                        usersVC.jobTypeId = jobTypeAtIndexPath (indexPath: indexPath as NSIndexPath).id
                    }
                default :
                    break
            }
        }
        
    }
    
    // Mark: - Helper Method
    private func jobTypeAtIndexPath (indexPath: NSIndexPath) -> JobType {
        return currentJobTypeArray [indexPath.row]
    }
    
    
}
