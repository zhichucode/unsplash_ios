//
//  SearchResultsView.swift
//  unsplash
//
//  Search results grid view
//

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var viewModel: SearchViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 2)
    ]

    var body: some View {
        Group {
            if viewModel.isSearching && viewModel.searchResults.isEmpty {
                LoadingIndicator("Searching...")
            } else if !viewModel.searchResults.isEmpty {
                VStack(spacing: 0) {
                    // Results count
                    HStack {
                        Text("\(viewModel.totalResults.formatted()) results")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))

                    Divider()

                    // Results grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(viewModel.searchResults) { photo in
                                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                    PhotoGridCell(photo: photo)
                                        .aspectRatio(photo.aspectRatio, contentMode: .fit)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    // Load more when reaching near the end
                                    if photo.id == viewModel.searchResults[safe: viewModel.searchResults.count - 5]?.id {
                                        Task {
                                            await viewModel.loadMoreResults()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)

                        // Loading indicator for pagination
                        if viewModel.isSearching {
                            ProgressView()
                                .tint(.primary)
                                .padding()
                        }
                    }
                }
            } else if viewModel.hasSearched {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "No Results",
                    subtitle: "Try a different search term"
                )
            }
        }
    }
}

// Preview
#Preview {
    NavigationStack {
        let viewModel = SearchViewModel()
        SearchResultsView(viewModel: viewModel)
    }
}
