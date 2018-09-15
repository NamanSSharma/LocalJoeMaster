//
//  ViewPaymentsController.swift
//  joeDemo
//
//  Created by User on 1/20/18.
//  Copyright © 2018 User. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewPaymentsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var myList:[String] = []
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var paymentList: UITableView!
    
    var testJoe = ["Priyonto Rahman", "Steve Rogers","Tony Stark"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))

        paymentList.delegate = self
        paymentList.dataSource = self
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
                    self.myList.append(client + "                                                         messageID:" + messageID)
                    
                }else{
                    self.myList.append(joe + "                                                            messageID:" + messageID)
                    
                }
                DispatchQueue.main.async(){
                    self.paymentList.reloadData()
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
            let cell = tableView.cellForRow(at: indexPath)
            print(cell?.textLabel?.text ?? "Could not get value")
            let delimiter = "messageID:"
            let cellText = cell?.textLabel?.text
            let openMessagewithID = cellText?.components(separatedBy: delimiter).last
            let joeName = cellText?.components(separatedBy: delimiter).first
            print(openMessagewithID!)
            let values2 = ["openedMessage": openMessagewithID!]
            usersRef.updateChildValues(values2, withCompletionBlock: {(err,ref) in
                if err != nil{
                    print(err as Any)
                    return
                }
            })
            
        //alert for sending money to joe
        let alert = UIAlertController(title: "Pay \(testJoe[indexPath.row])", message: "Enter an amount: ", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "$"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text!)")
            let confirmAlert = UIAlertController(title: "You Are Sending \(textField.text!) To \(joeName!)", message: "You cannot undo this action", preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StripePaymentVC") as! StripePaymentVC
                
                self.present(vc, animated: true, completion: nil)
            }))
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                let successAlert = UIAlertController(title: "Payment cancelled  to \(joeName!)", message: "", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                }))
                self.present(successAlert, animated: true, completion: nil)
            }))
            self.present(confirmAlert, animated: true, completion: nil)
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        default: break
        }

    }
    
}

class uitableCell : UITableViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    
}

