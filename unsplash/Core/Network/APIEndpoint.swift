//
//  APIEndpoint.swift
//  unsplash
//
//  API endpoint definitions
//

import Foundation

enum APIEndpoint {
    // Photos
    case listPhotos(page: Int, perPage: Int, orderBy: String)
    case getPhoto(id: String)
    case getPhotoStatistics(id: String)
    case getPhotoDownloadLink(id: String)
    case getRandomPhotos(count: Int?)

    // Search
    case searchPhotos(query: String, page: Int, perPage: Int)

    // Users
    case getUserProfile(username: String)
    case getUserPhotos(username: String, page: Int, perPage: Int)
    case getUserLikes(username: String, page: Int, perPage: Int)

    var path: String {
        switch self {
        // Photos
        case .listPhotos:
            return "/photos"
        case .getPhoto(let id):
            return "/photos/\(id)"
        case .getPhotoStatistics(let id):
            return "/photos/\(id)/statistics"
        case .getPhotoDownloadLink(let id):
            return "/photos/\(id)/download"
        case .getRandomPhotos:
            return "/photos/random"

        // Search
        case .searchPhotos:
            return "/search/photos"

        // Users
        case .getUserProfile(let username):
            return "/users/\(username)"
        case .getUserPhotos(let username, _, _):
            return "/users/\(username)/photos"
        case .getUserLikes(let username, _, _):
            return "/users/\(username)/likes"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .listPhotos(let page, let perPage, let orderBy):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "order_by", value: orderBy)
            ]
        case .getPhoto, .getPhotoStatistics, .getPhotoDownloadLink, .getUserProfile:
            return nil
        case .getRandomPhotos(let count):
            if let count = count {
                return [URLQueryItem(name: "count", value: "\(count)")]
            }
            return nil
        case .searchPhotos(let query, let page, let perPage):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .getUserPhotos(_, let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .getUserLikes(_, let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        }
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .requestFailed(let error):
            return "The request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "The response was invalid."
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

struct SearchResponse: Codable {
    let total: Int
    let totalPages: Int
    let results: [Photo]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}
