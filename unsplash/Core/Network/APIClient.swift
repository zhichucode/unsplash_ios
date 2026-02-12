//
//  APIClient.swift
//  unsplash
//
//  Network API client for Unsplash
//

import Foundation

// Helper structs for API responses
private struct DownloadResponse: Codable {
    let url: URL
}

class APIClient {
    static let shared = APIClient()

    private let baseURL = "https://api.unsplash.com"
    private let useMockData = true // Set to false when using real API
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        session = URLSession(configuration: configuration)
    }

    private func buildURL(for endpoint: APIEndpoint) -> URL? {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            return nil
        }
        components.queryItems = endpoint.queryItems
        return components.url
    }

    private func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        // Use mock data if enabled
        if useMockData {
            return try await mockRequest(endpoint: endpoint, responseType: responseType)
        }

        guard let url = buildURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add API key if using real API
        // request.setValue("Client-ID YOUR_ACCESS_KEY", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    private func mockRequest<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))

        switch endpoint {
        case .listPhotos(let page, let perPage, _):
            // Return mock photos with pagination
            let startIndex = (page - 1) * perPage
            let allPhotos = Photo.generateMockPhotos(count: 100)
            let endIndex = min(startIndex + perPage, allPhotos.count)

            if startIndex >= allPhotos.count {
                return [] as! T
            }

            let photos = Array(allPhotos[startIndex..<endIndex])
            return photos as! T

        case .getPhoto(let id):
            let allPhotos = Photo.generateMockPhotos(count: 100)
            if let photo = allPhotos.first(where: { $0.id == id }) {
                return photo as! T
            }
            throw NetworkError.unknown

        case .getPhotoDownloadLink:
            guard let url = URL(string: "https://unsplash.com/photos/download") else {
                throw NetworkError.invalidURL
            }
            return DownloadResponse(url: url) as! T

        case .searchPhotos(let query, let page, let perPage):
            let allPhotos = Photo.generateMockPhotos(count: 100)
            // Simple filter for mock search
            let filtered = allPhotos.filter { photo in
                photo.displayDescription?.localizedCaseInsensitiveContains(query) == true ||
                photo.user.name.localizedCaseInsensitiveContains(query) == true ||
                photo.user.username.localizedCaseInsensitiveContains(query) == true
            }

            let startIndex = (page - 1) * perPage
            let endIndex = min(startIndex + perPage, filtered.count)

            if startIndex >= filtered.count {
                let emptyResponse = SearchResponse(total: filtered.count, totalPages: 1, results: [])
                return emptyResponse as! T
            }

            let results = Array(filtered[startIndex..<endIndex])
            let response = SearchResponse(total: filtered.count, totalPages: (filtered.count / perPage) + 1, results: results)
            return response as! T

        case .getRandomPhotos(let count):
            let photoCount = count ?? 10
            let allPhotos = Photo.generateMockPhotos(count: 100)
            let randomPhotos = Array(allPhotos.shuffled().prefix(photoCount))
            return randomPhotos as! T

        case .getPhotoStatistics, .getUserProfile, .getUserPhotos, .getUserLikes:
            // Not fully implemented for mock
            throw NetworkError.unknown
        }
    }

    // MARK: - Photo APIs

    func fetchPhotos(page: Int = 1, perPage: Int = 20, orderBy: String = "latest") async throws -> [Photo] {
        return try await request(endpoint: .listPhotos(page: page, perPage: perPage, orderBy: orderBy), responseType: [Photo].self)
    }

    func fetchPhoto(id: String) async throws -> Photo {
        return try await request(endpoint: .getPhoto(id: id), responseType: Photo.self)
    }

    func fetchPhotoStatistics(id: String) async throws -> PhotoStats {
        return try await request(endpoint: .getPhotoStatistics(id: id), responseType: PhotoStats.self)
    }

    func fetchDownloadLink(for photoId: String) async throws -> URL {
        let response = try await request(endpoint: .getPhotoDownloadLink(id: photoId), responseType: DownloadResponse.self)
        return response.url
    }

    func fetchRandomPhotos(count: Int? = nil) async throws -> [Photo] {
        return try await request(endpoint: .getRandomPhotos(count: count), responseType: [Photo].self)
    }

    // MARK: - Search APIs

    func searchPhotos(query: String, page: Int = 1, perPage: Int = 20) async throws -> SearchResponse {
        guard !query.isEmpty else {
            return SearchResponse(total: 0, totalPages: 0, results: [])
        }
        return try await request(endpoint: .searchPhotos(query: query, page: page, perPage: perPage), responseType: SearchResponse.self)
    }

    // MARK: - User APIs

    func fetchUserProfile(username: String) async throws -> User {
        return try await request(endpoint: .getUserProfile(username: username), responseType: User.self)
    }

    func fetchUserPhotos(username: String, page: Int = 1, perPage: Int = 20) async throws -> [Photo] {
        return try await request(endpoint: .getUserPhotos(username: username, page: page, perPage: perPage), responseType: [Photo].self)
    }

    func fetchUserLikes(username: String, page: Int = 1, perPage: Int = 20) async throws -> [Photo] {
        return try await request(endpoint: .getUserLikes(username: username, page: page, perPage: perPage), responseType: [Photo].self)
    }
}
