//
//  FavoritesViewModel.swift
//  unsplash
//
//  ViewModel for favorites/collections view
//

import Foundation
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoritePhotos: Set<String> = []
    @Published var photos: [Photo] = []
    @Published var isLoading = false

    private let favoritesKey = "FavoritePhotos"

    init() {
        loadFavorites()
    }

    // MARK: - Favorites Management

    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoritePhotos = decoded
        }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoritePhotos) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    func isFavorite(_ photo: Photo) -> Bool {
        return favoritePhotos.contains(photo.id)
    }

    func toggleFavorite(_ photo: Photo) {
        if favoritePhotos.contains(photo.id) {
            favoritePhotos.remove(photo.id)
        } else {
            favoritePhotos.insert(photo.id)
        }
        saveFavorites()
        loadFavoritePhotos()
    }

    func loadFavoritePhotos() {
        isLoading = true

        // Filter mock photos by favorites
        let allPhotos = Photo.generateMockPhotos(count: 100)
        photos = allPhotos.filter { favoritePhotos.contains($0.id) }

        isLoading = false
    }

    func clearFavorites() {
        favoritePhotos.removeAll()
        saveFavorites()
        photos = []
    }
}
