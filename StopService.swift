//
//  StopService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

class StopsService{
    var stopWrapper = StopWrapper()
    let checkedStops = RealmService.sharedInstance.getStops()
    
    func getNearestStops(lat: String, long: String, onCompletion: (StopWrapper) -> Void){
        RestApiService.sharedInstance.getNearestStops(lat, long: long) { json in
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.stopWrapper.error = error.domain
                
                onCompletion(self.stopWrapper)
            }
            else{
                let stops = json["LocationList"]["StopLocation"]
                
                var tempNames = [String]()
                self.stopWrapper = StopWrapper()
                
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
                        
                        var stop = Stop()
                        stop.id = id!
                        stop.name = name!
                        stop.lat = lat!
                        stop.long = long!
                        stop = self.checkIfUserHasAddedStop(stop)
                        self.stopWrapper.stops.append(stop)
                        
                        if (self.stopWrapper.stops.count == 10){
                            break
                        }
                    }
                }
                onCompletion(self.stopWrapper)
            }
        }
    }
    
    func getStopsByInput(name : String, onCompletion: (StopWrapper) -> Void){
        RestApiService.sharedInstance.findStops(name) { json in
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.stopWrapper.error = error.domain
                
                onCompletion(self.stopWrapper)
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
                        self.stopWrapper.stops.append(stop as Stop)
                        break
                    }
                    
                    var stop = Stop()
                    stop.id = id!
                    stop.name = name!
                    stop.lat = lat!
                    stop.long = long!
                    stop = self.checkIfUserHasAddedStop(stop)
                    self.stopWrapper.stops.append(stop)
                }
                onCompletion(self.stopWrapper)
            }
        }
    }
    
    func checkIfUserHasAddedStop(stop: Stop) -> Stop{
        if (RealmService.sharedInstance.getStopsId().contains(stop.id)){
            stop.isChecked = true
        }
        else {
            stop.isChecked = false
        }
        return stop
    }
}