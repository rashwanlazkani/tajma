//
//  DepartureService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import CoreLocation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


open class DepartureService {
    var stopService = StopService()

    func getDeparturesFromStop(_ stopId: String, onSuccess: @escaping ([Line]) -> Void, onError: @escaping (NSError) -> Void){
        ApiService.sharedInstance.getDeparturesAtStop(stopId) { jsonDictionary in
            var lines = [Line]()
            let dbLines = DbService.sharedInstance.getLinesAtStop(stopId)
            
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
                
                // TODO: Lägg till i Extension
                let d = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(identifier: "sv_SE")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let localDate = dateFormatter.string(from: d)
                
                guard let departureTime = DateAndTimeFormat.instance.date(from: dateTime) else { continue }
                guard let serverTime = DateAndTimeFormat.instance.date(from: serverDateTime) else { continue }
                
                guard let localDateTime = DateAndTimeFormat.instance.date(from: localDate) else { continue }
                
                print(departureTime)
                print(serverTime)
                print(localDate)
                print(localDateTime)
                
                let intervalBetweenDepartures = Int(departureTime.timeIntervalSince(localDateTime) / 60) - 1
                let intervalBetweenDeparturesServerTime = Int(departureTime.timeIntervalSince(serverTime) / 60) - 1
                
                print(intervalBetweenDepartures)
                print(intervalBetweenDeparturesServerTime)
                
                line!.departures.times.append(intervalBetweenDepartures)
            }
            
            lines.sort(by: {$0.departures.times.first < $1.departures.times.first})
            onSuccess(lines)
        }
    }

    func getMyDepartures(_ coordinate: CLLocationCoordinate2D, onSuccess: @escaping ([Stop]) -> Void, onError: @escaping (NSError) -> Void) {
        let group = DispatchGroup()
        var stops = DbService.sharedInstance.getStops()

        for stop in stops{
            stop.distance = self.stopService.calculateDistance(stop, lat: coordinate.latitude, long: coordinate.longitude)
        }
        stops.sort(by: { $0.distance != $1.distance ? $0.distance < $1.distance : $0.id < $1.id})

        var closestStops = [Stop]()
        for stop in stops {
            if (closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000){
                group.enter()
                getDeparturesFromStop(stop.id, onSuccess: { lines -> Void in  defer { group.leave() }
                    stop.lines = lines
                    closestStops.append(stop)
                }, onError:{ error -> Void in defer { group.leave() }

                    return onError(NSError(domain: "Ett fel har inträffat, var god försök igen (0x000004)", code: 4, userInfo: nil))
                })
            }
        }
        
        group.notify(queue: DispatchQueue.main, execute: {
            onSuccess(closestStops.sorted(by: { $0.distance < $1.distance}))
        })
    }
    
    fileprivate func trimSname(_ sname: String) -> String{
       return sname.replacingOccurrences(of: "SVAR", with: "SVART")
    }
}
