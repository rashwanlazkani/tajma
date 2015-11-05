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
                return
            }
            else{
                let jsonLines = json["DepartureBoard"]["Departure"]
                var lines = [Line]()
                for (_,subJson):(String, JSON) in jsonLines {
                    let line = Line()
                    line.name = subJson["name"].string!
                    line.sname = subJson["sname"].string ?? ""
                    line.direction = subJson["direction"].string ?? ""
                    line.type = subJson["type"].string!
                    line.track = subJson["track"].string!
                    line.fgColor = subJson["fgColor"].string!
                    line.bgColor = subJson["bgColor"].string!
                    
                    if (line.sname == "" && line.direction == ""){
                        continue
                    }
                    
                    let lineAndDirection = self.subStringSnameAndDirection(line.sname, direction: line.direction)
                    if (from(lines).any{$0.lineAndDirection == lineAndDirection}){
                        continue
                    }
                    
                    lines.append(line)
                    
                }
                lines.sortInPlace({$0.lineAndDirection < $1.lineAndDirection})
                onSuccess(lines)
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