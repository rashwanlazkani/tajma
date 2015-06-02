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
    
    var dbService = DBService()
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
            
            for (index: String, subJson: JSON) in results {
                var stopId = subJson["stopid"].string!
                var sname = subJson["sname"].string!
                var track = subJson["track"].string ?? ""
                var direction = subJson["direction"].string!
                
                var rtTimeFromServer = subJson["rtTime"].string! ?? subJson["time"].string!

                var rtTime = [subJson["rtDate"].string! + " " + rtTimeFromServer]
                
                let serverTime = dateFormatter.dateFromString(serverDate) as NSDate!
                let departureTime = dateFormatter.dateFromString(rtTime[0]) as NSDate!
                
                let intervalBetweenDepartures = Int(departureTime.timeIntervalSinceDate(serverTime) / 60) - 1
                
                var departure = Departure(stopId: stopId, sname: sname, track: track, direction: direction, rtTimes: [intervalBetweenDepartures])
                tempDepartures.append(departure)
            }
            
            tempDepartures.sort({ $0.sname != $1.sname ? $0.sname < $1.sname : $0.track < $1.track})
            
            var previousSname = ""
            var previousTrack = ""
            for row in tempDepartures {
                
                var existingStop = self.stopService.checkIfUserHasAddedStop(stopId)
                
                
//                if (!existingStop.name.isEmpty){
//                }
//                else{
//                }
                
                
                var departure : Departure
                
                
                if (previousSname == row.sname && previousTrack == row.track) {
                    departure = self.departures[self.departures.count - 1]
                    departure.rtTimes.append(row.rtTimes[0])
                }
                else {
                    departure = Departure(stopId: row.stopId, sname: row.sname, track: row.track, direction: row.direction, rtTimes: row.rtTimes)
                    self.departures.append(departure)
                }
                
                
                previousSname = row.sname
                previousTrack = row.track
            }
            
            onCompletion(self.departures)
        }
    }
    
    func roundToTwentyFive(x : Double) -> Int {
        return 25 * Int(round(x / 25.0))
    }
    
    func getMyDepartures(lat: Double, long: Double) -> [Stop] {
        
        println("LAT")
        println(lat)
        println("LONG")
        println(long)
        
        
        var stops = dbService.getStops()
        var closestStops = [Stop]()
        
        //- getMyDestination
        //-   hämtar mina stops från db
        //-   hämtar departures via Västtrafi api
        //-   räkna ut avstånd
        //-   merga stops med departures
        //-   sortera baserat på avstånd
        //-   returnera samlat objekt tillbaka hit
        
        
        var getDeparturesGroup = dispatch_group_create()
        
        // Hämta x närmaste hållplatser i närheten
        if (stops.count > 0){
            
            for stop in stops {
                // räkna ut avstånd
                var stopLat = (stop.lat as NSString).doubleValue
                var stopLong = (stop.long as NSString).doubleValue
                
                var userLocation = CLLocation(latitude: lat, longitude: long)
                var stopLocation = CLLocation(latitude: stopLat, longitude: stopLong)
                var distance = userLocation.distanceFromLocation(stopLocation)
                
                var roundDistance = roundToTwentyFive(distance)
                
                stop.distance = roundDistance
            }
            
            // sortera baserat på avstånd
            stops.sort({ $0.distance != $1.distance
                ? $0.distance < $1.distance
                : $0.id < $1.id})
            
            // hämta upp till 5 st stops inom 300 meter eller upp till 2 stops i övriga fall
            for stop in stops {
                if (closestStops.count < 5 && stop.distance <= 300 || closestStops.count < 2 && stop.distance < 1000){
                    closestStops.append(stop)
                }
                else{
                    break
                }
            }
            
            for stop in closestStops {
                let linesAtStop = dbService.getLinesAtStopArr(stop.id)

                // hämta departures via Västtrafik api
                dispatch_group_enter(getDeparturesGroup)
                getDeparturesFromStop(stop.id, onCompletion: { departures -> Void in
                    
                    stop.departures = [Departure]()
                    
                    
                    for line in linesAtStop {
                    
                        for departure in departures{
                            if (departure.sname != line.sname || departure.track != line.track) {
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
}