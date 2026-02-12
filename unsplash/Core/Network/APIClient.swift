//
//  APIClient.swift
//  unsplash
//
//  Network API client for Pexels
//

import Foundation

class APIClient {
    static let shared = APIClient()

    // Load API configuration from xcconfig file
    private let baseURL: String
    private let apiKey: String
    private let useMockData = false // Set to true for testing without API calls
    private let session: URLSession

    private init() {
        // Read from Pexels.config.xcconfig
        let environment = ProcessInfo.processInfo.environment

        // Try to get from config file first
        if let configPath = Bundle.main.path(forResource: "Pexels.config", ofType: "xcconfig"),
           let config = NSDictionary(contentsOfFile: configPath),
           let apiKey = config["PEXELS_API_KEY"] as? String,
           let baseUrl = config["PEXELS_BASE_URL"] as? String {
            self.baseURL = baseUrl
            self.apiKey = apiKey
        } else {
            // Fallback to environment variables or hardcoded values
            self.baseURL = environment["PEXELS_BASE_URL"] ?? "https://api.pexels.com/v1"
            self.apiKey = environment["PEXELS_API_KEY"] ?? ""
        }

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
        request.setValue(apiKey, forHTTPHeaderField: "Authorization") // Pexels API key

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

    // Convert PexelsPhoto to our Photo model
    private func convertToPhoto(_ pexelsPhoto: PexelsPhoto) -> Photo {
        let urls = PhotoURLs(
            raw: pexelsPhoto.src.original,
            full: pexelsPhoto.src.large2x,
            regular: pexelsPhoto.src.large,
            small: pexelsPhoto.src.medium,
            thumb: pexelsPhoto.src.small,
            smallS3: pexelsPhoto.src.tiny
        )

        let user = User(
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
        )

        return Photo(
            id: "\(pexelsPhoto.id)",
            width: pexelsPhoto.width,
            height: pexelsPhoto.height,
            color: pexelsPhoto.avgColor,
            blurHash: nil,
            description: pexelsPhoto.alt,
            altDescription: pexelsPhoto.alt,
            urls: urls,
            links: PhotoLinks(
                selfLink: nil,
                html: nil,
                download: pexelsPhoto.url,
                downloadLocation: nil
            ),
            likes: 0,
            likedByUser: pexelsPhoto.liked,
            user: user,
            exif: nil,
            location: nil,
            stats: nil,
            createdAt: nil
        )
    }

    private func mockRequest<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))

        switch endpoint {
        case .curatedPhotos, .listPhotos:
            // Return mock photos with pagination - reuse existing generator
            let photos = Photo.generateMockPhotos(count: 20)
            if case .curatedPhotos(let page, let perPage) = endpoint {
                let startIndex = (page - 1) * perPage
                let endIndex = min(startIndex + perPage, photos.count)
                if startIndex >= photos.count {
                    return [] as! T
                }
                return Array(photos[startIndex..<endIndex]) as! T
            }
            return [] as! T

        case .searchPhotos(let query, let page, let perPage):
            // Simple filter for mock search
            let allPhotos = Photo.generateMockPhotos(count: 100)
            let filtered = allPhotos.filter { photo in
                photo.displayDescription?.localizedCaseInsensitiveContains(query) == true ||
                photo.user.name.localizedCaseInsensitiveContains(query) == true ||
                photo.user.username.localizedCaseInsensitiveContains(query) == true
            }

            let startIndex = (page - 1) * perPage
            let endIndex = min(startIndex + perPage, filtered.count)

            if startIndex >= filtered.count {
                // Return empty Pexels response
                let emptyPhotos: [PexelsPhoto] = []
                let emptyResponse = PexelsSearchResponse(
                    photos: emptyPhotos,
                    page: page,
                    perPage: perPage,
                    totalResults: 0,
                    nextPage: nil
                )
                if let data = try? JSONEncoder().encode(emptyResponse),
                   let decoded = try? JSONDecoder().decode(T.self, from: data) {
                    return decoded
                }
            }

            // Map Photos to PexelsPhoto format
            var pexelsPhotos: [PexelsPhoto] = []
            for photo in filtered[startIndex..<endIndex] {
                let pPhoto = PexelsPhoto(
                    id: Int(photo.id) ?? 0,
                    width: photo.width,
                    height: photo.height,
                    url: photo.urls.regular ?? "",
                    photographer: photo.user.name,
                    photographerURL: photo.user.links?.html,
                    photographerID: Int(photo.id) ?? 0,
                    avgColor: photo.color,
                    src: PexelsPhotoSource(
                        original: photo.urls.raw ?? "",
                        large2x: photo.urls.full ?? "",
                        large: photo.urls.regular ?? "",
                        medium: photo.urls.small ?? "",
                        small: photo.urls.thumb ?? "",
                        portrait: nil,
                        landscape: nil,
                        tiny: nil
                    ),
                    alt: photo.displayDescription,
                    liked: photo.likedByUser
                )
                pexelsPhotos.append(pPhoto)
            }

            let response = PexelsSearchResponse(
                photos: pexelsPhotos,
                page: page,
                perPage: perPage,
                totalResults: filtered.count,
                nextPage: page < (filtered.count / perPage + 1) ? "\(page + 1)" : nil
            )

            if let data = try? JSONEncoder().encode(response),
               let decoded = try? JSONDecoder().decode(T.self, from: data) {
                return decoded
            }
            throw NetworkError.unknown
        }
    }

    // MARK: - Photo APIs

    func fetchPhotos(page: Int = 1, perPage: Int = 20, orderBy: String = "latest") async throws -> [Photo] {
        let response = try await request(endpoint: .curatedPhotos(page: page, perPage: perPage), responseType: PexelsPhotosResponse.self)
        return response.photos.map { convertToPhoto($0) }
    }

    func fetchCuratedPhotos(page: Int = 1, perPage: Int = 20) async throws -> [Photo] {
        let response = try await request(endpoint: .curatedPhotos(page: page, perPage: perPage), responseType: PexelsPhotosResponse.self)
        return response.photos.map { convertToPhoto($0) }
    }

    func fetchPhoto(id: String) async throws -> Photo {
        // For Pexels, we need to fetch individual photo
        // Pexels doesn't have a dedicated endpoint for single photo details
        // We'll search by ID using a workaround
        throw NetworkError.unknown
    }

    // MARK: - Search APIs

    func searchPhotos(query: String, page: Int = 1, perPage: Int = 20) async throws -> PexelsSearchResponse {
        guard !query.isEmpty else {
            return PexelsSearchResponse(photos: [], page: 1, perPage: perPage, totalResults: 0, nextPage: nil)
        }
        return try await request(endpoint: .searchPhotos(query: query, page: page, perPage: perPage), responseType: PexelsSearchResponse.self)
    }
}
