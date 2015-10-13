//
//  StopService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class StopsService{
    var dbService = DBService()
    var stops = StopWrapper()
    
    // Cache
    func getNearestStops(lat: String, long: String, onCompletion: (StopWrapper) -> Void){
        RestApiService.sharedInstance.getNearestStops(lat, long: long) { json in
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                var error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.stops.error = error.domain
                
                onCompletion(self.stops)
            }
            else{
                let stops = json["LocationList"]["StopLocation"]
                
                var tempNames = [String]()
                self.stops = StopWrapper()
                
                for (index, subJson): (String, JSON) in stops {
                    let user: AnyObject = subJson["name"].object
                    
                    var id = subJson["id"].string
                    var name = subJson["name"].string
                    var lat = subJson["lat"].string
                    var long = subJson["lon"].string
                    
                    if let dotRange = name!.rangeOfString(",") {
                        name!.removeRange(dotRange.startIndex..<name!.endIndex)
                    }
                    
                    
                    // Kollar så att man endast visar en hållplats och inte alla tracks (A,B,C osv...)
                    if (!tempNames.contains((name!))){
                        tempNames.insert(name!, atIndex: 0)
                        // För att kolla om hållplatsen redan finns tillagd av användaren
                        // För att hämta rätt koordinater och stopId för att Västtrafiks API innehåller flera hållplatser med samma namn fast annorlunda stopId
                        var existingStop = self.checkIfUserHasAddedStop(name!)
                        
                        if (!existingStop.name.isEmpty){
                            var stop = Stop(id: existingStop.id, name: existingStop.name, lat: existingStop.lat, long: existingStop.long, distance: 0, departures: nil)
                            self.stops.stops.append(stop as Stop)
                        }
                        else{
                            var stop = Stop(id: id!, name: name!, lat: lat!, long: long!, distance: 0, departures: nil)
                            self.stops.stops.append(stop as Stop)
                        }
                        
                        if (self.stops.stops.count == 10){
                            break
                        }
                    }
                    else{
                        
                    }
                }
                
                onCompletion(self.stops)
                
            }
            
        }
    }
    
    // Cache
    func getStopsByInput(name : String, onCompletion: (StopWrapper) -> Void){
        RestApiService.sharedInstance.findStops(name) { json in
            
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                var error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.stops.error = error.domain
                
                onCompletion(self.stops)
                //self.getStops(name) { stops in
                //    onCompletion(stops)
                //}
            }
            else{
                let stops = json["LocationList"]["StopLocation"]
                
                for (index, subJson): (String, JSON) in stops {
                    let user: AnyObject = subJson["name"].object
                    
                    var id = subJson["id"].string
                    var name = subJson["name"].string
                    var lat = subJson["lat"].string
                    var long = subJson["lon"].string
                    
                    if (name == nil){
                        var stop = Stop(id: "", name: "Inget stopp hittades", lat: "", long: "", distance: 0, departures: nil)
                        self.stops.stops.append(stop as Stop)
                        break
                    }
                    
                    // Resultatet kommer "Olskrokstorget, Göteborg", vi vill ta bort kommatecknet
                    if let dotRange = name!.rangeOfString(",") {
                        name!.removeRange(dotRange.startIndex..<name!.endIndex)
                    }
                    
                    var existingStop = self.checkIfUserHasAddedStop(name!)
                    
                    if (!existingStop.name.isEmpty){
                        var stop = Stop(id: existingStop.id, name: existingStop.name, lat: existingStop.lat, long: existingStop.long, distance: 0, departures: nil)
                        self.stops.stops.append(stop as Stop)
                    }
                    else{
                        var stop = Stop(id: id!, name: name!, lat: lat!, long: long!, distance: 0, departures: nil)
                        self.stops.stops.append(stop as Stop)
                    }
                }
                
                onCompletion(self.stops)
                
            }
            
        }
    }
    
    func checkIfUserHasAddedStop(stopName : String) -> Stop{
        var userStops = [Stop]()
        var userStopsArr = [String]()
        let userStopsFromDB = self.dbService.getStops()
        
        var stop = Stop(id: "", name: "", lat: "", long: "", distance: 0, departures: [])
        
        for stop in userStopsFromDB{
            let stop = Stop(id: stop.id, name: stop.name, lat: stop.lat, long: stop.long, distance: stop.distance, departures: stop.departures)
            
            userStops.append(stop)
            userStopsArr.append(stop.name)
        }
        
        if (userStopsArr.contains(stopName)){
            for item in userStops{
                if (item.name == stopName){
                    stop = Stop(id: item.id, name: item.name, lat: item.lat, long: item.long, distance: 0, departures: nil)
                }
            }
            
        }
        
        return stop
    }
    
}