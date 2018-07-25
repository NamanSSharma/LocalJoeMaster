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

class LocalJoeEstimator : UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var alert: UIAlertController?
    
    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    var lat1: NSString = "";
    var lng1: NSString = "";
    var userID: String = "";
    private func calculateEta() {
        // Get current position
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D (latitude: self.location.coordinate.latitude, longitude: self.location.coordinate.longitude), addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Get destination position
        let destinationCoordinates = CLLocationCoordinate2DMake(lat1.doubleValue, lng1.doubleValue)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create request
        let request = MKDirectionsRequest()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        print("lat:\(self.lat1)")
        print("lng: \(self.lng1)");
        directions.calculate { response, error in
            if let route = response?.routes.first {
                self.alert?.message = "ETA: \(route.expectedTravelTime)";
                print("Distance: \(route.distance), ETA: \(route.expectedTravelTime)")
            } else {
                print("Error!")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.location = locations.last! as CLLocation
        calculateEta ()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat1.doubleValue, longitude: lng1.doubleValue)
        mapView.addAnnotation(annotation)
        alert = UIAlertController (title: "ETA", message: "Calculating", preferredStyle: UIAlertControllerStyle.alert)
        alert!.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }
            )
        );
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert!, animated: true, completion: nil)
        // centerMapOnLocation(location: self.location)
    }
    
}
