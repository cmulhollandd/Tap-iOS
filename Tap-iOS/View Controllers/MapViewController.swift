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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    private var locationManager: CLLocationManager!
    private var fountainStore: FountainStore = FountainStore()
    private var location: CLLocation!
    private var prevLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        fountainStore.delegate = self
        
        // Configure Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "fountainPin")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fountainStore.updateFountains(around: mapView.region)
    }
    
    
    // MARK: - CLLocationManagerDelegate methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("Got location Services")
        default:
            print("Location services denied")
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.title == "My Location") {
            return MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
        }
        let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "fountainPin", for: annotation) as! MKMarkerAnnotationView
        marker.markerTintColor = UIColor(named: "PrimaryBlue")
        marker.glyphImage = UIImage(systemName: "spigot")
        return marker
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        // Tell fountainStore to update
        fountainStore.updateFountains(around: mapView.region)
    }
}

extension MapViewController: FountainStoreDelegate {
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains fountains: [Fountain]) {
        for fountain in fountains {
            let annot = MKPointAnnotation()
            annot.coordinate = fountain.getLocation()
            mapView.addAnnotation(annot)
        }
    }
}
