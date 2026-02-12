//
//  SettingsView.swift
//  unsplash
//
//  Settings view with appearance, notifications, and privacy options
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("autoPlayGIFs") private var autoPlayGIFs = true
    @AppStorage("imageQuality") private var imageQuality: ImageQuality = .regular
    @AppStorage("clearCacheOnExit") private var clearCacheOnExit = false

    @State private var showingAbout = false
    @State private var showingCacheAlert = false
    @State private var cacheSize: String = "Calculating..."

    var body: some View {
        NavigationStack {
            List {
                // Appearance Section
                Section("Appearance") {
                    Picker(selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            HStack {
                                Image(systemName: mode.icon)
                                    .frame(width: 24)
                                Text(mode.displayName)
                            }
                            .tag(mode)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.purple)
                            Text("Appearance")
                            Text(appearanceMode.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                    .pickerStyle(.inline)

                    Toggle("Auto-play GIFs", isOn: $autoPlayGIFs)

                    Picker("Image Quality", selection: $imageQuality) {
                        ForEach(ImageQuality.allCases) { quality in
                            Text(quality.displayName).tag(quality)
                        }
                    }
                }

                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $enableNotifications)

                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Notification Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Privacy Section
                Section("Privacy") {
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Privacy & Security")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: DataSettingsView()) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Data & Storage")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Storage Section
                Section("Storage") {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "externaldrive.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 24)
                                Text("Cache Size")
                                Spacer()
                            }

                            Text(cacheSize)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Button(action: {
                            showingCacheAlert = true
                        }) {
                            Text("Clear Cache")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    Toggle("Clear cache on exit", isOn: $clearCacheOnExit)
                }

                // Support Section
                Section("Support") {
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.indigo)
                                .frame(width: 24)
                            Text("About")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios/issues")!) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Help & Support")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }

                    Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios")!) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            Text("Rate Us")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                }

                // Version Info
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Unsplash iOS")
                                .font(.headline)
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Made with ❤️")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            calculateCacheSize()
        }
    }

    private func calculateCacheSize() {
        // Calculate cache size (mock implementation)
        let size = Int.random(in: 10_000_000...100_000_000)
        cacheSize = formatBytes(size)
    }

    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    private func clearCache() {
        // Implement cache clearing
        cacheSize = "0 B"
    }
}

// MARK: - Models

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

enum ImageQuality: String, CaseIterable, Identifiable {
    case low = "low"
    case regular = "regular"
    case high = "high"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Low (Save Data)"
        case .regular: return "Regular"
        case .high: return "High"
        }
    }
}

// MARK: - Sub-Views

struct NotificationSettingsView: View {
    @AppStorage("newPhotoAlerts") private var newPhotoAlerts = true
    @AppStorage("weeklyDigest") private var weeklyDigest = false

    var body: some View {
        List {
            Section("Photo Notifications") {
                Toggle("New photo alerts", isOn: $newPhotoAlerts)
                Toggle("Weekly digest", isOn: $weeklyDigest)
            }

            Section("Marketing") {
                Toggle("Tips & tricks", isOn: .constant(true))
                Toggle("Feature updates", isOn: .constant(true))
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PrivacySettingsView: View {
    @AppStorage("analyticsEnabled") private var analyticsEnabled = true
    @AppStorage("crashReportsEnabled") private var crashReportsEnabled = true

    var body: some View {
        List {
            Section("Data Collection") {
                Toggle("Analytics", isOn: $analyticsEnabled)
                Toggle("Crash reports", isOn: $crashReportsEnabled)
            }

            Section("Account") {
                NavigationLink("Download my data") {
                    Text("Download data")
                }

                NavigationLink("Delete account") {
                    Text("Delete account")
                        .foregroundColor(.red)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("We value your privacy and are committed to protecting your personal information.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Link("Learn more", destination: URL(string: "https://github.com/zhichucode/unsplash_ios")!)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DataSettingsView: View {
    @State private var showingClearAlert = false

    var body: some View {
        List {
            Section("Cache") {
                Button(action: {
                    showingClearAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                        Text("Clear All Cache")
                            .foregroundColor(.red)
                        Spacer()
                        Text("128 MB")
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: {
                    // Clear image cache only
                }) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.orange)
                        Text("Clear Image Cache")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("98 MB")
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Downloads") {
                NavigationLink("Download location") {
                    Text("Downloads")
                }

                Toggle("Auto-save to photos", isOn: .constant(true))
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cached images are stored locally on your device to improve performance.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Data & Storage")
        .navigationBarTitleDisplayMode(.large)
        .alert("Clear Cache", isPresented: $showingClearAlert, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                // Clear cache action
            }
        }, message: {
            Text("This will remove all cached data. This action cannot be undone.")
        })
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "app.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Unsplash iOS")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Version 1.0.0 (Build 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }

            Section("Information") {
                Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios")!) {
                    Label("Website", systemImage: "link")
                }

                Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios/blob/main/LICENSE")!) {
                    Label("License", systemImage: "doc.text")
                }

                Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios/blob/main/CONTRIBUTING.md")!) {
                    Label("Contributing", systemImage: "person.2")
                }

                NavigationLink("Privacy Policy") {
                    Text("Privacy Policy")
                }

                NavigationLink("Terms of Service") {
                    Text("Terms of Service")
                }
            }

            Section("Credits") {
                HStack {
                    Text("Photos by")
                    Spacer()
                    Link("Pexels", destination: URL(string: "https://www.pexels.com")!)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Made with ❤️ using SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("Open source")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Link(destination: URL(string: "https://github.com/zhichucode/unsplash_ios")!) {
                            Text("on GitHub")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
}

// Preview
#Preview {
    SettingsView()
}
