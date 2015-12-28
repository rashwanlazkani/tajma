//
//  StopService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import CoreLocation
import SINQ

class StopsService{
    let checkedStops = SqliteService.sharedInstance.getStops()
    
    func getNearestStops(lat: String, long: String, onSuccess: ([Stop]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.getNearestStops(lat, long: long) { json in
            var error = json["LocationList"]
            if (String(error["error"]) == Constants.VTerrorCode){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                onError(error)
                return
            }
            else{
                let jsonStops = json["LocationList"]["StopLocation"]
                let stops = from(self.mapToStop(jsonStops)).distinct{$0.0.name == $0.1.name}.toArray()
                for stop in stops{
                    stop.id = StringHelper.customVtStopId(stop.id)
                }
                onSuccess(stops)
            }
        }
    }
    
    func getStopsByInput(name : String, onSuccess: ([Stop]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.findStops(name) { json in
            var error = json["LocationList"]
            if (String(error["error"]) == Constants.VTerrorCode){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                onError(error)
                return
            }
            else{
                let jsonStops = json["LocationList"]["StopLocation"]
                var stops = from(self.mapToStop(jsonStops)).distinct{$0.0.name == $0.1.name}.toArray()
                for stop in stops{
                    if (stop.id.isEmpty){
                        if (stops.count == 1){
                            stops.removeAll()
                        }
                        continue
                    }
                    stop.id = StringHelper.customVtStopId(stop.id)
                }
                onSuccess(stops)
            }
        }
    }
    
    func calculateDistance(stop: Stop, lat: Double, long: Double) -> Int{
        let userLocation = CLLocation(latitude: lat, longitude: long)
        let stopLocation = CLLocation(latitude: (stop.lat as NSString).doubleValue, longitude: (stop.long as NSString).doubleValue)
        let distance = userLocation.distanceFromLocation(stopLocation)
        
        return roundToFive(distance)
    }
    
    private func mapToStop(json: JSON) -> [Stop]{
        var stops = [Stop]()
        
        for (_,subJson):(String, JSON) in json {
            let stop = Stop()
            stop.id = subJson["id"].string ?? ""
            stop.name = subJson["name"].string ?? ""
            stop.lat = subJson["lat"].string ?? ""
            stop.long = subJson["lon"].string ?? ""
            stops.append(stop)
        }
        return stops
    }
    
    private func roundToFive(x : Double) -> Int {
        return 5 * Int(round(x / 5.0))
    }
}