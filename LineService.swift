//
//  LineService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class LineService{
    var lineWrapper = LineWrapper()
    
    func getAllLinesAtStop(stopId: String, onCompletion: (LineWrapper) -> Void){
        RestApiService.sharedInstance.findAllLinesOnStop(stopId) { json in
            self.lineWrapper.lines = []
            
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.lineWrapper.error = error.domain
                
                onCompletion(self.lineWrapper)
            }
            else{
                let results = json["DepartureBoard"]["Departure"]
                var tempNames = [String]()
                
                for (_,subJson):(String, JSON) in results {
                    let name = subJson["name"].string
                    let sname = subJson["sname"].string
                    let direction = subJson["direction"].string
                    let type = subJson["type"].string
                    let track = subJson["track"].string
                    let fgColor = subJson["fgColor"].string
                    let bgColor = subJson["bgColor"].string
                    
                    if (sname == nil && direction == nil){
                        self.lineWrapper.error = "No stop"
                        break
                    }
                    else{
                        
                        let lineAndDirection = self.subStringSnameAndDirection(sname!, direction: direction!)
                        if (!tempNames.contains(lineAndDirection)){
                            tempNames.insert(lineAndDirection, atIndex: 0)
                            
                            let line = Line()
                            line.name = name ?? ""
                            line.sname = sname ?? ""
                            line.direction = direction ?? ""
                            line.type = type ?? ""
                            line.track = track ?? ""
                            line.fgColor = fgColor ?? ""
                            line.bgColor = bgColor ?? ""
                            line.lineAndDirection = lineAndDirection ?? ""
                            
                            self.lineWrapper.lines.append(line as Line)
                        }
                    }
                }
                self.lineWrapper.lines.sortInPlace({$0.lineAndDirection < $1.lineAndDirection})
                onCompletion(self.lineWrapper)
            }
        }
    }
    
    func getDeparturesAtStop(stopId: String, onCompletion: (LineWrapper) -> Void){
        RestApiService.sharedInstance.getDeparturesAtStop(stopId) { json in
            self.lineWrapper.departures = []
            
            var error = json["LocationList"]
            if (error["error"] == "R0007"){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                self.lineWrapper.error = error.domain
                
                onCompletion(self.lineWrapper)
            }
            else{
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm"

                let results = json["DepartureBoard"]["Departure"]
                var tempNames = [String]()
                
                for (_,subJson):(String, JSON) in results {
                    let stopId = subJson["stopId"].string
                    let sname = subJson["sname"].string
                    let direction = subJson["direction"].string
                    let departure = subJson["rtTime"].string
                    
                    let lineAndDirection = self.subStringSnameAndDirection(sname!, direction: direction!)
                    
                    if (!tempNames.contains(lineAndDirection)){
                        tempNames.insert(lineAndDirection, atIndex: 0)
                    
                        let departureTime = dateFormatter.dateFromString(departure!) as NSDate!
                        let interval = String(stringInterpolationSegment: departureTime.timeIntervalSinceDate(departureTime))
                        
                        let line = LinesAtStop()
                        line.stopId = stopId!
                        line.lineAndDirection = lineAndDirection
                        line.departure = interval
                        
                        self.lineWrapper.departures.append(line)
                    }
                }
                
                self.lineWrapper.lines.sortInPlace({$0.lineAndDirection < $1.lineAndDirection})
                onCompletion(self.lineWrapper)
            }
        }
    }
    
    func subStringSnameAndDirection(sname: String, direction: String) -> String{
        var lineAndDirection : String
        lineAndDirection = sname + " " + direction
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Buss", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Spårvagn", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
        
        return lineAndDirection
    }
}