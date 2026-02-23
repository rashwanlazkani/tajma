import Foundation
import UIKit
import WidgetKit

@MainActor
class LinesViewModel: ObservableObject {
    @Published var lines = [Line]()
    @Published var isLoading = false
    @Published var errorMessage: String?

    let stop: Stop
    private let webService = WebService()

    init(stop: Stop) {
        self.stop = stop
        stop.lines = DbService.shared.getLinesAtStop(stop.id)
    }

    var displayName: String {
        stop.name.components(separatedBy: ",").first ?? stop.name
    }

    func loadDepartures() {
        Task {
            isLoading = true
            do {
                lines = try await webService.getDeparturesAt(stop.id)
            } catch {
                errorMessage = "Inga avgångar för tillfället på denna hållplats, försök igen senare."
            }
            isLoading = false
        }
    }

    func toggleLine(_ line: Line) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        line.stopid = stop.id
        if stop.lines.filter({ $0.id == line.id }).isEmpty {
            DbService.shared.addLine(line, stop: stop)
        } else {
            DbService.shared.removeLine(line, stopId: stop.id)
        }
        stop.lines = DbService.shared.getLinesAtStop(stop.id)
        objectWillChange.send()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func isLineSelected(_ line: Line) -> Bool {
        stop.lines.contains(where: { $0.id == line.id })
    }
}
