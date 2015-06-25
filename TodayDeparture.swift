//
//  TodayDeparture.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-06-24.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class TodayDeparture {
    public var sname: String
    public var direction: String
    public var fgColor: String
    public var bgColor: String
    public var rtTimes: [Int]
    
    public init(sname: String, direction: String, fgColor: String, bgColor: String, rtTimes:[Int]) {
        self.sname = sname
        self.direction = direction
        self.fgColor = fgColor
        self.bgColor = bgColor
        self.rtTimes = rtTimes
    }
}