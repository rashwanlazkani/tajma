//
//  RestApiManager.swift
//  Tajmapp
//
//  Created by Rashwan Lazkani on 2015-05-01.
//  Copyright (c) 2015 Rashwan Lazkani. All rights reserved.
//

import Foundation
import MapKit

class WebService {

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601FormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func parseISO8601(_ string: String) -> Date? {
        iso8601Formatter.date(from: string) ?? iso8601FormatterNoFraction.date(from: string)
    }

    private static let sharedDefaults = UserDefaults(suiteName: "group.tajma.today")!

    /// Invalidate any cached v2 token so a fresh v4 token is fetched.
    static func clearCachedToken() {
        sharedDefaults.removeObject(forKey: "token")
        sharedDefaults.removeObject(forKey: "expires")
        // Also clear from standard in case of stale v2 tokens
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "expires")
    }

    // MARK: - Async/Await API

    func getStops(userInput: String? = nil, location: CLLocationCoordinate2D? = nil) async throws -> [Stop] {
        var urlString = ""
        if let userInput = userInput {
            let escapedUserInput = userInput.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            urlString = "\(Constants.apiBaseURL)/locations/by-text?q=\(escapedUserInput)&limit=50&types=stoparea"
        } else if let location = location {
            urlString = "\(Constants.apiBaseURL)/locations/by-coordinates?latitude=\(location.latitude)&longitude=\(location.longitude)&radiusInMeters=3000&limit=50&types=stoparea"
        }

        let token = try await getValidToken()
        print("[WebService] getStops URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 400)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("[WebService] getStops status: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                // Token expired, invalid, or missing API subscription — clear and retry once
                WebService.clearCachedToken()
                let newToken = try await getValidToken()
                request.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                let (retryData, retryResponse) = try await URLSession.shared.data(for: request)
                if let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode != 200 {
                    print("[WebService] getStops retry failed: \(retryHttp.statusCode)")
                    print("[WebService] body: \(String(data: retryData, encoding: .utf8) ?? "")")
                    throw NSError(domain: "API error \(retryHttp.statusCode)", code: retryHttp.statusCode)
                }
                return try parseStops(retryData)
            }
            if httpResponse.statusCode != 200 {
                print("[WebService] getStops error body: \(String(data: data, encoding: .utf8) ?? "")")
                throw NSError(domain: "API error \(httpResponse.statusCode)", code: httpResponse.statusCode)
            }
        }

        return try parseStops(data)
    }

    private func parseStops(_ data: Data) throws -> [Stop] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            print("[WebService] parseStops unexpected JSON: \(String(data: data, encoding: .utf8) ?? "")")
            throw NSError(domain: "Kunde inte hämta hållplatser, försök igen.", code: 500)
        }

        var stops = [Stop]()
        for result in results {
            guard let gid = result["gid"] as? String,
                  let name = result["name"] as? String else { continue }
            let lat = (result["latitude"] as? Double).map { String($0) } ?? ""
            let lon = (result["longitude"] as? Double).map { String($0) } ?? ""
            let stop = Stop(id: gid, name: name, latitude: lat, longitude: lon, distance: 0, lines: [])
            stops.append(stop)
        }

        return stops.sorted(by: { $0.name < $1.name }).orderedSetValue
    }

    func getDeparturesAt(_ stopid: String, widgetData: Bool = false) async throws -> [Line] {
        let urlString = "\(Constants.apiBaseURL)/stop-areas/\(stopid)/departures?timeSpanInMinutes=60&maxDeparturesPerLine=2"

        let token = try await getValidToken()

        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 400)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("[WebService] getDepartures status: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                WebService.clearCachedToken()
                let newToken = try await getValidToken()
                request.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                let (retryData, retryResponse) = try await URLSession.shared.data(for: request)
                if let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode != 200 {
                    print("[WebService] getDepartures retry failed: \(retryHttp.statusCode)")
                    print("[WebService] body: \(String(data: retryData, encoding: .utf8) ?? "")")
                    throw NSError(domain: "API error \(retryHttp.statusCode)", code: retryHttp.statusCode)
                }
                return try parseDepartures(retryData, stopid: stopid, widgetData: widgetData)
            }
            if httpResponse.statusCode != 200 {
                print("[WebService] getDepartures error body: \(String(data: data, encoding: .utf8) ?? "")")
                throw NSError(domain: "API error \(httpResponse.statusCode)", code: httpResponse.statusCode)
            }
        }

        return try parseDepartures(data, stopid: stopid, widgetData: widgetData)
    }

    private func parseDepartures(_ data: Data, stopid: String, widgetData: Bool) throws -> [Line] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            print("[WebService] parseDepartures unexpected JSON: \(String(data: data, encoding: .utf8) ?? "")")
            throw NSError(domain: "Kunde inte hämta avgångar, försök igen.", code: 500)
        }

        let now = Date()
        var lines = [Line]()

        for departure in results {
            let isCancelled = departure["isCancelled"] as? Bool ?? false
            if isCancelled { continue }

            let serviceJourney = departure["serviceJourney"] as? [String: Any] ?? [:]
            let lineInfo = serviceJourney["line"] as? [String: Any] ?? [:]
            let direction = serviceJourney["direction"] as? String ?? ""

            let sname = lineInfo["shortName"] as? String ?? lineInfo["designation"] as? String ?? ""
            let name = lineInfo["name"] as? String ?? ""
            let bgColor = (lineInfo["backgroundColor"] as? String ?? "").replacingOccurrences(of: "#", with: "")
            let fgColor = (lineInfo["foregroundColor"] as? String ?? "").replacingOccurrences(of: "#", with: "")

            let stopPoint = departure["stopPoint"] as? [String: Any] ?? [:]
            let platform = stopPoint["platform"] as? [String: Any]
            let track = platform?["name"] as? String ?? ""

            let timeString = departure["estimatedOtherwisePlannedTime"] as? String
                          ?? departure["estimatedTime"] as? String
                          ?? departure["plannedTime"] as? String
                          ?? ""

            var minutesUntil = 0
            if !timeString.isEmpty, let departureDate = WebService.parseISO8601(timeString) {
                minutesUntil = Int(departureDate.timeIntervalSince(now) / 60)
            }

            let lineId = "\(stopid)-\(sname)-\(direction)"
            let lineAndDirection = "\(sname) \(direction)".subStringSnameAndDirection

            if let existingLine = lines.first(where: { $0.lineAndDirection == lineAndDirection }) {
                existingLine.departures.append(minutesUntil)
            } else {
                let line = Line(
                    id: lineId,
                    stop: Stop(),
                    stopId: stopid,
                    lineAndDirection: lineAndDirection,
                    name: name,
                    sname: sname,
                    direction: direction,
                    type: "",
                    track: track,
                    bgColor: bgColor,
                    fgColor: fgColor,
                    departures: [minutesUntil]
                )
                lines.append(line)
            }
        }

        if widgetData {
            let dbLines = DbService.shared.getLines()
            lines = lines.filter { line in
                dbLines.firstOrDefault({ $0.stopid == line.stopid && $0.sname == line.sname }) != nil
            }
        }

        let numberLines = lines.filter({ Int($0.sname) != nil }).sorted(by: { Int($0.sname)! < Int($1.sname)! })
        let charLines = lines.filter({ Int($0.sname) == nil }).sorted(by: { $0.sname < $1.sname })
        return numberLines + charLines
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
        let defaults = WebService.sharedDefaults
        let isV4 = defaults.bool(forKey: "tokenV4")
        if isV4,
           let tokenDate = defaults.object(forKey: "expires") as? Date,
           let token = defaults.string(forKey: "token"),
           tokenDate > Date() {
            return token
        }
        return try await fetchNewToken()
    }

    private func fetchNewToken() async throws -> String {
        guard let url = URL(string: Constants.tokenURL) else {
            throw NSError(domain: "Invalid token URL", code: 400)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(Constants.authKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = "grant_type=client_credentials"
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("[WebService] fetchNewToken status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                print("[WebService] token error body: \(String(data: data, encoding: .utf8) ?? "")")
                throw NSError(domain: "Token request failed (\(httpResponse.statusCode))", code: httpResponse.statusCode)
            }
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["access_token"] as? String,
              let expires = json["expires_in"] as? Int else {
            print("[WebService] token unexpected JSON: \(String(data: data, encoding: .utf8) ?? "")")
            throw NSError(domain: "Failed to get token", code: 401)
        }

        let defaults = WebService.sharedDefaults
        defaults.set(token, forKey: "token")
        defaults.set(Date().addSeconds(expires), forKey: "expires")
        defaults.set(true, forKey: "tokenV4")

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
