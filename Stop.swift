//
//  Stop.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class Stop {
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var lat: String = ""
    dynamic var long: String = ""
    dynamic var distance: Int = 0
    var departures = [Departure]?()
    
//    dynamic init(id: String, name: String, lat: String, long: String, distance: Int, departures: [Departure]?) {
//        self.id = id
//        self.name = name
//        self.lat = lat
//        self.long = long
//        self.distance = distance
//        self.departures = departures
//        
//        super.init()
//    }
//    
//    required public init() {
//        fatalError("init() has not been implemented")
//    }
}