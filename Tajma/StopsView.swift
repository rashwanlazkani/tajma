import SwiftUI

struct StopsView: View {
    @StateObject private var viewModel = StopsViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                stopsHeader

                ZStack {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.stops.enumerated()), id: \.element.id) { index, stop in
                                Button {
                                    viewModel.searchText = ""
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    navigationPath.append(stop)
                                } label: {
                                    StopRowView(stop: stop, index: index, hasSavedLines: viewModel.hasSavedLines(for: stop))
                                }
                                .buttonStyle(.plain)

                                TajmaTheme.separator.frame(height: 0.5)
                            }
                        }
                    }
                    .background(TajmaTheme.tableBackground)

                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
            }
            .background(TajmaTheme.brandRed)
            .navigationBarHidden(true)
            .navigationDestination(for: Stop.self) { stop in
                LinesView(stop: stop)
            }
            .onAppear { viewModel.onAppear() }
            .alert(item: $viewModel.errorAlert) { alert in
                Alert(
                    title: Text("Tajma"),
                    message: Text(alert.message),
                    primaryButton: .default(Text("OK")),
                    secondaryButton: .default(Text("Försök igen")) { alert.retryAction?() }
                )
            }
        }
    }

    private var stopsHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image("search-white")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)

                    TextField("", text: $viewModel.searchText, prompt: Text("Sök hållplats").foregroundColor(.white.opacity(0.4)))
                        .foregroundColor(.white)
                        .tint(.white)
                        .autocorrectionDisabled()
                        .onSubmit {
                            viewModel.searchStops(viewModel.searchText)
                        }
                        .onChange(of: viewModel.searchText) { newValue in
                            viewModel.searchStops(newValue)
                        }

                    if !viewModel.searchText.isEmpty {
                        Button { viewModel.searchText = "" } label: {
                            Image("erase")
                                .resizable()
                                .frame(width: 14, height: 14)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(8)
                .padding(.leading, 16)

                NavigationLink {
                    MenuView()
                } label: {
                    Image("more-white")
                        .resizable()
                        .frame(width: 29, height: 29)
                        .padding(.horizontal, 12)
                }
            }
            .padding(.top, 8)

            Picker("", selection: $viewModel.segmentIndex) {
                Text(viewModel.segmentTitle).tag(0)
                Text("Favoriter").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 15)
            .onChange(of: viewModel.segmentIndex) { _ in
                viewModel.refreshForSegment()
            }
        }
        .background(TajmaTheme.brandRed)
    }
}
