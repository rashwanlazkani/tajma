//
//  DepartureService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-15.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import UIKit
import CoreLocation
import SINQ

public class DepartureService {
    var stopService = StopsService()
    
    func getDeparturesFromStop(stopId: String, onSuccess: ([Line]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.getDeparturesAtStop(stopId) { json in
            var error = json["DepartureBoard"]
            if (String(error["error"]) == Constants.VTerrorCode){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                onError(error)
                return
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let serverDate = dateFormatter.dateFromString(self.serverDateTime(json)) as NSDate!
            let jsonDepartures = json["DepartureBoard"]["Departure"]
            
            var lines = [Line]()
            for (_,subJson):(String, JSON) in jsonDepartures {
                var line = Line()
                line.sname = self.trimSname(subJson["sname"].string!)
                line.track = subJson["track"].string ?? ""
                line.direction = subJson["direction"].string!
                line.fgColor = subJson["fgColor"].string!
                line.bgColor = subJson["bgColor"].string!
                line.lineAndDirection = "\(line.sname) \(line.direction)"
                
                if (from(lines).any{$0.lineAndDirection == line.lineAndDirection}){
                    line = from(lines).single({$0.lineAndDirection == line.lineAndDirection})
                }
                else{
                    lines.append(line)
                }

                let time = subJson["rtTime"].string ?? subJson["time"].string
                let date = subJson["rtDate"].string ?? subJson["date"].string
                let dateTime = "\(date!) \(time!)"
                
                let departureTime = dateFormatter.dateFromString(dateTime) as NSDate!
                let intervalBetweenDepartures = Int(departureTime.timeIntervalSinceDate(serverDate) / 60) - 1
                
//                let departure = Departure()
//                departure.times = [intervalBetweenDepartures]
//                line.departures.times.append(departure)
            }
            lines.sortInPlace({ $0.lineAndDirection != $1.lineAndDirection})
            onSuccess(lines)
        }
    }
    
    func getMyDepartures(var stops: [Stop], lat: Double, long: Double) -> [Stop] {
        let getDeparturesGroup = dispatch_group_create()
        
        from(stops).each({
            $0.distance = self.stopService.calculateDistance($0, lat: lat, long: long)
        })
        stops.sortInPlace({ $0.distance != $1.distance ? $0.distance < $1.distance : $0.id < $1.id})

        
        var closestStops = [Stop]()
        for stop in stops {
            if (closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000){
                closestStops.append(stop)
            }
            else{
                break
            }
        }
        
        dispatch_group_wait(getDeparturesGroup, DISPATCH_TIME_FOREVER)
        return closestStops
    }
    
    private func trimSname(sname: String) -> String{
       return sname.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
    }
    
    private func serverDateTime(json: JSON) -> String{
        let serverDateStr = String(stringInterpolationSegment: json["DepartureBoard"]["serverdate"])
        let serverTimeStr = String(stringInterpolationSegment: json["DepartureBoard"]["servertime"])
        
        return ("\(serverDateStr) \(serverTimeStr)")
    }
}