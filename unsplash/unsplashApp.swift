//
//  unsplashApp.swift
//  unsplash
//
//  Unsplash iOS Application
//  A beautiful photo browsing app powered by Unsplash API
//

import SwiftUI

@main
struct unsplashApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(nil) // Follow system appearance
        }
    }
}
