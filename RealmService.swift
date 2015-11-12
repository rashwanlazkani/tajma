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
        
        var lines = [Line]()
        let l = realm.objects(Line).filter("stop.id = '\(stopId)'")
        if(l.count == 0){
            return lines
        }
        
        let objects = realm.objects(Line).filter("stop.id = '\(stopId)'")
        
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
    
    func addLine(line: Line, stop: Stop) -> Void{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
    
        
    }
    
    func updateLine(line: Line, stopId: String) -> Void{
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        
        let lines = realm.objects(Line).filter("stop.id = '\(stopId)'")
        if (from(lines).any({$0.id == line.id})){
            do{
                try! realm.write({ () -> Void in
                    let l = realm.objects(Line).filter("id == '\(line.id)'").first
                    l!.stop = self.getStop(stopId)
                    realm.delete(l!)
                    
                    let lines = realm.objects(Line).filter("stop.id = '\(stopId)'")
                    if(lines.count == 0){
                        let s = realm.objects(Stop).filter("id = '\(stopId)'")
                        realm.delete(s)
                    }
                })
            }
        }
        else{
            do{
                try! realm.write({ () -> Void in
                    line.stop = self.getStop(stopId)
                    realm.add(line)
                })
            }
        }
    }
    
    func getStop(stopId: String) -> Stop? {
        let realm = try! Realm()
        
        return realm.objects(Stop).filter("id = '\(stopId)'").first
    }
    
    func setDefaultRealmConfiguration() {
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.tajma.today")!
        let realmPath = directory.URLByAppendingPathComponent("default.realm")
        let urlSubString = realmPath.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        print(realmPath)
        Realm.Configuration.defaultConfiguration.path = urlSubString
    }
    
    class var sharedInstance: RealmService {
        struct Static {
            static let instance = RealmService()
        }
        return Static.instance
    }
}