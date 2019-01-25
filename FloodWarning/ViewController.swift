//
//  ViewController.swift
//  FloodWarning
//
//  Created by Romel Levy on 1/24/19.
//  Copyright © 2019 Romel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //Connecting mapView to Controller
    @IBOutlet weak var mapView :MKMapView!
    
    private var rootRef :DatabaseReference!
    
    private var locationManager :CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rootRef = Database.database().reference()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        //permisson to access users location
        self.locationManager.requestWhenInUseAuthorization()
        
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        self.locationManager.startUpdatingLocation()
        
        setupUI()
        
        populateFloodedRegions()
        
    }
    
    private func populateFloodedRegions(){
        
        let floodedRegionsRef = self.rootRef.child("flooded-regions")
        
        floodedRegionsRef.observe(.value) { snapshot in
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            let floodDictionaries = snapshot.value as? [String:Any] ?? [:]
            
            for (key, _) in floodDictionaries {
                
                if let floodDict = floodDictionaries[key] as? [String:Any] {
                
                if let flood = Flood(dictionary: floodDict) {
                    
                    DispatchQueue.main.async {
                        
                        let floodAnnotation = MKPointAnnotation()
                        floodAnnotation.coordinate = CLLocationCoordinate2D(latitude: flood.latitude, longitude: flood.longitude)
                        
                        self.mapView.addAnnotation(floodAnnotation)
                    }
                }
            }
            }
            
        }
    }
    // function to add button for user to add flood warning on map
    private func setupUI(){
        //setting .png to button
        let addFloodButton = UIButton(frame: CGRect.zero)
        addFloodButton.setImage(UIImage(named: "plus-image"), for: .normal)
        
        //target\functionality of button
        addFloodButton.addTarget(self , action: #selector(addFloodAnnotationButtonPressed), for: .touchUpInside)
        addFloodButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(addFloodButton)
        
        addFloodButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        addFloodButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        addFloodButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        addFloodButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    @objc func addFloodAnnotationButtonPressed(sender :Any?){
        //let user drop pin where flood is 
        if let location = self.locationManager.location{
            
            let floodAnnotation = MKPointAnnotation()
            floodAnnotation.coordinate = location.coordinate
            self.mapView.addAnnotation(floodAnnotation)
            
            
            let coordinate = location.coordinate
            let flood = Flood(latitude: coordinate.latitude, longitude: coordinate.longitude )
            
            let floodedRegionsRef = self.rootRef.child("flooded-regions")
            
            let floodRef =  floodedRegionsRef.childByAutoId()
            floodRef.setValue(flood.toDictionary())
            
            
            
        }
        
        print("addFloodAnnotationButtonPressed")
        
    }
    
    
    // function to zoom into users location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            
            let coordinate = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }


}

