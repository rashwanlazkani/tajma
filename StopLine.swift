//
//  StopLines.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-03.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class StopLine {
    public var stopId: String
    public var stopName: String
    public var lat: String
    public var long: String
    public var sname: String
    public var tag: Int
    public var type: String
    public var track: String
    public var direction: String
    public var lineAndDirection: String
    public var isChecked: Bool
    
    public init(stopId: String, stopName: String, lat: String, long: String, sname: String, tag: Int, type: String, track: String, direction: String, lineAndDirection:String, isChecked: Bool) {
        self.stopId = stopId
        self.stopName = stopName
        self.lat = lat
        self.long = long
        self.sname = sname
        self.tag = tag
        self.type = type
        self.track = track
        self.direction = direction
        self.lineAndDirection = lineAndDirection
        self.isChecked = isChecked
    }
}