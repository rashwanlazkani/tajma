import SwiftUI

struct TajmaNavigationBar<TrailingContent: View>: View {
    let title: String
    var showBackButton: Bool = false
    var backAction: (() -> Void)? = nil
    var trailingContent: (() -> TrailingContent)?

    init(title: String, showBackButton: Bool = false, backAction: (() -> Void)? = nil, @ViewBuilder trailingContent: @escaping () -> TrailingContent) {
        self.title = title
        self.showBackButton = showBackButton
        self.backAction = backAction
        self.trailingContent = trailingContent
    }

    var body: some View {
        HStack {
            if showBackButton {
                Button(action: { backAction?() }) {
                    Image("back")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(8)
                }
                .accessibilityLabel("Tillbaka")
                .padding(.leading, 8)
            } else {
                Color.clear.frame(width: 40, height: 40).padding(.leading, 8)
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            if let trailingContent = trailingContent {
                trailingContent()
            } else {
                Color.clear.frame(width: 40, height: 40).padding(.trailing, 8)
            }
        }
        .padding(.bottom, 8)
        .frame(height: 47)
        .background(TajmaTheme.brandRed.ignoresSafeArea(edges: .top))
    }
}

extension TajmaNavigationBar where TrailingContent == EmptyView {
    init(title: String, showBackButton: Bool = false, backAction: (() -> Void)? = nil) {
        self.title = title
        self.showBackButton = showBackButton
        self.backAction = backAction
        self.trailingContent = nil
    }
}
