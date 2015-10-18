//
//  LineService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class LineService{
    var lines = LineWrapper()
    
    // Cache
    func getAllLinesAtStop(stopId: String, onCompletion: (LineWrapper) -> Void){
        RestApiService.sharedInstance.findAllLinesOnStop(stopId) { json in
            self.lines.lines = []
            
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                var error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.lines.error = error.domain
                
                onCompletion(self.lines)
            }
            else{
                let results = json["DepartureBoard"]["Departure"]
                
                var tempNames = [String]()
                
                for (key,subJson):(String, JSON) in results {
                    let name = subJson["name"].string
                    let sname = subJson["sname"].string
                    let direction = subJson["direction"].string
                    let type = subJson["type"].string
                    let track = subJson["track"].string
                    let fgColor = subJson["fgColor"].string
                    let bgColor = subJson["bgColor"].string
                    
                    if (sname == nil && direction == nil){
                        self.lines.error = "No stop"
                        break
                        
                    }
                    else{
                        
                        let lineAndDirection = self.subStringSnameAndDirection(sname!, direction: direction!, addWhereTo: false)
                        
                        // Kollar så att man endast visar en linje + direction per hållplats
                        if (!tempNames.contains(lineAndDirection)){
                            tempNames.insert(lineAndDirection, atIndex: 0)
                            
                            // init!
                            //let line = Line(name: name ?? "", sname: sname ?? "", direction: direction ?? "", type: type ?? "", track: track ?? "", fgColor: fgColor ?? "", bgColor: bgColor ?? "", lineAndDirection: lineAndDirection)
                            
                            let line = Line()
                            line.name = name ?? ""
                            line.sname = sname ?? ""
                            line.direction = direction ?? ""
                            line.type = type ?? ""
                            line.track = track ?? ""
                            line.fgColor = fgColor ?? ""
                            line.bgColor = bgColor ?? ""
                            line.lineAndDirection = lineAndDirection ?? ""
                            
                            self.lines.lines.append(line as Line)
                        }
                    }
                    
                    
                }
                
                self.lines.lines.sortInPlace({$0.lineAndDirection < $1.lineAndDirection})
                onCompletion(self.lines)
                
            }
        }
    }
    
    // DB
    func getUserLinesAtStop(stopId: String){
        RealmService.sharedInstance.getLinesAtStop(stopId)
    }
    
    // Live -> WS
    func getDeparturesAtStop(stopId: String, onCompletion: (LineWrapper) -> Void){
        RestApiService.sharedInstance.getDeparturesAtStop(stopId) { json in
            self.lines.departures = []
            
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                var error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.lines.error = error.domain
                
                onCompletion(self.lines)
            }
            else{
                let departureBoard = json["DepartureBoard"]
                var serverTimeStr = ""
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                for (key, subJson):(String, JSON) in departureBoard{
                    serverTimeStr = subJson["servertime"].string!
                }
                
                let results = json["DepartureBoard"]["Departure"]
                
                var tempNames = [String]()
                
                for (key,subJson):(String, JSON) in results {
                    var stopId = subJson["stopId"].string
                    var sname = subJson["sname"].string
                    var direction = subJson["direction"].string
                    var departure = subJson["rtTime"].string
                    
                    var lineAndDirection = sname! + " " + direction!
                    lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Buss", withString: "")
                    lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Spårvagn", withString: "")
                    lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
                    
                    if (!tempNames.contains(lineAndDirection)){
                        tempNames.insert(lineAndDirection, atIndex: 0)
                        
                        let serverTime = dateFormatter.dateFromString(serverTimeStr) as NSDate!
                        let departureTime = dateFormatter.dateFromString(departure!) as NSDate!
                        
                        let interval = String(stringInterpolationSegment: departureTime.timeIntervalSinceDate(departureTime))
                        
                        // init!
                        //var line = LinesAtStop(stopId: stopId!, lineAndDirection: lineAndDirection, departure: interval)
                        
                        var line = LinesAtStop()
                        line.stopId = stopId!
                        line.lineAndDirection = lineAndDirection
                        line.departure = interval
                        
                        self.lines.departures.append(line)
                    }
                    
                }
                
                self.lines.lines.sortInPlace({$0.lineAndDirection < $1.lineAndDirection})
                onCompletion(self.lines)
                
            }
        }
    }
    
    func subStringSnameAndDirection(sname: String, direction: String, addWhereTo: Bool) -> String{
        var lineAndDirection : String
        if (addWhereTo){
            lineAndDirection = sname + " mot " + direction
        }
        else{
            lineAndDirection = sname + " " + direction
        }
        
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Buss", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Spårvagn", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
        
        return lineAndDirection
        
    }
}