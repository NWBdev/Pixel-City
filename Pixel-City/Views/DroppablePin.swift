//
//  DroppablePin.swift
//  Pixel-City
//
//  Created by Nathaniel Burciaga on 3/4/18.
//  Copyright © 2018 Nathaniel Burciaga. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
}
