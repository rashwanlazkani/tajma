//
//  Line.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class Line {
    public var name: String
    public var sname: String
    public var direction: String
    public var type: String
    public var track: String
    public var lineAndDirection: String
    
    public init(name : String, sname: String, direction: String, type: String, track: String, lineAndDirection: String) {
        self.name = name
        self.sname = sname
        self.direction = direction
        self.type = type
        self.track = track
        self.lineAndDirection = lineAndDirection
    }
}