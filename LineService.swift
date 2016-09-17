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
        RestApiService.sharedInstance.findAllLinesOnStop(stopId) { jsonDictionary in
            let dbLines = SqliteService.sharedInstance.getLinesAtStop(stopId)
            
            guard let jsonLines = jsonDictionary["Departure"] as? [[String:AnyObject]] else {return}
            var lines = [Line]()
            
            for line in jsonLines{
                guard let name = line["name"] as? String,
                    let sname = line["sname"] as? String,
                    let direction = line["direction"] as? String,
                    let type = line["type"] as? String,
                    let track = line["track"] as? String,
                    let fgColor  = line["fgColor"] as? String,
                    let bgColor  = line["bgColor"] as? String
                else { continue }
                
                var line = Line()
                
                let id = "\(stopId)-\(sname)-\(direction)"
                
                let dbLine = dbLines.firstOrDefault({$0.id == id})
                if(dbLine != nil){
                    line = dbLine!
                }
                else{
                    line.id = id
                    line.stopId = stopId
                    line.name = name
                    line.sname = sname
                    line.direction = direction
                    line.type = type
                    line.track = track
                    line.fgColor = fgColor
                    line.bgColor = bgColor
                    line.lineAndDirection = "\(line.sname) \(line.direction)"
                }
                
                let lineAndDirection = self.subStringSnameAndDirection(line.lineAndDirection)
                if !lines.filter({$0.lineAndDirection == lineAndDirection}).isEmpty{
                    continue
                }
                
                lines.append(line)
                
                // om en linje inte går för tillfället så ska vi ändå lägga till den om den är tillagd sedan tidigare
                for dbLine in dbLines{
                    let line = lines.firstOrDefault({$0.id == dbLine.id})
                    if line == nil{
                        lines.append(dbLine)
                    }
                }
                
                let numberLines = lines.filter({Int($0.sname) != nil}).sort({Int($0.sname)! < Int($1.sname)})
                let charLines = lines.filter({Int($0.sname) == nil}).sort({$0.sname < $1.sname})
                
                onSuccess(numberLines + charLines)
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
