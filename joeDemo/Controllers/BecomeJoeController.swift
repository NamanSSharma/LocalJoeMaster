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

class BecomeJoeController : FormViewController, MFMailComposeViewControllerDelegate{
    
    var ref: DatabaseReference!
    let reachability = Reachability()!
    let userID : String = (Auth.auth().currentUser?.uid)!

    var jobTypesArray = [JobType]()
    
    func configureMailController() -> MFMailComposeViewController {
        let dict       = self.form.values (includeHidden: true)
        let joePhone = dict["Phone"] as? String ?? ""
        // let daysToWork = dict["daysToWork"] as! String
        
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["Info@localjoeservices.com"])
        mailComposerVC.setSubject("LocalJoe: New Joe Applicant")
        mailComposerVC.setMessageBody("Verify my profile: \nUserID:\(userID)\n\(joePhone)" , isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: "Could not send application", message: "Please try again later", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated:true, completion:  nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated:true, completion: nil)
        _ = self.navigationController?.popToRootViewController(animated: true)

    }
    
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
                    
                    +++ Section ("About yourself:")
                    
                    <<< PushRow<String>() {
                        $0.tag = "joeGender"
                        $0.title = "Gender:"
                        $0.selectorTitle = "Type of Joe:"
                        $0.options = ["Male", "Female", "Other"]
                    }
                    
                    <<< DateRow(){
                        $0.tag = "joeBirthday"
                        $0.title = "Birthday"
                        $0.value = Date(timeIntervalSinceReferenceDate: 0)
                    }
                    <<< PushRow<String>() {
                        $0.tag = "joeType"
                        $0.title = "Occupation:"
                        $0.selectorTitle = "Type of Joe:"
                        $0.options = options
                        $0.value = options[0]    // initially selected
                    }
                    

                    
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
                    
                    +++ Section ("Tell us a little about yourself")
                    
                    <<< TextAreaRow(){
                        $0.tag = "joeDescription"
                        $0.title = "Text Row"
                        $0.placeholder = "Enter description here"
                    }
                    
                    +++ Section()
                    
                    <<< ButtonRow() {
                        $0.title = "Submit Application"
                        }
                        .onCellSelection {  cell, row in
                            
                            let mailComposeViewController = self.configureMailController()
                            if MFMailComposeViewController.canSendMail() {
                                self.present(mailComposeViewController, animated: true, completion: nil)
                            }else {
                                self.showMailError()
                            }
                            
                            let dict       = self.form.values (includeHidden: true)
                            let date = dict["joeBirthday"] as! Date
                            let joeBirthday = date.toString(dateFormat: "dd-MM-YYYY") as? String ?? "Other"
                            let joeGender = dict["joeGender"] as? String ?? "Other"
                            let joeType    = dict["joeType"] as! String ?? ""
                            // let joeAddress = dict["joeAddress"] as! String
                          //  print(dict["joeAddress"] as! String)
                            let joePhone = dict["Phone"] as? String ?? ""
                            let joeDescription = dict["joeDescription"] as? String ?? ""
                            
                            if(joeDescription.count < 50){
                                let alert = UIAlertController(title: "Edit Description", message: "the minimum length for the description is 50 characters", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }else{
                            
                                let jobTypeFiltered = self.jobTypesArray.filter { $0.name == joeType }
                                
                                if jobTypeFiltered.isEmpty {
                                    return;
                                }
                                
                                let joeId = jobTypeFiltered[0].id
                                let senderUUID  = UUID ().uuidString
                                
                                //store information in database
                                let values = [
                                   "joeGender"  : joeGender,
                                    "joeType"   : joeId,
                                    "joeBirthday":joeBirthday,
                                   // "joeAddress" : joeAddress,
                                    "joePhone" : joePhone,
                                    "joeDescription": joeDescription,
                                   "online"     : "online",
                                   "status"     : "unapproved",
                                   "senderId"   : senderUUID,
                                   "id"         : userID,
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
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
