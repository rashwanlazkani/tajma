//
//  RestApiManager.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

extension Int  {
    var day: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Calendar.union(.Day))
    }
}

class RestApiService: NSObject {
    static let sharedInstance = RestApiService()
    
    func getNearestStops(lat: String, long: String, onCompletion: (JSON) -> Void){
        let url = "\(Constants.VTurl)location.nearbystops?authKey=\(Constants.VTauth)&format=json&originCoordLat=\(lat)&originCoordLong=\(long)&maxNo=50&MaxDist=3000"
        
        makeHTTPGetRequest(url, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func findStops(userInput: String, onCompletion: (JSON) -> Void){
        let escapedUserInput = userInput.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = "\(Constants.VTurl)location.name?authKey=\(Constants.VTauth)&format=json&input=\(escapedUserInput)"
        
        makeHTTPGetRequest(url, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func findLinesOnStopAtTime (stopId: String, onCompletion: (JSON) -> Void){
        let date = NSDate()
        let formatterTime = NSDateFormatter()
        formatterTime.timeStyle = .ShortStyle
        formatterTime.dateFormat = "HH:mm"
        let timeString = formatterTime.stringFromDate(date)
        
        let formatterDate = NSDateFormatter()
        formatterDate.dateStyle = .ShortStyle
        formatterDate.dateFormat = "yyyy-MM-dd"
        let dateString = formatterDate.stringFromDate(date)
    
        let url = "\(Constants.VTurl)departureBoard?authKey=\(Constants.VTauth)&format=json&id=\(stopId)&date=\(dateString)&time=\(timeString)"
        
        makeHTTPGetRequest(url, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func findAllLinesOnStop (stopId: String, onCompletion: (JSON) -> Void){
        var date = NSDate()
        let dateFormattera = NSDateFormatter()
        dateFormattera.dateFormat = "EEEE"
        
        let formatterTime = NSDateFormatter()
        formatterTime.timeStyle = .ShortStyle //Set style of time
        formatterTime.dateFormat = "HH:mm"

        let formatterDate = NSDateFormatter()
        formatterDate.dateStyle = .ShortStyle //Set style of date
        formatterDate.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatterDate.stringFromDate(date) //Convert to String
        
        var url = "\(Constants.VTurl)departureBoard?authKey=\(Constants.VTauth)&format=json&id=\(stopId)&date=\(dateString)"
        
        makeHTTPGetRequest(url, onCompletion: { json, err in
            let result = json["DepartureBoard"]["Departure"]
            if (result.count == 0){
                var dateString = formatterDate.stringFromDate(date)
                date = DateHelper.get(DateHelper.SearchDirection.Next, "Monday")
                dateString = formatterDate.stringFromDate(date)
                
                url = "\(Constants.VTurl)departureBoard?authKey=\(Constants.VTauth)&format=json&id=\(stopId)&date=\(dateString)"
                self.makeHTTPGetRequest(url, onCompletion: { json, err in
                    onCompletion(json as JSON)
                })
                return
            }
            onCompletion(json as JSON)
        })
    }
    
    func getDeparturesAtStop (stopId: String, onCompletion: (JSON) -> Void){
        let url = "\(Constants.VTurl)departureBoard?authKey=\(Constants.VTauth)&format=json&id=\(stopId)&timeSpan=120&maxDeparturesPerLine=2"
        
        makeHTTPGetRequest(url, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func twitchTest (stopId: String, onCompletion: (JSON) -> Void){
        let url = "http://pastebin.com/nRp92hyd"
        
        makeHTTPGetRequest(url, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    private func addDays(date: NSDate, additionalDays: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = additionalDays
        
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
        return futureDate!
    }
    
    private func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        let session = NSURLSession.sharedSession()
        
        session.configuration.timeoutIntervalForRequest = 0.000001
        session.configuration.timeoutIntervalForResource = 0.000001
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume()
    }
}