import Foundation
import SwiftUI

// MARK: - Post Model
// Represents a single post in the Bulletin app. Supports image, text, or both.
struct Post: Identifiable, Hashable {
    let id: UUID
    var imageData: Data?
    var text: String?
    var emoji: String?
    let timestamp: Date

    init(id: UUID = UUID(), image: UIImage? = nil, text: String? = nil, emoji: String? = nil, timestamp: Date = Date()) {
        self.id = id
        self.text = (text?.isEmpty == true) ? nil : text
        self.emoji = (emoji?.isEmpty == true) ? nil : emoji
        self.timestamp = timestamp
        if let image = image, let data = image.jpegData(compressionQuality: 0.9) {
            self.imageData = data
        } else {
            self.imageData = nil
        }
    }

    // Derived property for convenient display usage
    var uiImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }

    // Convenience to know if this is an emoji-only post
    var isEmojiOnly: Bool {
        return emoji != nil && uiImage == nil && (text == nil || text?.isEmpty == true)
    }
}

// MARK: - Sample Data (for previews)
extension Post {
    static let samples: [Post] = [
        Post(text: "Catch the light."),
        Post(image: UIImage(systemName: "photo")?.withTintColor(.black, renderingMode: .alwaysOriginal), text: "Moodboard vibes"),
        Post(image: UIImage(systemName: "sun.max.fill")?.withTintColor(.orange, renderingMode: .alwaysOriginal)),
        Post(text: "Design inspo: rounded corners, soft shadows, neutral palette."),
        Post(emoji: "🌈"),
    ]
}
