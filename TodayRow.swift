//
//  TestLabel.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-23.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import RealmSwift

public class TodayRow {
    dynamic var stopName: String = ""
    dynamic var distance: Int = 0
    dynamic var sname: String = ""
    dynamic var direction: String = ""
    dynamic var snameAndDirection: String = ""
    dynamic var fgColor: String = ""
    dynamic var bgColor: String = ""
    dynamic var rtTimes = [Int]()
    public var row: Row = Row.Empty
}