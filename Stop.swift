//
//  Stop.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class Stop {
    public var id: String
    public var name: String
    public var lat: String
    public var long: String
    public var distance: Int
    public var departures: [Departure]?
    
    public init(id: String, name: String, lat: String, long: String, distance: Int, departures: [Departure]?) {
        self.id = id
        self.name = name
        self.lat = lat
        self.long = long
        self.distance = distance
        self.departures = departures
    }
}