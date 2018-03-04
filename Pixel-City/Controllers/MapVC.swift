//
//  ViewController.swift
//  Pixel-City
//
//  Created by Nathaniel Burciaga on 3/3/18.
//  Copyright © 2018 Nathaniel Burciaga. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    //Location Service
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    //location Constant
    let regionRadius: Double = 1000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.mapView.showsUserLocation = true
        configureLocationServices()
    }

    
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// Set Location service Radius on User location
extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation() {
        guard let cordinate = locationManager.location?.coordinate else {return}
        let cordinateRegion = MKCoordinateRegionMakeWithDistance(cordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(cordinateRegion, animated: true)
    }
}

//LocationService Extn.
extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
