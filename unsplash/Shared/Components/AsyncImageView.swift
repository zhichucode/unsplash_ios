//
//  AsyncImageView.swift
//  unsplash
//
//  Async image loading component with caching
//

import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    let placeholder: AnyView?
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasError = false

    init(url: URL?, placeholder: AnyView? = nil) {
        self.url = url
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if hasError {
                if let placeholder = placeholder {
                    placeholder
                } else {
                    defaultPlaceholder
                }
            } else {
                if let placeholder = placeholder {
                    placeholder
                } else {
                    ProgressView()
                        .tint(.secondary)
                }
            }
        }
        .task {
            await loadImage()
        }
        .id(url) // Reload when URL changes
    }

    private var defaultPlaceholder: some View {
        ZStack {
            Color(.systemGray6)
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
        }
    }

    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            hasError = true
            return
        }

        // Check cache first
        if let cachedImage = ImageCache.shared.image(for: url) {
            await MainActor.run {
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
            self.hasError = false
        }

        // Download image
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let uiImage = UIImage(data: data) {
                ImageCache.shared.setImage(uiImage, for: url)

                await MainActor.run {
                    self.image = uiImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                    self.hasError = true
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.hasError = true
            }
        }
    }
}

// Convenience initializers
extension AsyncImageView {
    init(url: URL?, placeholder: some View) {
        self.url = url
        self.placeholder = AnyView(placeholder)
    }

    init(string: String?, placeholder: AnyView? = nil) {
        self.url = URL(string: string ?? "")
        self.placeholder = placeholder
    }

    init(string: String?, placeholder: some View) {
        self.url = URL(string: string ?? "")
        self.placeholder = AnyView(placeholder)
    }
}

// Preview
#Preview {
    VStack(spacing: 20) {
        AsyncImageView(url: URL(string: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400"))
            .frame(width: 200, height: 200)
            .cornerRadius(12)

        AsyncImageView(url: URL(string: "https://example.com/invalid"))
            .frame(width: 200, height: 200)
            .cornerRadius(12)
    }
    .padding()
}
