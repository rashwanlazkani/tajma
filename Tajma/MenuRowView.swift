import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let action: MenuAction
}

enum MenuAction {
    case facebook
    case appStore
    case share
    case feedback
    case widgetGuide
    case faq
    case about
}

struct MenuRowView: View {
    let item: MenuItem
    let index: Int

    var body: some View {
        HStack(spacing: 0) {
            Image(item.iconName)
                .resizable()
                .frame(width: 18, height: 18)
                .opacity(0.9)
                .padding(.leading, 27)

            Text(item.title)
                .font(.system(size: 15))
                .foregroundStyle(TajmaTheme.menuText)
                .padding(.leading, 15)
                .lineLimit(1)

            Spacer()

            Image("disclosureIndicator")
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.trailing, 8)
        }
        .frame(height: 44)
        .background(index % 2 == 0 ? TajmaTheme.rowEven : TajmaTheme.rowOdd)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
    }
}
