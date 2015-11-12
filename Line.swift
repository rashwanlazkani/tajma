//
//  Line.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import RealmSwift

public class Line: Object {
    dynamic var stop = Stop?()
    dynamic var lineAndDirection = ""
    dynamic var name = ""
    dynamic var sname = ""
    dynamic var direction = ""
    dynamic var type = ""
    dynamic var track = ""
    dynamic var bgColor = ""
    dynamic var fgColor = ""
    var departures = Departure()
    
    override public static func primaryKey() -> String? {
        return "lineAndDirection"
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["departures"]
    }
}