# Unsplash iOS App

<div align="center">

![Unsplash iOS](https://img.shields.io/badge/platform-iOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green)
![Xcode](https://img.shields.io/badge/Xcode-16.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A beautiful iOS photo browsing app inspired by Unsplash, built with SwiftUI and MVVM architecture.

[Features](#features) • [Tech Stack](#tech-stack) • [Installation](#installation) • [Usage](#usage) • [Contributing](#contributing)

</div>

## 📸 Features

### Core Functionality
- **🏠 Home Feed** - Browse beautiful photos in a responsive grid layout
  - Pull-to-refresh support
  - Infinite scroll pagination
  - Adaptive grid columns

- **🔍 Search** - Discover photos by keywords
  - Real-time search with debouncing
  - Search history persistence
  - Popular topics suggestions

- **🖼️ Photo Detail** - Full-screen photo viewing experience
  - Pinch-to-zoom gestures
  - Pan and double-tap to reset
  - EXIF information display
  - Like, share, and download actions

- **❤️ Favorites** - Save your favorite photos
  - Persistent favorites list
  - Quick access from tab bar

- **👤 Profile** - User profile and settings
  - Statistics overview
  - Settings placeholder

### Technical Features
- **MVVM Architecture** - Clean separation of concerns
- **Async/Await** - Modern Swift concurrency
- **Combine** - Reactive data binding
- **Image Caching** - Memory + disk cache for performance
- **Mock Data** - Built-in generator for testing
- **Dark Mode** - Full system appearance support

## 🛠 Tech Stack

| Component | Technology |
|------------|-------------|
| **Language** | Swift 5.9+ |
| **UI Framework** | SwiftUI (iOS 16+) |
| **Architecture** | MVVM |
| **Concurrency** | async/await |
| **Networking** | URLSession |
| **Caching** | Custom cache layer |
| **Navigation** | NavigationStack + TabView |
| **Persistence** | UserDefaults |

## 📦 Installation

### Prerequisites
- Xcode 16.2+
- iOS 16.2+ / iPadOS 16.2+
- Swift 5.9+

### Clone & Run
```bash
# Clone the repository
git clone https://github.com/zhichucode/unsplash_ios.git
cd unsplash_ios

# Open in Xcode
open unsplash.xcodeproj

# Or build using xcodebuild
xcodebuild -project unsplash.xcodeproj \
  -scheme unsplash \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### Configuration
To use the real Unsplash API instead of mock data:

1. Get your [Unsplash API Access Key](https://unsplash.com/developers)
2. In `Core/Network/APIClient.swift`, change:
   ```swift
   private let useMockData = false // Set to false
   ```
3. Add your access key:
   ```swift
   request.setValue("Client-ID YOUR_ACCESS_KEY", forHTTPHeaderField: "Authorization")
   ```

## 📱 Usage

### Main Tabs
| Tab | Description |
|------|-------------|
| **Home** | Browse latest photos |
| **Search** | Search by keywords |
| **Favorites** | View saved photos |
| **Profile** | User settings |

### Gestures
- **Pull down** - Refresh feed
- **Scroll to bottom** - Auto-load more
- **Pinch** - Zoom photo
- **Double tap** - Reset zoom or zoom in
- **Swipe** - Navigate back (in detail view)

## 🏗 Project Structure

```
unsplash/
├── App/                          # App entry point
│   └── MainTabView.swift          # Tab navigation
├── Core/
│   ├── Cache/                     # Image caching
│   ├── Data/Models/               # Data models
│   └── Network/                  # API client
├── Features/
│   ├── HomeFeed/                 # Home feed feature
│   ├── PhotoDetail/              # Photo detail view
│   ├── Search/                   # Search feature
│   ├── Favorites/                # Favorites management
│   └── Profile/                 # User profile
└── Shared/Components/            # Reusable UI components
```

## 🔐 Privacy

### Photo Library Permission
This app requires photo library access to save downloaded images. The permission is requested only when you tap the download button.

### Data Collection
This app does not collect or transmit any user data. All data is stored locally on the device.

## 🚀 Roadmap

- [ ] Real Unsplash API integration
- [ ] User authentication (OAuth 2.0)
- [ ] Offline mode with Core Data
- [ ] Home screen widgets
- [ ] Spotlight search integration
- [ ] Masonry waterfall layout
- [ ] Photo filters and editing
- [ ] Multi-language support

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Contact

- **GitHub**: [@zhichucode](https://github.com/zhichucode)
- **Project**: https://github.com/zhichucode/unsplash_ios

## 🙏 Acknowledgments

- [Unsplash](https://unsplash.com) for the amazing photo platform
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) by Apple

---

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/zhichucode">zhichucode</a></sub>
</div>
