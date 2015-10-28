//
//  TestLabel.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-23.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class TodayLabel {
    dynamic var stopName: String = ""
    dynamic var distance: Int = 0
    dynamic var sname: String = ""
    dynamic var direction: String = ""
    dynamic var snameAndDirection: String = ""
    dynamic var fgColor: String = ""
    dynamic var bgColor: String = ""
    dynamic var rtTimes = [Int]()
    public var row: Row = Row.Empty
    
//    init(stopName : String, distance: Int, sname: String, direction: String, snameAndDirection: String, fgColor: String, bgColor: String, rtTimes: [Int], row: Row) {
//        self.stopName = stopName
//        self.distance = distance
//        self.sname = sname
//        self.direction = direction
//        self.snameAndDirection = snameAndDirection
//        self.fgColor = fgColor
//        self.bgColor = bgColor
//        self.rtTimes = rtTimes
//        self.row = row
//        
//        super.init()
//    }
//    
//    required public init() {
//        fatalError("init() has not been implemented")
//    }
}