//
//  SupabaseAuthService.swift
//  unsplash
//
//  Authentication service using Supabase
//

import Foundation
import Combine

// Supabase Configuration
struct SupabaseConfig {
    static let projectURL = "https://qcglsuvjjjuykihzsgss.supabase.co"
    static let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFjZ2xzdXZqamp1eWtpaHpzZ3NzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4NTU2NzMsImV4cCI6MjA4NjQzMTY3M30.QpVV0tik-95ImKQ2SJhneYMFyeBaVHM7LceScm_ispo"
    static let publishableKey = "sb_publishable_bkUHmjvYXvozKqVec9e4vg_rujd2SXW"
}

// MARK: - Auth Models

struct AuthResponse: Codable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Int
    let token_type: String
    let user: SupabaseUser?
}

struct SupabaseUser: Codable {
    let id: String
    let email: String?
    let email_confirmed_at: String?
    let created_at: String?
    let updated_at: String?
    let user_metadata: [String: String]?
}

struct SignInRequest: Codable {
    let email: String
    let password: String
}

struct SignUpRequest: Codable {
    let email: String
    let password: String
    let options: SignUpOptions?
}

struct SignUpOptions: Codable {
    let data: SignUpData?
}

struct SignUpData: Codable {
    let display_name: String?
}

struct UserProfile: Codable, Hashable {
    let id: String
    let email: String
    let display_name: String?
    let user_metadata: [String: String]?

    var avatar_url: String? {
        return user_metadata?["avatar_url"]
    }
    var username: String {
        return display_name ?? email.split(separator: "@")[0]
    }
}

// MARK: - Auth Service

@MainActor
class SupabaseAuthService: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()

    // MARK: - Public Methods

    func checkCurrentUser() async {
        isLoading = true
        errorMessage = nil

        // Get current user from cached profile
        await getCurrentUser()
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = SignInRequest(email: email, password: password)
            let response: AuthResponse = try await performRequest(
                endpoint: "/auth/v1/token?grant_type=password",
                method: "POST",
                body: request
            )

            // Save token
            UserDefaults.standard.set(response.access_token, forKey: "supabase_access_token")
            if let refreshToken = response.refresh_token {
                UserDefaults.standard.set(refreshToken, forKey: "supabase_refresh_token")
            }

            // Get user profile
            await getCurrentUser()
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func signUp(email: String, password: String, displayName: String? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = SignUpRequest(
                email: email,
                password: password,
                options: SignUpOptions(data: SignUpData(display_name: displayName))
            )
            let response: AuthResponse = try await performRequest(
                endpoint: "/auth/v1/signup",
                method: "POST",
                body: request
            )

            // Save token
            UserDefaults.standard.set(response.access_token, forKey: "supabase_access_token")
            if let refreshToken = response.refresh_token {
                UserDefaults.standard.set(refreshToken, forKey: "supabase_refresh_token")
            }

            // Get user profile
            await getCurrentUser()
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func signOut() {
        // Clear tokens and user
        UserDefaults.standard.removeObject(forKey: "supabase_access_token")
        UserDefaults.standard.removeObject(forKey: "supabase_refresh_token")
        UserDefaults.standard.removeObject(forKey: "supabase_user_profile")

        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Private Methods

    private func getCurrentUser() async {
        guard let token = UserDefaults.standard.string(forKey: "supabase_access_token") else {
            currentUser = nil
            isAuthenticated = false
            return
        }

        // Get user from Supabase
        do {
            let userProfile: UserProfile = try await performRequest(
                endpoint: "/auth/v1/user",
                method: "GET",
                requiresAuth: true
            )
            currentUser = userProfile
            isAuthenticated = true

            // Cache user profile
            if let userData = try? JSONEncoder().encode(userProfile),
               let jsonString = String(data: userData, encoding: .utf8) {
                UserDefaults.standard.set(jsonString, forKey: "supabase_user_profile")
            }
        } catch {
            print("Failed to get user: \(error)")
        }
    }

    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: SupabaseConfig.projectURL + endpoint) else {
            throw NSError(domain: "SupabaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseConfig.apiKey)", forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.publishableKey)", forHTTPHeaderField: "Authorization")

        if requiresAuth, let token = UserDefaults.standard.string(forKey: "supabase_access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SupabaseAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error"])
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
