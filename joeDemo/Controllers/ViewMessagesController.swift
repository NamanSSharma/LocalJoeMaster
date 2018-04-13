//
//  ViewMessagesController.swift
//  joeDemo
//
//  Created by User on 1/20/18.
//  Copyright © 2018 User. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewMessagesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var myList:[String] = []
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var messageList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))

        
        messageList.delegate = self
        messageList.dataSource = self
        ref = Database.database().reference()
       
        handle = ref.child("users").child(userID).child("chats").observe(.childAdded, with: {(snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let joe = value["joe"] as? String ?? ""
                let client = value["client"] as? String ?? ""
                let messageID = value["messageID"] as? String ?? ""
                let joeID = value["joeID"] as? String ?? ""
                print(joe)
                
                if (self.userID == joeID) {
                    print("its the same shit")
                    self.myList.append(client + "                                                                     messageID:" + messageID)

                }else{
                    self.myList.append(joe + "                                                                        messageID:" + messageID)

                }
                DispatchQueue.main.async(){
                    self.messageList.reloadData()
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text=myList[indexPath.row]
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usersRef = ref.child("users").child(userID);

        switch indexPath.section {
        case 0..<100:
            //self.performSegue(withIdentifier: "openMessage", sender: self)
            let cell = tableView.cellForRow(at: indexPath)
            print(cell?.textLabel?.text ?? "Could not get value")
            let delimiter = "messageID:"
            let cellText = cell?.textLabel?.text
            let openMessagewithID = cellText?.components(separatedBy: delimiter).last
            print(openMessagewithID!)
            let values2 = ["openedMessage": openMessagewithID!]
            usersRef.updateChildValues(values2, withCompletionBlock: {(err,ref) in
                if err != nil{
                    print(err as Any)
                    return
                }
            })
            let myVC = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            myVC.idPassed = openMessagewithID!
            navigationController?.pushViewController(myVC, animated: true)
            
        default: break
   
        }
    }
   
}

