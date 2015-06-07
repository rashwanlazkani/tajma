//
//  TestLabel.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-23.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class TodayLabel {
    public var stopName: String
    public var distance: Int
    public var sname: String
    public var direction: String
    public var fgColor: String
    public var bgColor: String
    public var rtTimes: [Int]
    public var isStop: Bool
    
    public init(stopName : String, distance: Int, sname: String, direction: String, fgColor: String, bgColor: String, rtTimes: [Int], isStop: Bool) {
        self.stopName = stopName
        self.distance = distance
        self.sname = sname
        self.direction = direction
        self.fgColor = fgColor
        self.bgColor = bgColor
        self.rtTimes = rtTimes
        self.isStop = isStop
    }
}