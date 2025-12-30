//
//  CollectionView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

// NOTE: RecipeCollection struct is defined in RecipeManager.swift now.
// Do NOT redefine it here.

// MARK: - New View: Create Collection Sheet
struct AddCollectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var collections: [RecipeCollection]
    
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    
    // Expanded Icon List (20 options)
    let icons = [
        "folder.fill", "star.fill", "heart.fill", "bookmark.fill",
        "birthday.cake.fill", "fork.knife", "cup.and.saucer.fill", "wineglass.fill",
        "carrot.fill", "leaf.fill", "flame.fill", "drop.fill",
        "cart.fill", "bag.fill", "gift.fill", "party.popper.fill",
        "house.fill", "clock.fill", "tag.fill", "globe"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BakersTableBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        Text("New Collection")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.forestGreen)
                            .padding(.top, 20)
                        
                        // Icon Picker Card
                        VStack(spacing: 16) {
                            Text("Choose an Icon")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.forestGreen)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: { withAnimation { selectedIcon = icon } }) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == icon ? Color.terracotta : Color.white)
                                                .frame(width: 56, height: 56)
                                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                            
                                            Image(systemName: icon)
                                                .font(.title3)
                                                .foregroundColor(selectedIcon == icon ? .white : .forestGreen)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                        
                        // Name Input Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Collection Name")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.mediumGray)
                                .padding(.leading, 4)
                            
                            TextField("e.g. Grandma's Favorites", text: $name)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .foregroundColor(.forestGreen)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                        .padding(.horizontal, 8)
                        
                        // Create Button
                        Button(action: {
                            if !name.isEmpty {
                                let newCollection = RecipeCollection(title: name, icon: selectedIcon)
                                collections.append(newCollection)
                                dismiss()
                            }
                        }) {
                            Text("Create Collection")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.isEmpty ? Color.gray : Color.forestGreen)
                                .cornerRadius(25)
                                .shadow(color: name.isEmpty ? .clear : Color.forestGreen.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(name.isEmpty)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                    .padding(24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - New View: Inside a Collection (Detail View)
struct CollectionDetailView: View {
    @Environment(\.dismiss) var dismiss
    let collection: RecipeCollection
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BakersTableBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack(alignment: .center) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(.forestGreen)
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Icon + Title
                        HStack(spacing: 12) {
                            Image(systemName: collection.icon)
                                .font(.title2)
                                .foregroundColor(.terracotta)
                            Text(collection.title)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(.forestGreen)
                        }
                        
                        Spacer()
                        
                        // Placeholder for symmetry (invisible button)
                        Image(systemName: "arrow.left").opacity(0).padding(10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .padding(.top, 10)
                    
                    // Content
                    if collection.recipes.isEmpty {
                        // Empty State
                        Spacer()
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 140, height: 140)
                                Image(systemName: "basket.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.terracotta.opacity(0.8))
                            }
                            
                            VStack(spacing: 8) {
                                Text("This basket is empty")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.forestGreen)
                                
                                Text("Go to a recipe and tap 'Save' to add it here.")
                                    .font(.subheadline)
                                    .foregroundColor(.mediumGray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        Spacer()
                        Spacer()
                    } else {
                        // List of Recipes
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(collection.recipes) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeListCard(recipe: recipe) // Uses shared component
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(24)
                        }
                    }
                }
            }
            .navigationBarHidden(true) // Hides default ugly header
        }
    }
}
