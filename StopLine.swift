//
//  StopLines.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-03.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import RealmSwift

public class StopLine {
    dynamic var stopId: String = ""
    dynamic var stopName: String = ""
    dynamic var lat: String = ""
    dynamic var long: String = ""
    dynamic var sname: String = ""
    dynamic var tag: Int = 0
    dynamic var type: String = ""
    dynamic var track: String = ""
    dynamic var direction: String = ""
    dynamic var lineAndDirection: String = ""
    dynamic var isChecked: Bool = false
}