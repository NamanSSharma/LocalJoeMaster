//
//  DetailViewController.swift
//  Swift-TableView-Example
//
//  Created by Bilal ARSLAN on 12/10/14.
//  Copyright (c) 2014 Bilal ARSLAN. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var prepTime: UILabel!
    @IBOutlet weak var mapsOnline: UISwitch!
    @IBOutlet weak var chatsOnline: UISwitch!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var profilePic: UIButton!
    //database
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    let userID : String = (Auth.auth().currentUser?.uid)!

    @IBAction func mapsOnlineButton(_ sender: Any) {
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        if(mapsOnline.isOn){
            print("on")
            //store information in database
            let values = ["online": "online" ]
            usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
                if err != nil{
                    print(err as Any)
                    return
                }
                print("Joe is online")
            })
            
        }else{
            print("off")
            //store information in database
            let values = ["online": "offline" ]
            
            usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
                if err != nil{
                    print(err as Any)
                    return
                }
                print("Joe is offline")
            })
        }
    }
    
    @IBAction func chatOnlineButton(_ sender: Any) {
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        if(chatsOnline.isOn){
            print("on")
            //store information in database
            let values = ["chatOnline": "online" ]
            usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
                if err != nil{
                    print(err as Any)
                    return
                }
                print("Joe is online")
            })
            
        }else{
            print("off")
            //store information in database
            let values = ["chatOnline": "offline" ]
            
            usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
                if err != nil{
                    print(err as Any)
                    return
                }
                print("Joe is offline")
            })
        }
    }
    
    
    
    @IBAction func profileUpload(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            print("image has successfully loaded")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageAlert  = UIImageView(frame: CGRect(x: 80, y: 50, width: 100, height: 100))
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageAlert.image = image
        }else{
            //error
        }
        self.dismiss(animated:true, completion: nil)
        let alert = UIAlertController(title: "Confirm Upload?", message: "\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        // Create the actions
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { UIAlertAction in
            NSLog("Yes Pressed")
            
            //Store image based on number of images
            self.ref = Database.database().reference()
            let usersRef = self.ref.child("users").child(self.userID);
            let usersStorageRef = self.storage.child("users").child(self.userID);
            
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let tmpImgRef = usersStorageRef.child("profilePic")
                tmpImgRef.putData(UIImageJPEGRepresentation(imageAlert.image!, 0.4)!)
            }) { (error) in
                print(error.localizedDescription)
            }
            
            //reload images (not working)
            self.loadPic()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.view.addSubview(imageAlert)
        // show the alert
        self.present(alert, animated: true, completion: nil)
        //after its complete
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let usersStorageRef = self.storage.child("users").child(userID);
        ref = Database.database().reference()
        let usersRef = self.ref.child("users").child(userID);
        let profile = usersStorageRef.child("profilePic")
        profile.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.imageView.image = UIImage(data:data!)
                self.imageView.setRounded()
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            // Get user's name
            let joeType = value?["joeType"] as? String ?? ""
            if (joeType == "none"){
                self.displayView.isHidden = true;
            }
        }) { (error) in
            print(error.localizedDescription)
        }
       
    }
    
  
    func loadPic(){
        print("hi")
        let usersStorageRef = self.storage.child("users").child(userID);
        let profile = usersStorageRef.child("profilePic")
        profile.getData(maxSize: 1*1000*1000){ (data,error) in
            print("whoa")
            if error == nil{
                self.imageView.image = nil

                print("he")
                self.imageView.image = UIImage(data:data!)
                self.imageView.layer.borderWidth = 1
                self.imageView.layer.masksToBounds = false
                self.imageView.layer.borderColor = UIColor.black.cgColor
                self.imageView.layer.cornerRadius = self.imageView.frame.height/2 //This will change with corners of image and height/2 will make this circle shape
                self.imageView.clipsToBounds = true
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    
    
}

extension UIImageView {
    func setRounded() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}


