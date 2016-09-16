//
//  DepartureService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import CoreLocation

public class DepartureService {
    var stopService = StopService()
    
    func getDeparturesFromStop(stopId: String, onSuccess: ([Line]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.getDeparturesAtStop(stopId) { json in
//            var error = json["DepartureBoard"]
//            if (String(error["error"]) == Constants.errorCode){
//                onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000001)", code: 1, userInfo: nil))
//                return
//            }
//            
            
            
//            if json["DepartureBoard"]["serverdate"] == nil || json["DepartureBoard"]["servertime"] == nil{
//                return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000002)", code: 2, userInfo: nil))
//            }
//            
            guard let serverDate = json.serverDate where json["DepartureBoard"]["serverdate"] != nil  || json["DepartureBoard"]["servertime"] != nil
            else {
                
                return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000002)", code: 2, userInfo: nil))
            }
            
//           if json["DepartureBoard"]["Departure"] == nil{
//                return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000003)", code: 3, userInfo: nil))
//            }
            
            guard json["DepartureBoard"]["Departure"] != nil else {
                return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000003)", code: 3, userInfo: nil))
            }
            
            
            let jsonDeparturesArrayValue = json["DepartureBoard"]["Departure"].arrayValue
            print("jsonDeparturesArrayValue:", jsonDeparturesArrayValue)
            
            
            let jsonDepartures = json["DepartureBoard"]["Departure"]
            let dbLines = SqliteService.sharedInstance.getLinesAtStop(stopId)
            var lines = [Line]()
            
            //for departure in jsonDepartures {
            for (_,subJson):(String, JSON) in jsonDepartures {
                if subJson["sname"].string == nil || subJson["direction"].string == nil {
                    continue
                }
                
                let id = "\(stopId)-\(subJson["sname"].string!)-\(subJson["direction"].string!)"
                
                var line = lines.firstOrDefault {$0.id == id}
                if(line == nil){
                    line = dbLines.firstOrDefault({$0.id == id})
                    
                    if(line != nil){
                        lines.append(line!)
                    }
                }
                
                if(line == nil){
                    continue
                }
                
                if subJson["rtTime"].string == nil && subJson["time"].string == nil {
                    continue
                }
                
                if subJson["rtDate"].string == nil && subJson["date"].string == nil{
                    continue
                }
                
                let time = subJson["rtTime"].string ?? subJson["time"].string
                let date = subJson["rtDate"].string ?? subJson["date"].string
                let dateTime = "\(date!) \(time!)"
                
                guard let departureTime = Formatter.instance.dateFromString(dateTime) else { return }
                let intervalBetweenDepartures = Int(departureTime.timeIntervalSinceDate(serverDate) / 60) - 1
                
                line!.departures.times.append(intervalBetweenDepartures)
            }
            lines.sortInPlace({$0.departures.times.first < $1.departures.times.first})
            
            onSuccess(lines)
        }
    }

    func getMyDepartures(coordinate: CLLocationCoordinate2D, onSuccess: ([Stop]) -> Void, onError: (NSError) -> Void) {
        let group = dispatch_group_create()
        var stops = SqliteService.sharedInstance.getStops()

        for stop in stops{
            stop.distance = self.stopService.calculateDistance(stop, lat: coordinate.latitude, long: coordinate.longitude)
        }
        stops.sortInPlace({ $0.distance != $1.distance ? $0.distance < $1.distance : $0.id < $1.id})

        var closestStops = [Stop]()
        for stop in stops {
            if (closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000){
                dispatch_group_enter(group)
                getDeparturesFromStop(stop.id, onSuccess: { lines -> Void in  defer { dispatch_group_leave(group) }
                    stop.lines = lines
                    closestStops.append(stop)
                }, onError:{ error -> Void in defer { dispatch_group_leave(group) }
                    //dispatch_group_leave(group)
                    return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000004)", code: 4, userInfo: nil))
                })
            }
        }
        
        //dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            onSuccess(closestStops.sort({ $0.distance < $1.distance}))
        })
    }
    
    private func trimSname(sname: String) -> String{
       return sname.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
    }
    
//    private func serverDateTime(json: JSON) -> String{
//        
//    }
}
extension JSON {
    var serverDate: NSDate? {
        return Formatter.instance.dateFromString("\(self["DepartureBoard"]["serverdate"]) \(self["DepartureBoard"]["servertime"])")
    }
}
struct Formatter {
    static let instance = NSDateFormatter(dateFormat: "yyyy-MM-dd HH:mm")
}
extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
