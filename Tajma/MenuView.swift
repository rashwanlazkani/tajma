import SwiftUI
import MessageUI

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var showMailComposer = false
    @State private var showWidgetGuide = false

    var body: some View {
        VStack(spacing: 0) {
            TajmaNavigationBar(
                title: "Tajma",
                showBackButton: true,
                backAction: { dismiss() }
            )

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                        Group {
                            switch item.action {
                            case .faq:
                                NavigationLink {
                                    WebViewScreen(url: viewModel.faqURL, title: "Vanliga frågor")
                                } label: {
                                    MenuRowView(item: item, index: index)
                                }
                            case .about:
                                NavigationLink {
                                    WebViewScreen(url: viewModel.aboutURL, title: "Om oss")
                                } label: {
                                    MenuRowView(item: item, index: index)
                                }
                            default:
                                Button { handleAction(item.action) } label: {
                                    MenuRowView(item: item, index: index)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        TajmaTheme.separator.frame(height: 0.5)
                    }
                }
            }
            .background(TajmaTheme.tableBackground)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ActivityViewControllerRepresentable(activityItems: viewModel.shareItems)
        }
        .sheet(isPresented: $showMailComposer) {
            if MFMailComposeViewController.canSendMail() {
                MailComposeViewRepresentable()
            }
        }
        .sheet(isPresented: $showWidgetGuide) {
            WidgetGuideView()
        }
    }

    private func handleAction(_ action: MenuAction) {
        switch action {
        case .facebook: viewModel.openFacebook()
        case .appStore: viewModel.openAppStore()
        case .share: showShareSheet = true
        case .feedback: showMailComposer = true
        case .widgetGuide: showWidgetGuide = true
        case .faq, .about: break
        }
    }
}
