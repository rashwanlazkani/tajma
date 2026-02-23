//
//  Line.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

class Line: Codable, Identifiable {
    public var id: String = ""
    var stop = Stop()
    var stopid: String
    var lineAndDirection: String = ""
    let name: String
    let sname: String
    let direction: String
    let type: String
    let track: String
    let bgColor: String
    let fgColor: String
    let rtTime: String?
    let time: String
    let rtDate: String?
    let date: String
    var departures = [Int]()
    
    private enum CodingKeys: String, CodingKey {
        case stopid, name, sname, direction, type, track, bgColor, fgColor, rtDate, date, rtTime, time
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
        self.rtTime = ""
        self.time = ""
        self.rtDate = ""
        self.date = ""
    }
    
    init(id: String, stop: Stop, stopId: String, lineAndDirection: String, name: String, sname: String, direction: String, type: String, track: String, bgColor: String, fgColor: String, departures: [Int], rtDate: String = "", date: String = "", rtTime: String = "", time: String = "") {
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
        self.rtTime = rtTime
        self.time = time
        self.rtDate = rtDate
        self.date = date
    }
}
