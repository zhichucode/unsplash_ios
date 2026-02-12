//
//  FavoritesView.swift
//  unsplash
//
//  Favorites/collections view
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.photos.isEmpty {
                    EmptyStateView(
                        systemImage: "heart",
                        title: "No Favorites",
                        subtitle: "Start adding photos to your favorites"
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(viewModel.photos) { photo in
                                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                    PhotoGridCell(photo: photo)
                                        .aspectRatio(photo.aspectRatio, contentMode: .fit)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.photos.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            viewModel.clearFavorites()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                viewModel.loadFavoritePhotos()
            }
        }
    }
}

// Preview
#Preview {
    FavoritesView()
}
