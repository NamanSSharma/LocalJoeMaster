//
//  ExploreController.swift
//  joeDemo
//
//  Created by Naman Sharma on 11/5/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps

class ExploreController : UIViewController, GMSMapViewDelegate {
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let userID : String = (Auth.auth().currentUser?.uid)!
    private var infoWindow = MapMarkerInfoWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    private var categories = [JobType]()
    
    private func setupCategories () {
        let jobTypesRef = ref.child (FirebaseDatabaseRefs.jobTypes)
        
        jobTypesRef.observeSingleEvent (of: .value, with :
            {
                (snapshot) in
                for child in snapshot.children {
                    let snap  = child as! DataSnapshot
                    let key   = snap.key
                    let value = snap.value as? NSDictionary
                    
                    print (value)
                    
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
            
            //setup MapView (set camera to your location)
            let camera = GMSCameraPosition.camera(withLatitude: 49.18683, longitude: -122.84899, zoom: 10)
            let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
            
            mapView.isMyLocationEnabled = true;
            
            for singleUser in allUserSnap.children.allObjects as! [DataSnapshot]
            {
                let value = singleUser.value as? NSDictionary
                let isOnline = value!["online"] as? String ?? ""
                if (isOnline == "online") {
                    
                    let name    = value?["name"]    as? String ?? ""
                    let joeType = value?["joeType"] as? String ?? ""
                    let lat     = value?["lat"]     as? String ?? ""
                    let long    = value?["long"]    as? String ?? ""
                    
                    guard let latNum:CLLocationDegrees  = CLLocationDegrees (lat) else {
                        continue
                    }
                    
                    guard let longNum:CLLocationDegrees = CLLocationDegrees (long) else {
                        continue
                    }
                    
                    let marker = GMSMarker ()
                    
                    marker.position = CLLocationCoordinate2DMake (latNum, longNum)
                    marker.title = name + " the \(joeType)";
                    
                    print (self.categories)
                    
                    if let joeTypeFound = self.categories.first (where: { $0.id == joeType } ) {
                        marker.title = name + " the \(joeTypeFound.name)";
                    } else {
                        marker.title = name + " the \(joeType)";
                    }
                    
                    marker.snippet = "\(singleUser.key)"
                    marker.map = mapView
                    
                }
                
                mapView.delegate = self
                self.view = mapView;
            }
        }
        ) {
            (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        //Load Name
        ref = Database.database ().reference ()
        // let usersRef = self.ref.child ("users").child (userID);
        setupCategories ()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Name
        ref = Database.database().reference()
        
        // Loads All Users To Map
        setupUsers ()
    }
    
    // Handles marker tap
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        // Needed to create the custom info window
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        
        //upload tapped person's name to firebase, to load for later in viewJoeProfileController
        let values = ["checkedOut": "\(marker.snippet!)" ]
        Constants.refs.databaseRoot.child("users/\(self.userID)").updateChildValues(values, withCompletionBlock: {(err,ref) in
            if err != nil{
                print(err as Any)
                return
            }
            print("worked")
        })
        
        infoWindow.text.text = marker.title;
        infoWindow.center = mapView.projection.point (for: location)
        infoWindow.center.y = infoWindow.center.y - sizeForOffset (view: infoWindow)
        self.view.addSubview(infoWindow)
        
        return false
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    /* handles Info Window tap */
    func mapView(_ mapView: GMSMapView, InfoWindowOf marker: GMSMarker) {
        print("didTapInfoWindowOf")
    }
    
    /* handles Info Window long press */
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("didLongPressInfoWindowOf")
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    }
    
    /* set a custom Info Window */
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    @objc func buttonTapped () {
        print ("Press Button")
    }
    
    // MARK: Needed to create the custom info window (this is optional)
    func loadNiB() -> MapMarkerInfoWindow{
        let infoWindow = MapMarkerInfoWindow.instanceFromNib() as! MapMarkerInfoWindow
        return infoWindow
    }
    
    
    
    // MARK: Needed to create the custom info window (this is optional)
    func sizeForOffset(view: UIView) -> CGFloat {
        return  135.0
    }
}

