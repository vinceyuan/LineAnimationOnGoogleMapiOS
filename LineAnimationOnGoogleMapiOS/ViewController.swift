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

let FPS = 20
let TOTAL_SECONDS = 2

class ViewController: UIViewController {

    var mapView: GMSMapView! = nil
    var markerStart = GMSMarker()
    var markerEnd = GMSMarker()
    var polylineLower = GMSPolyline(path: GMSPath())
    var polylineUpper = GMSPolyline(path: GMSPath())

    var positionStart = CLLocationCoordinate2D(latitude: 1.277287, longitude: 103.845669)
    var positionEnd = CLLocationCoordinate2D(latitude: 1.292747, longitude: 103.859696)

    var routeGenerator: RouteGenerator! = nil
    var totalTimingIntervals: Int = TOTAL_SECONDS * FPS
    var allTimingRoutes: [GMSPath] = []

    var currentTimingIndexLower: Int = 0
    var timerLower: Timer! = nil

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

        // Creates two polylines
//        let gradient = GMSStrokeStyle.gradient(from: .green, to: .black)
//        polyline.spans = [GMSStyleSpan(style: gradient)]
        polylineLower.strokeColor = .black
        polylineLower.strokeWidth = 2
        polylineLower.map = mapView


        getRoute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressButtonChange(_ sender: Any) {
        
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
            let path = GMSPath.init(fromEncodedPath: parsedData["routes"][0]["overview_polyline"]["points"].string!)

            // Creates a RouteGenerator
            self.routeGenerator = RouteGenerator(
                originalPath: path!,
                totalTimingIntervals: self.totalTimingIntervals,
                timingFunction: RSTimingFunction.init(controlPoint1: CGPoint(x: 0.6, y: 0), controlPoint2: CGPoint(x: 0.4, y: 1.0)))

            // Gets and caches all timing routes.
            // (But the bottle neck is not at computing. It's in google maps rendering.)
            self.allTimingRoutes = self.routeGenerator.allTimingRoutes()

            self.startAnimation()

        }, failure: {  operation, error -> Void in

            //print_debug(error)
//            let errorDict = NSMutableDictionary()
//            errorDict.setObject(ErrorCodes.errorCodeFailed.rawValue, forKey: ServiceKeys.keyErrorCode.rawValue as NSCopying)
//            errorDict.setObject(ErrorMessages.errorTryAgain.rawValue, forKey: ServiceKeys.keyErrorMessage.rawValue as NSCopying)

        })
    }


    func startAnimation() {
        currentTimingIndexLower = 0
        timerLower = Timer.scheduledTimer(withTimeInterval: 1.0/Double(FPS), repeats: true) { (timer: Timer) in
            self.polylineLower.path = self.allTimingRoutes[self.currentTimingIndexLower]
            if self.currentTimingIndexLower == self.totalTimingIntervals {
                self.timerLower.invalidate()
            } else {
                self.currentTimingIndexLower = (self.currentTimingIndexLower + 1) % (self.totalTimingIntervals + 1)
            }
        }
        
    }

}

