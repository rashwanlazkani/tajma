//
//  RestApiManager.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

typealias ServiceResponse = (NSData, NSError?) -> Void

class RestApiService: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    static let sharedInstance = RestApiService()

    func getNearestStops(lat: String, long: String, onCompletion: ([String: AnyObject]) -> Void){
        let link = "\(Constants.restURL)location.nearbystops?originCoordLat=\(lat)&originCoordLong=\(long)&maxNo=50&MaxDist=3000&format=json"
        
        getToken(link, onCompletion: {jsonDic in
            print("jsonDic:", jsonDic)
            onCompletion(jsonDic)
        })
    }
    
    func findStops(userInput: String, onCompletion: ([String: AnyObject]) -> Void){
        let escapedUserInput = userInput.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = "\(Constants.restURL)location.name?input=\(escapedUserInput)&format=json"
        
        getToken(url, onCompletion: {json in
            onCompletion(json)
        })
    }
    
    func findAllLinesOnStop (stopId: String, onCompletion: ([String: AnyObject]) -> Void){
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
        let url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(dateString)&time=\(timeString)&timeSpan=60&maxDeparturesPerLine=1&format=json"
        
        getToken(url, onCompletion: {data in
            onCompletion(data)
            
            
//            let result = json["DepartureBoard"]["Departure"]
//            if (result.count == 0){
//                var dateString = formatterDate.stringFromDate(date)
//                date = DateHelper.get(DateHelper.SearchDirection.Next, "Monday")
//                dateString = formatterDate.stringFromDate(date)
//                
//                url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(dateString)&time=\(timeString)&timeSpan=60&maxDeparturesPerLine=1&format=json"
//                
//                self.getToken(url, onCompletion: {json in
//                    onCompletion(json as NSData)
//                })
//                return
//            }
            
        })
    }
    
    func getDeparturesAtStop (stopId: String, onCompletion: ([String: AnyObject]) -> Void){
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
        
        let escapedString = timeString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        
        let url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(dateString)&time=\(escapedString)&timeSpan=60&maxDeparturesPerLine=2&format=json"
        
        getToken(url, onCompletion: {json in
            print(json)
            onCompletion(json)
        })
        
        
    }
    
    private func addDays(date: NSDate, additionalDays: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = additionalDays
        
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
        return futureDate!
    }
    
    private func getToken(url: String, onCompletion: ([String: AnyObject]) -> Void){
        let data = ("\(Constants.key):\(Constants.secret)").dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        let parameters = [
            "grant_type": "client_credentials",
            "scope": "\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
        ]
        
        let headers = [
            "Authorization": "Basic \(base64)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        Alamofire.request(.POST, Constants.tokenURL, parameters: parameters, headers: headers, encoding: .URLEncodedInURL)
            .responseJSON { response in
                if let json = response.result.value {
                    if let token = json["access_token"]!{

                        let headers = [
                            "Authorization": "Bearer \(token)",
                            "Content-Type": "application/x-www-form-urlencoded"
                        ]
                        
                        Alamofire.request(.GET, url, headers: headers, encoding: .JSON)
                            .responseJSON { response in
                                switch response.result {
                                case .Success:
                                    print("data:\n", response.data?.json.dictionary?["LocationList"] )
                                    guard let dic = response.data?.json.dictionary?["LocationList"] as? [String:AnyObject] else { return }
                                    print("dic:", dic)
                                    onCompletion(dic)
                                case .Failure(let error):
                                    print(error)
                                    //onCompletion(error)
                                }
                        }
                    }
                }
                else{
                    print(response.description)
                }
        }
    }
}

extension NSData {
    var string: String {
        return String(data: self, encoding: NSUTF8StringEncoding) ?? ""
    }
    var json: (dictionary: [String: AnyObject]?, array: [AnyObject]?) {
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(self, options: .AllowFragments)
            return (jsonObject as? [String: AnyObject], jsonObject as? [AnyObject])
        } catch let error as NSError {
            print("JSONSerialization error")
            print("error.code = ",error.code)
            print("error.domain = ",error.domain)
            return (nil,nil)
        }
    }
}
