import SwiftUI

struct iPadMainView: View {
    @StateObject private var stopsVM = StopsViewModel()
    @State private var selectedStop: Stop?
    @State private var linesVM: LinesViewModel?

    var body: some View {
        VStack(spacing: 0) {
            iPadHeader

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left panel: Stops
                    ZStack {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(stopsVM.stops.enumerated()), id: \.element.id) { index, stop in
                                    Button {
                                        stopsVM.searchText = ""
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        selectStop(stop)
                                    } label: {
                                        StopRowView(stop: stop, index: index, hasSavedLines: stopsVM.hasSavedLines(for: stop), savedLines: stopsVM.savedLineNumbers(for: stop))
                                    }
                                    .buttonStyle(.plain)

                                    TajmaTheme.separator.frame(height: 0.5)
                                }
                            }
                        }
                        .refreshable { stopsVM.refresh() }
                        .scrollDismissesKeyboard(.interactively)
                        .background(TajmaTheme.tableBackground)

                        if stopsVM.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(TajmaTheme.brandRed)
                        }
                    }
                    .frame(width: selectedStop != nil ? geometry.size.width / 2 : geometry.size.width)
                    .animation(.easeInOut(duration: 0.5), value: selectedStop != nil)

                    // Right panel: Lines
                    if let linesVM = linesVM {
                        VStack(spacing: 0) {
                            Text(linesVM.displayName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(TajmaTheme.brandRed)

                            ZStack {
                                LinesListContent(viewModel: linesVM)

                                if linesVM.isLoading {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .tint(TajmaTheme.brandRed)
                                }
                            }
                        }
                        .frame(width: geometry.size.width / 2)
                        .transition(.move(edge: .trailing))
                    }
                }
            }
        }
        .background(TajmaTheme.brandRed)
        .onAppear { stopsVM.onAppear() }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width > 50 {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedStop = nil
                            linesVM = nil
                        }
                    }
                }
        )
        .alert("Tajma", isPresented: Binding(
            get: { stopsVM.errorAlert != nil },
            set: { if !$0 { stopsVM.errorAlert = nil } }
        )) {
            Button("OK", role: .cancel) {}
            if stopsVM.errorAlert?.retryAction != nil {
                Button("Försök igen") { stopsVM.errorAlert?.retryAction?() }
            }
        } message: {
            Text(stopsVM.errorAlert?.message ?? "")
        }
    }

    private var iPadHeader: some View {
        VStack(spacing: 0) {
            SearchBarView(
                searchText: $stopsVM.searchText,
                onSubmit: { stopsVM.searchStops(stopsVM.searchText) },
                onChange: { stopsVM.searchStops($0) }
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Picker("", selection: $stopsVM.segmentIndex) {
                Text(stopsVM.segmentTitle).tag(0)
                Text("Favoriter").tag(1)
            }
            .pickerStyle(.segmented)
            .frame(width: selectedStop != nil ? UIScreen.main.bounds.width / 2 - 48 : UIScreen.main.bounds.width - 48)
            .animation(.easeInOut(duration: 0.5), value: selectedStop != nil)
            .padding(.top, 10)
            .padding(.bottom, 15)
            .onChange(of: stopsVM.segmentIndex) { _ in
                stopsVM.refreshForSegment()
            }
        }
        .background(TajmaTheme.brandRed)
    }

    private func selectStop(_ stop: Stop) {
        selectedStop = stop
        let vm = LinesViewModel(stop: stop)
        linesVM = vm
        vm.loadDepartures()
    }
}
