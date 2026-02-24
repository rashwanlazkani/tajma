import SwiftUI

struct StopRowView: View {
    let stop: Stop
    let index: Int
    let hasSavedLines: Bool

    var body: some View {
        HStack(spacing: 0) {
            Text(stop.name)
                .font(.system(size: 17))
                .foregroundStyle(TajmaTheme.primaryText)
                .padding(.leading, 15)
                .lineLimit(1)

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
        .frame(height: 44)
        .background(index % 2 == 0 ? TajmaTheme.rowEven : TajmaTheme.rowOdd)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stop.name + (hasSavedLines ? ", har sparade linjer" : ""))
    }
}
