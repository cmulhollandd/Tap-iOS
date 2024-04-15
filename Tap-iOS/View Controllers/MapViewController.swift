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
import FloatingPanel

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var panelController: FloatingPanelController!
    var supportingVC: FountainDetailViewController!
    
    private var locationManager: CLLocationManager!
    var fountainStore: FountainStore = (UIApplication.shared.delegate as! AppDelegate).fountainStore
    private var focusedFountain: Fountain? = nil
    private var myAnnotations =  [MKPointAnnotation]()
    private let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        return nf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panelController = FloatingPanelController()
        panelController.layout = PanelLayout()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 20
        appearance.backgroundColor = UIColor.clear
        panelController.surfaceView.appearance = appearance
        supportingVC = storyboard?.instantiateViewController(withIdentifier: "FountainDetailViewController") as? FountainDetailViewController
        supportingVC.referringVC = self
        panelController.set(contentViewController: supportingVC)
        panelController.addPanel(toParent: self)
        panelController.move(to: .tip, animated: false)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
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
    
    func setFountainDistance() {
        guard let fountain = self.focusedFountain else {
            self.supportingVC.distanceLabel.text = ""
            return
        }
        
        if let location = locationManager.location {
            var dist = location.distance(from: fountain.getLocation()) * 3.28084
            if dist > 528 {
                dist /= 5280 // Convert to miles if far enough
                self.supportingVC.distanceLabel.text = "\(nf.string(from: dist as NSNumber)!) mi away"
            } else {
                let nf = NumberFormatter()
                nf.maximumFractionDigits = 0
                self.supportingVC.distanceLabel.text = "\(nf.string(from: dist as NSNumber)!) feet away"
            }
        }
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
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [any MKAnnotation]) -> MKClusterAnnotation {
        let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
        return cluster
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
        self.supportingVC.setFountain(to: self.focusedFountain)
        self.setFountainDistance()
        self.panelController.move(to: .half, animated: true)
    
        let offset = self.mapView.frame.maxY - self.panelController.surfaceLocation(for: .tip).y
        let locPoint = mapView.convert(location, toPointTo: self.mapView)
        let offsetPoint = CGPoint(x: locPoint.x, y: locPoint.y+offset)
        let offsetCoord = mapView.convert(offsetPoint, toCoordinateFrom: self.mapView)
        
        let camera = MKMapCamera(lookingAtCenter: offsetCoord, fromDistance: mapView.camera.altitude, pitch: mapView.camera.pitch, heading: mapView.camera.heading)
        mapView.setCamera(camera, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.focusedFountain = nil
        
        // Remove details and animate dismissal
        self.supportingVC.setFountain(to: nil)
        self.setFountainDistance()
        self.panelController.move(to: .tip, animated: true)
    }
}

extension MapViewController: FountainStoreDelegate {
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains fountains: [Fountain]) {
        if (myAnnotations.count == 0) {
            for fountain in fountains {
                let annot = MKPointAnnotation()
                annot.coordinate = fountain.getLocationCoordinate()
                myAnnotations.append(annot)
                mapView.addAnnotation(annot)
            }
            return
        }
        
        
        var newAnnotations = [MKPointAnnotation]()
        var updatedAnnotations = myAnnotations
        for fountain in fountains {
            let annotation = MKPointAnnotation()
            annotation.coordinate = fountain.getLocationCoordinate()
            newAnnotations.append(annotation)
        }
        // Find new annotations that should be added
        var adding = [MKPointAnnotation]()
        for newAnnot in newAnnotations {
            var contained = false
            for existing in myAnnotations {
                if (newAnnot.coordinate.latitude == existing.coordinate.latitude && newAnnot.coordinate.longitude == existing.coordinate.longitude) {
                    contained = true
                    break
                }
            }
            if contained {
                continue;
            } else {
                adding.append(newAnnot)
                updatedAnnotations.append(newAnnot)
            }
        }
        // Find old annotations that should be removed
        var removing = [MKPointAnnotation]()
        for existing in myAnnotations {
            var contained = false
            for newAnnot in newAnnotations {
                if (newAnnot.coordinate.latitude == existing.coordinate.latitude && newAnnot.coordinate.longitude == existing.coordinate.longitude) {
                    contained = true
                    break
                }
            }
            if contained {
                continue;
            } else {
                removing.append(existing)
                updatedAnnotations.remove(at: updatedAnnotations.firstIndex(of: existing)!)
            }
        }
        
        self.mapView.addAnnotations(adding)
        self.mapView.removeAnnotations(removing)
        self.myAnnotations = updatedAnnotations
    }
}

private class PanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 100.0, edge: .top, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(absoluteInset: 260.0, edge: .bottom, referenceGuide: .safeArea),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
    ]
}
