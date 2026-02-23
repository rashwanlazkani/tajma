import SwiftUI

struct StopRowView: View {
    let stop: Stop
    let index: Int
    let hasSavedLines: Bool
    let savedLines: [Line]

    var body: some View {
        HStack(spacing: 0) {
            Text(stop.name)
                .font(.system(size: 17))
                .foregroundStyle(TajmaTheme.primaryText)
                .padding(.leading, 15)
                .lineLimit(1)

            Spacer()

            if !savedLines.isEmpty {
                HStack(spacing: 4) {
                    ForEach(savedLines, id: \.sname) { line in
                        Text(line.sname)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: line.bgColor))
                            .frame(minWidth: 22, minHeight: 18)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: line.fgColor))
                            )
                    }
                }
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
        .accessibilityLabel(stop.name + (savedLines.isEmpty ? "" : ", sparade linjer: " + savedLines.map(\.sname).joined(separator: ", ")))
    }
}
