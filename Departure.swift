//
//  DepartureTimes.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class Departure {
    public var stopId: String
    public var sname: String
    public var track: String
    public var direction: String
    public var fgColor: String
    public var bgColor: String
    public var rtTimes: [Int]
    
    public init(stopId: String, sname: String, track: String, direction: String, fgColor: String, bgColor: String, rtTimes:[Int]) {
        self.stopId = stopId
        self.sname = sname
        self.track = track
        self.direction = direction
        self.fgColor = fgColor
        self.bgColor = bgColor
        self.rtTimes = rtTimes
    }
}
