//
//  LineService.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-06.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

open class LineService{
    var lines = [Line]()
    var dbLines = [Line]()
    
    func getAllLinesAtStop(_ stopId: String, onSuccess: @escaping ([Line]) -> Void, onError: @escaping (NSError) -> Void){
        ApiService.sharedInstance.findAllLinesOnStop(stopId) { jsonDictionary in
            self.dbLines = DbService.sharedInstance.getLinesAtStop(stopId)
            
            if let jsonLines = jsonDictionary["Departure"] as? [[String:AnyObject]] {
                for json in jsonLines{
                    self.getLine(stopId: stopId, json: json)
                }
            }
            else if let jsonLine = jsonDictionary["Departure"] as? [String:AnyObject] {
                self.getLine(stopId: stopId, json: jsonLine)
            }
            else {
                return onError(NSError(domain: "Inga stopp hittades", code: 1, userInfo: nil))
            }
            
            let numberLines = self.lines.filter({Int($0.sname) != nil}).sorted(by: {Int($0.sname)! < Int($1.sname)})
            let charLines = self.lines.filter({Int($0.sname) == nil}).sorted(by: {$0.sname < $1.sname})
            
            if !numberLines.isEmpty || !charLines.isEmpty {
                return onSuccess(numberLines + charLines)
            }
            else {
                return onError(NSError(domain: "Inga stopp hittades", code: 1, userInfo: nil))
            }
        }
    }
    
    func getLine(stopId: String, json: [String:Any]) {
        var line = Line()
        
        guard let name = json["name"] as? String,
            let sname = json["sname"] as? String,
            let direction = json["direction"] as? String,
            let type = json["type"] as? String,
            let fgColor  = json["fgColor"] as? String,
            let bgColor  = json["bgColor"] as? String
            else { return }
        
        if type != "VAS"{
            guard let track = json["track"] as? String else { return }
            line.track = track
        }
        else{
            line.track = "VAS"
        }
        
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
            //line.track = track
            line.fgColor = fgColor
            line.bgColor = bgColor
            line.lineAndDirection = "\(line.sname) \(line.direction)"
        }
        
        let lineAndDirection = StringHelper.subStringSnameAndDirection(line.lineAndDirection)
        if !lines.filter({$0.lineAndDirection == lineAndDirection}).isEmpty{
            return
        }
        
        lines.append(line)
        
        // om en linje inte går för tillfället så ska vi ändå lägga till den om den är tillagd sedan tidigare
        for dbLine in dbLines{
            let line = lines.firstOrDefault({$0.id == dbLine.id})
            if line == nil{
                lines.append(dbLine)
            }
        }
    }
}
