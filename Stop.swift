//
//  Stop.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import RealmSwift

public class Stop: Object {
    var id = ""
    var name = ""
    var lat = ""
    var long = ""
    var distance = 0
    var lines = [Line]()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["distance"]
    }
}