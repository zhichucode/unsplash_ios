//
//  Photo.swift
//  unsplash
//
//  Core data model for photo information
//

import Foundation

struct PhotoURLs: Codable, Hashable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
    let smallS3: String?

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

struct PhotoStats: Codable, Hashable {
    let downloads: Int?
    let views: Int?
    let likes: Int?
}

struct PhotoLinks: Codable, Hashable {
    let selfLink: String?
    let html: String?
    let download: String?
    let downloadLocation: String?

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

struct ExifInfo: Codable, Hashable {
    let make: String?
    let model: String?
    let exposureTime: String?
    let aperture: String?
    let focalLength: String?
    let iso: Int?

    var formattedDescription: String? {
        var components: [String] = []
        if let make = make, let model = model {
            components.append("\(make) \(model)")
        }
        if let aperture = aperture {
            components.append("f/\(aperture)")
        }
        if let exposureTime = exposureTime {
            components.append("\(exposureTime)s")
        }
        if let iso = iso {
            components.append("ISO \(iso)")
        }
        if let focalLength = focalLength {
            components.append("\(focalLength)mm")
        }
        return components.isEmpty ? nil : components.joined(separator: " · ")
    }

    enum CodingKeys: String, CodingKey {
        case make, model
        case exposureTime = "exposure_time"
        case aperture
        case focalLength = "focal_length"
        case iso
    }
}

struct PhotoLocation: Codable, Hashable {
    let city: String?
    let country: String?
    let position: Position?

    struct Position: Codable, Hashable {
        let latitude: Double?
        let longitude: Double?
    }
}

struct User: Codable, Identifiable, Hashable {
    let id: String
    let username: String
    let name: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let location: String?
    let links: UserLinks?
    let profileImage: ProfileImage?
    let totalLikes: Int?
    let totalPhotos: Int?
    let totalCollections: Int?
    let instagramUsername: String?
    let twitterUsername: String?

    var displayName: String {
        return name.isEmpty ? username : name
    }

    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.map { String($0.prefix(1)) }.joined()
    }

    enum CodingKeys: String, CodingKey {
        case id, username, name, bio, location, links
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case instagramUsername = "instagram_username"
        case twitterUsername = "twitter_username"
    }
}

struct UserLinks: Codable, Hashable {
    let selfLink: String?
    let html: String?
    let photos: String?
    let likes: String?
    let portfolio: String?

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case html, photos, likes, portfolio
    }
}

struct ProfileImage: Codable, Hashable {
    let small: String?
    let medium: String?
    let large: String?
}

struct Photo: Identifiable, Codable, Hashable {
    let id: String
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let description: String?
    let altDescription: String?
    let urls: PhotoURLs
    let links: PhotoLinks
    let likes: Int
    let likedByUser: Bool
    let user: User
    let exif: ExifInfo?
    let location: PhotoLocation?
    let stats: PhotoStats?
    let createdAt: Date?

    var aspectRatio: CGFloat {
        return height > 0 ? CGFloat(width) / CGFloat(height) : 1.0
    }

    var displayDescription: String? {
        return description?.isEmpty == false ? description : altDescription
    }

