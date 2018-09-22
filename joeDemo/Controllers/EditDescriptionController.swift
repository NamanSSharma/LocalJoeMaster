//
//  BecomeJoeController.swift
//  joeDemo
//
//  Created by Naman Sharma on 11/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import Eureka
import PostalAddressRow
import MessageUI

import FirebaseAuth
import FirebaseDatabase

class EditDescriptionController : FormViewController{
    
    var ref: DatabaseReference!
    let reachability = Reachability()!
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    var jobTypesArray = [JobType]()
   
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        let userID : String = (Auth.auth ().currentUser?.uid)!
        
        ref = Database.database ().reference()
        
        let usersRef    = self.ref.child (FirebaseDatabaseRefs.users).child (userID);
        
        var options = [String]()
        
        let jobTypesRef = self.ref.child (FirebaseDatabaseRefs.jobTypes)
        
        jobTypesRef.observeSingleEvent (of: .value, with :
            {
                (snapshot) in
                for child in snapshot.children {
                    let snap  = child as! DataSnapshot
                    let key   = snap.key
                    let value = snap.value as? NSDictionary
                    
                    if let name = value?["name"] as? String,
                        let image_url = value?["image_url"] as? String {
                        self.jobTypesArray.append (JobType (id: key, name : name, image_url : image_url))
                        
                        // Does not deal well with two job types with the same name
                        options.append (name)
                    }
                }
                
                if options.isEmpty {
                    return
                }
                
                self.form
                    
                    +++ Section ("Tell us a little about yourself")
                    
                    <<< TextAreaRow(){
                        $0.tag = "joeDescription"
                        $0.title = "Text Row"
                        $0.placeholder = "Enter description here (Min. 50 characters)"
                    }
                    
                    +++ Section()
                    
                    <<< ButtonRow() {
                        $0.title = "Submit Application"
                        }
                        .onCellSelection {  cell, row in
                            
                            let dict       = self.form.values (includeHidden: true)
                            
                            let joeDescription = dict["joeDescription"] as? String ?? ""
                            
                            if(joeDescription.count < 50){
                                let alert = UIAlertController(title: "Edit Description", message: "the minimum length for the description is 50 characters", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }else{
                                //store information in database
                                let values = [
                                    "joeDescription": joeDescription,
                                ]
                                
                                usersRef.updateChildValues(values, withCompletionBlock: {
                                    (err,ref) in
                                    if err != nil {
                                        print (err as Any)
                                        return
                                    }
                                    print("Saved user successfully into Firebase DB")
                                    
                                }
                                )
                            }
                            
                }
                
        }
        )
        
    }
}

