import SwiftUI

struct LineRowView: View {
    let line: Line
    let isSelected: Bool
    private var isArrivingNow: Bool {
        sortedDepartures.first == 0
    }

    var body: some View {
        HStack(spacing: 0) {
            Image(isSelected ? "check-box-red" : "unchecked-box")
                .resizable()
                .frame(width: 28, height: 28)
                .padding(.leading, 19)

            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: line.fgColor))
                    .frame(width: 28, height: 28)

                Text(formattedSname)
                    .font(.system(size: snameFontSize))
                    .foregroundStyle(Color(hex: line.bgColor))
            }
            .padding(.leading, 20)

            Text(line.direction)
                .font(.system(size: 14))
                .foregroundStyle(TajmaTheme.primaryText)
                .lineLimit(1)
                .padding(.leading, 9)

            Spacer()

            HStack(spacing: 10) {
                ForEach(Array(sortedDepartures.enumerated()), id: \.offset) { index, time in
                    Text(departureText(time))
                        .font(.system(size: 14, weight: index == 0 && isArrivingNow ? .bold : .regular))
                        .foregroundStyle(index == 0 && isArrivingNow ? TajmaTheme.brandRed : (index == 0 ? TajmaTheme.primaryText : TajmaTheme.secondaryText))
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 44)
        .background(TajmaTheme.linesBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Linje \(line.sname) \(line.direction), avgår om \(sortedDepartures.map { departureText($0) }.joined(separator: ", ")) minuter" + (isSelected ? ", sparad" : ""))
        .accessibilityHint(isSelected ? "Tryck för att ta bort från favoriter" : "Tryck för att spara som favorit")
    }

    private var formattedSname: String {
        switch line.sname.count {
        case 1, 2, 3: return line.sname
        case 4...: return String(line.sname.prefix(3))
        default: return ""
        }
    }

    private var snameFontSize: CGFloat {
        line.sname.count >= 3 ? 12 : 14
    }

    private var sortedDepartures: [Int] {
        line.departures.sorted()
    }

    private func departureText(_ time: Int) -> String {
        time == 0 ? "Nu" : (time < 0 ? "0" : String(time))
    }

}
