//
//  Stop.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

open class Stop: Codable, Equatable {
    var id : String
    var name : String
    var latitude : String
    var longitude : String
    var distance: Int?
    var lines = [Line]()
    
    init(){
        self.id = ""
        self.name = ""
        self.latitude = ""
        self.longitude = ""
        self.distance = 0
        self.lines = [Line]()
    }
    
    init(id: String?, name: String?, latitude: String?, longitude: String?, distance: Int?, lines: [Line]){
        self.id = id!
        self.name = name!
        self.latitude = latitude!
        self.longitude = longitude!
        self.distance = distance!
        self.lines = lines
    }
}

public func ==(lhs: Stop, rhs: Stop) -> Bool {
    return lhs.name == rhs.name
}
