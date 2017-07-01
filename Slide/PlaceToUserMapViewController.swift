//
//  PlaceToUserMapViewController.swift
//  Slide
//
//  Created by bibek timalsina on 4/13/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceToUserMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    
    var place: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }
    
    private func configureMapView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        
        if let name = self.place?.nameAddress {
            self.placeNameLabel.text = name
        }
        if let userLocation = SlydeLocationManager.shared.getLocation() {
            let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 6.0)
            self.mapView.camera = camera
            //        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            //        view = mapView
        }
        
        if let lat = place?.lat, let long = place?.long {
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            marker.title = place?.nameAddress ?? ""
            //marker.snippet = "Australia"
            marker.map = mapView
        }
        
        self.mapView.isMyLocationEnabled = true 
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var back: UIButton!}
