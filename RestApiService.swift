//
//  RestApiManager.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Alamofire
import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

extension Int  {
    var day: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Calendar.union(.Day))
    }
}

class RestApiService: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    static let sharedInstance = RestApiService()
    
    // v2
    func getNearestStops(lat: String, long: String, onCompletion: (JSON) -> Void){
        let url = "\(Constants.VTurl)location.nearbystops?originCoordLat=\(lat)&originCoordLong=\(long)&maxNo=50&MaxDist=3000&format=json"
        
        getToken(url, onCompletion: {json in
            onCompletion(json as JSON)
        })
    }
    
    // v2
    func findStops(userInput: String, onCompletion: (JSON) -> Void){
        let escapedUserInput = userInput.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = "\(Constants.VTurl)location.name?input=\(escapedUserInput)&format=json"
        
        getToken(url, onCompletion: {json in
            return json
        })
    }
    
    // v2
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
        let timeString = formatterTime.stringFromDate(date)
        var url = "\(Constants.VTurl)departureBoard?id=\(stopId)&date=\(dateString)&time=\(timeString)&timeSpan=60&maxDeparturesPerLine=1&format=json"
        
        getToken(url, onCompletion: {json in
            let result = json["DepartureBoard"]["Departure"]
            if (result.count == 0){
                var dateString = formatterDate.stringFromDate(date)
                date = DateHelper.get(DateHelper.SearchDirection.Next, "Monday")
                dateString = formatterDate.stringFromDate(date)
                
                url = "\(Constants.VTurl)departureBoard?id=\(stopId)&date=\(dateString)&time=\(timeString)&timeSpan=60&maxDeparturesPerLine=1&format=json"
                self.makeHTTPGetRequest(url, onCompletion: { json, err in
                    onCompletion(json as JSON)
                })
                return
            }
            onCompletion(json as JSON)
        })
    }
    
    // v2
    func getDeparturesAtStop (stopId: String, onCompletion: (JSON) -> Void){
        let date = NSDate()
        let dateFormattera = NSDateFormatter()
        dateFormattera.dateFormat = "EEEE"
        
        let formatterTime = NSDateFormatter()
        formatterTime.timeStyle = .ShortStyle //Set style of time
        formatterTime.dateFormat = "HH:mm"
        
        let formatterDate = NSDateFormatter()
        formatterDate.dateStyle = .ShortStyle //Set style of date
        formatterDate.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatterDate.stringFromDate(date) //Convert to String
        let timeString = formatterTime.stringFromDate(date)
        
        let escapedString = timeString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let url = "\(Constants.VTurl)departureBoard?id=\(stopId)&date=\(dateString)&time=\(escapedString)&timeSpan=60&maxDeparturesPerLine=2&format=json"
        
        getToken(url, onCompletion: {json in
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
    
    private func getToken(url: String, onCompletion: (JSON) -> Void){
        let data = Constants.VTkeysecret.dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.vasttrafik.se/token")!)
        request.HTTPMethod = "POST"
        let bodyData = "grant_type=client_credentials&scope=\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = 15
        urlconfig.timeoutIntervalForResource = 15
        let session = NSURLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if data == nil{
                print(error!)
                return
            }
            let json:JSON = JSON(data: data!)
            NSUserDefaults(suiteName: "group.tajma.today")!.setObject(json["access_token"].string!, forKey: "token")
            print("Token " + NSUserDefaults(suiteName: "group.tajma.today")!.stringForKey("token")!)
            
            self.makeHTTPGetRequest(url, onCompletion: { json, err in
                onCompletion(json as JSON)
            })
        })
        task.resume()
    }
    
    private func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        print("Bearer \(NSUserDefaults(suiteName: "group.tajma.today")!.stringForKey("token")!)")
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.addValue("Bearer \(NSUserDefaults(suiteName: "group.tajma.today")!.stringForKey("token")!)", forHTTPHeaderField: "Authorization")
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = 15
        urlconfig.timeoutIntervalForResource = 15
        let session = NSURLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if data == nil{
                print(error)
                onCompletion(nil, error)
                return
            }
            onCompletion(JSON(data: data!), error)
        })
        task.resume()
    }
}