//
//  TodayStop.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-06-24.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class TodayStop {
    public var id : String
    public var name: String
    public var distance: Int
    public var departures: [TodayDeparture]?
    
    public init(id: String, name: String, distance: Int, departures: [TodayDeparture]?) {
        self.id = id
        self.name = name
        self.distance = distance
        self.departures = departures
        
    }
}