//
//  SearchViewModel.swift
//  unsplash
//
//  ViewModel for search functionality
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [Photo] = []
    @Published var searchQuery = ""
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var totalResults = 0
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared
    private var searchTask: Task<Void, Never>?
    private var currentPage = 1
    private var totalPages = 1

    // Search history
    @Published var searchHistory: [String] = []
    private let maxHistoryItems = 10
    private let historyKey = "SearchHistory"

    // Popular topics
    let popularTopics = [
        "Nature", "Architecture", "People", "Travel",
        "Animals", "Food", "Technology", "Abstract",
        "Fashion", "Sports", "Business", "Music"
    ]

    init() {
        loadSearchHistory()
    }

    // MARK: - Search

    func search(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            totalResults = 0
            hasSearched = false
            return
        }

        // Cancel previous search
        searchTask?.cancel()

        // Debounce search
        searchTask = Task {
            isSearching = true
            hasSearched = true

            do {
                // Small delay for debouncing
                try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

                try Task.checkCancellation()

                let response = try await apiClient.searchPhotos(
                    query: query,
                    page: 1,
                    perPage: 20
                )

                // Convert PexelsPhoto to Photo
                searchResults = response.photos.map { pexelsPhoto in
                    Photo(
                        id: "\(pexelsPhoto.id)",
                        width: pexelsPhoto.width,
                        height: pexelsPhoto.height,
                        color: pexelsPhoto.avgColor,
                        blurHash: nil,
                        description: pexelsPhoto.alt,
                        altDescription: pexelsPhoto.alt,
                        urls: PhotoURLs(
                            raw: pexelsPhoto.src.original,
                            full: pexelsPhoto.src.large2x,
                            regular: pexelsPhoto.src.large,
                            small: pexelsPhoto.src.medium,
                            thumb: pexelsPhoto.src.small,
                            smallS3: pexelsPhoto.src.tiny
                        ),
                        links: PhotoLinks(
                            selfLink: nil,
                            html: pexelsPhoto.photographerURL,
                            download: pexelsPhoto.url,
                            downloadLocation: nil
                        ),
                        likes: 0,
                        likedByUser: pexelsPhoto.liked,
                        user: User(
                            id: "\(pexelsPhoto.photographerID)",
                            username: "",
                            name: pexelsPhoto.photographer,
                            firstName: pexelsPhoto.photographer,
                            lastName: nil,
                            bio: nil,
                            location: nil,
                            links: UserLinks(
                                selfLink: nil,
                                html: pexelsPhoto.photographerURL,
                                photos: nil,
                                likes: nil,
                                portfolio: nil
                            ),
                            profileImage: nil,
                            totalLikes: nil,
                            totalPhotos: nil,
                            totalCollections: nil,
                            instagramUsername: nil,
                            twitterUsername: nil
                        ),
                        exif: nil,
                        location: nil,
                        stats: nil,
                        createdAt: nil
                    )
                }
                totalResults = response.totalResults ?? 0
                totalPages = Int((Double(totalResults) / Double(20)).rounded(.up)) + 1
                currentPage = 1
                errorMessage = nil

                addToSearchHistory(query)
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }

            isSearching = false
        }

        await searchTask?.value
    }

    func loadMoreResults() async {
        guard !isSearching && currentPage < totalPages else { return }

        do {
            currentPage += 1
            let response = try await apiClient.searchPhotos(
                query: searchQuery,
                page: currentPage,
                perPage: 20
            )

            // Convert PexelsPhoto to Photo and append
            let newPhotos = response.photos.map { pexelsPhoto in
                Photo(
                    id: "\(pexelsPhoto.id)",
                    width: pexelsPhoto.width,
                    height: pexelsPhoto.height,
                    color: pexelsPhoto.avgColor,
                    blurHash: nil,
                    description: pexelsPhoto.alt,
                    altDescription: pexelsPhoto.alt,
                    urls: PhotoURLs(
                        raw: pexelsPhoto.src.original,
                        full: pexelsPhoto.src.large2x,
                        regular: pexelsPhoto.src.large,
                        small: pexelsPhoto.src.medium,
                        thumb: pexelsPhoto.src.small,
                        smallS3: pexelsPhoto.src.tiny
                    ),
                    links: PhotoLinks(
                        selfLink: nil,
                        html: pexelsPhoto.photographerURL,
                        download: pexelsPhoto.url,
                        downloadLocation: nil
                    ),
                    likes: 0,
                    likedByUser: pexelsPhoto.liked,
                    user: User(
                        id: "\(pexelsPhoto.photographerID)",
                        username: "",
                        name: pexelsPhoto.photographer,
                        firstName: pexelsPhoto.photographer,
                        lastName: nil,
                        bio: nil,
                        location: nil,
                        links: UserLinks(
                            selfLink: nil,
                            html: pexelsPhoto.photographerURL,
                            photos: nil,
                            likes: nil,
                            portfolio: nil
                        ),
                        profileImage: nil,
                        totalLikes: nil,
                        totalPhotos: nil,
                        totalCollections: nil,
                        instagramUsername: nil,
                        twitterUsername: nil
                    ),
                    exif: nil,
                    location: nil,
                    stats: nil,
                    createdAt: nil
                )
            }
            searchResults.append(contentsOf: newPhotos)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search History

    private func loadSearchHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            searchHistory = decoded
        }
    }

    private func saveSearchHistory() {
        if let encoded = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    private func addToSearchHistory(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)

        // Remove if already exists
        searchHistory.removeAll { $0 == trimmedQuery }

        // Add to beginning
        searchHistory.insert(trimmedQuery, at: 0)

        // Limit history size
        if searchHistory.count > maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxHistoryItems))
        }

        saveSearchHistory()
    }

    func removeFromSearchHistory(_ query: String) {
        searchHistory.removeAll { $0 == query }
        saveSearchHistory()
    }

    func clearSearchHistory() {
        searchHistory = []
        saveSearchHistory()
    }

    func searchFromHistory(_ query: String) async {
        searchQuery = query
        await search(query: query)
    }

    // MARK: - Clear

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        totalResults = 0
        hasSearched = false
        errorMessage = nil
    }
}
