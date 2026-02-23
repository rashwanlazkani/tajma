import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSubmit: () -> Void
    var onChange: (String) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image("search-white")
                .renderingMode(.template)
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundStyle(.white)

            TextField("", text: $searchText, prompt: Text("Sök hållplats").foregroundStyle(.white.opacity(0.4)))
                .foregroundStyle(.white)
                .tint(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit { onSubmit() }
                .onChange(of: searchText) { newValue in
                    onChange(newValue)
                }

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image("erase")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .accessibilityLabel("Rensa sökning")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
