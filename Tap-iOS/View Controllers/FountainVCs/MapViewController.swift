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
    @IBOutlet var toastView: UIVisualEffectView!
    @IBOutlet var toastLabel: UILabel!
    
    var panelController: FloatingPanelController!
    var supportingVC: FountainDetailViewController!
    
    // These track the overall area we have already fetched fountains for
    var minLat: Double = 1000.0
    var maxLat: Double = -1000.0
    var minLon: Double = 1000.0
    var maxLon: Double = -1000.0
    
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
        
        // Setup toast View
        self.toastView.layer.cornerRadius = 15.0
        self.toastView.clipsToBounds = true
        self.toastView.layer.opacity = 0
        
        panelController = FloatingPanelController()
        panelController.layout = PanelLayout()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 20
        appearance.backgroundColor = UIColor.clear
        panelController.surfaceView.appearance = appearance
        supportingVC = storyboard?.instantiateViewController(withIdentifier: "FountainDetailViewController") as? FountainDetailViewController
        supportingVC.referringVC = self
        supportingVC.fountainStore = self.fountainStore
        panelController.set(contentViewController: supportingVC)
        panelController.addPanel(toParent: self)
        panelController.move(to: .tip, animated: false)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.tintColor = UIColor(named: "PrimaryBlue")
        
        fountainStore.delegate = self
        
        // Configure Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "fountainPin")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fountainStore.updateFountains(around: mapView.region) {
            (error: Bool, message: String?) -> Void in
            
            if (error) {
                self.presentToast(saying: message!)
            }
        }
        fountainStore.filterFountains(by: .all)
    }
    
    /// Finds the distance between the selected fountain and user if available
    /// Rounds this distance to reasonable units and sets the value to the label distanceLabel
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
    
    /// Presents a toast message to the user displaying the string phrase
    /// - Parameter phrase: string to be put on the toast
    func presentToast(saying phrase: String) {
        self.toastLabel.text = phrase
        
        UIView.animate(withDuration: 0.2) {
            self.toastView.layer.opacity = 100.0
        } completion: { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: DispatchWorkItem(block: {
                UIView.animate(withDuration: 0.2) {
                    self.toastView.layer.opacity = 0.0
                }
            }))
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
        
        let region = mapView.region
        
        let currentMinLon = region.center.longitude - (region.span.longitudeDelta / 2.0)
        let currentMinLat = region.center.latitude + (region.span.latitudeDelta / 2.0)
        let currentMaxLon = region.center.longitude - (region.span.longitudeDelta / 2.0)
        let currentMaxLat = region.center.latitude + (region.span.latitudeDelta / 2.0)
        
        if (currentMinLon < minLon || currentMinLat < minLat || currentMaxLon > maxLon || currentMaxLat > maxLat) {
            // new data needed
            fountainStore.updateFountains(around: mapView.region) {
                (error: Bool, message: String?) -> Void in
                
                if (error) {
                    self.presentToast(saying: message!)
                }
            }
        }
        
        minLon = min(minLon, currentMinLon)
        minLat = min(minLat, currentMinLat)
        maxLon = max(maxLon, currentMaxLon)
        maxLat = max(maxLat, currentMaxLat)
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
        .full: FloatingPanelLayoutAnchor(absoluteInset: 70.0, edge: .top, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(absoluteInset: 200.0, edge: .bottom, referenceGuide: .safeArea),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
    ]
}
