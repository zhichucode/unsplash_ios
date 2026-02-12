//
//  HomeFeedViewModel.swift
//  unsplash
//
//  ViewModel for the home photo feed
//

import Foundation
import Combine

@MainActor
class HomeFeedViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasError = false

    private let apiClient = APIClient.shared
    private var currentPage = 1
    private let perPage = 20
    private var totalPages = 1

    init() {
        Task {
            await loadPhotos()
        }
    }

    func loadPhotos() async {
        currentPage = 1
        isLoading = true
        errorMessage = nil
        hasError = false

        do {
            let fetchedPhotos = try await apiClient.fetchPhotos(
                page: currentPage,
                perPage: perPage,
                orderBy: "latest"
            )
            photos = fetchedPhotos
            currentPage += 1
        } catch {
            errorMessage = error.localizedDescription
            hasError = true
        }

        isLoading = false
    }

    func loadMorePhotos() async {
        guard !isLoadingMore && currentPage <= totalPages else { return }

        isLoadingMore = true

        do {
            let fetchedPhotos = try await apiClient.fetchPhotos(
                page: currentPage,
                perPage: perPage,
                orderBy: "latest"
            )

            if !fetchedPhotos.isEmpty {
                photos.append(contentsOf: fetchedPhotos)
                currentPage += 1
            } else {
                totalPages = currentPage - 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    func refresh() async {
        await loadPhotos()
    }
}
