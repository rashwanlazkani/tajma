//
//  RealmLine.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-10-18.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

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
}