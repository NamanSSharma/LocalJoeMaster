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
    
    @IBOutlet weak var bigView: UIView!
    @IBOutlet weak var smallBView: UIView!
    @IBOutlet weak var smallButtonView: UIView!
    @IBOutlet weak var bigButton: UIButton!
    @IBOutlet weak var smallButton: UIButton!
    
    @IBAction func bigButtonAction(_ sender: Any) {
        bigView.isHidden = true
        smallBView.isHidden = false
        
    }
    @IBAction func smallButtonAction(_ sender: Any) {
        bigView.isHidden = false
        smallBView.isHidden = true
    }
    
    
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    var locationInitSetup:Bool! = false
    var ref: DatabaseReference!
    var usersRef: DatabaseReference!
    var handle:DatabaseHandle?
    
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
    
    private func setupFCMToken () {
        let userRef = ref.child (FirebaseDatabaseRefs.users).child (userID);
        userRef.updateChildValues(
            [
                "fcmToken" : AppDelegate.fcmToken
            ]
        ) {
            (err, ref) in
            if err != nil {
                print(err as Any)
                return
            }
            
            print("completed: \(AppDelegate.fcmToken)")
        }
    }
    
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
                if let value = singleUser.value as? NSDictionary as! [String:Any]? {
                    let isOnline = value["online"] as? String ?? ""
                    let status = value["status"] as? String ?? ""
                    if (isOnline == "online" && status == "approved") {
                        let joeID   = value["id"] as? String ?? ""
                        if joeID == self.userID {
                            continue
                        }
                        let name    = value["name"]    as? String ?? ""
                        let joeType = value["joeType"] as? String ?? ""
                        let lat     = value["lat"]     as? Double ?? 0.0
                        let long    = value["long"]    as? Double ?? 0.0
                        
                        print("\(name), \(joeType), \(lat), \(long)")
                        let marker = MapJoe(title: name, joeID: joeID, profession: joeType, coordinate: CLLocationCoordinate2DMake (CLLocationDegrees (lat), CLLocationDegrees (long)), distance: -1)
                        
                        print(self.categories.count)
                        if let joeTypeFound = self.categories.first (where: { $0.id == joeType } ) {
                            marker.profession = joeTypeFound.name;
                        }
                        
                        self.markers.append(marker)
                        self.map.addAnnotation(marker)
                    }
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
                    print("INDEX: \(index), \(markers[index].joeID ?? "" )")
                    markers[index].distance = (self.location.distance(from: CLLocation(latitude: markers[index].coordinate.latitude, longitude: markers[index].coordinate.longitude)))/1000; // result is in meters
                }
                markers = markers.sorted(by:
                    {
                        $0.distance < $1.distance
                    }
                )
                
                if 2 < size {
                    let distance1 = (markers[0].distance).truncate(places:2);
                    let distance2 = (markers[1].distance).truncate(places:2);
                    let distance3 = (markers[2].distance).truncate(places:2);

                    firstNearbyName.text = "\(markers[0].title ?? "") (\(markers[0].profession))"
                    firstNearbyDistance.text = "\(distance1) km"
                    secondNearbyName.text = "\(markers[1].title ?? "") (\(markers[1].profession))"
                    secondNearbyDistance.text = "\(distance2) km"
                    thirdNearbyName.text = "\(markers[2].title ?? "") (\(markers[2].profession))"
                    thirdNearbyDistance.text = "\(distance3) km"
                }
                
                locationInitSetup = true;
            }
        }
        
        
        usersRef.updateChildValues(["lat": self.location.coordinate.latitude, "long": self.location.coordinate.longitude], withCompletionBlock:
            {
                (err,ref) in
                    if err != nil {
                        print(err as Any)
                        return
                    }
            }
        )
        
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
        usersRef = self.ref.child(FirebaseDatabaseRefs.users).child(userID);
        
        // Loads All Users To Map
        setupCategories ()
        setupFCMToken ()
        // setupUsers ()
        map.delegate = self
        let showTutorial = usersRef.child("showTutorial")
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
        let identifier: String = UUID().uuidString
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -10, y: -5)
            let image = UIImage(named: "chat.png");
            let btn = MarkerButton(type: .custom)
            // btn.tag = Int.random(in: 0 ..< 6)
            btn.tag = 1
            btn.frame = CGRect.init(x: 5, y: 10, width: 70, height: 45)
            btn.setImage(image, for: .normal)
            print("ID: \(annotation.joeID!)")
            btn.buttonIdentifier = annotation.joeID
            btn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
            view.rightCalloutAccessoryView = btn
        }
        return view
    }
    
    @objc func sendMessage(sender: MarkerButton!) {
        if sender.tag == 1 {
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
                                    let joeRef = self.ref.child (FirebaseDatabaseRefs.users).child (joeID);
                                    let myName = value?["name"] as? String ?? ""
                                    let myId   = value?["senderId"] as? String ?? ""
                                    
                                    joeRef.observeSingleEvent(of: .value, with:
                                        {
                                            (snapshot) in
                                            let value = snapshot.value as? NSDictionary
                                            // Get user's name
                                            let joeName       = value?["name"]     as? String ?? ""
                                            let joeId         = value?["senderId"] as? String ?? ""
                                            
                                            let chatId        = myId > joeId ? "\(myId)_\(joeId)" : "\(joeId)_\(myId)"
                                            
                                            print("\(myId) => \(joeId)")
                                            if myId == joeId {
                                                return
                                            }
                                            
                                            let userChatValues = [
                                                "userid"   : joeId,
                                                "username" : joeName,
                                                "firstID"  : self.userID,
                                                "secondID" : joeID
                                            ]
                                            
                                            let joeChatValues = [
                                                "userid"   : myId,
                                                "username" : myName,
                                                "firstID"  : self.userID,
                                                "secondID" : joeID
                                            ]
                                            
                                            let chatValues = [
                                                "chatid" : chatId,
                                                "userid" : myId,
                                                "joeid"  : joeId,
                                                "firstID": self.userID,
                                                "secondID": joeID
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
                                                (err, ref) in
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
                                                    "date"        : String (Date().timeIntervalSince1970),
                                                    "senderUserID" : self.userID
                                                ]
                                            print("\(chatId) => \(messageId)")
                                            chatRef.child (messageId).updateChildValues(messageValues as [AnyHashable : Any], withCompletionBlock: {
                                                    (err, ref) in
                                                    if err != nil {
                                                        print(err as Any)
                                                        return
                                                    }
                                                }
                                            )
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
                
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
                print("cancelled")
            }))
            
                self.present(alert, animated: true, completion:
                    {
                        alert.view.superview?.isUserInteractionEnabled = true
                        alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
                    }
                )
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
