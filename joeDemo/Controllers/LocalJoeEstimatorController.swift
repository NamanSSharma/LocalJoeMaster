//
//  LocalJoeEstimatorController.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-05-22.
//  Copyright © 2018 User. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMaps

class LocalJoeEstimator : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var alert: UIAlertController?
    var chatID: String = ""
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var eta: UILabel!
    var zoomed:Bool! = false
    
    let userID : String = (Auth.auth().currentUser?.uid)!
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    //database
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    var lat1: NSString = "";
    var lng1: NSString = "";
    var chatStatus: String = "";
    var destinationID: String = "";
   // var userID: String = "";
    private func calculateEta() {
        // Get current position
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D (latitude: self.location.coordinate.latitude, longitude: self.location.coordinate.longitude), addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Get destination position
        let locationRef = self.ref.child("chats").child(self.chatID);
        locationRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let firstID = postDict["firstID"] as? String ?? ""
            let secondID = postDict["secondID"] as? String ?? ""
            
            if (firstID == self.userID){
                self.destinationID = secondID
            }else{
                self.destinationID = firstID
            }
            
            let latlongRef = self.ref.child("users").child(self.destinationID);
            latlongRef.observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let lat = value!["lat"] as? Float ?? 0
                let long = value!["long"] as? Float ?? 0
                self.chatStatus = value!["chatOnline"] as? String ?? ("online") as String
                self.lat1 = "\(lat)" as NSString
                self.lng1 = "\(long)" as NSString
                print("lat1:\(self.lat1)")
                print("chat status: \(self.chatStatus)")
            })
        })
        let destinationCoordinates = CLLocationCoordinate2DMake(lat1.doubleValue, lng1.doubleValue)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create request
       /* if !zoomed {
            centerMapOnLocation(location: self.location)
            zoomed = false;
        }*/
        let request = MKDirectionsRequest()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        print(self.location.coordinate.latitude, self.location.coordinate.longitude)
        print("lat:\(self.lat1)")
        print("lng: \(self.lng1)");
        directions.calculate { response, error in
            if let route = response?.routes.first {
                // self.alert?.message = "ETA: \(route.expectedTravelTime)";
                let timeInMins = (route.expectedTravelTime/60).truncate(places:2);
                if(self.chatStatus == "online"){
                    self.eta.text = "Distance: \(timeInMins) mins";
                    print("Distance: \(route.distance), Distance: \(route.expectedTravelTime)")
                    
                    self.mapView.add(route.polyline, level: .aboveRoads)
                    let rekt = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated:true)
                }
                
            } else {
                print("Error!")
                self.eta.text = "Calculating..."
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay:MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.location = locations.last! as CLLocation
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            self.calculateEta ()
        })
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        print("chat: \(self.chatID)")
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat1.doubleValue, longitude: lng1.doubleValue)
        self.mapView.addAnnotation(annotation)
    }
    
    
    
}


