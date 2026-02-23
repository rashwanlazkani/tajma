import SwiftUI

struct WidgetGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TajmaTheme.brandRed
                .ignoresSafeArea()

            VStack(spacing: 15) {
                Text("Tajmas Widget")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Text("Lägg till Tajmas Widget för att se avgångstiderna för dina Favoriter ännu snabbare. Så här gör du:")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 10)

                Image("high-quality-widget-guide.gif")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 274, height: 492)

                Spacer()
            }

            Button { dismiss() } label: {
                Image("close-white")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(5)
            }
            .padding(.trailing, 10)
            .padding(.top, 16)
        }
    }
}
