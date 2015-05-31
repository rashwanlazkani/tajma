//
//  LinesAtStopToday.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-09.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class LinesAtStop{
    public var stopId: String
    public var lineAndDirection: String
    public var departure: String
    
    public init(stopId: String, lineAndDirection:String, departure: String) {
        self.stopId = stopId
        self.lineAndDirection = lineAndDirection
        self.departure = departure
    }
}