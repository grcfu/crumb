//
//  ImportFlowViews.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

// MARK: - 1. Paste Link Modal
struct PasteLinkView: View {
    @Binding var isPresented: Bool
    @State private var urlText = ""
    @State private var navigateToLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Import from Web")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.forestGreen)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.lightGray)
                    }
                }
                
                Text("Paste a URL below. We'll clean up the clutter, remove the ads, and just get the steps for you.")
                    .font(.subheadline)
                    .foregroundColor(.mediumGray)
                    .lineSpacing(4)
                
                // Input Field
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.lightGray)
                    TextField("https://", text: $urlText)
                        .foregroundColor(.forestGreen)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lightGray.opacity(0.3)))
                
                // "Detected on Clipboard" Pill (Mock Logic for demo)
                Button(action: { urlText = "https://www.bonappetit.com/recipe/basque-burnt-cheesecake" }) {
                    HStack {
                        Image(systemName: "doc.on.clipboard")
                        Text("DETECTED ON CLIPBOARD")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.forestGreen)
                    .padding()
                    .background(Color.sageGreen.opacity(0.2))
                    .cornerRadius(10)
                }
                
                // Magic Import Button
                Button(action: {
                    if !urlText.isEmpty {
                        navigateToLoading = true
                    }
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Magic Import")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(urlText.isEmpty ? Color.gray : Color.forestGreen)
                    .cornerRadius(25)
                }
                .disabled(urlText.isEmpty)
                
                Spacer()
                
                // Navigation to Loading Screen (Passing the URL)
                NavigationLink(destination: ChefThinkingView(targetUrl: urlText), isActive: $navigateToLoading) {
                    EmptyView()
                }
            }
            .padding(24)
            .background(Color.cream.ignoresSafeArea())
        }
    }
}

// MARK: - 2. Chef Thinking (Loading Screen)
struct ChefThinkingView: View {
    let targetUrl: String
    
    @EnvironmentObject var recipeManager: RecipeManager
    @State private var progress: CGFloat = 0.0
    @State private var navigateToRecipe = false
    @State private var fetchedRecipe: Recipe? = nil
    @State private var statusText = "Chef is Thinking..."
    
    // Animation State
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 1. Background: Warm Cream Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.cream, Color.warmBeige.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background Pattern
            Circle()
                .fill(Color.terracotta.opacity(0.05))
                .frame(width: 300, height: 300)
                .offset(x: -150, y: -300)
            
            Circle()
                .fill(Color.forestGreen.opacity(0.05))
                .frame(width: 400, height: 400)
                .offset(x: 200, y: 300)
            
            VStack(spacing: 40) {
                Spacer()
                
                // 2. Animated Centerpiece
                ZStack {
                    // Outer pulsing rings
                    Circle()
                        .stroke(Color.forestGreen.opacity(0.1), lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.0 : 1.0)
                    
                    Circle()
                        .stroke(Color.forestGreen.opacity(0.2), lineWidth: 2)
                        .frame(width: 160, height: 160)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    // Main Icon Background
                    Circle()
                        .fill(Color.white)
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.forestGreen.opacity(0.15), radius: 15, x: 0, y: 10)
                    
                    // The Icon
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.forestGreen)
                        .rotationEffect(.degrees(isAnimating ? 10 : -10))
                }
                
                // 3. Status Text
                VStack(spacing: 12) {
                    Text(statusText)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.forestGreen)
                        .animation(.easeInOut, value: statusText)
                    
                    Text("Scraping the good stuff...")
                        .font(.body)
                        .foregroundColor(.mediumGray)
                        .tracking(1.0)
                }
                
                // 4. RESPONSIVE Progress Pill (The Fix)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("ANALYZING RECIPE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.terracotta)
                            .tracking(2)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.terracotta)
                    }
                    
                    // GeometryReader lets us measure the exact available width
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // The Track (Background)
                            Capsule()
                                .fill(Color.black.opacity(0.05))
                                .frame(height: 12)
                                .frame(width: geometry.size.width) // Full width
                            
                            // The Fill (Foreground)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.forestGreen, .sageGreen],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 12) // Dynamic width
                                .shadow(color: .forestGreen.opacity(0.3), radius: 4, y: 2)
                        }
                    }
                    .frame(height: 12) // Constrain the GeometryReader height
                }
                .padding(.horizontal, 40) // This controls the width (margin from edges)
                
                Spacer()
                
                // 5. "Pro Tip" Paper Note
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.golden.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.golden)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PRO TIP")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.forestGreen)
                            .tracking(1)
                        
                        Text("While you wait, verify you have enough butter. It's usually the first thing to run out!")
                            .font(.caption)
                            .foregroundColor(.mediumGray)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                    }
                }
                .padding(20)
                .background(
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            
            // Invisible Link
            if let result = fetchedRecipe {
                NavigationLink(destination: RecipeDetailView(recipe: result), isActive: $navigateToRecipe) {
                    EmptyView()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            performMagicImport()
        }
    }
    
    func performMagicImport() {
        withAnimation(.easeOut(duration: 4.0)) {
            progress = 0.85
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            
            let result = await recipeManager.extractRecipe(from: targetUrl)
            
            await MainActor.run {
                if let recipe = result {
                    self.fetchedRecipe = recipe
                    withAnimation(.spring()) {
                        self.progress = 1.0
                        self.statusText = "Found it!"
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.navigateToRecipe = true
                    }
                } else {
                    self.statusText = "Could not find recipe :("
                    self.progress = 0.0
                }
            }
        }
    }
}
