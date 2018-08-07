//
//  MapViewController.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-08-05.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MarkerButton: UIButton {
    var buttonIdentifier: String?
}

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var map: MKMapView!
    
    @IBOutlet var firstNearbyName: UILabel!
    @IBOutlet var secondNearbyName: UILabel!
    @IBOutlet var thirdNearbyName: UILabel!
    
    @IBOutlet var firstNearbyDistance: UILabel!
    @IBOutlet var secondNearbyDistance: UILabel!
    @IBOutlet var thirdNearbyDistance: UILabel!
    
    var locationInitSetup:Bool! = false
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    // set initial location in Honolulu
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        map.setRegion(MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius), animated: true)
    }
    
    private var categories = [JobType]()
    private var markers = [MapJoe]()
    
    private func setupCategories () {
        let jobTypesRef = ref.child (FirebaseDatabaseRefs.jobTypes)
        
        jobTypesRef.observeSingleEvent (of: .value, with :
            {
                (snapshot) in
                for child in snapshot.children {
                    let snap  = child as! DataSnapshot
                    let key   = snap.key
                    let value = snap.value as? NSDictionary
                    
                    if let name = value?["name"] as? String,
                        let image_url = value?["image_url"] as? String {
                        self.categories.append (JobType (id: key, name : name, image_url : image_url))
                    }
                }
                self.setupUsers ()
            }
        )
    }
    
    func setupUsers () {
        // Loads All Users To Map
        let allUsers = self.ref.child("users")
        allUsers.observeSingleEvent(of: .value, with: {
            (allUserSnap) in
            
            // setup MapView (set camera to your location)
            for singleUser in allUserSnap.children.allObjects as! [DataSnapshot]
            {
                let value = singleUser.value as? NSDictionary
                let isOnline = value!["online"] as? String ?? ""
                if (isOnline == "online") {
                    
                    let name    = value?["name"]    as? String ?? ""
                    let joeType = value?["joeType"] as? String ?? ""
                    let joeID   = value?["id"]      as? String ?? ""
                    print("IDD \(joeID)")
                    let lat     = value?["lat"]     as? String ?? ""
                    let long    = value?["long"]    as? String ?? ""
                    
                    guard let latNum:CLLocationDegrees  = CLLocationDegrees (lat) else {
                        continue
                    }
                    
                    guard let longNum:CLLocationDegrees = CLLocationDegrees (long) else {
                        continue
                    }
                    let marker = MapJoe(title: name, joeID: joeID, profession: joeType, coordinate: CLLocationCoordinate2DMake (latNum, longNum), distance: -1)
                    
                    print(self.categories.count)
                    if let joeTypeFound = self.categories.first (where: { $0.id == joeType } ) {
                        marker.profession = joeTypeFound.name;
                    }
                    
                    self.markers.append(marker)
                    self.map.addAnnotation(marker)
                }
            }
        }
        ) {
            (error) in
            print(error.localizedDescription)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last! as CLLocation
        // Create request
        if !locationInitSetup {
            centerMapOnLocation(location: self.location)
            let size = markers.count
            print("COUNT IS :\(size)")
            if size > 0 {
                for index in 0 ..< size {
                    markers[index].distance = self.location.distance(from: CLLocation(latitude: markers[index].coordinate.latitude, longitude: markers[index].coordinate.longitude)) // result is in meters
                }
                markers = markers.sorted(by:
                    {
                        $0.distance < $1.distance
                    }
                )
                
                if 3 < size {
                    firstNearbyName.text = markers[0].title
                    firstNearbyDistance.text = "\(markers[0].distance)m"
                    secondNearbyName.text = markers[1].title
                    secondNearbyDistance.text = "\(markers[1].distance)m"
                    thirdNearbyName.text = markers[2].title
                    thirdNearbyDistance.text = "\(markers[2].distance)m"
                }
                
                locationInitSetup = true;
            }
            
            
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (CLLocationManager.locationServicesEnabled()){
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
        }
        map.showsUserLocation = true
        
        // Load Name
        ref = Database.database().reference()
        
        // Loads All Users To Map
        setupCategories ()
        setupUsers ()
        map.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        // Dispose of any resources that can be recreated.
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapJoe else {
            return nil
        }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: -5)
            let image = #imageLiteral(resourceName: "star")
            let btn = MarkerButton(type: .custom)
            btn.tag = 1
            btn.frame = CGRect.init(x: 10, y: 10, width: 100, height: 45)
            btn.setImage(image, for: .normal)
            print("ID: \(annotation.joeID!)")
            btn.buttonIdentifier = annotation.joeID
            btn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
            view.rightCalloutAccessoryView = btn
        }
        return view
    }
    
    @objc func sendMessage(sender: MarkerButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            let alert = UIAlertController(title: "Send a message", message: "Enter message", preferredStyle: .alert)
            alert.addTextField {
                (textField) in
                    textField.text = ""
            }
            
            alert.addAction(UIAlertAction(title: "Send Message", style: .default, handler:
                    {
                        [weak alert] (_) in
                            let text = alert!.textFields![0].text // Force unwrapping because we know it exists.
                            let joeID = sender.buttonIdentifier ?? ""
                            print("JOEID: \(joeID)")
                        
                            let messageId = UUID().uuidString
                        
                        
                            let chatsRef = self.ref.child("chats");
                            let usersRef = self.ref.child("users").child (self.userID);
                            usersRef.observeSingleEvent (of: .value, with:
                                {
                                    (snapshot) in
                                    let value = snapshot.value as? NSDictionary
                                    
                                    // Get user's name
                                    // Get joeID from marker
                                    let joeRef = self.ref.child ("users").child (joeID);
                                    let myName = value?["name"] as? String ?? ""
                                    let myId   = value?["senderId"] as? String ?? ""
                                    
                                    joeRef.observeSingleEvent(of: .value, with:
                                        {
                                            (snapshot) in
                                            let value = snapshot.value as? NSDictionary
                                            // Get user's name
                                            let joeName       = value?["name"]     as? String ?? ""
                                            let joeId         = value?["senderId"] as? String ?? ""
                                            
                                            let chatId        = myId > joeId ? "\(myId)_\(joeId)" : "\(joeId)_\(myId)" // UUID().uuidString;
                                            
                                            if myId == joeId {
                                                return
                                            }
                                            
                                            let userChatValues = [
                                                "userid"   : joeId,
                                                "username" : joeName
                                            ]
                                            
                                            let joeChatValues = [
                                                "userid"   : myId,
                                                "username" : myName
                                            ]
                                            
                                            let chatValues = [
                                                "chatid" : chatId,
                                                "userid" : myId,
                                                "joeid"  : joeId,
                                            ]
                                            
                                            usersRef.child ("chats").child (chatId).updateChildValues (userChatValues, withCompletionBlock: {
                                                (err,ref) in
                                                    if err != nil {
                                                        print(err as Any)
                                                        return
                                                    }
                                                }
                                            )
                                            
                                            joeRef.child ("chats").child (chatId).updateChildValues (joeChatValues, withCompletionBlock: {
                                                (err,ref) in
                                                    if err != nil {
                                                        print (err as Any)
                                                        return
                                                    }
                                                }
                                            )
                                            
                                            chatsRef.child (chatId).updateChildValues (chatValues, withCompletionBlock: {
                                                (err,ref) in
                                                    if err != nil {
                                                        print(err as Any)
                                                        return
                                                    }
                                                }
                                            )
                                            
                                            let chatRef = self.ref.child (FirebaseDatabaseRefs.chats).child (chatId).child ("messages")
                                            let messageValues =
                                                [
                                                    "senderId"    : myId,
                                                    "displayName" : myName,
                                                    "text"        : text,
                                                    "date"        : String (Date().timeIntervalSince1970)
                                            ]
                                            chatRef.child (messageId).updateChildValues (messageValues)
                                        }
                                    ) {
                                        (error) in
                                        print(error.localizedDescription)
                                    }
                                    
                                }
                            )
                        }
                    )
                )
            
                self.present(alert, animated: true, completion: nil)
        }
    }
}
