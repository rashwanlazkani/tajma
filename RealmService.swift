//
//  RealmService.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-10-17.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

// Singleton class

import Foundation
import Realm
import RealmSwift

class RealmService {
    let realm = try! Realm()
    
    func getStopsId() -> [String]{
        var ids = [String]()
        let userStops = realm.objects(StopLine)
        
        for row in userStops{
            ids.append(row.stopId)
        }
        return ids
    }
    
    func getStops() -> [Stop]{
        var stops = [Stop]()
        
        let userStops = realm.objects(StopLine)
        
        for row in userStops{
            let stop = Stop()
            stop.id = row.stopId
            stop.name = row.stopName
            stop.lat = row.lat
            stop.long = row.long
            stop.distance = 0//row.distance
            stop.departures = [Departure]()//row.departures
            
            stops.append(stop)
        }
        
        stops.sortInPlace({ $0.name < $1.name })
        
        return stops
        
    }
    
    func getStopsCount() -> Int{
        return Int(realm.objects(StopLine).count)
    }

    func getStopsNearLocationCount(lat: String, long: String) -> Int{
        let stopsNearLocation = realm.objects(StopLine).filter("lat BEGINSWITH = '\(lat)' AND long BEGINSWITH = '\(long)")
        return stopsNearLocation.count
    }
    
    func getStopName(stopId: String) -> String{
        let stop = realm.objects(StopLine).filter("id = '\(stopId)'")
        
        for s in stop{
            return s.stopName
        }
        return "Ingen hållplats hittades"
    }
    
    func getLinesAtStop(stopId : String) -> [String]{
        Global.linesAtStop = [StopLine]()
        Global.allaStopp = [String]()
        
        let getRows = realm.objects(StopLine).filter("stopId = '\(stopId)'")
        
        for row in getRows{
            let stopline = StopLine()
            stopline.stopId = row.stopId
            stopline.stopName = row.stopName
            stopline.lat = row.lat
            stopline.long = row.long
            stopline.sname = row.sname
            stopline.tag = row.tag
            stopline.type = row.type
            stopline.track = row.track
            stopline.direction = row.direction
            stopline.lineAndDirection = row.lineAndDirection
            stopline.isChecked = row.isChecked
            
            Global.allaStopp.append(row.lineAndDirection)
            
        }
        return Global.allaStopp
    }
    
    func getLinesAtStopArr(stopId : String) -> [LineAtStopToday]{
        var lineArr = [LineAtStopToday]()
        let lines = realm.objects(StopLine).filter("stopId = '\(stopId)'")
        
        for line in lines{
            let lineAtStop = LineAtStopToday()
            lineAtStop.stopId = line.stopId
            lineAtStop.track = line.track
            lineAtStop.sname = line.sname
            lineAtStop.direction = line.direction

            lineArr.append(lineAtStop)
        }
        return lineArr
    }
    
    func getLinesAtStopToday(stopId: String) -> [LineAtStopToday]{
        let userStops = realm.objects(StopLine).filter("stopId = '\(stopId)'")
        
        var tempLinesAtStopTodayArr = [LineAtStopToday]()
        
        for line in userStops{
            let lineAtStop = LineAtStopToday()
            lineAtStop.stopId = line.stopId
            lineAtStop.track = line.track
            lineAtStop.sname = line.sname
            lineAtStop.direction = line.direction
            
            tempLinesAtStopTodayArr.append(lineAtStop)
        }
        return tempLinesAtStopTodayArr
    }
    
    func addLinesToStop(stop: StopLine){
        let s = realm.objects(StopLine).filter("stopId = '\(stop.stopId)'")
        if (!s.isEmpty){
            try! realm.write({ () -> Void in
                self.realm.delete(s)
            })
        }
        
        if(realm.objects(StopLine).filter("stopId = '\(stop.stopId)'").count == 0){
            let s = StopLine()
            s.stopId = stop.stopId
            s.stopName = stop.stopName
            s.lat = stop.lat
            s.long = stop.long
            
            do{
                try! realm.write({ () -> Void in
                    self.realm.add(s)
                })
            }
        }

        for stopline in Global.linesAtStop
        {
            if (stopline.isChecked == true && stopline.stopId == stop.stopId){
                let line = StopLine()
                line.stopId = stopline.stopId
                line.stopName = stopline.stopName
                line.lat = stopline.lat
                line.long = stopline.long
                line.sname = stopline.sname
                line.direction = stopline.direction
                line.lineAndDirection = stopline.lineAndDirection
                line.type = stopline.type
                line.track = stopline.track
                
                do{
                    try! realm.write({ () -> Void in
                        self.realm.add(s)
                    })
                }
            }
        }
        
        let lines = realm.objects(StopLine).filter("stopId = '\(stop.stopId)'")

        if(lines.count == 0){
            realm.delete(lines)
        }
    }
    
    func getLines() -> [LineAtStopToday]{
        var lineArr = [LineAtStopToday]()
        let lines = realm.objects(StopLine)
        
        for line in lines{
            let lineAtStop = LineAtStopToday()
            lineAtStop.stopId = line.stopId
            lineAtStop.track = line.track
            lineAtStop.sname = line.sname
            lineAtStop.direction = line.direction

            lineArr.append(lineAtStop)
        }
        
        return lineArr
    }
    
    // Så att vi endast kan köra en instans av Storage åt gången
    class var sharedInstance: RealmService {
        struct Static {
            static let instance = RealmService()
        }
        return Static.instance
    }
}