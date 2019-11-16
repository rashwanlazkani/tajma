//
//  Line.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

open class Line: Codable {
    var id: String
    var stop = Stop()
    var stopId : String
    var lineAndDirection : String
    var name : String
    var sname : String
    var direction : String
    var type : String
    var track : String
    var bgColor : String
    var fgColor : String
    var departures = Departure()
    
    init(){
        self.id = ""
        self.stop = Stop()
        self.stopId = ""
        self.lineAndDirection = ""
        self.name = ""
        self.sname = ""
        self.direction = ""
        self.type = ""
        self.track = ""
        self.bgColor = ""
        self.fgColor = ""
        self.departures = Departure()
    }
    
    init(id: String, stop: Stop, stopId: String, lineAndDirection: String, name: String, sname: String, direction: String, type: String, track: String, bgColor: String, fgColor: String, departures: Departure){
        self.id = id
        self.stop = stop
        self.stopId = stopId
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
