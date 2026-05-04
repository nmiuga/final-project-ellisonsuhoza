import SwiftUI
import PhotosUI

// MARK: - Image Picker using PhotosPicker (modern API)
struct ImagePicker: View {
    @Binding var selectedImage: UIImage?

    @State private var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
            HStack(spacing: 10) {
                Image(systemName: "photo.on.rectangle")
                Text(selectedImage == nil ? "Add Photo" : "Change Photo")
            }
            .font(.system(.body, design: .rounded))
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .onChange(of: selection) { newValue in
            Task { await loadTransferable(from: newValue) }
        }
    }

    private func loadTransferable(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
            await MainActor.run { self.selectedImage = image }
        }
    }
}

#Preview {
    StatefulPreviewWrapper(nil as UIImage?) { binding in
        ImagePicker(selectedImage: binding)
            .padding()
    }
}

// MARK: - Small helper to preview with @Binding
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(wrappedValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
