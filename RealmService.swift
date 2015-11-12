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
import SINQ

class RealmService {
    func getStops() -> [Stop]{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        
        var stops = realm.objects(Stop).map({$0})
        stops.sortInPlace({ $0.name < $1.name })
        
        return stops
    }

    func getLinesAtStop(stopId : String) -> [Line]{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        
        let objects = realm.objects(Line).filter("stop.id = '\(stopId)'")
        var lines = [Line]()
        for object in objects{
            let line = Line()
            
            line.stop = object.stop
            line.lineAndDirection = object.lineAndDirection
            line.name = object.name
            line.sname = object.sname
            line.direction = object.direction
            line.type = object.type
            line.track = object.track
            line.bgColor = object.bgColor
            line.fgColor = object.fgColor
            lines.append(line)
        }
        return lines
    }
    
    func addLine(line: Line) -> Void{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        
        let stops = realm.objects(Stop).filter("id = '\(line.stop!.id)'")
        try! realm.write({ () -> Void in
            if(stops.count == 0){
                realm.add(line.stop!)
            }
            realm.add(line)
        })
    }
    
    func removeLine(line: Line) -> Void{
        setDefaultRealmConfiguration()
        let realm = try! Realm()

        let lines = realm.objects(Line).filter("stop.id = '\(line.stop!.id)'")
        try! realm.write({ () -> Void in
            let l = realm.objects(Line).filter("lineAndDirection = '\(line.lineAndDirection)'")
            realm.delete(l)
        })
//        if(lines.count == 0){
//            try! realm.write({ () -> Void in
//                let s = realm.objects(Stop).filter("id = '\(line.stop!.id)'")
//                realm.delete(s)
//            })
//        }
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