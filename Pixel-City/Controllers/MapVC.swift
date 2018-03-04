//
//  ViewController.swift
//  Pixel-City
//
//  Created by Nathaniel Burciaga on 3/3/18.
//  Copyright © 2018 Nathaniel Burciaga. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
    }

    
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension MapVC: MKMapViewDelegate {
    
}
