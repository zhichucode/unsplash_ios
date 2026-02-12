//
//  LoadingIndicator.swift
//  unsplash
//
//  Reusable loading indicator component
//

import SwiftUI

struct LoadingIndicator: View {
    let text: String?
    @State private var isAnimating = false

    init(_ text: String? = nil) {
        self.text = text
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.primary)

            if let text = text {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .animation(.easeInOut(duration: 0.8).repeatForever(), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let subtitle: String?

    init(systemImage: String, title: String, subtitle: String? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

struct ErrorView: View {
    let error: String
    let onRetry: (() -> Void)?

    init(error: String, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Something went wrong")
                .font(.headline)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
    }
}

// Preview
#Preview("Loading Indicator") {
    LoadingIndicator("Loading photos...")
}

#Preview("Empty State") {
    EmptyStateView(
        systemImage: "photo.stack",
        title: "No Photos",
        subtitle: "Check back later for new photos"
    )
}

#Preview("Error View") {
    ErrorView(error: "Failed to load photos. Please check your internet connection.") {
        print("Retry tapped")
    }
}
