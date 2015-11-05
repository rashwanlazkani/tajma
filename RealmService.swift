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
        Global.addedLinesAtStop = [String]()
        
        let getRows = realm.objects(RealmObject).filter("stopId = '\(stopId)'")
        
        for row in getRows{
            Global.addedLinesAtStop.append(row.lineAndDirection)
        }
        return Global.addedLinesAtStop
    }
    
    func getLinesAtStopArr(stopId : String) -> [LinesAtStop]{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        var lineArr = [LinesAtStop]()
        let lines = realm.objects(RealmObject).filter("stopId = '\(stopId)'")
        
        for line in lines{
            let lineAtStop = LinesAtStop()
            lineAtStop.stopId = line.stopId
            lineAtStop.track = line.track
            lineAtStop.sname = line.sname
            lineAtStop.direction = line.direction

            lineArr.append(lineAtStop)
        }
        return lineArr
    }
    
    func getLinesAtStopToday(stopId: String) -> [LinesAtStop]{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        
        let userStops = realm.objects(RealmObject).filter("stopId = '\(stopId)'")
        
        var tempLinesAtStopTodayArr = [LinesAtStop]()
        
        for line in userStops{
            let lineAtStop = LinesAtStop()
            lineAtStop.stopId = line.stopId
            lineAtStop.track = line.track
            lineAtStop.sname = line.sname
            lineAtStop.direction = line.direction
            
            tempLinesAtStopTodayArr.append(lineAtStop)
        }
        return tempLinesAtStopTodayArr
    }
    
    func updateLinesToStop(stopLine: StopLine){
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        
        if(stopLine.isChecked){
            let realmObject = RealmObject()
            realmObject.stopId = stopLine.stopId
            realmObject.stopName = stopLine.stopName
            realmObject.lat = stopLine.lat
            realmObject.long = stopLine.long
            realmObject.sname = stopLine.sname
            realmObject.tag = stopLine.tag
            realmObject.type = stopLine.type
            realmObject.track = stopLine.track
            realmObject.direction = stopLine.direction
            realmObject.lineAndDirection = stopLine.lineAndDirection
            realmObject.isChecked = stopLine.isChecked
            do{
                try! realm.write({ () -> Void in
                    realm.add(realmObject)
                })
            }
        }
        else{
            let realmObject = realm.objects(RealmObject).filter("stopId = '\(stopLine.stopId)' AND lineAndDirection = '\(stopLine.lineAndDirection)'").first
            try! realm.write({ () -> Void in
                realm.delete(realmObject!)
            })
        }
    }
    
    func getLines() -> [LinesAtStop]{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        var lineArr = [LinesAtStop]()
        let lines = realm.objects(RealmObject)
        
        for line in lines{
            let lineAtStop = LinesAtStop()
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