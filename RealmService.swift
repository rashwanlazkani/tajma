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
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        var ids = [String]()
        let userStops = realm.objects(RealmObject)
        
        for row in userStops{
            ids.append(row.stopId)
        }
        return ids
    }
    
    func getStops() -> [Stop]{
        setDefaultRealmConfiguration()
        
        let realm = try! Realm()

        var stops = [Stop]()
        var tempStopsName = [String]()
        let userStops = realm.objects(RealmObject)
        
        for row in userStops{
            // För att hämta unika hållplatsnamn
            if(tempStopsName.contains(row.stopName)){
                continue
            }
            tempStopsName.append(row.stopName)
            let stop = Stop()
            stop.id = row.stopId
            stop.name = row.stopName
            stop.lat = row.lat
            stop.long = row.long
            stop.distance = 0
            stop.departures = [Departure]()
            stop.isChecked = true
            
            stops.append(stop)
        }
        
        stops.sortInPlace({ $0.name < $1.name })
        
        return stops
        
    }
    
    func getStopsCount() -> Int{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        return Int(realm.objects(RealmObject).count)
    }

    func getStopsNearLocationCount(lat: String, long: String) -> Int{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        let stopsNearLocation = realm.objects(RealmObject).filter("lat BEGINSWITH = '\(lat)' AND long BEGINSWITH = '\(long)")
        return stopsNearLocation.count
    }
    
    func getStopName(stopId: String) -> String{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        let stop = realm.objects(RealmObject).filter("id = '\(stopId)'")
        
        for s in stop{
            return s.stopName
        }
        return "Ingen hållplats hittades"
    }
    
    func getLinesAtStop(stopId : String) -> [String]{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        Global.linesAtStop = [StopLine]()
        Global.allaStopp = [String]()
        
        let getRows = realm.objects(RealmObject).filter("stopId = '\(stopId)'")
        
        for row in getRows{
            Global.allaStopp.append(row.lineAndDirection)
        }
        return Global.allaStopp
    }
    
    func getLinesAtStopArr(stopId : String) -> [LineAtStopToday]{
        setDefaultRealmConfiguration()
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
        setDefaultRealmConfiguration()
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
    
    func updateLinesToStop(stop: StopLine){
        setDefaultRealmConfiguration()
        
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
                line.isChecked = true
                
                do{
                    try! realm.write({ () -> Void in
                        realm.add(line)
                    })
                }
            }
        }
    }
    
    func getLines() -> [LineAtStopToday]{
        setDefaultRealmConfiguration()
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
    
    func setDefaultRealmConfiguration() {
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.tajma.today")!
        let realmPath = directory.URLByAppendingPathComponent("default.realm")
        let urlSubString = realmPath.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        Realm.Configuration.defaultConfiguration.path = urlSubString
    }
    
    class var sharedInstance: RealmService {
        struct Static {
            static let instance = RealmService()
        }
        return Static.instance
    }
}