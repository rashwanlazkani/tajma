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
                    .refreshable { viewModel.refresh() }
                    .scrollDismissesKeyboard(.interactively)
                    .background(TajmaTheme.tableBackground)

                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(TajmaTheme.brandRed)
                            .transition(.opacity)
                    }
                }
            }
            .background(TajmaTheme.brandRed)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Stop.self) { stop in
                LinesView(stop: stop)
            }
            .onAppear { viewModel.onAppear() }
            .alert("Tajma", isPresented: Binding(
                get: { viewModel.errorAlert != nil },
                set: { if !$0 { viewModel.errorAlert = nil } }
            )) {
                Button("OK", role: .cancel) {}
                if viewModel.errorAlert?.retryAction != nil {
                    Button("Försök igen") { viewModel.errorAlert?.retryAction?() }
                }
            } message: {
                Text(viewModel.errorAlert?.message ?? "")
            }
            .alert("Tack för att du använder Tajma!", isPresented: $viewModel.showWelcome) {
                Button("OK") {}
            } message: {
                Text("En uppdatering till appen är här!\n\nWidgeten visar nu avgångar för dina sparade hållplatser som är i närheten. Lägg till widgeten på hemskärmen för att snabbt se nästa avgång.\n\nNär du sparar en linje på en hållplats visas båda riktningarna automatiskt.")
            }
        }
    }

    private var stopsHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                SearchBarView(
                    searchText: $viewModel.searchText,
                    onSubmit: { viewModel.searchStops(viewModel.searchText) },
                    onChange: { viewModel.searchStops($0) }
                )
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
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.refreshForSegment()
                }
            }
        }
        .background(TajmaTheme.brandRed)
    }
}
