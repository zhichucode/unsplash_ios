# Contributing to Unsplash iOS

Thank you for your interest in contributing to the Unsplash iOS app!

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Bug Report Template:**
```
**Description**: A clear and concise description of what the bug is.

**To Reproduce**:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**: A concise description of what you expected to happen.

**Actual Behavior**: A concise description of what actually happened.

**Screenshots**: If applicable, add screenshots to help explain your problem.

**Environment**:
 - Device: [e.g. iPhone 15 Pro]
 - iOS Version: [e.g. iOS 17.2]
 - App Version: [e.g. 1.0.0]
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Use Case**: What problem would this solve?
- **Proposed Solution**: How do you think it should be implemented?
- **Alternatives**: What other solutions have you considered?

### Pull Requests

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Code Style Guidelines

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Commit Messages

Follow conventional commits format:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `test:` Adding or updating tests

Example:
```
feat: add dark mode support to photo detail view
fix: resolve infinite scroll pagination issue
docs: update README with installation instructions
```

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/unsplash_ios.git
cd unsplash_ios

# Install dependencies (if any)
# No external dependencies currently

# Open in Xcode
open unsplash.xcodeproj
```

### Running Tests

```bash
# Run all tests
xcodebuild test -project unsplash.xcodeproj -scheme unsplash

# Run specific test
xcodebuild test -project unsplash.xcodeproj -scheme unsplash -only-testing:unsplashTests/SpecificTest
```

## Project Structure

Understanding the project structure will help you navigate the codebase:

```
unsplash/
├── App/                    # App lifecycle and navigation
├── Core/
│   ├── Cache/              # Image caching implementation
│   ├── Data/Models/        # Data models (Photo, User, etc.)
│   └── Network/           # API client and endpoints
├── Features/
│   ├── HomeFeed/          # Photo browsing
│   ├── PhotoDetail/        # Full-screen photo view
│   ├── Search/             # Search functionality
│   ├── Favorites/          # Saved photos
│   └── Profile/           # User profile
└── Shared/Components/     # Reusable UI components
```

## Questions?

Feel free to open an issue for any questions about contributing or the codebase itself.

---

**Thank you for your contributions! 🙏**
