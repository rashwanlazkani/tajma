//
//  LocationHelper.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-08-30.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import CoreLocation

 class LocationHelper {
    
    func CalculateDistance(l1 : Double, l2 : Double, l3 : Double, l4 : Double ) -> Int{
        let userLocation = CLLocation(latitude: l1, longitude: l2)
        let stopLocation = CLLocation(latitude: l3, longitude: l4)
        let distance = userLocation.distanceFromLocation(stopLocation)
        
        return r(distance)
    }
    
    private func r(x : Double) -> Int {
        return 5 * Int(round(x / 5.0))
    }
}