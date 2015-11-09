//
//  Line.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import RealmSwift

public class Line: Object {
    var stop = Stop?()
    var lineAndDirection = ""
    var name = ""
    var sname = ""
    var direction = ""
    var type = ""
    var track = ""
    var fgColor = ""
    var bgColor = ""
    var departures = Departure()
    
    override public static func primaryKey() -> String? {
        return "lineAndDirection"
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["departures"]
    }
}