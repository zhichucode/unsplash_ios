//
//  PhotoGridCell.swift
//  unsplash
//
//  Photo grid cell with dynamic height and alternating layout
//

import SwiftUI

struct PhotoGridCell: View {
    let photo: Photo
    let index: Int
    let totalPhotos: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Image
                AsyncImageView(url: URL(string: photo.urls.small ?? photo.urls.regular ?? ""))
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .onAppear {
                        // Calculate aspect ratio is handled at parent level
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
