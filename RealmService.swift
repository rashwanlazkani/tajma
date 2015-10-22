//
//  RealmService.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2015-10-17.
//  Copyright © 2015 Rashwan Lazkani. All rights reserved.
//

// Singleton class

import Foundation
import RealmSwift

class RealmService {
    func getStopsId() -> [String]{
        let realm = try! Realm()
        var ids = [String]()
        let userStops = realm.objects(RealmObject)
        
        for row in userStops{
            ids.append(row.stopId)
        }
        return ids
    }
    
    func getStops() -> [Stop]{
        
        DbService.setSharedURL()
        let realm = try! Realm()
//        let sortProperties = [SortDescriptor(property: "dateStart", ascending: true), SortDescriptor(property: "timeStart", ascending: true)]
//        allShowsByDate = Realm().objects(MyObjectType).sorted(sortProperties)

        var stops = [Stop]()
        var tempStopsName = [String]()
        let userStops = realm.objects(RealmObject)
        
        for row in userStops{
            if(tempStopsName.contains(row.stopName)){
                continue
            }
            tempStopsName.append(row.stopName)
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
        let realm = try! Realm()
        return Int(realm.objects(RealmObject).count)
    }

    func getStopsNearLocationCount(lat: String, long: String) -> Int{
        let realm = try! Realm()
        let stopsNearLocation = realm.objects(RealmObject).filter("lat BEGINSWITH = '\(lat)' AND long BEGINSWITH = '\(long)")
        return stopsNearLocation.count
    }
    
    func getStopName(stopId: String) -> String{
        let realm = try! Realm()
        let stop = realm.objects(RealmObject).filter("id = '\(stopId)'")
        
        for s in stop{
            return s.stopName
        }
        return "Ingen hållplats hittades"
    }
    
    func getLinesAtStop(stopId : String) -> [String]{
        let realm = try! Realm()
        Global.linesAtStop = [StopLine]()
        Global.allaStopp = [String]()
        
        let getRows = realm.objects(RealmObject).filter("stopId = '\(stopId)'")
        
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
        let realm = try! Realm()
        var lineArr = [LineAtStopToday]()
        let lines = realm.objects(RealmObject).filter("stopId = '\(stopId)'")
        
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
        let realm = try! Realm()
        
        let userStops = realm.objects(RealmObject).filter("stopId = '\(stopId)'")
        
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
        let realm = try! Realm()

        let s = realm.objects(RealmObject).filter("stopId = '\(stop.stopId)'")
        if (!s.isEmpty){
            try! realm.write({ () -> Void in
                realm.delete(s)
            })
        }
        
        for stopline in Global.linesAtStop
        {
            if (stopline.isChecked == true && stopline.stopId == stop.stopId){
                let line = RealmObject()
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
                        realm.add(line)
                    })
                }
            }
        }
    }
    
    func getLines() -> [LineAtStopToday]{
        let realm = try! Realm()
        var lineArr = [LineAtStopToday]()
        let lines = realm.objects(RealmObject)
        
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