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
        self.timingFunction = timingFunction
    }

    func allTimingRoutes() -> [GMSPath] {
        var routes: [GMSPath] = []
        for i: Int in 0 ... totalTimingIntervals {
            routes.append(route(at: i))
        }
        return routes
    }

    func allTimingGradientSpansArray(startColor: UIColor, endColor: UIColor) -> [[GMSStyleSpan]] {
        var spansArray: [[GMSStyleSpan]] = []
        for i: Int in 0 ... totalTimingIntervals {
            let newColor = color(at: i, startColor: startColor, endColor: endColor)
            var spans:[GMSStyleSpan] = []
            spans.append(GMSStyleSpan(style: GMSStrokeStyle.gradient(from: startColor, to: newColor)))
            spansArray.append(spans)
        }
        return spansArray
    }

    // Get a route at timing index
    func route(at timingIndex: Int) -> GMSPath {
        let route = GMSMutablePath()
        let x = CGFloat(Double(timingIndex) / Double(totalTimingIntervals))
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

    func color(at timingIndex: Int, startColor: UIColor, endColor: UIColor) -> UIColor {
        let x = CGFloat(Double(timingIndex) / Double(totalTimingIntervals))
        let y = timingFunction.valueFor(x: x)

        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        let red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat
        red = startRed + (endRed - startRed) * y
        green = startGreen + (endGreen - startGreen) * y
        blue = startBlue + (endBlue - startBlue) * y
        alpha = startAlpha + (endAlpha - startAlpha) * y
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}
