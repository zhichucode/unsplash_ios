//
//  APIEndpoint.swift
//  unsplash
//
//  API endpoint definitions for Pexels
//

import Foundation

enum APIEndpoint {
    // Photos
    case curatedPhotos(page: Int, perPage: Int)
    case listPhotos(page: Int, perPage: Int)
    case searchPhotos(query: String, page: Int, perPage: Int)

    var path: String {
        switch self {
        // Photos
        case .curatedPhotos:
            return "/curated"
        case .listPhotos:
            return "/photos"
        case .getPhoto(let id):
            return "/photos/\(id)"
        case .searchPhotos:
            return "/search" // Note: Pexels uses /search not /search/photos
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .curatedPhotos(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .listPhotos(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        case .searchPhotos:
            return nil
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

// MARK: - Pexels API Response Models

struct PexelsPhotosResponse: Codable {
    let photos: [PexelsPhoto]
    let page: Int?
    let perPage: Int?
    let totalResults: Int?
    let nextPage: String?

    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case page
        case perPage = "per_page"
        case totalResults = "total_results"
        case nextPage
    }
}

struct PexelsSearchResponse: Codable {
    let photos: [PexelsPhoto]
    let page: Int?
    let perPage: Int?
    let totalResults: Int?
    let nextPage: String?

    enum CodingKeys: String, CodingKey {
        case photos
        case page
        case perPage = "per_page"
        case totalResults = "total_results"
        case nextPage
    }
}

// Pexels specific photo model
struct PexelsPhoto: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerURL: String?
    let photographerID: Int
    let avgColor: String?
    let src: PexelsPhotoSource
    let alt: String?
    let liked: Bool

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer
        case photographerURL = "photographer_url"
        case photographerID = "photographer_id"
        case avgColor = "avg_color"
        case src, alt, liked
    }
}

struct PexelsPhotoSource: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String?
    let landscape: String?
    let tiny: String?
}
