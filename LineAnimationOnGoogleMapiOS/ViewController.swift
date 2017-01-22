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

#if (arch(i386) || arch(x86_64)) && os(iOS)
let FPS = 20
#else
let FPS = 40
#endif

let TOTAL_SECONDS = 2
let FADING_FRAMES = 14

enum ColorMode: Int {
    case solid = 0, gradient1, gradient2
}

class ViewController: UIViewController, GMSMapViewDelegate  {

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
    var allTimingGradientSpansArray: [[GMSStyleSpan]] = []

    var currentTimingIndexLower: Int = 0
    var timerLower: Timer! = nil
    var currentTimingIndexUpper: Int = 0
    var timerUpper: Timer! = nil

    var colorMode: ColorMode = .solid

    @IBOutlet weak var segmentedControlColor: UISegmentedControl!

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
        markerStart.isDraggable = true

        markerEnd.position = positionEnd
        markerEnd.icon = GMSMarker.markerImage(with: .green)
        markerEnd.map = mapView
        markerEnd.isDraggable = true

        mapView.delegate = self

        createPolylinesAndGetRoute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func stopAnimation() {
        timerUpper.invalidate()
        timerLower.invalidate()
    }

    func removePolylinesFromMap() {
        polylineUpper.path = nil
        polylineLower.path = nil
        polylineUpper.spans = nil
        polylineUpper.map = nil
        polylineLower.map = nil
    }

    func createPolylinesAndGetRoute() {
        // Creates two polylines
        switch colorMode {
        case .solid:
            polylineLower.strokeColor = .black
            polylineUpper.strokeColor = UIColor(red: 91.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 91.0/255.0)
        case .gradient1:
            polylineLower.strokeColor = .lightGray
            let gradient = GMSStrokeStyle.gradient(from: .green, to: .black)
            polylineUpper.spans = [GMSStyleSpan(style: gradient)]
        case .gradient2:
            polylineLower.strokeColor = .lightGray
        }
        polylineLower.strokeWidth = 3
        polylineLower.map = mapView

        polylineUpper.strokeWidth = 3
        polylineUpper.map = mapView
        
        getRoute()

    }

    func restart() {
        stopAnimation()
        removePolylinesFromMap()
        createPolylinesAndGetRoute()
    }

    @IBAction func didPressButtonRestart(_ sender: Any) {
        restart()
    }

    @IBAction func didChangeSegmentedControlColor(_ sender: Any) {
        stopAnimation()
        removePolylinesFromMap()
        colorMode = ColorMode(rawValue: segmentedControlColor.selectedSegmentIndex)!
        createPolylinesAndGetRoute()
    }


    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if (marker == markerStart) {
            positionStart = marker.position
        } else {
            positionEnd = marker.position
        }
        restart()
    }

    func getRoute() {
        let key = (UIApplication.shared.delegate as! AppDelegate).googleMapsAPIKey
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
                timingFunction: RSTimingFunction.init(controlPoint1: CGPoint(x: 0.7, y: 0), controlPoint2: CGPoint(x: 0.3, y: 1.0)))

            // Gets and caches all timing routes.
            // (But the bottle neck is not at computing. It's in google maps rendering.)
            self.allTimingRoutes = self.routeGenerator.allTimingRoutes()
            self.allTimingGradientSpansArray = self.routeGenerator.allTimingGradientSpansArray(startColor: .green, endColor: .black)

            self.startAnimation()

        }, failure: {  operation, error -> Void in

            //print_debug(error)
//            let errorDict = NSMutableDictionary()
//            errorDict.setObject(ErrorCodes.errorCodeFailed.rawValue, forKey: ServiceKeys.keyErrorCode.rawValue as NSCopying)
//            errorDict.setObject(ErrorMessages.errorTryAgain.rawValue, forKey: ServiceKeys.keyErrorMessage.rawValue as NSCopying)

        })
    }

    func startAnimation() {
        startLowerRouteAnimation()
    }

    func startLowerRouteAnimation() {
        currentTimingIndexLower = 0
        timerLower = Timer.scheduledTimer(withTimeInterval: 1.0/Double(FPS), repeats: true) { (timer: Timer) in
            self.polylineLower.path = self.allTimingRoutes[self.currentTimingIndexLower]
            if self.currentTimingIndexLower == self.totalTimingIntervals {
                self.timerLower.invalidate()
                self.startUpperRouteAnimation()
            } else {
                self.currentTimingIndexLower = (self.currentTimingIndexLower + 1) % (self.totalTimingIntervals + 1)
            }
        }
    }

    func startUpperRouteAnimation() {
        currentTimingIndexUpper = 0
        timerUpper = Timer.scheduledTimer(withTimeInterval: 1.0/Double(FPS), repeats: true) { (timer: Timer) in
            self.polylineUpper.path = self.allTimingRoutes[self.currentTimingIndexUpper]

            if self.colorMode == .solid {
                if self.currentTimingIndexUpper == 0 {
                    // Reset line alpha
                    self.polylineUpper.strokeColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
                } else if self.currentTimingIndexUpper >= self.totalTimingIntervals - FADING_FRAMES {
                    // Change line alpha when the line is ending.
                    self.polylineUpper.strokeColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: CGFloat(1.0 * Double(self.totalTimingIntervals - self.currentTimingIndexUpper) / Double(FADING_FRAMES)))
                }
            } else if self.colorMode == .gradient2 {
                self.polylineUpper.spans = self.allTimingGradientSpansArray[self.currentTimingIndexUpper]
            }

            self.currentTimingIndexUpper = (self.currentTimingIndexUpper + 1) % (self.totalTimingIntervals + 1)

        }
    }

}

