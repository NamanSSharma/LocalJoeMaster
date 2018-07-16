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

class LocalJoeEstimator : UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private func calculateEta() {
        // Get current position
        
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D (latitude: 57.619302, longitude: 12.954928), addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Get destination position
        let lat1: NSString = "57.619302"
        let lng1: NSString = "11.954928"
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
        directions.calculate { response, error in
            if let route = response?.routes.first {
                print("Distance: \(route.distance), ETA: \(route.expectedTravelTime)")
            } else {
                print("Error!")
            }
        }
    }
    
    override func loadView() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cameraPositionCoordinates = CLLocationCoordinate2D(latitude: 18.5203, longitude: 73.8567)
        let cameraPosition = GMSCameraPosition.camera(withTarget: cameraPositionCoordinates, zoom: 12)
        
        //Controls whether the My Location dot and accuracy circle is enabled.
        
        print (self.mapView)
        
        self.mapView.isMyLocationEnabled = true;
        
        //Controls the type of map tiles that should be displayed.
        
        // self.mapView.mapType = kGMSTypeNormal;
        
        //Shows the compass button on the map
        
        self.mapView.settings.compassButton = true;
        
        //Shows the my location button on the map
        
        self.mapView.settings.myLocationButton = true;
        
        //Sets the view controller to be the GMSMapView delegate
        
        self.mapView.delegate = self;
        
        // self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cameraPosition)
        // self.mapView.isMyLocationEnabled = true
        
        /* let marker = GMSMarker()
         marker.position = CLLocationCoordinate2DMake(18.5203, 73.8567)
         marker.groundAnchor = CGPoint (x : 0.5, y : 0.5)
         marker.map = self.mapView
         
         let path = GMSMutablePath()
         path.add(CLLocationCoordinate2DMake(18.520, 73.856))
         path.add(CLLocationCoordinate2DMake(16.7, 73.8567))
         
         let rectangle = GMSPolyline(path: path)
         rectangle.strokeWidth = 2.0
         rectangle.map = mapView */
        
        // self.mapView = mapView
        // self.view = mapView
        
        calculateEta ()
    }
    
    
}
