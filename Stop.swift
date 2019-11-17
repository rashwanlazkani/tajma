//
//  Stop.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

open class Stop: Codable, Equatable {
    var id: String
    let name: String
    let lat: String
    let lon: String
    var distance: Int?
    var lines = [Line]()
    
    private enum CodingKeys: String, CodingKey {
        case id, name, lat, lon
    }
    
    init() {
        self.id = ""
        self.name = ""
        self.lat = ""
        self.lon = ""
        self.distance = 0
        self.lines = [Line]()
    }
    
    init(id: String?, name: String?, latitude: String?, longitude: String?, distance: Int?, lines: [Line]){
        self.id = id!
        self.name = name!
        self.lat = latitude!
        self.lon = longitude!
        self.distance = distance!
        self.lines = lines
    }
}

public func ==(lhs: Stop, rhs: Stop) -> Bool {
    return lhs.name == rhs.name
}
