//
//  RouteGenerator.swift
//  LineAnimationOnGoogleMapiOS
//
//  Created by Vince Yuan on 1/15/17.
//
//

import Foundation
import CoreLocation
import GoogleMaps

class RouteGenerator {
    var originalLocations: [CLLocationCoordinate2D]
    var totalIntervals: Int

    var currentIndex: Int
    var route: GMSMutablePath = GMSMutablePath()

    var timingFunction: RSTimingFunction! = nil

    init(originalLocations: [CLLocationCoordinate2D],
         totalIntervals: Int
        ) {
        self.originalLocations = originalLocations
        self.totalIntervals = totalIntervals
        route.add(originalLocations[0])
        route.add(originalLocations[0])
        currentIndex = -1
        //timingFunction = RSTimingFunction.init(name: kRSTimingFunctionEaseInEaseOut)
        timingFunction = RSTimingFunction.init(controlPoint1: CGPoint(x: 0.5, y: 0), controlPoint2: CGPoint(x: 0.5, y: 1.0))
    }

    func nextRoute() -> GMSMutablePath {
        route.removeLastCoordinate()
        currentIndex += 1
        let x = CGFloat(Double(currentIndex) / Double(totalIntervals))
        let y = Double(timingFunction.valueFor(x: x))
        route.add(CLLocationCoordinate2D(
            latitude: originalLocations[0].latitude + (originalLocations[1].latitude - originalLocations[0].latitude) * y,
            longitude: originalLocations[0].longitude + (originalLocations[1].longitude - originalLocations[0].longitude) * y))
        if (currentIndex == totalIntervals) {
            currentIndex = -1
        }
        return route
    }

}
