//
//  RealmService.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-10-17.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

// Singleton class

import Foundation
import SQLite

class SqliteService {
    static let sharedInstance = SqliteService()
    let sharedHelper = SharedHelper()
    
    func getStops() -> [Stop]{
        let dbExists = UserDefaults(suiteName: "group.tajma.today")!.bool(forKey: "DbExists")
        if (!dbExists){
            createTables()
        }
        let db = try! Connection(sharedHelper.getSharedUrl())
        let data = Table("Stops")
        
        var stops = [Stop]()
        for row in try! db.prepare(data) {
            let stop = Stop(id: row[Expression<String>("id")], name: row[Expression<String>("name")], latitude: row[Expression<String>("lat")], longitude: row[Expression<String>("long")], distance: Int(), lines: [Line]())
            stops.append(stop)
        }
        stops.sort(by: { $0.name < $1.name })
        return stops
    }
    
    func getLines() -> [Line]{
        let dbExists = UserDefaults(suiteName: "group.tajma.today")!.bool(forKey: "DbExists")
        if (!dbExists){
            createTables()
        }
        let db = try! Connection(sharedHelper.getSharedUrl())
        let data = Table("Lines")
        
        var lines = [Line]()
        for row in try! db.prepare(data) {
            let line = Line(id: row[Expression<String>("id")], stop: Stop(), stopId: row[Expression<String>("stopId")], lineAndDirection: row[Expression<String>("lineAndDirection")], name: row[Expression<String>("name")], sname: row[Expression<String>("sname")], direction: row[Expression<String>("direction")], type: row[Expression<String>("type")], track: row[Expression<String>("track")], bgColor: row[Expression<String>("fgColor")], fgColor: row[Expression<String>("bgColor")], departures: Departure())

            lines.append(line)
        }
        return lines
    }
    
    func getLinesAtStop(_ stopId : String) -> [Line]{
        let db = try! Connection(sharedHelper.getSharedUrl())
        var lines = [Line]()
        
        let linesCount = try! db.scalar("SELECT count(*) FROM Lines where stopId = '\(stopId)'") as! Int64
        if(linesCount == 0){
            return lines
        }

        let stmt = try! db.prepare("SELECT * FROM Lines where stopId = '\(stopId)'")
        for row in stmt {
            let line = Line(id: row[0] as! String, stop: Stop(), stopId: stopId, lineAndDirection: row[5] as! String, name: row[2] as! String, sname: row[3] as! String, direction: row[4] as! String, type: row[6] as! String, track: row[7] as! String, bgColor: row[8] as! String, fgColor: row[9] as! String, departures: Departure())
            lines.append(line)
        }
        return lines
    }
    
    func addLine(_ line: Line, stop: Stop){
        let db = try! Connection(sharedHelper.getSharedUrl())
        
        let stopsCount = try! db.scalar("SELECT count(*) FROM Stops where id = '\(stop.id)'") as! Int64
        if (stopsCount == 0){
            try! db.execute("INSERT INTO Stops VALUES ('\(stop.id)','\(stop.name)','\(stop.latitude)','\(stop.longitude)')")
        }
        
         try! db.execute("INSERT INTO Lines VALUES ('\(line.id)','\(stop.id)','\(line.name)','\(line.sname)','\(line.direction)', '\(line.lineAndDirection)', '\(line.type)', '\(line.track)', '\(line.bgColor)', '\(line.fgColor)')")
    }
    
    func removeLine(_ line: Line, stopId: String){
        let db = try! Connection(sharedHelper.getSharedUrl())
        
        try! db.execute("DELETE FROM Lines WHERE id = '\(line.id)'")
        
        let linesCount = try! db.scalar("SELECT count(*) FROM Lines where stopId = '\(stopId)'") as! Int64
        if (linesCount == 0){
            try! db.execute("DELETE FROM Stops WHERE id = '\(stopId)'")
        }
    }
    
    func updateOptionals(){
        let db = try! Connection(sharedHelper.getSharedUrl())
        try! db.execute("UPDATE lines SET id = replace(replace(id, 'Optional(\"',''), '\")', '') WHERE id LIKE '%Optional%';")
    }
    
    fileprivate func createTables(){
        let db = try! Connection(sharedHelper.getSharedUrl())
        
        let dbExists = UserDefaults(suiteName: "group.tajma.today")!.bool(forKey: "DbExists")
        if !dbExists {
            UserDefaults(suiteName: "group.tajma.today")!.set(true, forKey: "DbExists")
            
            _ = try! db.run("CREATE TABLE 'Stops' ('id' VARCHAR NOT NULL  UNIQUE, 'name' VARCHAR, 'lat' VARCHAR, 'long' VARCHAR)")
            
            _ = try! db.run("CREATE TABLE 'Lines' ('id' VARCHAR NOT NULL, 'stopId' VARCHAR NOT NULL, 'name' VARCHAR NOT NULL, 'sname' VARCHAR NOT NULL,  'direction' VARCHAR NOT NULL, 'lineAndDirection' VARCHAR, 'type' VARCHAR, 'track' VARCHAR NOT NULL, 'bgColor' VARCHAR, 'fgColor' VARCHAR)")
        }
    }
}
