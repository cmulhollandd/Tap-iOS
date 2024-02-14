//
//  MapViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/13/24.
//

import Foundation
import UIKit
import CoreLocation
import CoreLocationUI
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    
    private var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Configure Location Manager
        locationManager = CLLocationManager()
        locationManager.distanceFilter = 5
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()
    }
}

extension MapViewController: CLLocationManagerDelegate {
}
