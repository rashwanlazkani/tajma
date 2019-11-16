//
//  Distance.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2019-11-16.
//  Copyright © 2019 Rashwan Lazkani. All rights reserved.
//

import MapKit

struct DistanceHelper {
    static func calculate(_ stop: Stop, lat: Double, long: Double) -> Int {
        let userLocation = CLLocation(latitude: lat, longitude: long)
        let stopLocation = CLLocation(latitude: (stop.lat as NSString).doubleValue, longitude: (stop.lon as NSString).doubleValue)
        let distance = userLocation.distance(from: stopLocation)
        
        return roundToFive(distance)
    }
    
    fileprivate static func roundToFive(_ value : Double) -> Int {
        return 5 * Int(round(value / 5.0))
    }
}
