//
//  ImageCache.swift
//  unsplash
//
//  Image cache with memory and disk caching
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache: URL?
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.unsplash.imageCache", attributes: .concurrent)

    private init() {
        // Set up memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB

        // Set up disk cache
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        diskCache = cachesDirectory?.appendingPathComponent("ImageCache")

        if let diskCache = diskCache {
            try? fileManager.createDirectory(at: diskCache, withIntermediateDirectories: true)
        }

        // Clear old cache on app launch if needed
        clearExpiredCache()
    }

    private func cacheKey(for url: URL) -> String {
        return url.absoluteString.data(using: .utf8)?.base64EncodedString() ?? url.lastPathComponent
    }

    private func diskCacheURL(for url: URL) -> URL? {
        guard let diskCache = diskCache else { return nil }
        return diskCache.appendingPathComponent(cacheKey(for: url))
    }

    // MARK: - Public Methods

    func image(for url: URL) -> UIImage? {
        // Check memory cache first
        if let image = memoryCache.object(forKey: url.absoluteString as NSString) {
            return image
        }

        // Check disk cache
        var image: UIImage?
        queue.sync {
            if let diskCacheURL = diskCacheURL(for: url),
               let data = try? Data(contentsOf: diskCacheURL) {
                image = UIImage(data: data)
                if let image = image {
                    memoryCache.setObject(image, forKey: url.absoluteString as NSString)
                }
            }
        }

        return image
    }

    func setImage(_ image: UIImage, for url: URL) {
        // Store in memory cache
        memoryCache.setObject(image, forKey: url.absoluteString as NSString)

        // Store in disk cache
        queue.async(flags: .barrier) {
            if let diskCacheURL = self.diskCacheURL(for: url),
               let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: diskCacheURL)
            }
        }
    }

    func removeImage(for url: URL) {
        memoryCache.removeObject(forKey: url.absoluteString as NSString)

        queue.async(flags: .barrier) {
            if let diskCacheURL = self.diskCacheURL(for: url) {
                try? self.fileManager.removeItem(at: diskCacheURL)
            }
        }
    }

    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }

    func clearDiskCache() {
        queue.async(flags: .barrier) {
            guard let diskCache = self.diskCache else { return }
            try? self.fileManager.removeItem(at: diskCache)
            try? self.fileManager.createDirectory(at: diskCache, withIntermediateDirectories: true)
        }
    }

    func clearExpiredCache() {
        queue.async(flags: .barrier) {
            guard let diskCache = self.diskCache else { return }

            let expirationInterval: TimeInterval = 7 * 24 * 60 * 60 // 7 days

            if let urls = try? self.fileManager.contentsOfDirectory(at: diskCache, includingPropertiesForKeys: [.contentModificationDateKey]) {
                for url in urls {
                    if let modificationDate = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                       Date().timeIntervalSince(modificationDate) > expirationInterval {
                        try? self.fileManager.removeItem(at: url)
                    }
                }
            }
        }
    }

    func getCacheSize() -> Int64 {
        var size: Int64 = 0

        if let diskCache = diskCache,
           let urls = try? fileManager.contentsOfDirectory(at: diskCache, includingPropertiesForKeys: [.fileSizeKey]) {
            for url in urls {
                if let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += Int64(fileSize)
                }
            }
        }

        return size
    }
}
