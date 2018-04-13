//
//  BecomeJoeController.swift
//  joeDemo
//
//  Created by Naman Sharma on 11/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import Eureka
import FirebaseAuth
import FirebaseDatabase

class BecomeJoeController : FormViewController{
    
    var ref: DatabaseReference!
    let reachability = Reachability()!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userID : String = (Auth.auth().currentUser?.uid)!
        ref = Database.database().reference()
        let usersRef = self.ref.child("users").child(userID);
    
        
        form
            +++ Section("Tell us about yourself")
        
            <<< PushRow<String>() {
                $0.tag = "joeType"
                $0.title = "Type of Joe:"
                $0.selectorTitle = "Type of Joe:"
                $0.options = ["Plumber","Electrician","Mechanic"]
                $0.value = "Plumber"    // initially selected
            }
        
            +++ Section("How Often Can You Work?")
    
            <<< ActionSheetRow<String>() {
                $0.tag = "daysToWork"
                $0.title = "Days In A Week:"
                $0.selectorTitle = "Days In A Week:"
                $0.options = ["1","2-4","4-7"]
                $0.value = "1"    // initially selected
            }
            
            +++ Section("Preferred Method of Payment:")
            
            <<< PushRow<String>() {
                $0.tag = "payment"
                $0.title = "Choose One:"
                $0.selectorTitle = "Choose One:"
                $0.options = ["E-transfer","Bank Account"]
                $0.value = "E-transfer"    // initially selected
            }
        
            +++ Section()
            
                <<< ButtonRow() {
                $0.title = "Submit Application"
                }
                .onCellSelection {  cell, row in
                    
                    let dict = self.form.values(includeHidden: true)
                    let joeType = dict["joeType"] as! String
                    let daysToWork = dict["daysToWork"] as! String
                    
                    //store information in database
                    let values = ["joeType": joeType, "daysToWork": daysToWork, "online": "online" ]
                   
                    usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
                        if err != nil{
                            print(err as Any)
                            return
                        }
                        print("Saved user successfully into Firebase DB")
                    })
                    
                    // create an alert
                    let alert = UIAlertController(title: "Congrats!", message: "You are now a registered Joe", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    
                }
       
    }
}
