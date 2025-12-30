//
//  CookbookView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct CookbookView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    
    @State private var searchText = ""
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var showAddCollection = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Background
                CookbookBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        searchBar
                        
                        // Collections Section
                        collectionsSection
                        
                        // Saved Recipes List
                        savedRecipesSection
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNotifications) {
                Text("Notifications")
            }
            .sheet(isPresented: $showSettings) {
                Text("Settings")
            }
            // Uses AddCollectionView from CollectionView.swift
            .sheet(isPresented: $showAddCollection) {
                AddCollectionView(collections: $recipeManager.collections)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Cookbook")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.forestGreen)
                    Text("Collections & Favorites")
                        .font(.subheadline)
                        .foregroundColor(.terracotta)
                }
                Spacer()
                HStack(spacing: 12) {
                    Button(action: { showNotifications = true }) {
                        Image(systemName: "bell.fill")
                            .font(.headline).foregroundColor(.forestGreen)
                            .frame(width: 48, height: 48).background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    }
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.headline).foregroundColor(.forestGreen)
                            .frame(width: 48, height: 48).background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Search
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.terracotta)
                .font(.title3)
            
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search recipes...")
                        .foregroundColor(.mediumGray)
                }
                TextField("", text: $searchText)
                    .foregroundColor(.forestGreen)
            }
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.forestGreen)
                    .font(.title3)
            }
        }
        .padding()
        .frame(height: 56)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal, 24)
        .shadow(color: Color.terracotta.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Collections Section
    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Collections").font(.title2).fontWeight(.bold).foregroundColor(.forestGreen)
                Button(action: { showAddCollection = true }) {
                    Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.terracotta)
                }
                Spacer()
                Button("See all") { }.font(.subheadline).foregroundColor(.forestGreen)
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recipeManager.collections) { collection in
                        NavigationLink(destination: CollectionDetailView(collection: collection)) {
                            collectionCard(collection: collection)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func collectionCard(collection: RecipeCollection) -> some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .frame(width: 140, height: 100)
                    .overlay(
                        Image(systemName: collection.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.forestGreen.opacity(0.8))
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                
                Text("\(collection.recipes.count)")
                    .font(.caption2).fontWeight(.bold).foregroundColor(.white)
                    .frame(width: 24, height: 24).background(Color.terracotta).clipShape(Circle())
                    .padding(12)
            }
            Text(collection.title).font(.subheadline).fontWeight(.medium).foregroundColor(.forestGreen)
        }
    }
    
    // MARK: - Saved Recipes
    private var savedRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Saved Recipes").font(.title2).fontWeight(.bold).foregroundColor(.forestGreen)
                Spacer()
            }
            .padding(.horizontal, 24)
            
            if recipeManager.savedRecipes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.largeTitle).foregroundColor(.terracotta.opacity(0.5))
                    Text("No favorites yet").font(.headline).foregroundColor(.mediumGray)
                    Text("Like recipes to save them here.").font(.caption).foregroundColor(.lightGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(recipeManager.savedRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            HStack {
                                if let urlString = recipe.imageUrl, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: { Color.gray.opacity(0.3) }
                                    .frame(width: 80, height: 80).cornerRadius(12).clipped()
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .font(.headline)
                                        .foregroundColor(.forestGreen)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    Text("Saved")
                                        .font(.caption)
                                        .foregroundColor(.mediumGray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.lightGray)
                            }
                            .padding()
                            .background(Color.white).cornerRadius(16)
                            .shadow(color: .black.opacity(0.03), radius: 5)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct CookbookBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.cream
                DotGrid(spacing: 30).fill(Color.terracotta.opacity(0.15))
                ZStack {
                    Image(systemName: "book.fill").font(.system(size: 300)).foregroundColor(.forestGreen.opacity(0.03)).position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.15).rotationEffect(.degrees(-15))
                    Image(systemName: "bookmark.fill").font(.system(size: 200)).foregroundColor(.terracotta.opacity(0.05)).position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.6).rotationEffect(.degrees(10))
                    Image(systemName: "pencil.and.scribble").font(.system(size: 150)).foregroundColor(.forestGreen.opacity(0.04)).position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.85)
                }
            }
        }
    }
}

struct DotGrid: Shape {
    let spacing: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, to: rect.width, by: spacing) {
            for y in stride(from: 0, to: rect.height, by: spacing) {
                path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
            }
        }
        return path
    }
}
