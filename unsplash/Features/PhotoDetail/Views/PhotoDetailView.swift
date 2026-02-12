//
//  PhotoDetailView.swift
//  unsplash
//
//  Full screen photo detail view
//

import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    @StateObject private var viewModel: PhotoDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showUserInfo = false

    init(photo: Photo) {
        self.photo = photo
        self._viewModel = StateObject(wrappedValue: PhotoDetailViewModel(photo: photo))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top toolbar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.ultraThinMaterial))
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        // Share button
                        if let shareURL = viewModel.shareImage() {
                            ShareLink(item: shareURL) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                        }

                        // Download button
                        Button {
                            Task {
                                await viewModel.downloadImage()
                            }
                        } label: {
                            if viewModel.isDownloading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(.ultraThinMaterial))
                            } else {
                                Image(systemName: "arrow.down.to.line")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                        }
                        .disabled(viewModel.isDownloading)

                        // Like button
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                viewModel.toggleLike()
                            }
                        } label: {
                            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(viewModel.isLiked ? .red : .white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                }
                .padding()

                // Photo
                PhotoZoomView(photo: photo)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom info panel
                photoInfoPanel
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }

    private var photoInfoPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // User info
                Button {
                    if let url = viewModel.openUserProfile() {
                        // In real app, you'd navigate to user profile
                        print("Open user profile: \(url)")
                    }
                } label: {
                    HStack(spacing: 12) {
                        AsyncImageView(
                            url: URL(string: photo.user.profileImage?.medium ?? ""),
                            placeholder: Circle()
                                .fill(Color(.systemGray5))
                        )
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(photo.user.name)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text("@\(photo.user.username)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Divider()

                // Description
                if let description = photo.displayDescription {
                    Text(description)
                        .font(.body)
                }

                // EXIF info
                if let exif = photo.exif, let exifDescription = exif.formattedDescription {
                    HStack {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.secondary)
                        Text(exifDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let location = photo.location {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.secondary)
                            Text([location.city, location.country].compactMap { $0 }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Published date
                if let createdAt = photo.createdAt {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Stats
                if let stats = photo.stats {
                    HStack(spacing: 20) {
                        if let views = stats.views {
                            StatItem(icon: "eye", count: views, label: "Views")
                        }
                        if let downloads = stats.downloads {
                            StatItem(icon: "arrow.down", count: downloads, label: "Downloads")
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .frame(maxHeight: 300)
    }
}

struct StatItem: View {
    let icon: String
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.secondary)

            Text(formatCount(count))
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}

// Preview
#Preview {
    NavigationStack {
        let mockPhoto = Photo.generateMockPhotos(count: 1).first!
        PhotoDetailView(photo: mockPhoto)
    }
}
