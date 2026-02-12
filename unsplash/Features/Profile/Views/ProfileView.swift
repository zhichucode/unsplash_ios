//
//  ProfileView.swift
//  unsplash
//
//  User profile view with authentication
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authService = SupabaseAuthService()
    @State private var showingAuth = false
    @State private var photosCount = 0
    @State private var likesCount = 0

    var body: some View {
        NavigationStack {
            List {
                if authService.isAuthenticated, let user = authService.currentUser {
                    // User Info Section
                    Section {
                        HStack(spacing: 16) {
                            // Avatar
                            AsyncImageView(
                                url: URL(string: user.avatar_url ?? ""),
                                placeholder: Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 70, height: 70)
                            )
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.title2.bold())

                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Sign out button
                            Button {
                                authService.signOut()
                            } label: {
                                Image(systemName: "arrow.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Statistics Section
                    Section("Statistics") {
                        HStack {
                            StatRowItem(icon: "photo", title: "Photos", count: "\(photosCount)")
                            StatRowItem(icon: "heart", title: "Likes", count: "\(likesCount)")
                            StatRowItem(icon: "rectangle.stack", title: "Collections", count: "0")
                        }
                    }

                    // Settings Section
                    Section("Settings") {
                        NavigationLink(destination: SettingsView()) {
                            SettingRow(icon: "gear", title: "Settings", color: .gray)
                        }
                        NavigationLink(destination: NotificationSettingsView()) {
                            SettingRow(icon: "bell", title: "Notifications", color: .orange)
                        }
                        NavigationLink(destination: AboutView()) {
                            SettingRow(icon: "info.circle", title: "About", color: .indigo)
                        }
                        Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios/issues")!) {
                            SettingRow(icon: "questionmark.circle", title: "Help & Support", color: .blue)
                        }
                    }
                } else {
                    // Guest User Section
                    Section {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color(.systemGray4))
                                .frame(width: 70, height: 70)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Guest User")
                                    .font(.title2.bold())

                                Text("Sign in to sync your favorites and access more features")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Sign in button
                            Button {
                                showingAuth = true
                            } label: {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Statistics Section
                    Section("Statistics") {
                        HStack {
                            StatRowItem(icon: "photo", title: "Photos", count: "0")
                            StatRowItem(icon: "heart", title: "Likes", count: "0")
                            StatRowItem(icon: "rectangle.stack", title: "Collections", count: "0")
                        }
                    }

                    // Settings Section
                    Section("Settings") {
                        NavigationLink(destination: SettingsView()) {
                            SettingRow(icon: "gear", title: "Settings", color: .gray)
                        }
                        NavigationLink(destination: NotificationSettingsView()) {
                            SettingRow(icon: "bell", title: "Notifications", color: .orange)
                        }
                        NavigationLink(destination: AboutView()) {
                            SettingRow(icon: "info.circle", title: "About", color: .indigo)
                        }
                        Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios/issues")!) {
                            SettingRow(icon: "questionmark.circle", title: "Help & Support", color: .blue)
                        }
                    }

                    Section {
                        HStack {
                            Spacer()
                            Button("Sign In / Create Account") {
                                showingAuth = true
                            }
                        }
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text("Unsplash iOS App")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAuth) {
                AuthView()
                    .presentationDetents([.sheet, .popover])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            // Check current user on appear
            Task {
                await authService.checkCurrentUser()
            }
        }
    }
}

struct StatRowItem: View {
    let icon: String
    let title: String
    let count: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(count)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .cornerRadius(8)

            Text(title)
                .font(.body)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Preview
#Preview {
    ProfileView()
}
