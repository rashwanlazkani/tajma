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
        
        return realm.objects(Line).filter("stopId = '\(stopId)'").map({$0})
    }
    
    func addObject(line: Line){
        setDefaultRealmConfiguration()
        let realm = try! Realm()
        
        let stop = realm.objects(Stop).filter("stopId = '\(line.stop)").map({$0})
        try! realm.write({ () -> Void in
            if(stop.isEmpty){
                realm.add(line.stop!)
            }

            realm.add(line)
        })
    }
    
    func removeObject(line: Line){
        setDefaultRealmConfiguration()
        let realm = try! Realm()

        let stop = realm.objects(Stop).filter("stopId = '\(line.stop!.id)").map({$0})
        try! realm.write({ () -> Void in
            realm.delete(line)
            
            if((stop.first?.lines.isEmpty) != nil){
                realm.delete(stop)
            }
        })
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