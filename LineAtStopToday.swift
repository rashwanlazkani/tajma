//
//  LineAtStopToday.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class LineAtStopToday: Object {
    dynamic var stopId: String = ""
    dynamic var track: String = ""
    dynamic var sname: String = ""
    dynamic var direction: String = ""
    
//    dynamic init(stopId: String, track:String, sname: String, direction: String) {
//        self.stopId = stopId
//        self.track = track
//        self.sname = sname
//        self.direction = direction
//        
//        super.init()
//    }
//    
//    required public init() {
//        fatalError("init() has not been implemented")
//    }
}