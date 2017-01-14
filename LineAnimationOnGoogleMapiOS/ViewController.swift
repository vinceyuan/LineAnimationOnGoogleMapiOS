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

    var mapView: GMSMapView! = nil
    var markerStart = GMSMarker()
    var markerEnd = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewFrame = view.frame;
        let mapFrame = CGRect(x: 0, y: 44, width: viewFrame.size.width, height: viewFrame.size.width)

        // Create a GMSCameraPosition that tells the map to display coordinate.
        let camera = GMSCameraPosition.camera(withLatitude: 1.2863672, longitude: 103.8543371, zoom: 14.5)
        mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
        view.addSubview(mapView)

        // Creates markers.

        markerStart.position = CLLocationCoordinate2D(latitude: 1.278287, longitude: 103.845669)
        markerStart.icon = GMSMarker.markerImage(with: .blue)
        markerStart.map = mapView

        markerEnd.position = CLLocationCoordinate2D(latitude: 1.292747, longitude: 103.859696)
        markerEnd.icon = GMSMarker.markerImage(with: .green)
        markerEnd.map = mapView

        // Creates a polyline
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: 1.278287, longitude: 103.845669))
        path.add(CLLocationCoordinate2D(latitude: 1.292747, longitude: 103.859696))
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

