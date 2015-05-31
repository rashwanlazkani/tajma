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
        return (self, NSCalendarUnit.CalendarUnitDay)
    }
}

class RestApiService: NSObject {
    
    // Singleton
    static let sharedInstance = RestApiService()
    
    func getNearestStops(lat: String, long: String, onCompletion: (JSON) -> Void){
        let route = "http://api.vasttrafik.se/bin/rest.exe/v1/location.nearbystops?authKey=1172d818-c330-435c-897c-9830750341c0&format=json&originCoordLat=\(lat)&originCoordLong=\(long)&maxNo=50&MaxDist=3000"
        
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
        
    }
    
    func findStops(userInput: String, onCompletion: (JSON) -> Void){
        var escapedUserInput = userInput.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let route = "http://api.vasttrafik.se/bin/rest.exe/v1/location.name?authKey=1172d818-c330-435c-897c-9830750341c0&format=json&input=\(escapedUserInput)"

        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
        
    }
    
    func findLinesOnStopAtTime (stopId: String, onCompletion: (JSON) -> Void){
        
        let date = NSDate() //Get current date
        //Formatter for time
        let formatterTime = NSDateFormatter()
        formatterTime.timeStyle = .ShortStyle //Set style of time
        formatterTime.dateFormat = "HH:mm"
        var timeString = formatterTime.stringFromDate(date) //Convert to String
        
        //Formatter for date
        let formatterDate = NSDateFormatter()
        formatterDate.dateStyle = .ShortStyle //Set style of date
        formatterDate.dateFormat = "yyyy-MM-dd"
        var dateString = formatterDate.stringFromDate(date) //Convert to String
        
        
        let route = "http://api.vasttrafik.se/bin/rest.exe/v1/departureBoard?authKey=1172d818-c330-435c-897c-9830750341c0&format=json&id=\(stopId)&date=\(dateString)&time=\(timeString)"
        
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
        
    }
    
    func findAllLinesOnStop (stopId: String, onCompletion: (JSON) -> Void){
        var date = NSDate() //Get current date
        
        // Get current day
        let dateFormattera = NSDateFormatter()
        dateFormattera.dateFormat = "EEEE"
        let dayOfWeekString = dateFormattera.stringFromDate(date)
        if (dayOfWeekString == "Saturday"){
            addDays(date, additionalDays: 2)
        }
        else if (dayOfWeekString == "Sunday"){
            date = addDays(date, additionalDays: 1)
        }
        
        //Formatter for time
        let formatterTime = NSDateFormatter()
        formatterTime.timeStyle = .ShortStyle //Set style of time
        formatterTime.dateFormat = "HH:mm"
        var timeString = formatterTime.stringFromDate(date) //Convert to String
        
        //Formatter for date
        let formatterDate = NSDateFormatter()
        formatterDate.dateStyle = .ShortStyle //Set style of date
        formatterDate.dateFormat = "yyyy-MM-dd"
        
        var dateString = formatterDate.stringFromDate(date) //Convert to String
        
        let route = "http://api.vasttrafik.se/bin/rest.exe/v1/departureBoard?authKey=1172d818-c330-435c-897c-9830750341c0&format=json&id=\(stopId)&date=\(dateString)"
        
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
        
    }
    
    func getDeparturesAtStop (stopId: String, onCompletion: (JSON) -> Void){
        let route = "http://api.vasttrafik.se/bin/rest.exe/v1/departureBoard?authKey=1172d818-c330-435c-897c-9830750341c0&format=json&id=\(stopId)&timeSpan=120&maxDeparturesPerLine=2"
        
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func addDays(date: NSDate, additionalDays: Int) -> NSDate {
        // adding $additionalDays
        var components = NSDateComponents()
        components.day = additionalDays
        
        // important: NSCalendarOptions(0)
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
        return futureDate!
    }
    
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data)
            onCompletion(json, error)
        })
        task.resume()
    }
}