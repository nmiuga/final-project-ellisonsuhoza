import SwiftUI

// MARK: - Post Card Component
struct PostCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let emoji = post.emoji, (post.uiImage == nil) && ((post.text == nil) || post.text?.isEmpty == true) {
                // Large centered emoji card
                ZStack {
                    Text(emoji)
                        .font(.system(size: 80))
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, minHeight: 160)
                        .padding(.vertical, 16)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            
            if let image = post.uiImage {
                GeometryReader { geo in
                    let width = geo.size.width
                    // Compute a stable height based on image aspect, clamped to reasonable bounds
                    let aspect = image.size.height / max(image.size.width, 1)
                    let minH: CGFloat = 160
                    let maxH: CGFloat = 320
                    let targetH = min(max(width * aspect, minH), maxH)

                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: targetH)
                            .clipped()
                    }
                    .frame(width: width, height: targetH)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.05))
                    )
                }
                .frame(height: dynamicImageFallbackHeight(for: image))
            }

            if let text = post.text, !text.isEmpty {
                Text(text)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dynamicImageFallbackHeight(for image: UIImage) -> CGFloat {
        // Provide a reasonable fallback height used by the outer frame of GeometryReader
        let aspect = image.size.height / max(image.size.width, 1)
        let base: CGFloat = 220
        let minH: CGFloat = 160
        let maxH: CGFloat = 320
        return min(max(base * aspect, minH), maxH)
    }

    private func dynamicImageHeight(for image: UIImage) -> CGFloat {
        let aspect = image.size.height / max(image.size.width, 1)
        // Bias toward consistent card heights for a cleaner masonry look
        let base: CGFloat = 220
        let minH: CGFloat = 160
        let maxH: CGFloat = 320
        return min(max(base * aspect, minH), maxH)
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 16) {
            ForEach(Post.samples, id: \.id) { post in
                PostCardView(post: post)
                    .padding(.horizontal)
            }
        }
    }
    .background(Color(.systemGroupedBackground))
}
