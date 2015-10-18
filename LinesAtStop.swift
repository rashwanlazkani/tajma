//
//  LinesAtStopToday.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-09.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import RealmSwift

public class LinesAtStop: Object{
    dynamic var stopId: String = ""
    dynamic var lineAndDirection: String = ""
    dynamic var departure: String = ""
    
//    dynamic init(stopId: String, lineAndDirection:String, departure: String) {
//        self.stopId = stopId
//        self.lineAndDirection = lineAndDirection
//        self.departure = departure
//        
//        super.init()
//    }
//    
//    required public init() {
//        fatalError("init() has not been implemented")
//    }
}