//
//  StopLines.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-03.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class StopLine: Object {
    dynamic var stopId: String = ""
    dynamic var stopName: String = ""
    dynamic var lat: String = ""
    dynamic var long: String = ""
    dynamic var sname: String = ""
    dynamic var tag: Int = 0
    dynamic var type: String = ""
    dynamic var track: String = ""
    dynamic var direction: String = ""
    dynamic var lineAndDirection: String = ""
    dynamic var isChecked: Bool = false
    
//    dynamic init(stopId: String, stopName: String, lat: String, long: String, sname: String, tag: Int, type: String, track: String, direction: String, lineAndDirection:String, isChecked: Bool) {
//        self.stopId = stopId
//        self.stopName = stopName
//        self.lat = lat
//        self.long = long
//        self.sname = sname
//        self.tag = tag
//        self.type = type
//        self.track = track
//        self.direction = direction
//        self.lineAndDirection = lineAndDirection
//        self.isChecked = isChecked
//        
//        super.init()
//    }
//    
//    required public init() {
//        fatalError("init() has not been implemented")
//    }
}