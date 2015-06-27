//
//  DBService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-07.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit

class DBService {
    let db : SQLiteDB
    
    init(){
        
        // Hämta Shared URL
        var url = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.tajma.today")!
        var urlSubString = url.absoluteString!.stringByReplacingOccurrencesOfString("file:///", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        // skapa en file manager för att hanera filerna
        let filemgr = NSFileManager.defaultManager()
        let databuffer = filemgr.contentsAtPath(urlSubString)
        
        // Kolla om databas filen finns
        if !filemgr.fileExistsAtPath(urlSubString + "data.sqlite") {
            // Skapa fil
            urlSubString = urlSubString + "data.sqlite"
            filemgr.createFileAtPath(urlSubString, contents: databuffer,
                attributes: nil)
        }
        
        db = SQLiteDB.sharedInstance()
    }
    
    func getStopsId() -> [String]{
        var ids = [String]()
        
        let userStops = db.query("SELECT stopId FROM stops")
        
        for row in userStops{
            ids.append(row["stopId"]!.asString())
        }
        
        return ids
    }
    
    func getStops() -> [Stop]{
        var stops = [Stop]()
        
        let userStops = db.query("SELECT * FROM stops")
        
        for row in userStops{
            var stop = Stop(id: row["stopId"]!.asString(), name: row["stopName"]!.asString(), lat: row["lat"]!.asString(), long: row["long"]!.asString(), distance: 0, departures: nil)
            
            stops.append(stop)
        }
        
        stops.sort({ $0.name < $1.name })
        
        return stops
        
    }
    
    func getStopsCount() -> Int{
        var stopsCount = db.query("SELECT count(*) FROM Stops")
        var row = stopsCount[0]
        return row["count(*)"]!.asInt()
    }
    
    func getStopsNearLocationCount(lat: String, long: String) -> Int{
        var stopsNearLocation = db.query("SELECT count(*) FROM stops WHERE lat like '\(lat))%' AND long like '\(long))%'")
        var row = stopsNearLocation[0]
        return row["count(*)"]!.asInt()
    }
    
    func getStopName(stopId: String) -> String{
        var stopName = ""
        let stopData = db.query("SELECT * FROM Stops where stopid = '\(stopId)'")
        for stopInfo in stopData{
            stopName = stopInfo["stopName"]!.asString()
        }
        
        return stopName
    }
    
    func getLinesAtStop(stopId : String) -> [String]{
        Global.linesAtStop = [StopLine]()
        Global.allaStopp = [String]()
        
        let db = SQLiteDB.sharedInstance()
        let getRows = db.query("SELECT * FROM Lines where stopId = '\(stopId)'")
        
        for row in getRows{
            var stopline = StopLine(stopId: row["stopId"]!.asString(), stopName: row["stopName"]!.asString(), lat: row["lat"]!.asString(), long: row["long"]!.asString(), sname: row["sname"]!.asString(), tag: 0, type: row["type"]!.asString(), track: row["track"]!.asString(), direction: row["direction"]!.asString(), lineAndDirection: row["lineAndDirection"]!.asString(), isChecked: true)
            
            Global.allaStopp.append(row["lineAndDirection"]!.asString())
            
        }
        
        return Global.allaStopp
    }
    
    func getLinesAtStopArr(stopId : String) -> [LineAtStopToday]{
        var lineArr = [LineAtStopToday]()
        var lines = db.query("SELECT * FROM Lines WHERE stopId = \(stopId)")
        
        for line in lines{
            var lineAtStop = LineAtStopToday(stopId: line["stopId"]!.asString(), track: line["track"]!.asString(), sname: line["sname"]!.asString(), direction: line["direction"]!.asString())
            
            lineArr.append(lineAtStop)
        }
        
        return lineArr
    }
    
    func getLinesAtStopToday(stopId: String) -> [LineAtStopToday]{
        let userStops = db.query("SELECT * FROM Lines where stopid = '\(stopId)'")
        
        var tempLinesAtStopTodayArr = [LineAtStopToday]()
        
        for line in userStops{
            var lineAtStop = LineAtStopToday(stopId: line["stopId"]!.asString(), track: line["track"]!.asString(), sname: line["sname"]!.asString(), direction: line["direction"]!.asString())
            tempLinesAtStopTodayArr.append(lineAtStop)
        }
        
        return tempLinesAtStopTodayArr
    }
    
    // För att visa i favoriter menyn under ett stop
    // 1,16,18,31 osv...
    func getLinesAtStopCommaSeparated(stopId : String) -> String{
        let data = db.query("SELECT * FROM lines where stopId = '\(stopId)'")
        
        var lines : String = ""
        var i = 0
        var lastRow = data.count - 1
        for row in data{
            if (i == 0 && data.count == 1){
                lines = row["sname"]!.asString()
            }
            else if (i == 0 && data.count > 1){
                lines = row["sname"]!.asString() + ", "
            }
            else if (i == lastRow){
                lines += row["sname"]!.asString()
            }
            else{
                lines += row["sname"]!.asString() + ", "
            }
            i++
        }
        
        return lines
        
    }
    
    func addLinesToStop(stop: StopLine){
        // Ta bort alla stopp från hållplatsen för att sedan lägga till dem
        db.query("DELETE FROM Lines WHERE stopId = '\(stop.stopId)'")
        
        // Kolla om hållplatsen redan finns
        var data = db.query("SELECT count(*) FROM Stops WHERE stopId = '\(stop.stopId)'")
        var row = data[0]
        var totStops = row["count(*)"]!.asInt()
        // Annars lägg till
        if (totStops == 0){
            db.query("INSERT INTO Stops VALUES('\(stop.stopId)','\(stop.stopName)','\(stop.lat)','\(stop.long)')")
        }
        
        var temp = [StopLine]()
        
        for stopline in Global.linesAtStop
        {
            if (stopline.isChecked == true && stopline.stopId == stop.stopId){
                db.query("INSERT INTO Lines VALUES ('\(stopline.stopId)','\(stopline.stopName)','\(stopline.lat)','\(stopline.long)','\(stopline.sname)', '\(stopline.direction)', '\(stopline.lineAndDirection)', '\(stopline.type)', '\(stopline.track)')")
            }
        }
        
        var queryLines = db.query("SELECT count(*) FROM Lines WHERE stopId = '\(stop.stopId)'")
        
        if (!queryLines.isEmpty){
            var lines = queryLines[0]
            var totLines = lines["count(*)"]!.asInt()
            
            if (totLines == 0){
                removeStop(stop.stopId)
            }
        }
    }
    
    func getLines() -> [LineAtStopToday]{
        var lineArr = [LineAtStopToday]()
        var lines = db.query("SELECT * FROM Lines")
        
        for line in lines{
            var lineAtStop = LineAtStopToday(stopId: line["stopId"]!.asString(), track: line["track"]!.asString(), sname: line["sname"]!.asString(), direction: line["direction"]!.asString())
            
            lineArr.append(lineAtStop)
        }
        
        return lineArr
    }
    
    func removeStop(stopId : String){
        let db = SQLiteDB.sharedInstance()
        
        db.query("DELETE FROM Lines WHERE stopId = '\(stopId)'")
        db.query("DELETE FROM Stops WHERE stopId = '\(stopId)'")
    }
    
    func addTablesIfNotExists(){
        
        let tableExists = db.query("SELECT name FROM sqlite_master WHERE type='table' AND name='Stops'")
        
        if (tableExists.isEmpty){
            //   create tables
            db.execute("CREATE TABLE 'Stops' ('stopId' VARCHAR NOT NULL  UNIQUE , 'stopName' VARCHAR, 'lat' VARCHAR, 'long' VARCHAR)")
            
            db.execute("CREATE TABLE 'Lines' ('stopId' VARCHAR NOT NULL, 'stopName' VARCHAR NOT NULL, 'lat' VARCHAR NOT NULL, 'long' VARCHAR NOT NULL,  'sname' VARCHAR NOT NULL , 'direction' VARCHAR NOT NULL, 'lineAndDirection' VARCHAR NOT NULL , 'type' VARCHAR NOT NULL, 'track' VARCHAR NOT NULL)")
        }
    }
}