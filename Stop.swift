//
//  Stop.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

public class Stop : Equatable {
    var id = ""
    var name = ""
    var lat = ""
    var long = ""
    var distance = 0
    var lines = [Line]()
}

public func ==(lhs: Stop, rhs: Stop) -> Bool {
    return lhs.name == rhs.name
}
