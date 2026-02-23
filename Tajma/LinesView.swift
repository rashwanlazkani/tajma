import SwiftUI

struct LinesView: View {
    @StateObject private var viewModel: LinesViewModel
    @Environment(\.dismiss) private var dismiss

    init(stop: Stop) {
        _viewModel = StateObject(wrappedValue: LinesViewModel(stop: stop))
    }

    var body: some View {
        VStack(spacing: 0) {
            TajmaNavigationBar(
                title: viewModel.displayName,
                showBackButton: true,
                backAction: { dismiss() }
            )

            ZStack {
                LinesListContent(viewModel: viewModel)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(TajmaTheme.brandRed)
                }
            }
        }
        .background(TajmaTheme.linesBackground)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.loadDepartures() }
        .alert("Tajma", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct LinesListContent: View {
    @ObservedObject var viewModel: LinesViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                LinesHeaderRowView()

                ForEach(viewModel.lines) { line in
                    Button {
                        viewModel.toggleLine(line)
                    } label: {
                        LineRowView(line: line, isSelected: viewModel.isLineSelected(line))
                    }
                    .buttonStyle(.plain)

                    Divider()
                }
            }
        }
        .background(TajmaTheme.linesBackground)
    }
}
