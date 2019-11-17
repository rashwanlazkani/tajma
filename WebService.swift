//
//  RestApiManager.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Alamofire
import Foundation
import MapKit
import UIKit

class WebService {
    func getStops(userInput: String? = nil, location: CLLocationCoordinate2D? = nil, onCompletion: @escaping ([Stop]) -> Void, onError: @escaping (Error) -> Void) {
        
        var url = ""
        if let userInput = userInput {
            let escapedUserInput = userInput.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            url = "\(Constants.restURL)location.name?input=\(escapedUserInput)&format=json"
        } else if let location = location {
            url = "\(Constants.restURL)location.nearbystops?originCoordLat=\(location.latitude)&originCoordLong=\(location.longitude)&maxNo=50&MaxDist=3000&format=json"
        }
        
        checkToken { (token) in
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { response in
                    do {
                        if
                            let json = response.result.value as? [String: Any],
                            let locationList = json["LocationList"] as? [String:Any],
                            let stopsLocation = locationList["StopLocation"] as? [[String:AnyObject]] {
                            let data = try JSONSerialization.data(withJSONObject: stopsLocation, options: .prettyPrinted)
                            let stops = try JSONDecoder().decode(Array<Stop>.self, from: data).sorted(by: { $0.name == $1.name }).orderedSetValue
                            stops.forEach { (stop) in
                                stop.id = stop.id.customizeStopID
                            }
                            onCompletion(stops)
                            return
                        }
                        
                    } catch {
                        print(error)
                        onError(error)
                    }
                    onError(NSError(domain: "Kunde inte hämta avgångar, försök igen.", code: 500, userInfo: nil))
            }
        }
    }
    
    func getDeparturesAtStop (_ stopId: String, isMyDeparture: Bool = false, onCompletion: @escaping ([Line]) -> Void, onError: @escaping (Error) -> Void) {
        let url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(Date().customDate)&time=\(Date().customTime)&timeSpan=60&maxDeparturesPerLine=2&format=json"
        
        checkToken { (token) in
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            
            Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { response in
                    do {
                        if
                            let json = response.result.value as? [String: Any],
                            let departureBoard = json["DepartureBoard"] as? [String:Any],
                            let departuresJson = departureBoard["Departure"] as? [[String:Any]],
                            let serverDate = departureBoard["serverdate"] as? String,
                            let serverTime = departureBoard["servertime"] as? String {
                            //let data = try JSONSerialization.data(withJSONObject: departuresJson, options: .prettyPrinted)
                            //let lines = try JSONDecoder().decode(Array<Line>.self, from: data)
                            
                            var lines = [Line]()
                            let departures = Departure()
                            let dbLines = DbService.sharedInstance.getLinesAtStop(stopId)
                            for object in departuresJson {
                                if object["rtTime"] == nil && object["time"] == nil {
                                    continue
                                }
                                if object["rtDate"] == nil && object["date"] == nil {
                                    continue
                                }
                                
                                guard
                                    let name = object["name"] as? String,
                                    let sname = object["sname"] as? String,
                                    let direction = object["direction"] as? String,
                                    let type = object["type"] as? String,
                                    let fgColor  = object["fgColor"] as? String,
                                    let bgColor  = object["bgColor"] as? String
                                    else { continue }
                                
                                let track = object["track"] as? String ?? ""
                                let time = object["rtTime"] ?? json["time"]
                                let date = object["rtDate"] ?? json["date"]
                                let dateTime = "\(date!) \(time!)"
                                
                                let serverDateTime = "\(serverDate) \(serverTime)"
                                
                                guard
                                    let departureTimeDate = dateTime.date,
                                    let serverTimeDate = serverDateTime.date
                                    else { continue }
                                
                                let intervalBetweenDepartures = departureTimeDate.timeIntervalSince(serverTimeDate) / 60
                                departures.times.append(Int(intervalBetweenDepartures))
                                
                                let id = "\(stopId)-\(sname)-\(direction)"
                                let lineAndDirection = ("\(sname) \(direction)").subStringSnameAndDirection
                                let line = Line(id: id, stop: Stop(), stopId: stopId, lineAndDirection: lineAndDirection, name: name, sname: sname, direction: direction, type: type, track: track, bgColor: bgColor, fgColor: fgColor, departures: Departure())
                                
                                if isMyDeparture && dbLines.firstOrDefault({$0.id == id}) == nil {
                                    continue
                                }
                                
                                let currentLine = lines.filter({$0.id == id })
                                if  currentLine.isEmpty {
                                    line.departures.times.append(Int(intervalBetweenDepartures))
                                    lines.append(line)
                                } else {
                                    currentLine[0].departures.times.append(Int(intervalBetweenDepartures))
                                }
                            }
                            
                            let numberLines = lines.filter({ Int($0.sname) != nil }).sorted(by: {Int($0.sname)! < Int($1.sname)!})
                            let charLines = lines.filter({Int($0.sname) == nil}).sorted(by: {$0.sname < $1.sname})
                            onCompletion(numberLines + charLines)
                            return
                        }
                    }
                    onError(NSError(domain: "Kunde inte hämta avgångar, försök igen.", code: 500, userInfo: nil))
            }
        }
        
    }
    
    func getMyDepartures(_ coordinate: CLLocationCoordinate2D, onCompletion: @escaping ([Stop]) -> Void, onError: @escaping (NSError) -> Void) {
        let group = DispatchGroup()
        var stops = DbService.sharedInstance.getStops()
        
        for stop in stops{
            stop.distance = DistanceHelper.calculate(stop, lat: coordinate.latitude, long: coordinate.longitude)
        }
        stops.sort(by: { $0.distance != $1.distance ? $0.distance < $1.distance : $0.id < $1.id})
        
        var closestStops = [Stop]()
        for stop in stops {
            if closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000 {
                group.enter()
                getDeparturesAtStop(stop.id, isMyDeparture: true, onCompletion: { (lines) -> Void in  defer { group.leave() }
                    stop.lines = lines
                    closestStops.append(stop)
                }) { (error) -> Void in  defer { group.leave() }
                    print(error)
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main, execute: {
            onCompletion(closestStops.sorted(by: { $0.distance < $1.distance}))
        })
    }
    
    private func getToken(onCompletion: @escaping (String) -> Void) {
        let data = ("\(Constants.key):\(Constants.secret)").data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        let parameters = [
            "grant_type": "client_credentials",
            "scope": "\(UIDevice.current.identifierForVendor!.uuidString)"
        ]
        
        let headers = [
            "Authorization": "Basic \(base64)",
        ]
        
        Alamofire.request(Constants.tokenURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.result.value as? [String: Any] {
                    if let token = json["access_token"] as? String, let expires = json["expires_in"] as? Int {
                        UserDefaults.standard.set(token, forKey: "token")
                        UserDefaults.standard.set(Date().addSeconds(expires), forKey: "expires")
                        onCompletion(token)
                    }
                } else {
                    print(response.description)
                }
        }
    }
    
    private func checkToken(onCompletion: @escaping (String) -> Void) {
        if let tokenDate = UserDefaults.standard.object(forKey: "expires") as? Date, let token = UserDefaults.standard.string(forKey: "token"), tokenDate > Date() {
            print(tokenDate)
            onCompletion(token)
        } else {
            getToken { (token) in
                onCompletion(token)
            }
        }
    }

    private func trimSname(_ sname: String) -> String{
        return sname.replacingOccurrences(of: "SVAR", with: "SVART")
    }
}

private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}
