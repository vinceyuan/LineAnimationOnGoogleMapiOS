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

    let FPS = 24
    let TOTAL_SECONDS = 4

    var mapView: GMSMapView! = nil
    var markerStart = GMSMarker()
    var markerEnd = GMSMarker()
    var polyline = GMSPolyline(path: GMSMutablePath())

    var positionStart = CLLocationCoordinate2D(latitude: 1.277287, longitude: 103.845669)
    var positionEnd = CLLocationCoordinate2D(latitude: 1.292747, longitude: 103.859696)

    var routeGenerator: RouteGenerator! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewFrame = view.frame;
        let mapFrame = CGRect(x: 0, y: 44, width: viewFrame.size.width, height: viewFrame.size.width)

        // Create a GMSCameraPosition that tells the map to display coordinate.
        let camera = GMSCameraPosition.camera(withLatitude: 1.2863672, longitude: 103.8543371, zoom: 14.5)
        mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
        view.addSubview(mapView)

        // Creates markers.
        markerStart.position = positionStart
        markerStart.icon = GMSMarker.markerImage(with: .blue)
        markerStart.map = mapView

        markerEnd.position = positionEnd
        markerEnd.icon = GMSMarker.markerImage(with: .green)
        markerEnd.map = mapView

        // Creates a polyline
        let path = GMSMutablePath()
        path.add(positionStart)
        path.add(positionEnd)
        polyline.path = path
        polyline.map = mapView

        routeGenerator = RouteGenerator(originalLocations: [markerStart.position, markerEnd.position], totalIntervals: TOTAL_SECONDS * FPS)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressButtonChange(_ sender: Any) {
        
        polyline.path = routeGenerator.nextRoute()
    }


    func startAnimation() {
        
    }

}

