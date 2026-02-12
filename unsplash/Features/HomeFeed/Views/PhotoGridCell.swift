//
//  PhotoGridCell.swift
//  unsplash
//
//  Photo grid cell component for home feed
//

import SwiftUI

struct PhotoGridCell: View {
    let photo: Photo
    @State private var imageAspectRatio: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Image
                AsyncImageView(url: URL(string: photo.urls.small ?? photo.urls.regular ?? ""))
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .onAppear {
                        // Calculate aspect ratio
                        imageAspectRatio = photo.aspectRatio
                    }

                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 60)

                // User info
                HStack(spacing: 2) {
                    // User avatar
                    AsyncImageView(
                        url: URL(string: photo.user.profileImage?.small ?? ""),
                        placeholder: Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 24, height: 24)
                    )
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(photo.user.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if let location = photo.location?.city {
                            Text(location)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Likes
                    HStack(spacing: 2) {
                        Image(systemName: photo.likedByUser ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(photo.likedByUser ? .red : .white)
                        Text("\(photo.likes)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Preview
#Preview {
    let mockPhotos = Photo.generateMockPhotos(count: 6)

    return LazyVGrid(
        columns: [
            GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 2)
        ],
        spacing: 2
    ) {
        ForEach(mockPhotos) { photo in
            PhotoGridCell(photo: photo)
                .aspectRatio(photo.aspectRatio, contentMode: .fit)
        }
    }
}
