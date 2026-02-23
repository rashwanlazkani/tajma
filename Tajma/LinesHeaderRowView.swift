import SwiftUI

struct LinesHeaderRowView: View {
    var body: some View {
        HStack {
            Text("Favorit")
                .font(.system(size: 11))
                .foregroundColor(TajmaTheme.secondaryText)
                .padding(.leading, 15)

            Text("Avgångar")
                .font(.system(size: 11))
                .foregroundColor(TajmaTheme.secondaryText)
                .padding(.leading, 16)

            Spacer()

            Text("Avgår om...")
                .font(.system(size: 11))
                .foregroundColor(TajmaTheme.secondaryText)
                .padding(.trailing, 10)
        }
        .frame(height: 28)
        .background(Color(red: 0.961, green: 0.961, blue: 0.961))
    }
}
