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

    init(originalLocations: [CLLocationCoordinate2D],
         totalIntervals: Int
        ) {
        self.originalLocations = originalLocations
        self.totalIntervals = totalIntervals
        route.add(originalLocations[0])
        route.add(originalLocations[0])
        currentIndex = -1
    }

    func nextRoute() -> GMSMutablePath {
        route.removeLastCoordinate()
        currentIndex += 1
        route.add(CLLocationCoordinate2D(
            latitude: originalLocations[0].latitude + (originalLocations[1].latitude - originalLocations[0].latitude) * Double(currentIndex) / Double(totalIntervals),
            longitude: originalLocations[0].longitude + (originalLocations[1].longitude - originalLocations[0].longitude) * Double(currentIndex) / Double(totalIntervals)))
        if (currentIndex == totalIntervals) {
            currentIndex = -1
        }
        return route
    }

}
