//
//  Line.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

class Line: Codable {
    var id: String = ""
    var stop = Stop()
    var stopid: String
    var lineAndDirection: String = ""
    var name: String
    var sname: String
    var direction: String
    var type: String
    var track: String
    var bgColor: String
    var fgColor: String
    var departures = Departure()
    
    private enum CodingKeys: String, CodingKey {
        case stopid, name, sname, direction, type, track, bgColor, fgColor
    }
    
    init() {
        self.stopid = ""
        self.name = ""
        self.sname = ""
        self.direction = ""
        self.type = ""
        self.track = ""
        self.bgColor = ""
        self.fgColor = ""
    }
    
    init(id: String, stop: Stop, stopId: String, lineAndDirection: String, name: String, sname: String, direction: String, type: String, track: String, bgColor: String, fgColor: String, departures: Departure){
        self.id = id
        self.stop = stop
        self.stopid = stopId
        self.lineAndDirection = lineAndDirection
        self.name = name
        self.sname = sname
        self.direction = direction
        self.type = type
        self.track = track
        self.bgColor = bgColor
        self.fgColor = fgColor
        self.departures = departures
    }
}
