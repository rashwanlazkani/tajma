import SwiftUI

struct StopRowView: View {
    let stop: Stop
    let index: Int
    let hasSavedLines: Bool

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(stop.name)
                    .font(.system(size: 17))
                    .foregroundStyle(TajmaTheme.primaryText)
                    .lineLimit(1)

                if let distance = stop.distance, distance > 0 {
                    Text(formattedDistance(distance))
                        .font(.system(size: 12))
                        .foregroundStyle(TajmaTheme.secondaryText)
                }
            }
            .padding(.leading, 15)

            Spacer()

            if hasSavedLines {
                Image("check-red")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .padding(.trailing, 8)
            }

            Image("disclosureIndicator")
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.trailing, 8)
        }
        .frame(height: 54)
        .background(index % 2 == 0 ? TajmaTheme.rowEven : TajmaTheme.rowOdd)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stop.name + (hasSavedLines ? ", har sparade linjer" : "") + distanceAccessibilityLabel)
    }

    private func formattedDistance(_ meters: Int) -> String {
        if meters < 1000 {
            return "\(meters) m"
        } else {
            let km = Double(meters) / 1000.0
            return String(format: "%.1f km", km)
        }
    }

    private var distanceAccessibilityLabel: String {
        guard let distance = stop.distance, distance > 0 else { return "" }
        return ", \(formattedDistance(distance)) bort"
    }
}
