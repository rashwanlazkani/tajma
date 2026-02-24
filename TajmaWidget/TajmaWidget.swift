import WidgetKit
import SwiftUI
import CoreLocation

struct DepartureEntry: TimelineEntry {
    let date: Date
    let stops: [Stop]
    let isPlaceholder: Bool
    let fetchedAt: Date
}

struct TajmaWidgetProvider: TimelineProvider {
    let webService = WebService()
    let locationManager = WidgetLocationManager()

    func placeholder(in context: Context) -> DepartureEntry {
        DepartureEntry(date: Date(), stops: [], isPlaceholder: true, fetchedAt: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DepartureEntry) -> Void) {
        completion(DepartureEntry(date: Date(), stops: [], isPlaceholder: false, fetchedAt: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DepartureEntry>) -> Void) {
        locationManager.getCurrentLocation { location in
            guard let location = location else {
                let entry = DepartureEntry(date: Date(), stops: [], isPlaceholder: false, fetchedAt: Date())
                completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(5))))
                return
            }

            webService.getMyDeparturesAt(location, onCompletion: { stops in
                let now = Date()
                let fetchedAt = now
                var entries = [DepartureEntry]()
                let minuteCount = 15

                for minuteOffset in 0..<minuteCount {
                    let entryDate = now.addingTimeInterval(Double(minuteOffset) * 60)
                    let adjustedStops = stops.compactMap { stop -> Stop? in
                        let adjustedLines = stop.lines.compactMap { line -> Line? in
                            let adjusted = line.departures.map { $0 - minuteOffset }.filter { $0 >= 0 }
                            guard !adjusted.isEmpty else { return nil }
                            return Line(id: line.id, stop: line.stop, stopId: line.stopid, lineAndDirection: line.lineAndDirection, name: line.name, sname: line.sname, direction: line.direction, type: line.type, track: line.track, bgColor: line.bgColor, fgColor: line.fgColor, departures: adjusted, rtDate: line.rtDate ?? "", date: line.date, rtTime: line.rtTime ?? "", time: line.time)
                        }
                        guard !adjustedLines.isEmpty else { return nil }
                        return Stop(id: stop.id, name: stop.name, latitude: stop.lat, longitude: stop.lon, distance: stop.distance, lines: adjustedLines)
                    }
                    entries.append(DepartureEntry(date: entryDate, stops: adjustedStops, isPlaceholder: false, fetchedAt: fetchedAt))
                }

                // Fetch fresh data after the last pre-computed entry
                completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(Double(minuteCount) * 60))))
            }, onError: { _ in
                let entry = DepartureEntry(date: Date(), stops: [], isPlaceholder: false, fetchedAt: Date())
                completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60))))
            })
        }
    }
}

struct TajmaWidgetEntryView: View {
    let entry: DepartureEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.isPlaceholder {
            placeholderView
        } else if entry.stops.isEmpty {
            emptyView
        } else {
            departuresView
        }
    }

    private var placeholderView: some View {
        VStack {
            Text("Tajma")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 231/255, green: 63/255, blue: 87/255))
            Text("Laddar avgångar...")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Text("Tajma")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(red: 231/255, green: 63/255, blue: 87/255))
            Text("Ingen vald hållplats i närheten.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var departuresView: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(entry.stops.prefix(maxStops).enumerated()), id: \.element.id) { _, stop in
                HStack {
                    Text(stop.name.components(separatedBy: ",")[0])
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary.opacity(0.7))
                        .lineLimit(1)
                    Spacer()
                    if let distance = stop.distance {
                        Text("\(distance) m")
                            .font(.system(size: 12))
                            .foregroundColor(.primary.opacity(0.5))
                    }
                }

                ForEach(Array(stop.lines.prefix(maxLines).enumerated()), id: \.element.id) { _, line in
                    WidgetDepartureRow(line: line)
                }

                if stop.id != entry.stops.prefix(maxStops).last?.id {
                    Divider().opacity(0.3)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var maxStops: Int {
        switch family {
        case .systemSmall: return 1
        case .systemMedium: return 2
        case .systemLarge: return 4
        default: return 2
        }
    }

    private var maxLines: Int {
        switch family {
        case .systemSmall: return 3
        case .systemMedium: return 3
        case .systemLarge: return 4
        default: return 3
        }
    }
}

struct WidgetDepartureRow: View {
    let line: Line

    var body: some View {
        HStack {
            Text("\(line.sname) \(line.direction)")
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.7))
                .lineLimit(1)
            Spacer()
            HStack(spacing: 4) {
                Text(departureText(0))
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 22, alignment: .trailing)
                Text(departureText(1))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 22, alignment: .trailing)
            }
        }
    }

    private func departureText(_ index: Int) -> String {
        let sorted = line.departures.sorted()
        guard index < sorted.count else { return "" }
        let time = sorted[index]
        return time == 0 ? "Nu" : (time < 0 ? "0" : String(time))
    }
}

@main
struct TajmaWidget: Widget {
    let kind: String = "TajmaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TajmaWidgetProvider()) { entry in
            TajmaWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Tajma")
        .description("Se avgångar för dina favorithållplatser.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
