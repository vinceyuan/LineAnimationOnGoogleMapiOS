//
//  ViewController.swift
//  LineAnimationOnGoogleMapiOS
//
//  Created by Vince Yuan on 1/13/17.
//
//

import UIKit
import GoogleMaps
import AFNetworking
import SwiftyJSON

class ViewController: UIViewController {

    let FPS = 20
    let TOTAL_SECONDS = 2

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
        let camera = GMSCameraPosition.camera(withLatitude: 1.2863672, longitude: 103.8543371, zoom: 14)
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

        // Creates a RouteGenerator
        routeGenerator = RouteGenerator(originalLocations: [markerStart.position, markerEnd.position], totalIntervals: TOTAL_SECONDS * FPS)

        getRoute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressButtonChange(_ sender: Any) {
        
        polyline.path = routeGenerator.nextRoute()
    }

    func getRoute() {
        let key = "your_key_here"
        var urlString = "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(markerStart.position.latitude),\(markerStart.position.longitude)&destination=\(markerEnd.position.latitude),\(markerEnd.position.longitude)&sensor=true&key=\(key)"
        urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!

        let manager = AFHTTPRequestOperationManager()

        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments) as AFJSONResponseSerializer

        manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer

        manager.responseSerializer.acceptableContentTypes = NSSet(objects:"application/json", "text/html", "text/plain", "text/json", "text/javascript", "audio/wav") as Set<NSObject>


        manager.post(urlString, parameters: nil, constructingBodyWith: { (formdata:AFMultipartFormData!) -> Void in

        }, success: {  operation, response -> Void in
            //{"responseString" : "Success","result" : {"userId" : "4"},"errorCode" : 1}
            //if(response != nil){
            let parsedData = JSON(response)
            //print_debug("parsedData : \(parsedData)")
            let path = GMSPath.init(fromEncodedPath: parsedData["routes"][0]["overview_polyline"]["points"].string!)
            self.polyline.path = path
            //GMSPath.fromEncodedPath(parsedData["routes"][0]["overview_polyline"]["points"].string!)
        }, failure: {  operation, error -> Void in

            //print_debug(error)
//            let errorDict = NSMutableDictionary()
//            errorDict.setObject(ErrorCodes.errorCodeFailed.rawValue, forKey: ServiceKeys.keyErrorCode.rawValue as NSCopying)
//            errorDict.setObject(ErrorMessages.errorTryAgain.rawValue, forKey: ServiceKeys.keyErrorMessage.rawValue as NSCopying)

        })
    }


    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.0/Double(FPS), repeats: true) { (timer: Timer) in
            self.polyline.path = self.routeGenerator.nextRoute()
        }
        
    }

}

