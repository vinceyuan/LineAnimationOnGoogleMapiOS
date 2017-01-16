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

let ROUNDING: Double = 0.01

class RouteGenerator {
    var totalDistance: CLLocationDistance
    var originalLocations: [CLLocationCoordinate2D]     // N
    var distances: [CLLocationDistance] = []            // N - 1
    var cumulativeDistances: [CLLocationDistance] = []  // N
    var totalTimingIntervals: Int

    var currentTimingIndex: Int
    var route: GMSMutablePath = GMSMutablePath()

    var timingFunction: RSTimingFunction! = nil

    init(originalPath: GMSPath,
         totalTimingIntervals: Int,
         timingFunction: RSTimingFunction
        ) {
        var locations: [CLLocationCoordinate2D] = []
        totalDistance = 0
        for i: UInt in 0 ..< originalPath.count() {
            locations.append(originalPath.coordinate(at: i))
            if (i != 0) {
                let distance = GMSGeometryDistance(locations[Int(i)-1], locations[Int(i)])
                distances.append(distance)
                totalDistance += distance
                cumulativeDistances.append(totalDistance)
            } else {
                cumulativeDistances.append(0.0)
            }
        }
        GMSGeometryLength(originalPath)
        self.originalLocations = locations
        self.totalTimingIntervals = totalTimingIntervals
        currentTimingIndex = -1
        self.timingFunction = timingFunction
    }

    func nextRoute() -> GMSMutablePath {
        route.removeAllCoordinates()
        currentTimingIndex += 1
        let x = CGFloat(Double(currentTimingIndex) / Double(totalTimingIntervals))
        let y = Double(timingFunction.valueFor(x: x))
        let distance = totalDistance * y

        let (index, matched) = getIndex(distance: distance)
        for i: Int in 0 ... index {
            route.add(originalLocations[i])
        }

        if !matched {
            let fraction = (distance - cumulativeDistances[index])/distances[index]
            let newLocation = GMSGeometryInterpolate(originalLocations[index], originalLocations[index + 1], fraction)
            route.add(newLocation)
        }

        if (currentTimingIndex == totalTimingIntervals) {
            currentTimingIndex = -1
        }

        //print(currentTimingIndex, distance, index, matched)

        return route
    }

    // Get index of location which matches the distance.
    // Return the index and whether it is exactly the point. (False means we need to calculate)
    func getIndex(distance: Double) -> (Int, Bool) {
        for (index, cumulativeDistance) in cumulativeDistances.enumerated() {
            if abs(distance - cumulativeDistance) <= ROUNDING {
                return (index, true)
            } else if cumulativeDistance > distance {
                return (index - 1, false)
            }
        }
        return (cumulativeDistances.count - 1, true)
    }

}
