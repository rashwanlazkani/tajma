//
//  DepartureTimes.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class Departure {
    dynamic var stopId: String = ""
    dynamic var sname: String = ""
    dynamic var track: String = ""
    dynamic var direction: String = ""
    dynamic var fgColor: String = ""
    dynamic var bgColor: String = ""
    dynamic var rtTimes = [Int]()
    
//    dynamic init(stopId: String, sname: String, track: String, direction: String, fgColor: String, bgColor: String, rtTimes:[Int]) {
//        self.stopId = stopId
//        self.sname = sname
//        self.track = track
//        self.direction = direction
//        self.fgColor = fgColor
//        self.bgColor = bgColor
//        self.rtTimes = rtTimes
//        
//        super.init()
//    }
//    
//    required public init() {
//        fatalError("init() has not been implemented")
//    }
}
