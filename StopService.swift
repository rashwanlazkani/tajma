//
//  StopService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class StopsService{
    var stops = StopWrapper()
    let userStopsFromDB = RealmService.sharedInstance.getStops()
    
    func getNearestStops(lat: String, long: String, onCompletion: (StopWrapper) -> Void){
        RestApiService.sharedInstance.getNearestStops(lat, long: long) { json in
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.stops.error = error.domain
                
                onCompletion(self.stops)
            }
            else{
                let stops = json["LocationList"]["StopLocation"]
                
                var tempNames = [String]()
                self.stops = StopWrapper()
                
                for (_,subJson):(String, JSON) in stops {
                    let id = subJson["id"].string
                    let name = subJson["name"].string
                    let lat = subJson["lat"].string
                    let long = subJson["lon"].string
                    
                    // Kollar så att man endast visar en hållplats och inte alla tracks (A,B,C osv...)
                    if (!tempNames.contains(name!)){
                        tempNames.insert(name!, atIndex: 0)
                        // För att kolla om hållplatsen redan finns tillagd av användaren
                        // För att hämta rätt koordinater och stopId för att Västtrafiks API innehåller flera hållplatser med samma namn fast annorlunda stopId
                        
                        let stop = Stop()
                        stop.id = id!
                        stop.name = name!
                        stop.lat = lat!
                        stop.long = long!
                        self.checkIfUserHasAddedStop(name!, vtStop: stop)
                        
                        if (self.stops.stops.count == 10){
                            break
                        }
                    }
                }
                onCompletion(self.stops)
            }
        }
    }
    
    func getStopsByInput(name : String, onCompletion: (StopWrapper) -> Void){
        RestApiService.sharedInstance.findStops(name) { json in
            
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.stops.error = error.domain
                
                onCompletion(self.stops)
            }
            else{
                let stops = json["LocationList"]["StopLocation"]
                
                for (_,subJson):(String, JSON) in stops {
                    let id = subJson["id"].string
                    let name = subJson["name"].string
                    let lat = subJson["lat"].string
                    let long = subJson["lon"].string
                    
                    if (name == nil){
                        let stop = Stop()
                        stop.name = "Inget stopp hittades"
                        self.stops.stops.append(stop as Stop)
                        break
                    }
                    
                    let stop = Stop()
                    stop.id = id!
                    stop.name = name!
                    stop.lat = lat!
                    stop.long = long!
                    self.checkIfUserHasAddedStop(name!, vtStop: stop)
                }
                onCompletion(self.stops)
            }
        }
    }
    
    func checkIfUserHasAddedStop(stopName : String, vtStop: Stop){
        var userStops = [Stop]()
        var userStopsArr = [String]()

        let stop = Stop()
        stop.id = ""
        stop.name = ""
        stop.lat = ""
        stop.long = ""
        stop.distance = 0
        stop.departures = []
        
        for stop in userStopsFromDB{
            let s = Stop()
            s.id = stop.id
            s.name = stop.name
            s.lat = stop.lat
            s.long = stop.long
            s.distance = stop.distance
            s.departures = stop.departures
            
            userStops.append(stop)
            userStopsArr.append(stop.name)
        }
        
        if (userStopsArr.contains(stopName)){
            for item in userStops{
                if (item.name == stopName){
                    stop.id = item.id
                    stop.name = item.name
                    stop.lat = item.lat
                    stop.long = item.long
                    stop.distance = 0
                    stop.departures = nil
                }
            }
        }
        
        if (!stop.name.isEmpty){
            print(stop.id)
            let existingStop = Stop()
            existingStop.id = stop.id
            existingStop.name = stop.name
            existingStop.lat = stop.lat
            existingStop.long = stop.long
            self.stops.stops.append(existingStop as Stop)
        }
        else{
            print(stop.id)
            let newStop = Stop()
            newStop.id = vtStop.id
            newStop.name = vtStop.name
            newStop.lat = vtStop.lat
            newStop.long = vtStop.long
            self.stops.stops.append(newStop as Stop)
        }

    }
    
}