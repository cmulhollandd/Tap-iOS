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
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var coolnessLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var tasteLabel: UILabel!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var detailTopContraint: NSLayoutConstraint!
    
    private var locationManager: CLLocationManager!
    private var fountainStore: FountainStore = FountainStore()
    private var location: CLLocation!
    private var prevLocation: CLLocation!
    private var focusedFountain: Fountain? = nil
    private let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        return nf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 20.0
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let location = view.annotation?.coordinate else {
            return
        }
        self.focusedFountain = fountainStore.getFountain(from: location)
        
        // Populate details & animate presentation
        updateDetails()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.focusedFountain = nil
        
        // Remove details and animate dismissal
        updateDetails()
    }
    
    private func updateDetails() {
        
        let openPosition = 400.0
        let closedPosition = 600.0
        
        let offset = CGFloat((closedPosition - openPosition) / 2)
        
        guard let fountain = self.focusedFountain else {
            self.coolnessLabel.text = "0.0"
            self.pressureLabel.text = "0.0"
            self.tasteLabel.text = "0.0"
            
            let camera = MKMapCamera(lookingAtCenter: self.mapView.userLocation.coordinate, fromDistance: self.mapView.camera.centerCoordinateDistance, pitch: 0, heading: 0.0)
            
            UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveEaseInOut) {
                self.detailTopContraint.constant = closedPosition
                self.mapView.setCamera(camera, animated: true)
                self.view.layoutIfNeeded()
            }
            return
        }
        self.coolnessLabel.text = nf.string(from: NSNumber(value: fountain.getCoolness()))!
        self.pressureLabel.text = nf.string(from: NSNumber(value: fountain.getPressure()))!
        self.tasteLabel.text = nf.string(from: NSNumber(value: fountain.getTaste()))!
        
        let camera = MKMapCamera(lookingAtCenter: fountain.getLocationCoordinate(), fromDistance: self.mapView.camera.centerCoordinateDistance, pitch: 0, heading: 0.0)
        
        UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveEaseInOut) {
            self.detailTopContraint.constant = openPosition
            self.mapView.setCamera(camera, animated: true)
            self.view.layoutIfNeeded()
        }
    }
}

extension MapViewController: FountainStoreDelegate {
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains fountains: [Fountain]) {
        for fountain in fountains {
            let annot = MKPointAnnotation()
            annot.coordinate = fountain.getLocationCoordinate()
            mapView.addAnnotation(annot)
        }
    }
}
