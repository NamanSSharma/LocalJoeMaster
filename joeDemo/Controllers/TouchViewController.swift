//
//  TouchViewController.swift
//  joeDemo
//
//  Created by Naman Sharma on 11/5/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class TouchViewController: UIViewController {
  
    var ref : DatabaseReference! = Database.database().reference ()
    let userID:String = (Auth.auth().currentUser?.uid)!
    @IBOutlet weak var becomeJoe: UIButton!
    @IBAction func becomeJoeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "becomeAJoe", sender: self)
    }
    
    @IBOutlet weak var signOut: UIBarButtonItem!
    @IBAction func signOutAction(_ sender: Any) {
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
   
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userRef = ref.child (FirebaseDatabaseRefs.users).child (userID);
        userRef.updateChildValues(
            [
                "fcmToken" : AppDelegate.fcmToken
            ]
        )
       // sideMenu()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func sideMenu(){
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            revealViewController().rightViewRevealWidth = 160
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    } */

}
