import SwiftUI
import WebKit

struct WebViewScreen: View {
    let url: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            TajmaNavigationBar(
                title: title,
                showBackButton: true,
                backAction: { dismiss() }
            )

            ZStack {
                WebViewRepresentable(url: url, isLoading: $isLoading)

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let requestUrl = URL(string: url) {
            webView.load(URLRequest(url: requestUrl))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable
        init(_ parent: WebViewRepresentable) { self.parent = parent }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
    }
}
