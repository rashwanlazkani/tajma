//
//  RealmLine.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-10-18.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmObject: Object {
    dynamic var name: String = ""
    dynamic var stopId: String = ""
    dynamic var stopName: String = ""
    dynamic var lat: String = ""
    dynamic var long: String = ""
    dynamic var sname: String = ""
    dynamic var direction: String = ""
    dynamic var type: String = ""
    dynamic var track: String = ""
    dynamic var tag: Int = 0
    dynamic var isChecked: Bool = false
    dynamic var fgColor: String = ""
    dynamic var bgColor: String = ""
    dynamic var lineAndDirection: String = ""
    
    //    dynamic init(name : String, sname: String, direction: String, type: String, track: String, fgColor: String, bgColor: String, lineAndDirection: String) {
    //        self.name = name
    //        self.sname = sname
    //        self.direction = direction
    //        self.type = type
    //        self.track = track
    //        self.fgColor = fgColor
    //        self.bgColor = bgColor
    //        self.lineAndDirection = lineAndDirection
    //
    //        super.init()
    //    }
    //
    //    required public init() {
    //        fatalError("init() has not been implemented")
    //    }
}