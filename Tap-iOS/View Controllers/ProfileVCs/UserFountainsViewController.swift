//
//  UserFountainsViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/29/24.
//

import Foundation
import UIKit
import MapKit

class UserFountainsViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    var user: TapUser!
    var fountains = [Fountain]()
    var fountainAnnotations = [FountainAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegates and such
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.mapView.delegate = self
        
        titleLabel.text = "\(user.username)'s fountains:"
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "fountainPin")
        
        // Call API for user's fountains
        FountainStore.getFountainsBy(user: user.username) { fountains in
            self.fountains = fountains
            self.addFountainsToMap()
            self.centerMapView()
            // sort fountains by rating
            self.fountains.sort { lhs, rhs in
                return lhs.getAvgRating() > rhs.getAvgRating()
            }
            // Add fountains to tableView
            self.tableView.reloadData()
        }

    }
    
    private func centerMapView() {
        if fountains.count == 0 {
            return
        }
        let first = fountains[0].getLocationCoordinate()
        var minLat = first.latitude
        var minLon = first.longitude
        var maxLat = first.latitude
        var maxLon = first.longitude
        
        for fountain in fountains {
            let coord = fountain.getLocationCoordinate()
            minLat = Double.minimum(minLat, coord.latitude)
            minLon = Double.minimum(minLon, coord.longitude)
            maxLat = Double.maximum(maxLat, coord.latitude)
            maxLon = Double.maximum(maxLon, coord.longitude)
        }
        
        let originLat = (minLat + maxLat) / 2.0
        let originLon = (minLon + maxLon) / 2.0
        
        let latSpan = abs(maxLat.distance(to: minLat) * 1.25)
        let lonSpan = abs(maxLon.distance(to: minLon) * 1.15)
        
        let span = MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: lonSpan)
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: originLat, longitude: originLon), span: span)
        
        self.mapView.setRegion(region, animated: true)
        
        let rect = MKMapRectForCoordinateRegion(region: region)
        
        let offset = self.tableView.frame.height
        
        self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 0.0, left: 0.0, bottom: offset, right: 0.0), animated: true)
    }
    
    private func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
    private func addFountainsToMap() {
        for fountain in fountains {
            let marker = FountainAnnotation()
            marker.fountainID = fountain.id
            marker.coordinate = fountain.getLocationCoordinate()
            fountainAnnotations.append(marker)
            mapView.addAnnotation(marker)
        }
    }
    
    private func selectMapAnnotation(to annot: FountainAnnotation) {
        let coord = annot.coordinate
        
        // offset coord to fit on screen correctly
        let offset = self.tableView.frame.height / 2
        let mapPoint = mapView.convert(coord, toPointTo: self.mapView)
        let offsetPoint = CGPoint(x: mapPoint.x, y: mapPoint.y+offset)
        let newCoord = mapView.convert(offsetPoint, toCoordinateFrom: self.mapView)
        
        let camera = MKMapCamera(lookingAtCenter: newCoord, fromDistance: mapView.camera.centerCoordinateDistance, pitch: mapView.camera.pitch, heading: mapView.camera.heading)
        self.mapView.setCamera(camera, animated: true)
    }
}

extension UserFountainsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if (annotation.title == "My Location") {
            return MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
        }
        let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "fountainPin", for: annotation) as! MKMarkerAnnotationView
        marker.markerTintColor = UIColor(named: "PrimaryBlue")
        marker.glyphImage = UIImage(systemName: "spigot")
        return marker
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annot = view.annotation as! FountainAnnotation
        let fountainID = annot.fountainID
        
        var index = 0
        for fountain in fountains {
            if fountain.id == fountainID {
                break
            }
            index += 1
        }
        
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let annot = view.annotation as! FountainAnnotation
        let fountainID = annot.fountainID
        
        var index = 0
        for fountain in fountains {
            if fountain.id == fountainID {
                break
            }
            index += 1
        }
        tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
    }
}

extension UserFountainsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fountains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fountain = fountains[indexPath.row]
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserFountainViewCell", for: indexPath) as! UserFountainViewCell
        cell.typeLabel.text = "\(fountain.getFountainType())"
        cell.ratingLabel.text = "\(nf.string(from: fountain.getAvgRating() as NSNumber) ?? "0")"
        cell.fountainID = fountain.id
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        let index = indexPath.row
        
        let fountain = fountains[index]
        for annot in self.fountainAnnotations {
            print(annot.fountainID, fountain.id)
            if annot.fountainID == fountain.id {
                print("found a match")
                self.mapView.selectAnnotation(annot, animated: true)
                self.selectMapAnnotation(to: annot)
                break
            }
        }
    }
}
