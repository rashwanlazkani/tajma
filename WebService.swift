//
//  RestApiManager.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class WebService {

    // MARK: - Async/Await API

    func getStops(userInput: String? = nil, location: CLLocationCoordinate2D? = nil) async throws -> [Stop] {
        var urlString = ""
        if let userInput = userInput {
            let escapedUserInput = userInput.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            urlString = "\(Constants.restURL)location.name?input=\(escapedUserInput)&format=json"
        } else if let location = location {
            urlString = "\(Constants.restURL)location.nearbystops?originCoordLat=\(location.latitude)&originCoordLong=\(location.longitude)&maxNo=50&MaxDist=3000&format=json"
        }

        let token = try await getValidToken()

        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 400)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let locationList = json["LocationList"] as? [String: Any],
              let stopsLocation = locationList["StopLocation"] as? [[String: Any]] else {
            throw NSError(domain: "Kunde inte hämta avgångar, försök igen.", code: 500)
        }

        let stopsData = try JSONSerialization.data(withJSONObject: stopsLocation, options: .prettyPrinted)
        let stops = try JSONDecoder().decode([Stop].self, from: stopsData).sorted(by: { $0.name == $1.name }).orderedSetValue
        stops.forEach { stop in
            stop.id = stop.id.customizeStopID
        }
        return stops
    }

    func getDeparturesAt(_ stopid: String, widgetData: Bool = false) async throws -> [Line] {
        let urlString = "\(Constants.restURL)departureBoard?id=\(stopid)&date=\(Date().customDate)&time=\(Date().customTime)&timeSpan=60&maxDeparturesPerLine=2&format=json"

        let token = try await getValidToken()

        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 400)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let departureBoard = json["DepartureBoard"] as? [String: Any],
              let departuresJson = departureBoard["Departure"] as? [[String: Any]],
              let serverDate = departureBoard["serverdate"] as? String,
              let serverTime = departureBoard["servertime"] as? String else {
            throw NSError(domain: "Kunde inte hämta avgångar, försök igen.", code: 500)
        }

        let departuresData = try JSONSerialization.data(withJSONObject: departuresJson, options: .prettyPrinted)
        var lines = try JSONDecoder().decode([Line].self, from: departuresData)
        var dbLines: [Line]? = nil

        lines.forEach { line in
            line.stopid = line.stopid.customizeStopID
            line.id = "\(line.stopid)-\(line.sname)-\(line.direction)"
            line.lineAndDirection = ("\(line.sname) \(line.direction)").subStringSnameAndDirection
        }

        for line in lines {
            if widgetData {
                if dbLines == nil {
                    dbLines = DbService.shared.getLines()
                }

                let userLine = dbLines?.firstOrDefault({ $0.id == line.id })
                if userLine == nil {
                    lines.removeAll(where: { $0.id == line.id })
                    continue
                }
            }

            let departures = lines.filter({ $0.lineAndDirection == line.lineAndDirection })
            for departure in departures {
                let time = departure.rtTime ?? departure.time
                let date = departure.rtDate ?? departure.date
                let dateTime = "\(date) \(time)"
                let serverDateTime = "\(serverDate) \(serverTime)"

                if let departureTimeDate = dateTime.date, let serverTimeDate = serverDateTime.date {
                    let intervalBetweenDepartures = departureTimeDate.timeIntervalSince(serverTimeDate) / 60
                    line.departures.append(Int(intervalBetweenDepartures))
                }
            }
        }

        let numberLines = lines.filter({ Int($0.sname) != nil }).sorted(by: { Int($0.sname)! < Int($1.sname)! })
        let charLines = lines.filter({ Int($0.sname) == nil }).sorted(by: { $0.sname < $1.sname })
        let allLines = (numberLines + charLines).unique { $0.lineAndDirection }
        return allLines
    }

    func getMyDeparturesAt(_ location: CLLocationCoordinate2D) async throws -> [Stop] {
        var stops = DbService.shared.getStops()

        for stop in stops {
            stop.distance = DistanceHelper.calculate(stop, lat: location.latitude, long: location.longitude)
        }
        stops.sort(by: { $0.distance != $1.distance ? $0.distance < $1.distance : $0.id < $1.id })

        var closestStops = [Stop]()
        for stop in stops {
            if closestStops.count < 5 && stop.distance <= 750 || closestStops.count < 2 && stop.distance < 1000 {
                do {
                    let lines = try await getDeparturesAt(stop.id, widgetData: true)
                    stop.lines = lines
                    closestStops.append(stop)
                } catch {
                    print(error)
                }
            }
        }

        return closestStops.sorted(by: { $0.distance < $1.distance })
    }

    // MARK: - Completion handler API (for backward compatibility)

    func getStops(userInput: String? = nil, location: CLLocationCoordinate2D? = nil, onCompletion: @escaping ([Stop]) -> Void, onError: @escaping (Error) -> Void) {
        Task {
            do {
                let stops = try await getStops(userInput: userInput, location: location)
                await MainActor.run { onCompletion(stops) }
            } catch {
                await MainActor.run { onError(error) }
            }
        }
    }

    func getDeparturesAt(_ stopid: String, widgetData: Bool = false, onCompletion: @escaping ([Line]) -> Void, onError: @escaping (Error) -> Void) {
        Task {
            do {
                let lines = try await getDeparturesAt(stopid, widgetData: widgetData)
                await MainActor.run { onCompletion(lines) }
            } catch {
                await MainActor.run { onError(error) }
            }
        }
    }

    func getMyDeparturesAt(_ location: CLLocationCoordinate2D, onCompletion: @escaping ([Stop]) -> Void, onError: @escaping (Error) -> Void) {
        Task {
            do {
                let stops = try await getMyDeparturesAt(location)
                await MainActor.run { onCompletion(stops) }
            } catch {
                await MainActor.run { onError(error) }
            }
        }
    }

    // MARK: - Token Management

    private func getValidToken() async throws -> String {
        if let tokenDate = UserDefaults.standard.object(forKey: "expires") as? Date,
           let token = UserDefaults.standard.string(forKey: "token"),
           tokenDate > Date() {
            return token
        }
        return try await fetchNewToken()
    }

    private func fetchNewToken() async throws -> String {
        let credentials = "\(Constants.key):\(Constants.secret)"
        let base64 = credentials.data(using: .utf8)!.base64EncodedString()

        guard let url = URL(string: Constants.tokenURL) else {
            throw NSError(domain: "Invalid token URL", code: 400)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = "grant_type=client_credentials&scope=\(UIDevice.current.identifierForVendor!.uuidString)"
        request.httpBody = bodyString.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["access_token"] as? String,
              let expires = json["expires_in"] as? Int else {
            throw NSError(domain: "Failed to get token", code: 401)
        }

        UserDefaults.standard.set(token, forKey: "token")
        UserDefaults.standard.set(Date().addSeconds(expires), forKey: "expires")

        return token
    }
}

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}
