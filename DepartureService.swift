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
    var stopService = StopsService()
    var departures = [Departure]()
    
    func getDeparturesFromStop(stopId: String, onCompletion: ([Departure]) -> Void) {
        RestApiService.sharedInstance.getDeparturesAtStop(stopId) { json in
            self.departures = []
            
            var error = json["DepartureBoard"]
            if (error["error"] == "No journeys found") {
                onCompletion(self.departures)
                return
            }
            
            let serverDateStr = String(stringInterpolationSegment: json["DepartureBoard"]["serverdate"])
            let serverTimeStr = String(stringInterpolationSegment: json["DepartureBoard"]["servertime"])
            let serverDate = serverDateStr + " " + serverTimeStr

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let results = json["DepartureBoard"]["Departure"]
            var tempDepartures = [Departure]()
            
            for (_,subJson):(String, JSON) in results {
                let stopId = subJson["stopid"].string!
                var sname = subJson["sname"].string!
                let track = subJson["track"].string ?? ""
                let direction = subJson["direction"].string!
                let fgColor = subJson["fgColor"].string!
                let bgColor = subJson["bgColor"].string!
                
                if (sname == "SVAR"){
                    sname = "SVART"
                }
                
                let rtTimeFromServer = subJson["rtTime"].string ?? subJson["time"].string
                let rtDate = subJson["rtDate"].string ?? subJson["date"].string
                var rtTime = [rtDate!  + " " + rtTimeFromServer!]
                
                let serverTime = dateFormatter.dateFromString(serverDate) as NSDate!
                let departureTime = dateFormatter.dateFromString(rtTime[0]) as NSDate!
                
                let intervalBetweenDepartures = Int(departureTime.timeIntervalSinceDate(serverTime) / 60) - 1
                
                let departure = Departure()
                departure.stopId = stopId
                departure.sname = sname
                departure.track = track
                departure.direction = direction
                departure.fgColor = fgColor
                departure.bgColor = bgColor
                departure.rtTimes = [intervalBetweenDepartures]
                
                tempDepartures.append(departure)
            }
            
            tempDepartures.sortInPlace({ $0.sname != $1.sname ? $0.sname < $1.sname : $0.direction < $1.direction})
            
            var previousSname = ""
            var previousTrack = ""
            var previousDirection = ""
            for row in tempDepartures {
                var departure = Departure()
                
                if (previousSname == row.sname && previousTrack == row.track && previousDirection == row.direction) {
                    departure = self.departures[self.departures.count - 1]
                    departure.rtTimes.append(row.rtTimes[0])
                }
                else {
                    departure.stopId = row.stopId
                    departure.sname = row.sname
                    departure.track = row.track
                    departure.direction = row.direction
                    departure.fgColor = row.fgColor
                    departure.bgColor = row.bgColor
                    departure.rtTimes = row.rtTimes
                    
                    self.departures.append(departure)
                }
                
                previousSname = row.sname
                previousTrack = row.track
                previousDirection = row.direction
            }
            
            onCompletion(self.departures)
        }
    }
    
    func getMyDepartures(lat: Double, long: Double) -> [Stop] {
        let stops = RealmService.sharedInstance.getStops()
        var closestStops = [Stop]()
        
        let getDeparturesGroup = dispatch_group_create()
        if (stops.count > 0){
            for stop in stops {
                // räkna ut avstånd
                let stopLat = (stop.lat as NSString).doubleValue
                let stopLong = (stop.long as NSString).doubleValue
                let userLocation = CLLocation(latitude: lat, longitude: long)
                let stopLocation = CLLocation(latitude: stopLat, longitude: stopLong)
                let distance = userLocation.distanceFromLocation(stopLocation)
                
                let roundDistance = roundToFive(distance)
                stop.distance = roundDistance
            }
            
            // sortera baserat på avstånd
            //stops.sortInPlace({ $0.distance != $1.distance ? $0.distance < $1.distance : $0.id < $1.id})
            
            // hämta upp till 5 st stops inom 300 meter eller upp till 2 stops i övriga fall
            for stop in stops {
                if (closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000){
                    closestStops.append(stop)
                }
                else{
                    break
                }
            }
            
            for stop in closestStops {
                let linesAtStop = RealmService.sharedInstance.getLinesAtStopArr(stop.id)
                
                // hämta departures via Västtrafik api
                dispatch_group_enter(getDeparturesGroup)
                getDeparturesFromStop(stop.id, onCompletion: { departures -> Void in
                    
                    stop.departures = [Departure]()
                    
                    for line in linesAtStop {
                        for departure in departures{
                            if (departure.sname != line.sname || departure.track != line.track || departure.direction != line.direction) {
                                continue
                            }
                            else{
                                stop.departures?.append(departure)
                            }
                        }
                    }
                    dispatch_group_leave(getDeparturesGroup)
                })
            }
            // vänta tills alla departures är hämtade
            dispatch_group_wait(getDeparturesGroup, DISPATCH_TIME_FOREVER)
        }
        
        return closestStops
    }
    
    func roundToFive(x : Double) -> Int {
        return 5 * Int(round(x / 5.0))
    }
}