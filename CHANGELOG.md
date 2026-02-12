# Changelog

All notable changes to the Unsplash iOS app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Planned
- Real Unsplash API integration
- User authentication (OAuth 2.0)
- Offline mode with Core Data
- Home screen widgets
- Spotlight search integration
- Masonry waterfall layout
- Photo filters and editing
- Multi-language support

## [1.0.0] - 2025-02-12

### Added
- 🏠 Home feed with responsive photo grid
- 📱 Pull-to-refresh and infinite scroll pagination
- 🔍 Search functionality with debouncing
- 📝 Search history persistence
- 🖼️ Full-screen photo detail view
- 👆 Pinch-to-zoom gestures with pan support
- 💾 Download photos to library
- ❤️ Like/favorite photos
- 📤 Share photos
- 👤 Profile view with statistics
- 🌓 Full dark mode support
- ⚡ Image caching (memory + disk)
- 🎨 Mock data generator for testing
- 📦 MVVM architecture
- 🧪 Comprehensive CI/CD with GitHub Actions

### Security
- Photo library permission properly configured
- CodeQL security scanning enabled
- No user data collection

### Technical
- Minimum iOS version: 16.2
- Written in Swift 5.9+
- Built with Xcode 16.2
- Uses SwiftUI 4.0
- Async/await concurrency
- Combine framework for reactive bindings

---

[Unreleased]: https://github.com/zhichucode/unsplash_ios/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/zhichucode/unsplash_ios/releases/tag/v1.0.0
