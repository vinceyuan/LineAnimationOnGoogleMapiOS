//
//  ViewController.swift
//  LineAnimationOnGoogleMapiOS
//
//  Created by Vince Yuan on 1/13/17.
//
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView

        // Creates a polyline
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: -33.85, longitude: 151.20))
        path.add(CLLocationCoordinate2D(latitude: -33.70, longitude: 151.40))
        path.add(CLLocationCoordinate2D(latitude: -33.73, longitude: 151.41))
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView
    }
}

