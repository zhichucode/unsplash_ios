//
//  MainTabView.swift
//  unsplash
//
//  Main tab bar navigation for the app
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                }
                .tag(1)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: selectedTab == 2 ? "heart.fill" : "heart")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 3 ? "person.fill" : "person")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

// Preview
#Preview {
    MainTabView()
}