    enum CodingKeys: String, CodingKey {
        case id, width, height, color, exif, location, stats, urls, links, likes, user
        case blurHash = "blur_hash"
        case description
        case altDescription = "alt_description"
        case likedByUser = "liked_by_user"
        case createdAt = "created_at"
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Mock photos for testing
extension Photo {
    static let mockPhotos: [Photo] = [
        Photo(
            id: "1",
            width: 4000,
            height: 3000,
            color: "#262626",
            blurHash: "L8H;qYIpHzj]00RjxsWB0KsR.j[",
            description: "A beautiful landscape",
            altDescription: "Mountain landscape at sunset",
            urls: PhotoURLs(
                raw: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3",
                full: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb",
                regular: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&w=1080",
                small: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&w=400",
                thumb: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&w=200",
                smallS3: nil
            ),
            links: PhotoLinks(
                selfLink: "https://api.unsplash.com/photos/1",
                html: "https://unsplash.com/photos/1",
                download: "https://unsplash.com/photos/1/download",
                downloadLocation: "https://api.unsplash.com/photos/1/download"
            ),
            likes: 1247,
            likedByUser: false,
            user: User(
                id: "user1",
                username: "johndoe",
                name: "John Doe",
                firstName: "John",
                lastName: "Doe",
                bio: "Nature photographer",
                location: "California",
                links: UserLinks(
                    selfLink: "https://api.unsplash.com/users/johndoe",
                    html: "https://unsplash.com/@johndoe",
                    photos: "https://api.unsplash.com/users/johndoe/photos",
                    likes: "https://api.unsplash.com/users/johndoe/likes",
                    portfolio: "https://api.unsplash.com/users/johndoe/portfolio"
                ),
                profileImage: ProfileImage(
                    small: "https://images.unsplash.com/profile-1?w=32",
                    medium: "https://images.unsplash.com/profile-1?w=64",
                    large: "https://images.unsplash.com/profile-1?w=128"
                ),
                totalLikes: 1500,
                totalPhotos: 200,
                totalCollections: 10,
                instagramUsername: "johndoe",
                twitterUsername: "johndoe"
            ),
            exif: ExifInfo(
                make: "Canon",
                model: "EOS 5D Mark IV",
                exposureTime: "1/250",
                aperture: "8.0",
                focalLength: "50mm",
                iso: 400
            ),
            location: PhotoLocation(
                city: "Yosemite",
                country: "United States",
                position: PhotoLocation.Position(latitude: 37.8651, longitude: -119.5383)
            ),
            stats: PhotoStats(
                downloads: 15420,
                views: 125000,
                likes: 1247
            ),
            createdAt: Date().addingTimeInterval(-86400 * 7)
        ),
        Photo(
            id: "2",
            width: 3000,
            height: 4000,
            color: "#A8A8A8",
            blurHash: "L6H;qYIpHzj]00RjxsWB0KsR.j[",
            description: "Urban architecture",
            altDescription: "Modern building facade",
            urls: PhotoURLs(
                raw: "https://images.unsplash.com/photo-1486325212027-8081e485255e?ixlib=rb-4.0.3",
                full: "https://images.unsplash.com/photo-1486325212027-8081e485255e?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb",
                regular: "https://images.unsplash.com/photo-1486325212027-8081e485255e?ixlib=rb-4.0.3&w=1080",
                small: "https://images.unsplash.com/photo-1486325212027-8081e485255e?ixlib=rb-4.0.3&w=400",
                thumb: "https://images.unsplash.com/photo-1486325212027-8081e485255e?ixlib=rb-4.0.3&w=200",
                smallS3: nil
            ),
            links: PhotoLinks(
                selfLink: "https://api.unsplash.com/photos/2",
                html: "https://unsplash.com/photos/2",
                download: "https://unsplash.com/photos/2/download",
                downloadLocation: "https://api.unsplash.com/photos/2/download"
            ),
            likes: 892,
            likedByUser: true,
            user: User(
                id: "user2",
                username: "janesmith",
                name: "Jane Smith",
                firstName: "Jane",
                lastName: "Smith",
                bio: "Architecture and urban photography",
                location: "New York",
                links: UserLinks(
                    selfLink: "https://api.unsplash.com/users/janesmith",
                    html: "https://unsplash.com/@janesmith",
                    photos: "https://api.unsplash.com/users/janesmith/photos",
                    likes: "https://api.unsplash.com/users/janesmith/likes",
                    portfolio: "https://api.unsplash.com/users/janesmith/portfolio"
                ),
                profileImage: ProfileImage(
                    small: "https://images.unsplash.com/profile-2?w=32",
                    medium: "https://images.unsplash.com/profile-2?w=64",
                    large: "https://images.unsplash.com/profile-2?w=128"
                ),
                totalLikes: 2300,
                totalPhotos: 350,
                totalCollections: 15,
                instagramUsername: "janesmith",
                twitterUsername: nil
            ),
            exif: ExifInfo(
                make: "Sony",
                model: "A7III",
                exposureTime: "1/500",
                aperture: "11",
                focalLength: "35mm",
                iso: 200
            ),
            location: PhotoLocation(
                city: "New York",
                country: "United States",
                position: PhotoLocation.Position(latitude: 40.7128, longitude: -74.0060)
            ),
            stats: PhotoStats(
                downloads: 8930,
                views: 87000,
                likes: 892
            ),
            createdAt: Date().addingTimeInterval(-86400 * 3)
        )
    ]

