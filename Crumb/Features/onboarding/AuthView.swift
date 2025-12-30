//
//  AuthView.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Check if we are in Login or Signup mode
    @State var isLoginMode: Bool = false
    
    // REMOVED: var onSuccess: () -> Void
    // We don't need this anymore because RootView handles the flow automatically.
    
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header (NOW ANIMATED)
                Text(isLoginMode ? "Welcome Back" : "Create Account")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.forestGreen)
                    .padding(.top, 40)
                    // ANIMATION MAGIC:
                    .id(isLoginMode ? "Login" : "SignUp") // Tells SwiftUI these are different views
                    .transition(.move(edge: .top).combined(with: .opacity)) // Slide in from top
                
                // Form Fields
                VStack(spacing: 16) {
                    // 1. Email Field
                    ZStack(alignment: .leading) {
                        if authVM.email.isEmpty {
                            Text("Email")
                                .foregroundColor(.forestGreen.opacity(0.6))
                                .padding(.leading, 16)
                        }
                        TextField("", text: $authVM.email)
                            .padding()
                            .foregroundColor(.forestGreen)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // 2. Password Field
                    ZStack(alignment: .leading) {
                        if authVM.password.isEmpty {
                            Text("Password")
                                .foregroundColor(.forestGreen.opacity(0.6))
                                .padding(.leading, 16)
                        }
                        SecureField("", text: $authVM.password)
                            .padding()
                            .foregroundColor(.forestGreen)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                // Error Message
                if !authVM.errorMessage.isEmpty {
                    Text(authVM.errorMessage)
                        .foregroundColor(.terracotta)
                        .font(.caption)
                        .transition(.opacity) // Fade in error
                }
                
                // Action Button
                Button(action: {
                    Task {
                        if isLoginMode {
                            await authVM.signIn()
                        } else {
                            await authVM.signUp()
                        }
                        
                        // NOTE: No manual transition code needed here.
                        // Once authVM.isAuthenticated becomes true, RootView detects it
                        // and automatically switches screens.
                    }
                }) {
                    // NOW ANIMATED
                    Text(isLoginMode ? "Log In" : "Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.forestGreen)
                        .cornerRadius(25)
                        // ANIMATION MAGIC:
                        .id(isLoginMode) // Forces a refresh
                        .transition(.scale.combined(with: .opacity)) // Pop effect
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
                
                // Toggle Mode (NOW WITH SPRING ANIMATION)
                Button(action: {
                    // This creates the "Bouncy" feel
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isLoginMode.toggle()
                    }
                }) {
                    HStack {
                        Text(isLoginMode ? "Don't have an account?" : "Already have an account?")
                            .foregroundColor(.mediumGray)
                            // Smooth fade for this text
                            .transition(.opacity)
                            .id(isLoginMode)
                        
                        Text(isLoginMode ? "Sign Up" : "Log In")
                            .fontWeight(.bold)
                            .foregroundColor(.forestGreen)
                            // Smooth fade for this text
                            .transition(.opacity)
                            .id(isLoginMode)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}
