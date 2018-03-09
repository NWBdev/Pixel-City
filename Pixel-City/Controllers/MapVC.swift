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
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    //Location Service
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    //location Constant
    let regionRadius: Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    var ScreenSize = UIScreen.main.bounds
    
    //Collection View Progamaticlly
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    //Image Array
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.mapView.showsUserLocation = true
        configureLocationServices()
        addDoubleTap()
        
        //collection View
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // test
        
        pullUpView.addSubview(collectionView!)
    }

    
    //double tap for Pin Dropping
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    //swipe down on popup view it hides
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    
    func animateViewUp() {
        //animates hidden view up
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            print("ran popup View up")
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        //cancel Session for request of images
        cancelAllSessions()
        //animates hidden view down
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            print("ran popup View Down")
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (ScreenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgessLbl() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x:(ScreenSize.width / 2) - 120, y: 175, width: 200, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        //progressLabel?.text = "12/40 photos loaded" // test
        collectionView?.addSubview(progressLabel!)
        
    }
    
    func removeProgressLbl() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = UIColor.orange
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }   
    
    func centerMapOnUserLocation() {
        guard let cordinate = locationManager.location?.coordinate else {return}
        let cordinateRegion = MKCoordinateRegionMakeWithDistance(cordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(cordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        //remove pin, Progress Label, cancel all Sessions and spinner
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        
        //reload and clear previous Image Array
        imageUrlArray = []
        imageArray = []
        
        //add data of images
        collectionView?.reloadData()
        
        //pulls up view for Images
        animateViewUp()
        //Pull down View
        addSwipe()
        // add Spinner
        addSpinner()
        //progress Label
        addProgessLbl()
        
        // Drop pin on map
    print("pin was dropepd")
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
       // print(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40))

        
        // region for touch point on Map
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        print(touchPoint)
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            //code to parse
            print(self.imageUrlArray)
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        //hide spinner
                        self.removeSpinner()
                        //hide label
                        self.removeProgressLbl()
                        //reload CollectionView
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
        
}
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //Alamofire Request
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) ->() ){
        
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
        
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
        
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
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

//UICollection View
extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // number of Items in array
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}


