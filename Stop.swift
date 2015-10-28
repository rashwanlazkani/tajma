//
//  Stop.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import RealmSwift

public class Stop {
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var lat: String = ""
    dynamic var long: String = ""
    dynamic var distance: Int = 0
    var departures = [Departure]?()
}