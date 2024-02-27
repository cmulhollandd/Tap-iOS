//
//  NewFountainViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/15/24.
//

import Foundation
import UIKit
import CoreLocation
import MapKit


class NewFountainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var typePicker: UISegmentedControl!
    @IBOutlet var tempSlider: UISlider!
    @IBOutlet var pressureSlider: UISlider!
    @IBOutlet var tasteSlider: UISlider!
    @IBOutlet var fullScreenButton: UIButton!
    
    @IBOutlet var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var mapViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var mapViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Instance Variables
    private var fountainLocation: CLLocationCoordinate2D?
    private var fountainPin: MKAnnotation?
    private var mapIsFullScreen = false
    private var locationManager: CLLocationManager!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.layer.cornerRadius = 10.0
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        blur.layer.cornerRadius = 10
        blur.frame = fullScreenButton.bounds
        blur.clipsToBounds = true
        blur.isUserInteractionEnabled = false
        fullScreenButton.insertSubview(blur, at: 0)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        setupLocationServices()
    }
    
    
    // MARK: - @IBActions
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        if let annotation = fountainPin {
            mapView.removeAnnotation(annotation)
        }
        typePicker.selectedSegmentIndex = 0
        tempSlider.setValue(5.0, animated: true)
        pressureSlider.setValue(5.0, animated: true)
        tasteSlider.setValue(5.0, animated: true)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        // Send request to fountain API
        guard let location = fountainLocation else {
            // display toast to user
            return
        }
        let temp = Double(tempSlider.value.rounded())
        let pressure = Double(pressureSlider.value.rounded())
        let taste = Double(tasteSlider.value.rounded())
        let type = Fountain.FountainType(rawValue: typePicker.selectedSegmentIndex)!
        
        let fountain = Fountain(location: location, coolness: temp, pressure: pressure, taste: taste, type: type)
        
        print("New Fountain: \(fountain)")
    }
    
    @IBAction func longPressRecognized(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordLocation = mapView.convert(location, toCoordinateFrom: mapView)
        if let fountainPin = self.fountainPin {
            mapView.removeAnnotation(fountainPin)
        }
        let pin = MKPointAnnotation()
        pin.coordinate = coordLocation
        pin.title = "New Fountain"
        mapView.addAnnotation(pin)
        self.fountainPin = pin
        self.fountainLocation = coordLocation
    }
    
    @IBAction func fullscreenButtonPressed(_ sender: UIButton) {
        if mapIsFullScreen {
            // Collapse map back
            fullScreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
                self.mapViewLeadingConstraint.constant = 16
                self.mapViewTrailingConstraint.constant = 16
                self.mapViewBottomConstraint.constant = 7
                self.view.layoutIfNeeded()
            }
            mapIsFullScreen = false
        } else {
            // Make map full screen
            fullScreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
                self.mapViewLeadingConstraint.constant = 8
                self.mapViewTrailingConstraint.constant = 8
                self.mapViewBottomConstraint.constant = -300
                self.view.layoutIfNeeded()
            }
            mapIsFullScreen = true
        }
    }
    
    
    // MARK: - Instance Methods
    private func setupLocationServices() {
        switch locationManager.authorizationStatus {
        case .denied:
            print("Location Services unavailable, fix in settings app")
        case .restricted:
            print("Location services unavailable due to parental controls, etc.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            print("Location services enabled")
        }
    }
    
    
    // MARK: - MKMapViewDelegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
        }
        
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        if (annotation.title == "New Fountain") {
            marker.markerTintColor = UIColor.red
            marker.glyphImage = UIImage(systemName: "waterbottle")
        } else {
            marker.markerTintColor = UIColor(named: "PrimaryBlue")
        }
        return marker
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("Starting Location Services")
        case .authorizedAlways:
            print("Starting Location Services")
        default:
            print("Location Services denied")
        }
    }
}