    static func generateMockPhotos(count: Int = 20) -> [Photo] {
        guard count > 0 else { return [] }

        let adjectives = ["Beautiful", "Stunning", "Amazing", "Incredible", "Breathtaking", "Magnificent", "Charming", "Elegant"]
        let subjects = ["landscape", "portrait", "architecture", "nature", "urban", "mountain", "beach", "forest", "city", "sunset"]
        let locations = ["California", "New York", "Paris", "Tokyo", "London", "Sydney", "Dubai", "Singapore"]
        let makes = ["Canon", "Nikon", "Sony", "Fujifilm", "Leica"]
        let models = ["EOS R5", "D850", "A7III", "X-T4", "M10"]

        var photos: [Photo] = []
        let basePhotos = mockPhotos

        for i in 0..<count {
            let basePhoto = basePhotos[i % basePhotos.count]
            let adjective = adjectives.randomElement()!
            let subject = subjects.randomElement()!
            let location = locations.randomElement()!
            let make = makes.randomElement()!
            let model = models.randomElement()!

            let photo = Photo(
                id: "mock_\(i)",
                width: Int.random(in: 3000...5000),
                height: Int.random(in: 2000...4000),
                color: ["#262626", "#A8A8A8", "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8"].randomElement()!,
                blurHash: basePhoto.blurHash,
                description: "\(adjective) \(subject)",
                altDescription: "A \(adjective.lowercased()) \(subject) in \(location)",
                urls: PhotoURLs(
                    raw: basePhoto.urls.raw,
                    full: basePhoto.urls.full,
                    regular: basePhoto.urls.regular,
                    small: basePhoto.urls.small,
                    thumb: basePhoto.urls.thumb,
                    smallS3: nil
                ),
                links: basePhoto.links,
                likes: Int.random(in: 100...5000),
                likedByUser: Bool.random(),
                user: User(
                    id: "user_\(i)",
                    username: "photographer\(i)",
                    name: "Photographer \(i)",
                    firstName: "Photographer",
                    lastName: "\(i)",
                    bio: "Professional photographer",
                    location: location,
                    links: basePhoto.user.links,
                    profileImage: basePhoto.user.profileImage,
                    totalLikes: Int.random(in: 500...5000),
                    totalPhotos: Int.random(in: 50...500),
                    totalCollections: Int.random(in: 5...25),
                    instagramUsername: nil,
                    twitterUsername: nil
                ),
                exif: ExifInfo(
                    make: make,
                    model: model,
                    exposureTime: ["1/250", "1/500", "1/1000", "1/125"].randomElement(),
                    aperture: ["2.8", "4.0", "5.6", "8.0", "11"].randomElement(),
                    focalLength: ["24mm", "35mm", "50mm", "85mm"].randomElement(),
                    iso: Int.random(in: 100...1600)
                ),
                location: PhotoLocation(
                    city: location,
                    country: "United States",
                    position: PhotoLocation.Position(
                        latitude: Double.random(in: 25...45),
                        longitude: Double.random(in: -125 ... -70)
                    )
                ),
                stats: PhotoStats(
                    downloads: Int.random(in: 1000...20000),
                    views: Int.random(in: 10000...100000),
                    likes: Int.random(in: 100...5000)
                ),
                createdAt: Date().addingTimeInterval(-Double.random(in: 86400...864000))
            )
            photos.append(photo)
        }

        return photos
    }
}

// Helper for CGFloat
import CoreGraphics
