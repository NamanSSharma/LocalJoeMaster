//
//  ViewController.swift
//  joeDemo
//
//  Created by Naman Sharma on 11/3/17.
//  Copyright © 2017 User. All rights reserved.
//

//ViewController for User Profile

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var face: UIImageView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!
    @IBOutlet weak var image8: UIImageView!
    @IBOutlet weak var image9: UIImageView!
    @IBOutlet weak var online: UIView!
    @IBOutlet weak var onlineSwitch: UISwitch!
    //location manager
    let locationManager = CLLocationManager()
    var lat = "", long = "", originLocation = ""
    //database
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    let userID : String = (Auth.auth().currentUser?.uid)!

    @IBAction func uploadPhotoAction(_ sender: Any) {
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
                let value = snapshot.value as? NSDictionary
                // Get number of photos
                let numPhotos = value?["numPhotos"] as? String ?? ""
                var numPhotosInt:Int? = Int(numPhotos)
                numPhotosInt = numPhotosInt! % 9
                //Designated proper spot to store image
                let tmpImgRef = usersStorageRef.child("img\(numPhotosInt!)")
                //Increment Photo Count
                numPhotosInt = numPhotosInt! + 1
                //stores uploaded image into storage w/ half compression (0.0 is most)
                tmpImgRef.putData(UIImageJPEGRepresentation(imageAlert.image!, 0.4)!)
                
                let values = ["numPhotos": "\(numPhotosInt!)"]
                usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
                    if err != nil{
                        print(err as Any)
                        return
                    }
                    print("Saved user successfully into Firebase DB")
                    self.loadImages();
                })
            }) { (error) in
                print(error.localizedDescription)
            }
            
           //reload images (not working)
            self.viewWillAppear(true);
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
    
 
    @IBAction func onlineSwitchAction(_ sender: Any) {
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        
        if(onlineSwitch.isOn){
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

    
    override func viewWillAppear(_ animated: Bool){
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //get joe status
            let joeStatus = value?["joeType"] as? String ?? ""
            let notAJoe = "none"
            if (joeStatus == notAJoe){
                self.online.isHidden = true;
            }else{
                self.online.isHidden = false;
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        loadImages()
       
    }
    
    // Print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myLocation: CLLocationCoordinate2D = manager.location!.coordinate
        lat = String(myLocation.latitude)
        long = String(myLocation.longitude)
        originLocation = lat + "," + long
        print(originLocation)
        //store information in database
        
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        
        let values = ["lat": "\(lat)", "long": "\(long)"]
        
        usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in
            if err != nil{
                print(err as Any)
                return
            }
            print("Joe is online")
        })
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
        else if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "We need your location to display your location on the map",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
        locationManager.startUpdatingLocation()
        
        //Load Name
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        let usersStorageRef = self.storage.child("users").child(userID);

        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            // Get user's name
            let myName = value?["name"] as? String ?? ""
            self.name.text = myName;

            //get joe status
            let joeStatus = value?["joeType"] as? String ?? ""
            let notAJoe = "none"
            if (joeStatus == notAJoe){
                self.online.isHidden = true;
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //load images
        face.image = UIImage(named: "profile");
        self.face.layer.cornerRadius = self.face.frame.size.height/2;
        self.face.layer.masksToBounds = true;
        self.face.layer.borderWidth=2;
        
        loadImages();
    
        //Tap Image to Enlarge
        let image1Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image1.isUserInteractionEnabled = true;
        image1.addGestureRecognizer(image1Tap);
        
        let image2Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image2.isUserInteractionEnabled = true;
        image2.addGestureRecognizer(image2Tap);
        
        let image3Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image3.isUserInteractionEnabled = true;
        image3.addGestureRecognizer(image3Tap);
        
        let image4Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image4.isUserInteractionEnabled = true;
        image4.addGestureRecognizer(image4Tap);
        
        let image5Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image5.isUserInteractionEnabled = true;
        image5.addGestureRecognizer(image5Tap);
        
        let image6Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image6.isUserInteractionEnabled = true;
        image6.addGestureRecognizer(image6Tap);
        
        let image7Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image7.isUserInteractionEnabled = true;
        image7.addGestureRecognizer(image7Tap);
        
        let image8Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image8.isUserInteractionEnabled = true;
        image8.addGestureRecognizer(image8Tap);
        
        let image9Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image9.isUserInteractionEnabled = true;
        image9.addGestureRecognizer(image9Tap);
        
        
    }
    
    
    
    func loadImages () {
        //Load Name
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        let usersStorageRef = self.storage.child("users").child(userID);
        
        let image1Stored = usersStorageRef.child("img0")
        let image2Stored = usersStorageRef.child("img1")
        let image3Stored = usersStorageRef.child("img2")
        let image4Stored = usersStorageRef.child("img3")
        let image5Stored = usersStorageRef.child("img4")
        let image6Stored = usersStorageRef.child("img5")
        let image7Stored = usersStorageRef.child("img6")
        let image8Stored = usersStorageRef.child("img7")
        let image9Stored = usersStorageRef.child("img8")
        
        image1Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image1.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image2Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image2.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image3Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image3.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image4Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image4.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image5Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image5.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image6Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image6.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image7Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image7.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image8Stored.getData (maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image8.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        image9Stored.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.image9.image = UIImage(data:data!)
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
        

    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        //newImageView.contentMode = .scaleAspectFit
        newImageView.autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
}

