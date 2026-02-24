import SwiftUI

struct LinesHeaderRowView: View {
    var body: some View {
        HStack {
            Text("Favorit")
                .font(.system(size: 11))
                .foregroundStyle(TajmaTheme.secondaryText)
                .padding(.leading, 15)

            Text("Avgångar")
                .font(.system(size: 11))
                .foregroundStyle(TajmaTheme.secondaryText)
                .padding(.leading, 16)

            Spacer()

            Text("Avgår om...")
                .font(.system(size: 11))
                .foregroundStyle(TajmaTheme.secondaryText)
                .padding(.trailing, 10)
        }
        .frame(height: 28)
        .background(TajmaTheme.linesBackground)
    }
}
