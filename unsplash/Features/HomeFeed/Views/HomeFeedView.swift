//
//  HomeFeedView.swift
//  unsplash
//
//  Home feed view with Pinterest-style waterfall layout
//

import SwiftUI

struct HomeFeedView: View {
    @StateObject private var viewModel = HomeFeedViewModel()
    @Namespace private var animation

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
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(Array(viewModel.photos.enumerated()), id: \.element.id) { index, photo in
                                // Alternating layout: check if row is even (0, 2, 4...) or odd (1, 3, 5...)
                                let isEvenRow = (index / 2) % 2 == 0

                                Group {
                                    if isEvenRow {
                                        // Even row: 2-column layout
                                        HStack(spacing: 0) {
                                            ForEach(0..<2, id: \.self) { colIndex in
                                                let cellIndex = index + colIndex
                                                if cellIndex < viewModel.photos.count {
                                                    let cellPhoto = viewModel.photos[cellIndex]

                                                    PhotoGridCell(photo: cellPhoto)
                                                        .frame(maxWidth: .infinity)
                                                        .aspectRatio(cellPhoto.aspectRatio, contentMode: .fill)
                                                        .onAppear {
                                                            if cellIndex >= viewModel.photos.count - 5 {
                                                                Task {
                                                                    await viewModel.loadMorePhotos()
                                                                }
                                                            }
                                                        }
                                                }
                                            }
                                        }
                                    } else {
                                        // Odd row: 1 full-width photo
                                        HStack(spacing: 0) {
                                            PhotoGridCell(photo: photo)
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(photo.aspectRatio, contentMode: .fill)
                                                .onAppear {
                                                    if index >= viewModel.photos.count - 5 {
                                                        Task {
                                                            await viewModel.loadMorePhotos()
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }

                        // Loading indicator at bottom
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
                    .padding(.horizontal, 8)
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
