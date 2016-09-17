//
//  DepartureService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import CoreLocation
import UIKit

public class DepartureService {
    var stopService = StopService()

    func getDeparturesFromStop(stopId: String, onSuccess: ([Line]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.getDeparturesAtStop(stopId) { jsonDictionary in
            var lines = [Line]()
            let dbLines = SqliteService.sharedInstance.getLinesAtStop(stopId)
            
            guard let jsonDepartures = jsonDictionary["Departure"] as? [[String:AnyObject]]
                else {return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000003)", code: 3, userInfo: nil))}
            

            guard let serverDate = jsonDictionary["serverdate"] as? String,
                let serverTime = jsonDictionary["servertime"] as? String
                else { return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000002)", code: 2, userInfo: nil)) }
            
            for departure in jsonDepartures{
                if departure["rtTime"] == nil && departure["time"] == nil{
                    continue
                }
                if departure["rtDate"] == nil && departure["date"] == nil{
                    continue
                }
                
                guard let sname = departure["sname"],
                    let direction = departure["direction"] else {continue}
                
                let id = "\(stopId)-\(sname)-\(direction)"
                
                // TODO: Guard istället?
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
                
                let time = departure["rtTime"] ?? departure["time"]
                let date = departure["rtDate"] ?? departure["date"]
                let dateTime = "\(date!) \(time!)"

                let serverDateTime = "\(serverDate) \(serverTime)"
                
                
                
                guard let departureTime = Formatter.instance.dateFromString(dateTime) else { continue }
                guard let serverTime = Formatter.instance.dateFromString(serverDateTime) else { continue }
                let intervalBetweenDepartures = Int(departureTime.timeIntervalSinceDate(serverTime) / 60) - 1
                
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
}

//extension NSData {
//    var serverDate: NSDate? {
//        return Formatter.instance.dateFromString("\(self["DepartureBoard"]["serverdate"]) \(self["DepartureBoard"]["servertime"])")
//    }
//}

struct Formatter {
    static let instance = NSDateFormatter(dateFormat: "yyyy-MM-dd HH:mm")
}

extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
