#  Initial Prompt

#Prompt: Build a SwiftUI iOS App (“Bulletin”)
##Build a polished iOS app in SwiftUI for Xcode called “Bulletin” (temporary name). It should be a single-user, personal app with a modern, aesthetic design inspired by Pinterest, VSCO, and a digital bulletin board.

##Core Functionality
* One main home/feed screen shown on launch
* Vertically scrollable feed displaying all posts
* New posts appear at the top
* No accounts or multi-user features (single-user only)

##Feed / Layout Design
* Pinterest-style masonry grid
* 2–3 columns across screen width
* Posts displayed as dynamic cards that adjust height based on content
* Support:
    * Image-only posts
    * Text-only posts
    * Image + text posts
##Design style:
    * Clean, minimal, trendy (Gen Z aesthetic)
    * Rounded corners, soft shadows
    * Balanced spacing/padding
    * Smooth scrolling

##Post Creation
* + button (top right) opens a modal/new screen
* User can create:
    * Photo
    * Text
    * Photo + Text
##Requirements:
    * Image picker support
    * Optional caption field
    * Both inputs optional
* Include a clear “Post” button
* On submit:
    * Save locally
    * Return to feed
    * Display new post at top

##Data / State
* Use local state only (no backend)
* Create a Post model with:
    * Unique ID
    * Optional image
    * Optional text
    * Timestamp
* Structure code so backend integration can be added later

##Design / UI Expectations
* App should feel polished and App Store-ready
* Use:
    * Modern typography
    * Neutral/minimal color palette
    * Clean spacing hierarchy
    * Subtle animations/transitions
* Highly visual, “aesthetic board” feel

##Code Structure
###Organize into separate SwiftUI components:
* Main Feed View
* Post Card Component
* Add Post View
* Post Model
* Helpers/Extensions
Keep code clean, modular, and scalable.

##Extras
* Include a simple launch/opening animation
* Do not implement widgets yet, but keep structure widget-friendly

App Icon
Explain how to properly add a custom app icon in Xcode.

##Deliverable
* Fully functional, runnable SwiftUI project
* Clean, well-commented code
* Uses best practices
* Strong focus on UI/UX polish


