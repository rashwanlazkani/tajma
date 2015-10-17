//
//  Line.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-02.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class Line: Object {
    dynamic var name: String = ""
    dynamic var sname: String = ""
    dynamic var direction: String = ""
    dynamic var type: String = ""
    dynamic var track: String = ""
    dynamic var fgColor: String = ""
    dynamic var bgColor: String = ""
    dynamic var lineAndDirection: String = ""
    
    dynamic init(name : String, sname: String, direction: String, type: String, track: String, fgColor: String, bgColor: String, lineAndDirection: String) {
        self.name = name
        self.sname = sname
        self.direction = direction
        self.type = type
        self.track = track
        self.fgColor = fgColor
        self.bgColor = bgColor
        self.lineAndDirection = lineAndDirection
        
        super.init()
    }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
}