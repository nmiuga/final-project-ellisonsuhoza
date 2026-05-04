import SwiftUI

// MARK: - Feed View with Masonry Grid
struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var pinnedPostIDs: Set<UUID> = []
    @State private var showComposer = false
    @Namespace private var launchNS
    @State private var showLaunch = true

    @State private var draggingPostID: UUID? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartIndex: Int? = nil
    @State private var itemFrames: [UUID: CGRect] = [:]
    @State private var scrollViewProxy: ScrollViewProxy? = nil

    // Basic neutral palette
    private let background = Color(.secondarySystemBackground)
    private let minReorderCount = 4

    private struct ItemFramePreferenceKey: PreferenceKey {
        static var defaultValue: [UUID: CGRect] = [:]
        static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
            value.merge(nextValue(), uniquingKeysWith: { $1 })
        }
    }
    
    private func updateFrame(id: UUID, in geo: GeometryProxy) -> some View {
        let frame = geo.frame(in: .named("feedScroll"))
        return Color.clear.preference(key: ItemFramePreferenceKey.self, value: [id: frame])
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                feed
            }

            if showLaunch { launchOverlay }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showComposer) {
            AddPostView { newPost in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    posts.insert(newPost, at: 0)
                }
            }
            .presentationDetents([.medium, .large])
        }
        .task {
            // Start with an empty feed; no seeded content
            // Subtle launch animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.85)) {
                showLaunch = false
            }
            // Optionally: load persisted pins here later
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Bulletin")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tracking(-0.5)
            Spacer()
            Button { showComposer = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06))
                    )
            }
            .accessibilityLabel("Add Post")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.clear)
    }

    private var feed: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                if posts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.dashed")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("No posts yet")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("Tap the + to create your first post")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 80)
                } else {
                    LazyVGrid(columns: masonryColumns, spacing: 14, pinnedViews: []) {
                        ForEach(sortedPosts, id: \.id) { post in
                            ZStack(alignment: .topTrailing) {
                                // Draggable card content
                                PostCardView(post: post)
                                    .opacity(draggingPostID == post.id ? 0.7 : 1)
                                    .scaleEffect(draggingPostID == post.id ? 0.98 : 1)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.9), value: draggingPostID)
                                    .overlay(
                                        GeometryReader { geo in
                                            updateFrame(id: post.id, in: geo)
                                        }
                                    )
                                    .gesture(reorderGesture(for: post))

                                // Pin button overlay
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                        togglePin(post)
                                    }
                                } label: {
                                    Image(systemName: isPinned(post) ? "pin.fill" : "pin")
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(8)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .strokeBorder(Color.primary.opacity(0.06))
                                        )
                                        .symbolRenderingMode(.hierarchical)
                                        .contentTransition(.symbolEffect(.replace))
                                        .accessibilityLabel(isPinned(post) ? "Unpin Post" : "Pin Post")
                                }
                                .padding(8)
                                .buttonStyle(.plain)
                            }
                            .contextMenu {
                                Button(isPinned(post) ? "Unpin" : "Pin", systemImage: isPinned(post) ? "pin.slash" : "pin") {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                        togglePin(post)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .offset(draggingPostID == post.id ? dragOffset : .zero)
                            .zIndex(draggingPostID == post.id ? 1 : 0)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
            .coordinateSpace(name: "feedScroll")
            .onAppear {
                self.scrollViewProxy = proxy
            }
            .onPreferenceChange(ItemFramePreferenceKey.self) { itemFrames = $0 }
        }
    }

    // MARK: - Reordering helpers
    private var canReorder: Bool { posts.count >= minReorderCount }

    private func indexFor(id: UUID) -> Int? {
        posts.firstIndex { $0.id == id }
    }

    private func idForSortedIndex(_ sortedIndex: Int) -> UUID? {
        guard sortedIndex >= 0 && sortedIndex < sortedPosts.count else { return nil }
        return sortedPosts[sortedIndex].id
    }

    private func nearestIndex(to location: CGPoint) -> Int? {
        // Find the closest item's center to the given location
        let pairs = itemFrames.map { (id, frame) -> (UUID, CGPoint) in
            (id, CGPoint(x: frame.midX, y: frame.midY))
        }
        guard !pairs.isEmpty else { return nil }
        let closest = pairs.min(by: { lhs, rhs in
            let dl = hypot(lhs.1.x - location.x, lhs.1.y - location.y)
            let dr = hypot(rhs.1.x - location.x, rhs.1.y - location.y)
            return dl < dr
        })
        guard let closestID = closest?.0 else { return nil }
        return indexFor(id: closestID)
    }

    private func moveItem(from source: Int, to destination: Int) {
        guard source != destination,
              source >= 0, source < posts.count,
              destination >= 0, destination < posts.count else { return }
        let item = posts.remove(at: source)
        posts.insert(item, at: destination)
    }

    private func reorderGesture(for post: Post) -> some Gesture {
        let press = LongPressGesture(minimumDuration: 0.2)
        let drag = DragGesture(minimumDistance: 5)

        return press.sequenced(before: drag)
            .onChanged { value in
                guard canReorder else { return }
                switch value {
                case .first(true):
                    // began long press
                    if draggingPostID == nil {
                        draggingPostID = post.id
                        dragStartIndex = indexFor(id: post.id)
                    }
                case .second(true, let drag?):
                    if draggingPostID == nil {
                        draggingPostID = post.id
                        dragStartIndex = indexFor(id: post.id)
                    }
                    dragOffset = drag.translation
                    let location = drag.location
                    if let target = nearestIndex(to: location), let start = dragStartIndex {
                        if target != start {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                moveItem(from: start, to: target)
                                dragStartIndex = target
                            }
                        }
                    }
                default:
                    break
                }
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    draggingPostID = nil
                    dragOffset = .zero
                    dragStartIndex = nil
                }
            }
    }

    // 2–3 column adaptive masonry grid
    private var masonryColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 260), spacing: 14, alignment: .top)]
    }

    // MARK: - Pinning helpers
    private func isPinned(_ post: Post) -> Bool {
        pinnedPostIDs.contains(post.id)
    }

    private func togglePin(_ post: Post) {
        if pinnedPostIDs.contains(post.id) {
            pinnedPostIDs.remove(post.id)
        } else {
            pinnedPostIDs.insert(post.id)
        }
    }

    private var sortedPosts: [Post] {
        posts.sorted { a, b in
            let ap = pinnedPostIDs.contains(a.id)
            let bp = pinnedPostIDs.contains(b.id)
            if ap != bp { return ap && !bp }
            // Fallback to original order by comparing indices in `posts`
            let ai = posts.firstIndex { $0.id == a.id } ?? 0
            let bi = posts.firstIndex { $0.id == b.id } ?? 0
            return ai < bi
        }
    }

    // Simple launch overlay for a subtle opening animation
    private var launchOverlay: some View {
        ZStack {
            background.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Bulletin")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .matchedGeometryEffect(id: "title", in: launchNS)
                Text("Your aesthetic board")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    FeedView()
}
