//
//  LineService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import SINQ

public class LineService{
    func getAllLinesAtStop(stopId: String, onSuccess: ([Line]) -> Void, onError: (NSError) -> Void){
        RestApiService.sharedInstance.findAllLinesOnStop(stopId) { json in
            var error = json["LocationList"]
            if (String(error["error"]) == Constants.VTerrorCode){
                let error = NSError(domain: "FEL", code: 1000, userInfo: nil)
                onError(error)
                print(error)
                return
            }
            else{
                let jsonLines = json["DepartureBoard"]["Departure"]
                var lines = [Line]()
                let dbLines = SqliteService.sharedInstance.getLinesAtStop(stopId)
                
                for (_,subJson):(String, JSON) in jsonLines {
                    let id = "\(stopId)-\(subJson["sname"].string!)-\(subJson["direction"].string!)"

                    var line = Line()
                    let dbLine = from(dbLines).singleOrNil({$0.id == id})
                    if(dbLine != nil){
                        line = dbLine!
                    }
                    else {
                        line.id = id
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
                    if (from(lines).any{$0.lineAndDirection == lineAndDirection}){
                        continue
                    }
                    
                    lines.append(line)
                    
                }
                
                
                
                let numberLines = from(lines).whereTrue({Int($0.sname) != nil})
                let sortedNumberLines = numberLines.sort({Int($0.sname) < Int($1.sname)})
                let charLines = from(lines).whereTrue({Int($0.sname) == nil}).orderBy({$0.lineAndDirection})
    
                var orderedList = [Line]()
                for line in sortedNumberLines{
                    orderedList.append(line)
                }
                for line in charLines{
                    orderedList.append(line)
                }
                onSuccess(orderedList)
            }
        }
    }
    
    func subStringSnameAndDirection(var lineAndDirection: String) -> String{
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Buss", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("Spårvagn", withString: "")
        lineAndDirection = lineAndDirection.stringByReplacingOccurrencesOfString("SVAR", withString: "SVART")
        return lineAndDirection
    }
}