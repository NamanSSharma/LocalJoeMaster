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

class LocalJoeEstimator : UIViewController, CLLocationManagerDelegate {
    
    var alert: UIAlertController?
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var eta: UILabel!
    var zoomed:Bool! = false
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
        if !zoomed {
            centerMapOnLocation(location: self.location)
            zoomed = false;
        }
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
//                self.alert?.message = "ETA: \(route.expectedTravelTime)";
                self.eta.text = "ETA: \(route.expectedTravelTime)";
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
    
    // zoom in
    // add button
    // eta on bottom
    // line maybe??
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
    }
    
    @IBAction func goBack(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "TabbarIdentifier") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
}
