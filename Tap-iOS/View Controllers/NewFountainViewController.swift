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
    
    // MARK: - Instance Variables
    private var fountainLocation: CLLocationCoordinate2D?
    private var fountainPin: MKAnnotation?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
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
        let temp = Int(tempSlider.value.rounded())
        let pressure = Int(pressureSlider.value.rounded())
        let taste = Int(tasteSlider.value.rounded())
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
    
    
    // MARK: - MKMapViewDelegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        if (annotation.title == "New Fountain") {
            marker.markerTintColor = UIColor.red
        } else {
            marker.markerTintColor = UIColor(named: "PrimaryBlue")
        }
        return marker
    }
}
