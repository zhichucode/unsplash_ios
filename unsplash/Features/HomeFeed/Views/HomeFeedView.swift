//
//  HomeFeedView.swift
//  unsplash
//
//  Home feed view displaying photo grid
//

import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel = HomeFeedViewModel()
    @Namespace private var animation

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.photos.isEmpty {
                    LoadingIndicator("Loading photos...")
                } else if viewModel.hasError {
                    ErrorView(error: viewModel.errorMessage ?? "Unknown error") {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                } else if viewModel.photos.isEmpty {
                    EmptyStateView(
                        systemImage: "photo.stack",
                        title: "No Photos",
                        subtitle: "Check back later for new photos"
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
                                .onAppear {
                                    // Load more when reaching near the end
                                    if photo.id == viewModel.photos[safe: viewModel.photos.count - 5]?.id {
                                        Task {
                                            await viewModel.loadMorePhotos()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)

                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.primary)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// Helper for safe array access
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Preview
#Preview {
    HomeFeedView()
}
