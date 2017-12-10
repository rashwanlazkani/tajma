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

class WebService: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    static let sharedInstance = WebService()

    func getNearestStops(_ lat: Double, long: Double, onCompletion: @escaping ([String: AnyObject]) -> Void){
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

    func getDeparturesAtStop (_ stopId: String, onCompletion: @escaping ([String: AnyObject]) -> Void){
        let date = Date().customDate
        let time = Date().customTime
        print(date)
        print(time)
        let url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(date)&time=\(time)&timeSpan=60&maxDeparturesPerLine=2&format=json"
        
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
                                    var dic:[String:AnyObject]?
                                    if isDeparture {
                                        dic = response.data?.json.dictionary?["DepartureBoard"] as? [String:AnyObject]
                                      } else {
                                        dic = response.data?.json.dictionary?["LocationList"] as? [String:AnyObject]
                                    }
                                    
                                    if let dic = dic  {
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
                } else {
                    print(response.description)
                }
        }
    }
}
