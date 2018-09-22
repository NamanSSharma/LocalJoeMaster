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

class EditInfoController : FormViewController{
    
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
                    
                    +++ Section ("Contact Info:")
                    
                    +++ Section ("Address: ")
                    <<< PostalAddressRow() {
                        $0.tag = "joeAddress"
                        $0.streetPlaceholder = "Street"
                        $0.statePlaceholder = "Province"
                        $0.cityPlaceholder = "City"
                        $0.postalCodePlaceholder = "Zip code"
                    }
                    
                    +++ Section("What is your phone number? :")
                    
                    <<< PhoneRow(){
                        $0.tag = "Phone"
                        $0.title = "Phone Number"
                    }
                    
                    
                    +++ Section()
                    
                    <<< ButtonRow() {
                        $0.title = "Update Info"
                        }
                        .onCellSelection {  cell, row in
                            let dict       = self.form.values (includeHidden: true)
                            let joePhone = dict["Phone"] as? String ?? ""
                            let joeDescription = dict["joeDescription"] as? String ?? ""
                            
                            //store information in database
                            let values = [
                                "joePhone" : joePhone,
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
        )
        
    }
}

