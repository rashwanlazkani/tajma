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
        let url = "\(Constants.restURL)location.nearbystops?originCoordLat=\(lat)&originCoordLong=\(long)&maxNo=50&MaxDist=3000&format=json"
        
        getToken(url, isDeparture: false, onCompletion: {jsonDictionary in
            onCompletion(jsonDictionary)
        })
    }
    
    func findStops(userInput: String, onCompletion: ([String: AnyObject]) -> Void){
        let escapedUserInput = userInput.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = "\(Constants.restURL)location.name?input=\(escapedUserInput)&format=json"
        
        getToken(url, isDeparture: false, onCompletion: {jsonDictionary in
            onCompletion(jsonDictionary)
        })
    }
    
    func findAllLinesOnStop (stopId: String, onCompletion: ([String: AnyObject]) -> Void){
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
        var url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(dateString)&time=\(timeString)&timeSpan=60&maxDeparturesPerLine=1&format=json"
        // here we wnt to get the stops so departure is true
        getToken(url, isDeparture: true, onCompletion: {jsonDictionary in
            guard let jsonStops = jsonDictionary["Departure"] as? [[String:AnyObject]]
                else { return }
            
            if jsonStops.count == 0{
                var dateString = formatterDate.stringFromDate(date)
                date = DateHelper.get(DateHelper.SearchDirection.Next, "Monday")
                dateString = formatterDate.stringFromDate(date)
                
                url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(dateString)&time=\(timeString)&timeSpan=60&maxDeparturesPerLine=1&format=json"
                //okdo you need to pass on completion if it isDeparture? I think would be easier to detect the key
                self.getToken(url, isDeparture: true, onCompletion: {jsonDictionary in
                    onCompletion(jsonDictionary)
                })
                return
            }
            else{
                //print("findAllLinesOnStop:", jsonStops)
                onCompletion(jsonDictionary)
            }
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
        
        getToken(url, onCompletion: {jsonDictionary in
            onCompletion(jsonDictionary)
        })
        
        
    }
    
    private func addDays(date: NSDate, additionalDays: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = additionalDays
        
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
        return futureDate!
    }
    
    private func getToken(url: String, isDeparture: Bool = true, onCompletion: ([String: AnyObject]) -> Void){
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
                                    guard let keys = response.data?.json.dictionary?.keys else { return }
                                    let keysArray = keys.map{String($0) }
                                    //print("keys:",keysArray)
                                    //print("LoopLoop")
                                    for k in keys {
                                        //print(k)
                                    }
//                                   print("data:\n", response.data?.json.dictionary?["LocationList"] )
                                    var dic:[String:AnyObject]?
                                    // Should I or you write the code here?
                                    // Now it´s not working at all hmm
                                    print("isDeparture:", isDeparture)
                                    
                                    if isDeparture {
                                        dic = response.data?.json.dictionary?["DepartureBoard"] as? [String:AnyObject]
                                        //print("departureDic:", dic)  //  1 sec Optional(["Departure"
                                      } else {
                                        dic = response.data?.json.dictionary?["LocationList"] as? [String:AnyObject]
                                    }
                                    
                                    if let dic = dic  {
                                        print("Returning dic")
                                        onCompletion(dic)
                                    } else {
                                        print("failed with returning dic:")
                                        return
                                    }
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
