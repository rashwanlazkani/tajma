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
    
    // TODO: Fixa så att det är en metod istället
    func getAllDeparturesFromStop(_ stopId: String, onSuccess: @escaping ([Line]) -> Void, onError: @escaping (NSError) -> Void){
        WebService.sharedInstance.getDeparturesAtStop(stopId) { jsonDictionary in
            var lines = [Line]()
            let departures = Departure()

            guard let jsonDepartures = jsonDictionary["Departure"] as? [[String:AnyObject]]
                else {return onError(NSError(domain: "Laddar avgångar... (0x1)", code: 1, userInfo: nil))}
            
            guard let serverDate = jsonDictionary["serverdate"] as? String,
                let serverTime = jsonDictionary["servertime"] as? String
                else { return onError(NSError(domain: "Laddar avgångar... (0x2)", code: 2, userInfo: nil)) }
            
            for json in jsonDepartures{
                if json["rtTime"] == nil && json["time"] == nil{
                    continue
                }
                if json["rtDate"] == nil && json["date"] == nil{
                    continue
                }
                
                guard
                    let name = json["name"] as? String,
                    let sname = json["sname"] as? String,
                    let direction = json["direction"] as? String,
                    let type = json["type"] as? String,
                    let fgColor  = json["fgColor"] as? String,
                    let bgColor  = json["bgColor"] as? String
                else { continue }
                let track = json["track"] as? String ?? ""
                let time = json["rtTime"] ?? json["time"]
                let date = json["rtDate"] ?? json["date"]
                let dateTime = "\(date!) \(time!)"
                
                let serverDateTime = "\(serverDate) \(serverTime)"
                
                guard
                    let departureTime = dateTime.date,
                    let serverTime = serverDateTime.date
                    else { continue }
                
                let intervalBetweenDepartures = departureTime.timeIntervalSince(serverTime) / 60
                departures.times.append(Int(intervalBetweenDepartures))
                
                let id = "\(stopId)-\(sname)-\(direction)"
                let lineAndDirection = ("\(sname) \(direction)").subStringSnameAndDirection
                let line = Line(id: id, stop: Stop(), stopId: stopId, lineAndDirection: lineAndDirection, name: name, sname: sname, direction: direction, type: type, track: track, bgColor: bgColor, fgColor: fgColor, departures: Departure())
                
                let x = lines.filter({$0.id == id })
                if  x.isEmpty {
                    line.departures.times.append(Int(intervalBetweenDepartures))
                    lines.append(line)
                } else {
                    x[0].departures.times.append(Int(intervalBetweenDepartures))
                }
            }
            
            //lines.sort(by: {$0.departures.times.first < $1.departures.times.first})
            let numberLines = lines.filter({Int($0.sname) != nil}).sorted(by: {Int($0.sname)! < Int($1.sname)})
            let charLines = lines.filter({Int($0.sname) == nil}).sorted(by: {$0.sname < $1.sname})
            onSuccess(numberLines + charLines)
        }
    }

    func getDeparturesFromStop(_ stopId: String, onSuccess: @escaping ([Line]?) -> Void){
        WebService.sharedInstance.getDeparturesAtStop(stopId) { jsonDictionary in
            var lines = [Line]()
            let dbLines = DbService.sharedInstance.getLinesAtStop(stopId)

            guard let jsonDepartures = jsonDictionary["Departure"] as? [[String:Any]]
                else { return onSuccess(nil) }

            guard let serverDate = jsonDictionary["serverdate"] as? String,
                let serverTime = jsonDictionary["servertime"] as? String
                else { return onSuccess(nil) }
            
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
                if line == nil {
                    line = dbLines.firstOrDefault({$0.id == id})
                    
                    if line != nil {
                        lines.append(line!)
                    }
                }
                
                if line == nil {
                    continue
                }
                
                let time = departure["rtTime"] ?? departure["time"]
                let date = departure["rtDate"] ?? departure["date"]
                let dateTime = "\(date!) \(time!)"

                let serverDateTime = "\(serverDate) \(serverTime)"
                
                guard
                    let departureTime = dateTime.date,
                    let serverTime = serverDateTime.date
                else { continue }

                let intervalBetweenDepartures = departureTime.timeIntervalSince(serverTime) / 60

                line!.departures.times.append(Int(intervalBetweenDepartures))
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
            if closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000 {
                group.enter()
                getDeparturesFromStop(stop.id, onSuccess: { lines -> Void in  defer { group.leave() }
                    if let lines = lines {
                        stop.lines = lines
                        closestStops.append(stop)
                    }
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
