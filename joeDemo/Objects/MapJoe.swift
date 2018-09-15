//
//  MapJoe.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-08-05.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import MapKit

class MapJoe: NSObject, MKAnnotation {
    let title: String?
    let joeID: String?
    var profession: String
    
    let coordinate: CLLocationCoordinate2D
    var distance: Double
    
    init(title: String, joeID: String, profession: String, coordinate: CLLocationCoordinate2D, distance: Double) {
        self.title = title
        self.joeID = joeID
        self.profession = profession
        self.coordinate = coordinate
        self.distance = distance
        
        super.init()
    }
    
    var subtitle: String? {
        return profession
    }
}
