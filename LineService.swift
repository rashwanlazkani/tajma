//
//  LineService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class LineService{
    var dbService = DBService()
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
                
                for (index: String, subJson: JSON) in results {
                    var name = subJson["name"].string
                    var sname = subJson["sname"].string
                    var direction = subJson["direction"].string
                    var type = subJson["type"].string
                    var track = subJson["track"].string
                    
                    if (sname == nil && direction == nil){
                        self.lines.error = "No stop"
                        break
                        
                    }
                    else{
                        var lineAndDirection = self.subStringSnameAndDirection(sname!, direction: direction!, addWhereTo: false)
                        
                        // Kollar så att man endast visar en linje + direction per hållplats
                        if (!contains(tempNames, lineAndDirection)){
                            tempNames.insert(lineAndDirection, atIndex: 0)
                            
                            var line = Line(name: name ?? "", sname: sname ?? "", direction: direction ?? "", type: type ?? "", track: track ?? "", lineAndDirection: lineAndDirection)
                            self.lines.lines.append(line as Line)
                        }
                    }
                    
                    
                }
                
                self.lines.lines.sort({$0.lineAndDirection < $1.lineAndDirection})
                onCompletion(self.lines)
 
            }
        }
    }
    
    // DB
    func getUserLinesAtStop(stopId: String){
        dbService.getLinesAtStop(stopId)
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

                for (index: String, subJson:JSON) in departureBoard{
                    serverTimeStr = subJson["servertime"].string!
                }
                
                let results = json["DepartureBoard"]["Departure"]
                
                var tempNames = [String]()
                
                for (index: String, subJson: JSON) in results {
                    var stopId = subJson["stopId"].string
                    var sname = subJson["sname"].string
                    var direction = subJson["direction"].string
                    var departure = subJson["rtTime"].string
                    
                    var lineAndDirection = sname! + " " + direction!
                    lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Buss", withString: "")
                    lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Spårvagn", withString: "")
                    lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
                    
                    if (!contains(tempNames, lineAndDirection)){
                        tempNames.insert(lineAndDirection, atIndex: 0)
                        
                        let serverTime = dateFormatter.dateFromString(serverTimeStr) as NSDate!
                        let departureTime = dateFormatter.dateFromString(departure!) as NSDate!
                        
                        let interval = String(stringInterpolationSegment: departureTime.timeIntervalSinceDate(departureTime))
                        
                        var line = LinesAtStop(stopId: stopId!, lineAndDirection: lineAndDirection, departure: interval)
                        self.lines.departures.append(line)
                    }
                    
                }
                
                self.lines.lines.sort({$0.lineAndDirection < $1.lineAndDirection})
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