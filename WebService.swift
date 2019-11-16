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

typealias ServiceResponse = (Data, NSError?) -> Void


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
                        }
                        
                    } catch {
                        print(error)
                        onError(error)
                    }
            }
        }
    }

    func getDeparturesAtStop (_ stopId: String, onCompletion: @escaping ([String: AnyObject]) -> Void){
        let date = Date().customDate
        let time = Date().customTime
        // let weekday = Calendar.current.component(.weekday, from: Date())
        let url = "\(Constants.restURL)departureBoard?id=\(stopId)&date=\(date)&time=\(time)&timeSpan=60&maxDeparturesPerLine=2&format=json"
        
        getToken(url, onCompletion: {jsonDictionary in
            onCompletion(jsonDictionary)
        })
    }
    
    fileprivate func getToken(_ url: String, isDeparture: Bool = true, onCompletion: @escaping ([String: AnyObject]) -> Void) {
        
    }
    
    fileprivate func getToken(onCompletion: @escaping (String) -> Void) {
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
}
