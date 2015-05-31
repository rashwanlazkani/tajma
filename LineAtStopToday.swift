//
//  LineAtStopToday.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class LineAtStopToday {
    public var stopId: String
    public var track: String
    public var sname: String
    
    public init(stopId: String, track:String, sname: String) {
        self.stopId = stopId
        self.track = track
        self.sname = sname
    }
}