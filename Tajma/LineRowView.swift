import SwiftUI

struct LineRowView: View {
    let line: Line
    let isSelected: Bool

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
                    .foregroundColor(Color(hex: line.bgColor))
            }
            .padding(.leading, 20)

            Text(line.direction)
                .font(.system(size: 14))
                .foregroundColor(TajmaTheme.primaryText)
                .lineLimit(1)
                .padding(.leading, 9)

            Spacer()

            Text(firstDepartureText)
                .font(.system(size: 14))
                .foregroundColor(TajmaTheme.primaryText)
                .frame(width: 22, alignment: .trailing)

            Text(secondDepartureText)
                .font(.system(size: 14))
                .foregroundColor(TajmaTheme.secondaryText)
                .frame(width: 22, alignment: .trailing)
                .padding(.leading, 15)
                .padding(.trailing, 16)
        }
        .frame(height: 44)
        .background(TajmaTheme.linesBackground)
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

    private var firstDepartureText: String {
        guard let time = sortedDepartures.first else { return "-" }
        return time == 0 ? "Nu" : (time < 0 ? "0" : String(time))
    }

    private var secondDepartureText: String {
        guard sortedDepartures.count > 1 else { return "-" }
        let time = sortedDepartures[1]
        return time == 0 ? "Nu" : (time < 0 ? "0" : String(time))
    }
}
