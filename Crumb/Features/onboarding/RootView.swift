//
//  RootView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct RootView: View {
    @StateObject var authVM = AuthViewModel()
    @StateObject var recipeManager = RecipeManager()
    
    // Global App State
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // Temporary State for the Setup Flow
    @State private var showSplash = true
    @State private var isQuizComplete = false
    @State private var showSignUp = false // To trigger the login sheet from Welcome
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView(isActive: $showSplash)
                    .zIndex(2)
            } else {
                // 1. FINAL DESTINATION: Main App
                if hasCompletedOnboarding {
                    MainTabView()
                        .transition(.opacity)
                        .zIndex(1)
                
                // 2. USER IS LOGGED IN (The Setup Phase)
                } else if authVM.isAuthenticated {
                    
                    // A. Have they finished the quiz?
                    if isQuizComplete {
                        // Show Profile Creation (The Final Step)
                        // We pass $isQuizComplete so the Back button works!
                        CreateProfileView(isQuizComplete: $isQuizComplete)
                            .transition(.move(edge: .trailing))
                    } else {
                        // Show Quiz (The First Step after Login)
                        OnboardingQuizView(isQuizComplete: $isQuizComplete)
                            .transition(.opacity)
                    }
                    
                // 3. USER IS NOT LOGGED IN (Welcome Screen)
                } else {
                    WelcomeView(showSignUp: $showSignUp)
                        .sheet(isPresented: $showSignUp) {
                            AuthView()
                        }
                        .zIndex(0)
                }
            }
        }
        .environmentObject(authVM)
        .environmentObject(recipeManager)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSplash)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasCompletedOnboarding)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isQuizComplete)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: authVM.isAuthenticated)
    }
}
