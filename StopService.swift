//
//  StopService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import CoreLocation

class StopService{
    let checkedStops = SqliteService.sharedInstance.getStops()
    
    func getNearestStops(lat: String, long: String, onSuccess: ([Stop]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.getNearestStops(lat, long: long) { jsonDic in
            guard let stops = jsonDic["StopLocation"] as? [[String:AnyObject]]
            else { return }
            print("stoplocationListArrayDic:", stops)
            
            for stop in stops{
                let name = stop["nameaaa"]
                print("No crash")
            }
            
//            var error = json["LocationList"]
//            if (String(error["error"]) == Constants.errorCode){
//                onError(NSError(domain: "Fel vid hämtning av närmaste stopp (V)", code: 0, userInfo: nil))
//                return
//            }
//            else{
//                
//                
//                
//                let jsonStops = json["LocationList"]["StopLocation"]
//                let stops = self.mapToStop(jsonStops).sort{$0.0.name == $0.1.name}.orderedSetValue
//
//                for stop in stops{
//                    stop.id = StringHelper.customizeStopID(stop.id)
//                }
//                onSuccess(stops)
//            }
        }
    }
    
    func getStopsByInput(name : String, onSuccess: ([Stop]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.findStops(name) { json in
//            var error = json["LocationList"]
//            if (String(error["error"]) == Constants.errorCode){
//                onError(NSError(domain: "Fel vid hämtning av stopp efter sökning (V)", code: 0, userInfo: nil))
//                return
//            }
//            else{
//                let jsonStops = json["LocationList"]["StopLocation"]
//                var stops = self.mapToStop(jsonStops).sort{$0.0.name == $0.1.name}.orderedSetValue
//                for stop in stops{
//                    if (stop.id.isEmpty){
//                        if (stops.count == 1){
//                            stops.removeAll()
//                        }
//                        continue
//                    }
//                    stop.id = StringHelper.customizeStopID(stop.id)
//                }
//                onSuccess(stops)
//            }
        }
    }
    
//    func calculateDistance(stop: Stop, lat: Double, long: Double) -> Int{
//        let userLocation = CLLocation(latitude: lat, longitude: long)
//        let stopLocation = CLLocation(latitude: (stop.latitude as NSString).doubleValue, longitude: (stop.longitude as NSString).doubleValue)
//        let distance = userLocation.distanceFromLocation(stopLocation)
//        
//        return roundToFive(distance)
//    }
    
//    private func mapToStop(json: NSData) -> [Stop]{
//        var stops = [Stop]()
//        
//        for (_,subJson):(String, NSData) in json {
//            let stop = Stop(id: subJson["id"].string ?? "", name: subJson["name"].string ?? "", latitude: subJson["lat"].string ?? "", longitude: subJson["lon"].string ?? "", distance: Int(), lines: [Line]())
//            stops.append(stop)
//        }
//        return stops
//    }
//    
//    private func roundToFive(x : Double) -> Int {
//        return 5 * Int(round(x / 5.0))
//    }
}
