//
//  LineService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

public class LineService{
    func getAllLinesAtStop(stopId: String, onSuccess: ([Line]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.findAllLinesOnStop(stopId) { json in
            let dbLines = SqliteService.sharedInstance.getLinesAtStop(stopId)
            var error = json["LocationList"]
            if (String(error["error"]) == Constants.errorCode){
                onError(NSError(domain: "Fel vid hämtning av linjer (V)", code: 0, userInfo: nil))
                return
            }
            else{
                let jsonLines = json["DepartureBoard"]["Departure"]
                var lines = [Line]()
                
                for (_,subJson):(String, JSON) in jsonLines {
                    let sname = subJson["sname"].string
                    let direction = subJson["direction"].string
                    
                    if (sname == nil || direction == nil){
                        return onError(NSError(domain: "Data till id är nil (linjer)", code: 2, userInfo: nil))
                    }
                    let id = "\(stopId)-\(sname!)-\(direction!)"

                    var line = Line(id: String(), stop: Stop(), stopId: String(), lineAndDirection: String(), name: String(), sname: String(), direction: String(), type: String(), track: String(), bgColor: String(), fgColor: String(), departures: Departure())
                    
                    let dbLine = dbLines.firstOrDefault({$0.id == id})
                    if(dbLine != nil){
                        line = dbLine!
                    }
                    else {
                        line.id = id
                        line.stopId = stopId
                        line.name = subJson["name"].string ?? ""
                        line.sname = subJson["sname"].string ?? ""
                        line.direction = subJson["direction"].string ?? ""
                        line.type = subJson["type"].string ?? ""
                        line.track = subJson["track"].string ?? ""
                        line.fgColor = subJson["fgColor"].string ?? ""
                        line.bgColor = subJson["bgColor"].string ?? ""
                        line.lineAndDirection = "\(line.sname) \(line.direction)"
                    }
                    
                    if (line.sname == "" && line.direction == ""){
                        continue
                    }
                    
                    
                    let lineAndDirection = self.subStringSnameAndDirection(line.lineAndDirection)
                    if !lines.filter({$0.lineAndDirection == lineAndDirection}).isEmpty{
                        continue
                    }
                    
                    lines.append(line)
                }
                
                // om en linje inte går för tillfället så ska vi ändå lägga till den om den är tillagd sedan tidigare
                for dbLine in dbLines{
                    let line = lines.firstOrDefault({$0.id == dbLine.id})
                    if line == nil{
                        lines.append(dbLine)
                    }
                }
            
                let numberLines = lines.filter({Int($0.sname) != nil})
                let sortedNumberLines = numberLines.sort({Int($0.sname)! < Int($1.sname)})
                let charLines = lines.filter({Int($0.sname) == nil})
                let sortedCharLines = charLines.sort({Int($0.sname) < Int($1.sname)!})
                
                var orderedList = [Line]()
                for line in sortedNumberLines{
                    orderedList.append(line)
                }
                for line in sortedCharLines{
                    orderedList.append(line)
                }
                onSuccess(orderedList)
            }
        }
    }
    
    func subStringSnameAndDirection(lineAndDirection: String) -> String{
        var lineAndDirection = lineAndDirection
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Buss", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Spårvagn", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
        return lineAndDirection
    }
}