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
                        LazyVGrid(spacing: 2, pinnedViews: []) {
                            ForEach(viewModel.photos) { photo in
                                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                    PhotoGridCell(photo: photo)
                                }
                                .onAppear {
                                    if photo.id == viewModel.photos[safe: viewModel.photos.count - 5]?.id {
                                        Task {
                                            await viewModel.loadMorePhotos()
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
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// Preview
#Preview {
    HomeFeedView()
}
