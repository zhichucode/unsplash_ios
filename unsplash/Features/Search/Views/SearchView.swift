//
//  SearchView.swift
//  unsplash
//
//  Main search view with search bar and topics
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isEditing = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.hasSearched {
                    SearchResultsView(viewModel: viewModel)
                } else {
                    SearchSuggestionsView(viewModel: viewModel)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchQuery,
                isPresented: $isEditing,
                prompt: "Search photos..."
            )
            .onSubmit(of: .search) {
                Task {
                    await viewModel.search(query: viewModel.searchQuery)
                }
                isSearchFocused = false
            }
            .onChange(of: viewModel.searchQuery) { _, newValue in
                if newValue.isEmpty {
                    viewModel.clearSearch()
                }
            }
        }
    }
}

// MARK: - Search Suggestions View

struct SearchSuggestionsView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recent searches
                if !viewModel.searchHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Button("Clear") {
                                viewModel.clearSearchHistory()
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }

                        ForEach(viewModel.searchHistory, id: \.self) { query in
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.secondary)

                                Text(query)
                                    .font(.body)

                                Spacer()

                                Button {
                                    viewModel.removeFromSearchHistory(query)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Task {
                                    await viewModel.searchFromHistory(query)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }

                // Popular topics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Topics")
                        .font(.headline)
                        .foregroundColor(.primary)

                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100, maximum: 150))
                    ], spacing: 12) {
                        ForEach(viewModel.popularTopics, id: \.self) { topic in
                            Button {
                                Task {
                                    await viewModel.search(query: topic)
                                }
                            } label: {
                                Text(topic)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Preview
#Preview {
    SearchView()
}
