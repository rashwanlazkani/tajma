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
        let dbExists = NSUserDefaults(suiteName: "group.tajma.today")!.boolForKey("DbExists")
        if (!dbExists){
            createTables()
        }
        let db = try! Connection(sharedHelper.getSharedUrl())
        let data = Table("Stops")
        
        var stops = [Stop]()
        for row in try! db.prepare(data) {
            let stop = Stop()
            stop.id = row[Expression<String>("id")]
            stop.name = row[Expression<String>("name")]
            stop.lat = row[Expression<String>("lat")]
            stop.long = row[Expression<String>("long")]
            stops.append(stop)
        }
        stops.sortInPlace({ $0.name < $1.name })
        return stops
    }
    
    func getLines() -> [Line]{
        let dbExists = NSUserDefaults(suiteName: "group.tajma.today")!.boolForKey("DbExists")
        if (!dbExists){
            createTables()
        }
        let db = try! Connection(sharedHelper.getSharedUrl())
        let data = Table("Lines")
        
        var lines = [Line]()
        for row in try! db.prepare(data) {
            let line = Line()
            line.id = row[Expression<String>("id")]
            line.stopId = row[Expression<String>("stopId")]
            line.lineAndDirection = row[Expression<String>("lineAndDirection")]
            line.name = row[Expression<String>("name")]
            line.sname = row[Expression<String>("sname")]
            line.direction = row[Expression<String>("direction")]
            line.type = row[Expression<String>("type")]
            line.track = row[Expression<String>("track")]
            line.bgColor = row[Expression<String>("bgColor")]
            line.fgColor = row[Expression<String>("fgColor")]
            lines.append(line)
        }
        return lines
    }
    
    func getLinesAtStop(stopId : String) -> [Line]{
        let db = try! Connection(sharedHelper.getSharedUrl())
        var lines = [Line]()
        
        let linesCount = db.scalar("SELECT count(*) FROM Lines where stopId = '\(stopId)'") as! Int64
        if(linesCount == 0){
            return lines
        }

        let stmt = try! db.prepare("SELECT * FROM Lines where stopId = '\(stopId)'")
        for row in stmt {
            let line = Line()
            line.id = row[0] as! String
            line.stopId = stopId
            line.name = row[2] as! String
            line.sname = row[3] as! String
            line.direction = row[4] as! String
            line.lineAndDirection = row[5] as! String
            line.type = row[6] as! String
            line.track = row[7] as! String
            line.bgColor = row[8] as! String
            line.fgColor = row[9] as! String
            lines.append(line)
        }
        return lines
    }
    
    func addLine(line: Line, stop: Stop){
        let db = try! Connection(sharedHelper.getSharedUrl())
        
        let stopsCount = db.scalar("SELECT count(*) FROM Stops where id = '\(stop.id)'") as! Int64
        if (stopsCount == 0){
            try! db.execute("INSERT INTO Stops VALUES ('\(stop.id)','\(stop.name)','\(stop.lat)','\(stop.long)')")
        }
        
         try! db.execute("INSERT INTO Lines VALUES ('\(line.id)','\(stop.id)','\(line.name)','\(line.sname)','\(line.direction)', '\(line.lineAndDirection)', '\(line.type)', '\(line.track)', '\(line.bgColor)', '\(line.fgColor)')")
    }
    
    func removeLine(line: Line, stopId: String){
        let db = try! Connection(sharedHelper.getSharedUrl())
        
        try! db.execute("DELETE FROM Lines WHERE id = '\(line.id)'")
        
        let linesCount = db.scalar("SELECT count(*) FROM Lines where stopId = '\(stopId)'") as! Int64
        if (linesCount == 0){
            try! db.execute("DELETE FROM Stops WHERE id = '\(stopId)'")
        }
    }
    
    func updateOptionals(){
        let db = try! Connection(sharedHelper.getSharedUrl())
        try! db.execute("UPDATE lines SET id = replace(replace(id, 'Optional(\"',''), '\")', '') WHERE id LIKE '%Optional%';")
    }
    
    private func createTables(){
        let db = try! Connection(sharedHelper.getSharedUrl())
        
        let dbExists = NSUserDefaults(suiteName: "group.tajma.today")!.boolForKey("DbExists")
        if !dbExists {
            NSUserDefaults(suiteName: "group.tajma.today")!.setBool(true, forKey: "DbExists")
            
            try! db.run("CREATE TABLE 'Stops' ('id' VARCHAR NOT NULL  UNIQUE, 'name' VARCHAR, 'lat' VARCHAR, 'long' VARCHAR)")
            
            try! db.run("CREATE TABLE 'Lines' ('id' VARCHAR NOT NULL, 'stopId' VARCHAR NOT NULL, 'name' VARCHAR NOT NULL, 'sname' VARCHAR NOT NULL,  'direction' VARCHAR NOT NULL, 'lineAndDirection' VARCHAR, 'type' VARCHAR, 'track' VARCHAR NOT NULL, 'bgColor' VARCHAR, 'fgColor' VARCHAR)")
        }
    }
}