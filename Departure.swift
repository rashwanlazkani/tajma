//
//  DepartureTimes.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import RealmSwift

public class Departure {
    dynamic var stopId: String = ""
    dynamic var sname: String = ""
    dynamic var track: String = ""
    dynamic var direction: String = ""
    dynamic var fgColor: String = ""
    dynamic var bgColor: String = ""
    dynamic var rtTimes = [Int]()
}
