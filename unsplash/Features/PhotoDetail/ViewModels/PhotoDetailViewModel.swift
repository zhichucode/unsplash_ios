//
//  PhotoDetailViewModel.swift
//  unsplash
//
//  ViewModel for photo detail view
//

import Foundation
import UIKit
import Photos
import Combine

@MainActor
class PhotoDetailViewModel: ObservableObject {
    @Published var photo: Photo
    @Published var isLiked: Bool
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var showShareSheet = false
    @Published var downloadedImage: UIImage?

    private let apiClient = APIClient.shared

    init(photo: Photo) {
        self.photo = photo
        self.isLiked = photo.likedByUser
    }

    func toggleLike() {
        isLiked.toggle()
        // In real app, you'd make an API call here
        // POST /photos/:id/like or DELETE /photos/:id/like
    }

    func downloadImage() async {
        isDownloading = true
        downloadProgress = 0

        do {
            // Download the image
            guard let urlString = photo.urls.full ?? photo.urls.regular,
                  let url = URL(string: urlString) else {
                isDownloading = false
                return
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            downloadProgress = 0.8

            if let image = UIImage(data: data) {
                downloadedImage = image
                downloadProgress = 1.0

                // Request photo library permission and save
                let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

                if status == .authorized || status == .limited {
                    try await PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }
                }
            }
        } catch {
            print("Error downloading image: \(error)")
        }

        isDownloading = false
    }

    func shareImage() -> URL? {
        return URL(string: photo.links.html ?? "")
    }

    func openUserProfile() -> URL? {
        return URL(string: photo.user.links?.html ?? "")
    }
}
