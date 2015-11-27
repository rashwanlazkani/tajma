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
            
            let dbLines = SqliteService.sharedInstance.getLinesAtStop(stopId)
            var lines = [Line]()
            
            for (_,subJson):(String, JSON) in jsonDepartures {
                let id = "\(stopId)-\(subJson["sname"].string!)-\(subJson["direction"].string!)"
                
                var line = from(lines).singleOrNil({$0.id == id})
                if(line == nil){
                    line = from(dbLines).singleOrNil({$0.id == id})
                    
                    if(line != nil){
                        lines.append(line!)
                    }
                }
                
                if(line == nil){
                    continue
                }
                
                let time = subJson["rtTime"].string ?? subJson["time"].string
                let date = subJson["rtDate"].string ?? subJson["date"].string
                let dateTime = "\(date!) \(time!)"
                
                let departureTime = dateFormatter.dateFromString(dateTime) as NSDate!
                let intervalBetweenDepartures = Int(departureTime.timeIntervalSinceDate(serverDate) / 60) - 1
                
                line!.departures.times.append(intervalBetweenDepartures)
            }
            lines.sortInPlace({ $0.lineAndDirection != $1.lineAndDirection})
            onSuccess(lines)
        }
    }
    
    func getMyDepartures(lat: Double, long: Double) -> [Stop] {
        let getDeparturesGroup = dispatch_group_create()
        var stops = SqliteService.sharedInstance.getStops()
        
        from(stops).each({
            $0.distance = self.stopService.calculateDistance($0, lat: lat, long: long)
        })
        stops.sortInPlace({ $0.distance != $1.distance ? $0.distance < $1.distance : $0.id < $1.id})

        
        var closestStops = [Stop]()
        for stop in stops {
            if (closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000){
                dispatch_group_enter(getDeparturesGroup)
                getDeparturesFromStop(stop.id, onSuccess: { lines -> Void in
                    stop.lines = lines
                    closestStops.append(stop)
                    dispatch_group_leave(getDeparturesGroup)
                }, onError:{ error -> Void in
                    print(error)
                })
            }
            else{
                break
            }
        }
        
        dispatch_group_wait(getDeparturesGroup, DISPATCH_TIME_FOREVER)
        print("Hämtat closestStops")
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