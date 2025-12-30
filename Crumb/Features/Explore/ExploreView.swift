//
//  ExploreView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct ExploreView: View {
    // MARK: - State Variables
    @EnvironmentObject var recipeManager: RecipeManager
    
    @State private var selectedRecipe: RecipeModel?
    @State private var activeSheet: ActiveSheet?
    
    // NEW: Toast & Collection Logic
    @State private var showSaveToast = false
    @State private var lastSavedRecipe: RecipeModel?
    @State private var showCollectionSelector = false
    
    enum ActiveSheet: Identifiable {
        case pasteLink
        case pantry
        case notifications
        
        var id: Int { hashValue }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) { // Align bottom for the Toast
                // 1. Background
                BakersTableBackground().ignoresSafeArea()
                
                // 2. Content
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        heroSection
                        
                        // Netflix-Style Rows
                        VStack(spacing: 24) {
                            if recipeManager.exploreRecipes.isEmpty {
                                VStack(spacing: 12) {
                                    ProgressView().tint(.forestGreen)
                                    Text("Loading Trends...").font(.caption).foregroundColor(.mediumGray)
                                }
                                .padding().frame(height: 200)
                            } else {
                                recipeRow(title: "Trending Now", recipes: recipeManager.exploreRecipes, color: .forestGreen)
                            }
                            
                            if !recipeManager.exploreRecipes.isEmpty {
                                recipeRow(title: "For the Family", recipes: recipeManager.exploreRecipes.shuffled(), color: .terracotta)
                                recipeRow(title: "Quick Bakes", recipes: recipeManager.exploreRecipes.reversed(), color: .golden)
                            }
                        }
                        .padding(.bottom, 120)
                    }
                    .padding(.top, 10)
                }
                
                // 3. NEW: The "TikTok Style" Save Toast
                if showSaveToast, let recipe = lastSavedRecipe {
                    SaveToastView(
                        recipeTitle: recipe.title,
                        onManage: {
                            // Hide toast immediately and open the sheet
                            showSaveToast = false
                            showCollectionSelector = true
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 100) // Float above the Tab Bar
                    .zIndex(100) // Ensure it's on top of everything
                }
            }
            .navigationBarHidden(true)
            .task {
                if recipeManager.exploreRecipes.isEmpty {
                    await recipeManager.fetchExploreRecipes()
                }
            }
            // MARK: - SHEET MANAGER
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .pasteLink:
                    PasteLinkView(isPresented: Binding(
                        get: { activeSheet == .pasteLink },
                        set: { if !$0 { activeSheet = nil } }
                    ))
                    .presentationDetents([.medium, .large])
                    
                case .pantry:
                    PantryInputView()
                        .presentationDragIndicator(.visible)
                    
                case .notifications:
                    NotificationsView()
                }
            }
            // Detail View (Full Screen)
            .fullScreenCover(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            // NEW: Collection Selector Sheet (triggered by "Manage")
            .sheet(isPresented: $showCollectionSelector) {
                if let recipe = lastSavedRecipe {
                    AddToCollectionSheet(recipe: recipe)
                        .presentationDetents([.medium])
                }
            }
        }
        .onReceive(TabManager.shared.$shouldDismissSheets) { shouldDismiss in
            if shouldDismiss {
                selectedRecipe = nil
                activeSheet = nil
                TabManager.shared.shouldDismissSheets = false
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Explore").font(.system(size: 32, weight: .bold, design: .serif)).foregroundColor(.forestGreen)
                Text("What are we baking today?").font(.subheadline).foregroundColor(.lightGray)
            }
            Spacer()
            Button(action: { activeSheet = .notifications }) {
                Image(systemName: "bell.fill").font(.headline).foregroundColor(.forestGreen)
                    .frame(width: 48, height: 48).background(Color.white).clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 16) {
            Button(action: { activeSheet = .pasteLink }) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [Color.forestGreen, Color.forestGreen.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 140).shadow(color: .forestGreen.opacity(0.3), radius: 10, y: 5)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Found a recipe?").font(.headline).foregroundColor(.white.opacity(0.8))
                            Text("Paste Link").font(.system(size: 28, weight: .bold, design: .serif)).foregroundColor(.white)
                            HStack { Image(systemName: "link"); Text("Import from Web") }
                                .font(.caption).padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.white.opacity(0.2)).cornerRadius(20).foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "doc.on.clipboard.fill").font(.system(size: 60).bold()).foregroundColor(.white.opacity(0.2))
                            .rotationEffect(.degrees(-10)).offset(x: 10, y: 10)
                    }
                    .padding(24)
                }
            }
            .padding(.horizontal, 24)
            
            Button(action: { activeSheet = .pantry }) {
                HStack {
                    Image(systemName: "basket.fill").foregroundColor(.terracotta)
                    Text("Raid my pantry").fontWeight(.semibold).foregroundColor(.forestGreen)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.lightGray)
                }
                .padding().background(Color.white).cornerRadius(16).padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
            }
        }
    }
    
    // MARK: - Recipe Row
    private func recipeRow(title: String, recipes: [RecipeModel], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.title3).fontWeight(.bold).foregroundColor(.forestGreen)
                Spacer()
                Image(systemName: "arrow.right").font(.caption).foregroundColor(.lightGray)
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        // The card itself opens the details
                        Button(action: { selectedRecipe = recipe }) {
                            SmallRecipeCard(
                                recipe: recipe,
                                color: color,
                                isSaved: recipeManager.isSaved(recipe),
                                onToggleSave: { handleSaveToggle(recipe) } // Handle the heart click
                            )
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 10)
            }
        }
    }
    
    // MARK: - Logic: Save & Toast
    private func handleSaveToggle(_ recipe: RecipeModel) {
        recipeManager.toggleSave(recipe)
        
        // If we just SAVED it (not unsaved), show the toast
        if recipeManager.isSaved(recipe) {
            lastSavedRecipe = recipe
            withAnimation(.spring()) {
                showSaveToast = true
            }
            
            // Auto-hide toast after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { showSaveToast = false }
            }
        }
    }
}

