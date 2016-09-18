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

typealias ServiceResponse = (Data, NSError?) -> Void

class RestApiService: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    static let sharedInstance = RestApiService()

    func getNearestStops(_ lat: String, long: String, onCompletion: @escaping ([String: AnyObject]) -> Void){
        let url = "\(Constants.restURL)location.nearbystops?originCoordLat=\(lat)&originCoordLong=\(long)&maxNo=50&MaxDist=3000&format=json"
        
        getToken(url, isDeparture: false, onCompletion: {jsonDictionary in
            onCompletion(jsonDictionary)
        })
    }
    
    func findStops(_ userInput: String, onCompletion: @escaping ([String: AnyObject]) -> Void){
        let escapedUserInput = userInput.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = "\(Constants.restURL)location.name?input=\(escapedUserInput)&format=json"
        
        getToken(url, isDeparture: false, onCompletion: {jsonDictionary in
            onCompletion(jsonDictionary)
        })
    }
    
    func findAllLinesOnStop (_ stopId: String, onCompletion: @escaping ([String: AnyObject]) -> Void){
        var date = Date()
        let dateFormattera = DateFormatter()
        dateFormattera.dateFormat = "EEEE"
        
        let formatterTime = DateFormatter()
        formatterTime.timeStyle = .short //Set style of time
        formatterTime.dateFormat = "HH:mm"
        
        let formatterDate = DateFormatter()
        formatterDate.dateStyle = .short //Set style of date
        formatterDate.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatterDate.string(from: date) //Convert to String
        let timeString = formatterTime.string(from: date)
        var url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(dateString)&time=\(timeString)&timeSpan=60&maxDeparturesPerLine=1&format=json"
        // here we wnt to get the stops so departure is true
        getToken(url, isDeparture: true, onCompletion: {jsonDictionary in
            guard let jsonStops = jsonDictionary["Departure"] as? [[String:AnyObject]]
                else { return }
            
            if jsonStops.count == 0{
                var dateString = formatterDate.string(from: date)
                date = DateHelper.get(DateHelper.SearchDirection.next, "Monday")
                dateString = formatterDate.string(from: date)
                
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
    
    func getDeparturesAtStop (_ stopId: String, onCompletion: @escaping ([String: AnyObject]) -> Void){
        let date = Date()
        let dateFormattera = DateFormatter()
        dateFormattera.dateFormat = "EEEE"
        
        let formatterTime = DateFormatter()
        formatterTime.timeStyle = .short //Set style of time
        formatterTime.dateFormat = "HH:mm"
        
        let formatterDate = DateFormatter()
        formatterDate.dateStyle = .short //Set style of date
        formatterDate.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatterDate.string(from: date) //Convert to String
        let timeString = formatterTime.string(from: date)
        
        let escapedString = timeString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(dateString)&time=\(escapedString)&timeSpan=60&maxDeparturesPerLine=2&format=json"
        
        getToken(url, onCompletion: {jsonDictionary in
            onCompletion(jsonDictionary)
        })
        
        
    }
    
    fileprivate func addDays(_ date: Date, additionalDays: Int) -> Date {
        var components = DateComponents()
        components.day = additionalDays
        
        let futureDate = (Calendar.current as NSCalendar)
            .date(byAdding: components, to: date, options: NSCalendar.Options(rawValue: 0))
        return futureDate!
    }
    
    fileprivate func getToken(_ url: String, isDeparture: Bool = true, onCompletion: @escaping ([String: AnyObject]) -> Void){
        let data = ("\(Constants.key):\(Constants.secret)").data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        let parameters = [
            "grant_type": "client_credentials",
            "scope": "\(UIDevice.current.identifierForVendor!.uuidString)"
        ]
        
        let headers = [
            "Authorization": "Basic \(base64)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        Alamofire.request(Constants.tokenURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in
                if let json = response.result.value as? [String: AnyObject]{
                    if let token = json["access_token"]{
                        let headers = [
                            "Authorization": "Bearer \(token)",
                            "Content-Type": "application/x-www-form-urlencoded"
                        ]
                        
                        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                            .responseJSON { response in
                                switch response.result {
                                case .success:
                                    guard let keys = response.data?.json.dictionary?.keys else { return }
                                    _ = keys.map{String($0) }
                                    //print("keys:",keysArray)
                                    //print("LoopLoop")
                                    for _ in keys {
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
                                case .failure(let error):
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

extension Data {
    var string: String {
        return String(data: self, encoding: String.Encoding.utf8) ?? ""
    }
    var json: (dictionary: [String: AnyObject]?, array: [AnyObject]?) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
            return (jsonObject as? [String: AnyObject], jsonObject as? [AnyObject])
        } catch let error as NSError {
            print("JSONSerialization error")
            print("error.code = ",error.code)
            print("error.domain = ",error.domain)
            return (nil,nil)
        }
    }
}
