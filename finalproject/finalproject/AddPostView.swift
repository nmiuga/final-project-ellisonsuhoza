import SwiftUI

// MARK: - Add Post View
struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: UIImage? = nil
    @State private var caption: String = ""

    private enum ComposeMode { case photoText, emoji }
    @State private var mode: ComposeMode = .photoText
    @State private var selectedEmoji: String = ""
    @State private var isEmojiPickerPresented: Bool = false

    let onPost: (Post) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Button {
                            mode = .photoText
                        } label: {
                            Label("Photo/Text", systemImage: "photo.on.rectangle")
                                .font(.system(.subheadline, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(mode == .photoText ? Color.primary.opacity(0.08) : Color.clear, in: Capsule())
                        }

                        Button {
                            mode = .emoji
                        } label: {
                            Label("Emoji", systemImage: "face.smiling")
                                .font(.system(.subheadline, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(mode == .emoji ? Color.primary.opacity(0.08) : Color.clear, in: Capsule())
                        }
                        Spacer()
                    }
                    
                    if mode == .photoText {
                        ImagePicker(selectedImage: $selectedImage)

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $caption)
                                .frame(minHeight: 140)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.06))
                                )
                                .font(.system(.body, design: .rounded))
                                .scrollContentBackground(.hidden)
                                .textInputAutocapitalization(.sentences)
                                .disableAutocorrection(false)

                            if caption.isEmpty {
                                Text("Write something… (optional)")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                        }

                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.06))
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }

                    if mode == .emoji {
                        VStack(spacing: 14) {
                            Button {
                                isEmojiPickerPresented = true
                            } label: {
                                HStack {
                                    Image(systemName: "face.smiling")
                                    Text(selectedEmoji.isEmpty ? "Pick Emoji" : "Change Emoji")
                                }
                                .font(.system(.body, design: .rounded))
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.06))
                                )
                            }

                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(Color.primary.opacity(0.06))
                                    )

                                Text(selectedEmoji.isEmpty ? "😀" : selectedEmoji)
                                    .font(.system(size: 100))
                                    .minimumScaleFactor(0.5)
                                    .padding(24)
                            }
                            .frame(height: 220)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("New Post")
            .sheet(isPresented: $isEmojiPickerPresented) {
                EmojiPickerView(selectedEmoji: $selectedEmoji)
                    .presentationDetents([.medium])
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: postAction) {
                        Text("Post")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func postAction() {
        let post: Post
        switch mode {
        case .photoText:
            post = Post(image: selectedImage, text: caption.isEmpty ? nil : caption)
        case .emoji:
            let emojiString = selectedEmoji.isEmpty ? "😀" : selectedEmoji
            post = Post(image: nil, text: nil, emoji: emojiString)
        }
        onPost(post)
        dismiss()
    }
}

#Preview {
    AddPostView { _ in }
}
struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmoji: String

    // A simple grid of common emojis. Could be expanded.
    private let emojis: [String] = [
        "😀","😁","😂","🤣","😊","😍","😎","🤩","😇","🥳",
        "🤔","😴","😌","🤤","🤯","😱","😭","😤","😅","🤗",
        "👍","👎","🙏","👏","💪","🔥","✨","🌈","☀️","🌙",
        "⭐️","⚡️","💥","🌸","🌼","🍀","🍕","🍣","🍪","🍩",
        "🎉","🎈","🎨","🎧","💎","❤️","🧡","💛","💚","💙",
        "💜","🖤","🤍","🤎","🌀","🌊","☁️","🌟","🌿","🌻"
    ]

    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 32))
                                .frame(width: 52, height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.06))
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Pick Emoji")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
        }
    }
}

