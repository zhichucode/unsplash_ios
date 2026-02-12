//
//  AuthView.swift
//  unsplash
//
//  Authentication view with sign in and sign up
//

import SwiftUI

enum AuthMode {
    case signIn
    case signUp
}

struct AuthView: View {
    @StateObject private var authService = SupabaseAuthService()
    @State private var authMode: AuthMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var showPassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "app.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Unsplash")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Discover beautiful photos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 40)

                    // Auth Form
                    VStack(spacing: 20) {
                        // Mode toggle
                        Picker(selection: $authMode) {
                            Text("Sign In")
                                .tag(AuthMode.signIn)
                            Text("Sign Up")
                                .tag(AuthMode.signUp)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // Form
                        VStack(spacing: 16) {
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                TextField("Enter your email", text: $email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }

                            // Display name (only for sign up)
                            if authMode == .signUp {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Display Name")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    TextField("Enter your name", text: $displayName)
                                        .textContentType(.givenName)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                            }

                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                HStack {
                                    if showPassword {
                                        TextField("Enter your password", text: $password)
                                            .textContentType(.password)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textContentType(.password)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                    }

                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Submit button
                        Button {
                            if authMode == .signIn {
                                Task {
                                    await authService.signIn(email: email, password: password)
                                }
                            } else {
                                Task {
                                    await authService.signUp(email: email, password: password, displayName: displayName.isEmpty ? nil : displayName)
                                }
                            }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(authMode == .signIn ? "Sign In" : "Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .disabled(isLoading || email.isEmpty || password.isEmpty || (authMode == .signUp && displayName.isEmpty))

                        // Error message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }
}

// Preview
#Preview {
    AuthView()
}
