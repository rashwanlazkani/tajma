import Foundation
import CoreLocation
import StoreKit
import UIKit

struct AlertInfo: Identifiable {
    let id = UUID()
    let message: String
    let retryAction: (() -> Void)?
}

@MainActor
class StopsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var stops = [Stop]()
    @Published var savedLines = [Line]()
    @Published var isLoading = false
    @Published var segmentIndex = 0
    @Published var segmentTitle = "Nära mig"
    @Published var searchText = ""
    @Published var errorAlert: AlertInfo?

    private let webService = WebService()
    private let locationManager = CLLocationManager()
    private var location = CLLocationCoordinate2D()
    private var isFromBackground = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        DbService.shared.updateOptionals()

        NotificationCenter.default.addObserver(
            self, selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)

        checkAndAskForReview()
    }

    func onAppear() {
        locationManager.requestWhenInUseAuthorization()
        refreshForSegment()
        savedLines = DbService.shared.getLines()
    }

    func onReappear() {
        switch segmentIndex {
        case 0:
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        case 1:
            let swedish = Locale(identifier: "sv")
            stops = DbService.shared.getStops().sorted {
                $0.name.compare($1.name, locale: swedish) == .orderedAscending
            }
        default:
            break
        }
        savedLines = DbService.shared.getLines()
    }

    func refreshForSegment() {
        switch segmentIndex {
        case 0:
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        case 1:
            let swedish = Locale(identifier: "sv")
            stops = DbService.shared.getStops().sorted {
                $0.name.compare($1.name, locale: swedish) == .orderedAscending
            }
        default:
            break
        }
        segmentTitle = "Nära mig"
        searchText = ""
        savedLines = DbService.shared.getLines()
    }

    func searchStops(_ text: String) {
        if text.count >= 3 {
            performSearch(text)
        } else if text.isEmpty {
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        }
    }

    func hasSavedLines(for stop: Stop) -> Bool {
        savedLines.contains(where: { $0.stopid == stop.id })
    }

    func savedLineNumbers(for stop: Stop) -> [Line] {
        let linesAtStop = savedLines.filter { $0.stopid == stop.id }
        var seen = Set<String>()
        return linesAtStop.filter { seen.insert($0.sname).inserted }
    }

    // MARK: - Private

    private func performSearch(_ searchText: String) {
        Task {
            isLoading = true
            do {
                let results = try await webService.getStops(userInput: searchText)
                stops = results
                savedLines = DbService.shared.getLines()
                if !stops.isEmpty {
                    segmentTitle = "Sökresultat"
                }
            } catch {
                errorAlert = AlertInfo(message: "Ett fel har uppstått med sökningen.", retryAction: nil)
            }
            isLoading = false
        }
    }

    private func getNearestStops() {
        Task {
            isLoading = true
            do {
                var results = try await webService.getStops(location: location)
                for stop in results {
                    stop.distance = DistanceHelper.calculate(stop, lat: location.latitude, long: location.longitude)
                }
                results.sort(by: { ($0.distance ?? 0) < ($1.distance ?? 0) })
                stops = results
                if stops.isEmpty {
                    errorAlert = AlertInfo(message: "Inga hållplatser i närheten.", retryAction: { [weak self] in self?.getNearestStops() })
                }
                locationManager.stopUpdatingLocation()
            } catch {
                print("[StopsViewModel] getNearestStops error: \(error)")
                print("[StopsViewModel] location: \(location.latitude), \(location.longitude)")
                errorAlert = AlertInfo(message: "Ett fel har uppstått med hämtning av närmaste hållplatser.", retryAction: { [weak self] in
                    self?.location = CLLocationCoordinate2D()
                    self?.locationManager.startUpdatingLocation()
                })
            }
            isLoading = false
        }
    }

    private func checkAndAskForReview() {
        let count = UserDefaults.standard.integer(forKey: "appOpenCount")
        switch count {
        case 7, 50:
            SKStoreReviewController.requestReview()
        case _ where count % 100 == 0:
            SKStoreReviewController.requestReview()
        default:
            break
        }
    }

    @objc private func didBecomeActive() {
        if isFromBackground {
            isFromBackground = false
            segmentIndex = 0
            location = CLLocationCoordinate2D()
            locationManager.startUpdatingLocation()
        }
    }

    @objc private func didEnterBackground() {
        isFromBackground = true
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard location.latitude.isZero && location.longitude.isZero else { return }
            guard Reachability.isConnectedToNetwork() else {
                stops = []
                return
            }
            if let coordinate = manager.location?.coordinate {
                location = coordinate
            }
            locationManager.stopUpdatingLocation()
            getNearestStops()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            errorAlert = AlertInfo(
                message: "Kunde inte fastställa din position. Gå in på Inställningar -> Tajma, för att aktivera platstjänster.",
                retryAction: { [weak self] in self?.locationManager.startUpdatingLocation() }
            )
        }
    }
}