// MARK: - The "TikTok Style" Toast
struct SaveToastView: View {
    let recipeTitle: String
    let onManage: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bookmark.fill")
                .foregroundColor(.terracotta)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Saved to Cookbook")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.forestGreen)
                Text(recipeTitle)
                    .font(.caption)
                    .foregroundColor(.mediumGray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onManage) {
                Text("Manage")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.terracotta)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.terracotta.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        .padding(.horizontal, 24)
    }
}

// MARK: - Beautiful Add To Collection Sheet
struct AddToCollectionSheet: View {
    @EnvironmentObject var recipeManager: RecipeManager
    @Environment(\.dismiss) var dismiss
    let recipe: RecipeModel
    
    var body: some View {
        ZStack {
            // 1. Consistent App Background
            BakersTableBackground().ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 2. Custom Header
                HStack {
                    Text("Save to Collection")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.forestGreen)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.mediumGray)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // 3. Collection List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(recipeManager.collections) { collection in
                            Button(action: {
                                recipeManager.addToCollection(recipe: recipe, collectionID: collection.id)
                                // Optional: dismiss() immediately, or let them select multiple
                            }) {
                                HStack(spacing: 16) {
                                    // Icon Circle
                                    ZStack {
                                        Circle()
                                            .fill(Color.terracotta.opacity(0.1))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: collection.icon)
                                            .font(.title3)
                                            .foregroundColor(.terracotta)
                                    }
                                    
                                    // Title
                                    Text(collection.title)
                                        .font(.headline)
                                        .foregroundColor(.forestGreen)
                                    
                                    Spacer()
                                    
                                    // Custom Checkbox Logic
                                    if collection.recipes.contains(where: { $0.id == recipe.id }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.forestGreen)
                                            .transition(.scale.combined(with: .opacity))
                                    } else {
                                        Circle()
                                            .stroke(Color.lightGray, lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(ScaleButtonStyle()) // Adds a nice tap animation
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.medium, .large]) // Makes it a nice slide-up sheet
        .presentationCornerRadius(30)
    }
}

// Add this small helper for the button animation if you don't have it yet
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Background Components (PRESERVED)
struct BakersTableBackground: View {
    let icons = ["birthday.cake.fill", "fork.knife", "leaf.fill", "flame.fill", "timer"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.cream, Color.warmBeige.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                GridPattern(spacing: 40)
                    .stroke(Color.forestGreen.opacity(0.05), lineWidth: 1)
                ForEach(0..<15, id: \.self) { _ in
                    FlourDustParticle(screenSize: geometry.size)
                }
                ForEach(0..<8, id: \.self) { _ in
                    FloatingIcon(
                        iconName: icons.randomElement()!,
                        screenSize: geometry.size
                    )
                }
            }
        }
    }
}

struct GridPattern: Shape {
    let spacing: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, to: rect.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, to: rect.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

struct FlourDustParticle: View {
    let screenSize: CGSize
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0.0
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: CGFloat.random(in: 2...6))
            .blur(radius: 1)
            .position(position)
            .opacity(opacity)
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: CGFloat.random(in: 0...screenSize.height)
                )
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 2...5))
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.3...0.7)
                }
                withAnimation(
                    Animation.linear(duration: Double.random(in: 10...30))
                    .repeatForever(autoreverses: false)
                ) {
                    position.y += CGFloat.random(in: 50...100)
                    position.x += CGFloat.random(in: -20...20)
                }
            }
    }
}

struct FloatingIcon: View {
    let iconName: String
    let screenSize: CGSize
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: CGFloat.random(in: 20...40)))
            .foregroundColor(.terracotta.opacity(0.15))
            .position(position)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: CGFloat.random(in: 0...screenSize.height)
                )
                withAnimation(
                    Animation.linear(duration: Double.random(in: 20...40))
                    .repeatForever(autoreverses: false)
                ) {
                    position.y = -50
                    rotation = Double.random(in: 0...360)
                }
            }
    }
}
