//
//  StopService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import CoreLocation

class StopService{
    let checkedStops = DbService.sharedInstance.getStops()
    
    func getNearestStops(_ lat: String, long: String, onSuccess: @escaping ([Stop]) -> Void, onError: (NSError) -> Void){
        WebService.sharedInstance.getNearestStops(lat, long: long) { jsonDic in
            // TODO: Lägg till onError
            if let jsonStops = jsonDic["StopLocation"] as? [[String:AnyObject]] {
                if jsonStops.isEmpty {
                    onSuccess([Stop]())
                }
                
                let stops = self.mapToStop(jsonStops).sorted{$0.0.name == $0.1.name}.orderedSetValue
                
                for stop in stops{
                    stop.id = stop.id.customizeStopID
                }
                onSuccess(stops)
            }
            else {
                onSuccess([Stop]())
            }
        }
    }
    
    func getStopsByInput(_ name : String, onSuccess: @escaping ([Stop]) -> Void, onError: (NSError) -> Void){
        WebService.sharedInstance.findStops(name) { jsonDic in
            guard let jsonStops = jsonDic["StopLocation"] as? [[String:AnyObject]]
            else { return }
            
            var stops = self.mapToStop(jsonStops).sorted{$0.0.name == $0.1.name}.orderedSetValue
            
            for stop in stops{
                if (stop.id.isEmpty){
                    if (stops.count == 1){
                        stops.removeAll()
                    }
                    continue
                }
                stop.id = stop.id.customizeStopID
            }
            onSuccess(stops)
        }
    }
    
    func calculateDistance(_ stop: Stop, lat: Double, long: Double) -> Int{
        let userLocation = CLLocation(latitude: lat, longitude: long)
        let stopLocation = CLLocation(latitude: (stop.latitude as NSString).doubleValue, longitude: (stop.longitude as NSString).doubleValue)
        let distance = userLocation.distance(from: stopLocation)
        
        return roundToFive(distance)
    }
    
    fileprivate func mapToStop(_ json: [[String:AnyObject]]) -> [Stop]{
        var stops = [Stop]()

        for stop in json {
            guard let id = stop["id"] as? String,
                let name = stop["name"] as? String,
                let lat = stop["lat"] as? String,
                let long = stop["lon"] as? String
            else { continue }
            
            let s = Stop(id: id, name: name, latitude: lat, longitude: long, distance: Int(), lines: [Line]())
            
            stops.append(s)
        }
    
        return stops
    }
    
    fileprivate func roundToFive(_ x : Double) -> Int {
        return 5 * Int(round(x / 5.0))
    }
}
