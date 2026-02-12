//
//  ProfileView.swift
//  unsplash
//
//  User profile view
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 70, height: 70)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Guest User")
                                .font(.title2.bold())

                            Text("Sign in to sync your favorites")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                Section("Statistics") {
                    HStack {
                        StatRowItem(icon: "photo", title: "Photos", count: "0")
                        StatRowItem(icon: "heart", title: "Likes", count: "\(0)")
                        StatRowItem(icon: "rectangle.stack", title: "Collections", count: "0")
                    }
                }

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
                        Text("Unsplash iOS App")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
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
