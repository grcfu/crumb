//
//  PantryViews.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct PantryInputView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    @Environment(\.dismiss) var dismiss
    @State private var ingredientText = ""
    @State private var ingredients: [String] = [] // Start empty
    
    // Controls navigation to results
    @State private var showResults = false
    @State private var isLoading = false
    
    // MARK: - Autocomplete Data
    let allIngredients = [
        "All-Purpose Flour", "Almond Flour", "Apples",
        "Baking Powder", "Baking Soda", "Bananas", "Blueberries", "Brown Sugar", "Butter",
        "Carrots", "Chocolate Chips", "Cinnamon", "Cocoa Powder", "Cream Cheese",
        "Eggs", "Honey", "Lemon", "Milk", "Oats", "Olive Oil",
        "Peanut Butter", "Salt", "Strawberries", "Sugar", "Vanilla Extract", "Yeast", "Zucchini"
    ]
    
    var filteredSuggestions: [String] {
        if ingredientText.isEmpty { return [] }
        return allIngredients.filter { $0.localizedCaseInsensitiveContains(ingredientText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // Header Illustration
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color.terracotta)
                                    .frame(width: 80, height: 80)
                                    .overlay(Image(systemName: "basket.fill").foregroundColor(.white).font(.largeTitle))
                                    .shadow(color: .terracotta.opacity(0.3), radius: 10, y: 5)
                                
                                VStack(spacing: 8) {
                                    Text("What's in the pantry?")
                                        .font(.title2).fontWeight(.bold).foregroundColor(.forestGreen)
                                    Text("Toss in what you have, we'll bake something magic.")
                                        .font(.caption).foregroundColor(.mediumGray)
                                }
                            }
                            .padding(.top, 20)
                            
                            // Search Input
                            ZStack(alignment: .top) {
                                HStack {
                                    Image(systemName: "magnifyingglass").foregroundColor(.terracotta)
                                    TextField("Type ingredient (e.g. Eggs...)", text: $ingredientText)
                                        .foregroundColor(.forestGreen)
                                        .onSubmit { addIngredient(ingredientText) }
                                    
                                    if !ingredientText.isEmpty {
                                        Button(action: { ingredientText = "" }) {
                                            Image(systemName: "xmark.circle.fill").foregroundColor(.lightGray)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                                .padding(.horizontal, 24)
                                .zIndex(1)
                                
                                // Autocomplete Dropdown
                                if !filteredSuggestions.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(filteredSuggestions.prefix(3), id: \.self) { suggestion in
                                            Button(action: { addIngredient(suggestion) }) {
                                                HStack {
                                                    Text(suggestion).foregroundColor(.forestGreen)
                                                    Spacer()
                                                    Image(systemName: "plus.circle").foregroundColor(.lightGray)
                                                }
                                                .padding(.vertical, 12).padding(.horizontal, 16)
                                                .contentShape(Rectangle())
                                            }
                                            if suggestion != filteredSuggestions.prefix(3).last {
                                                Divider().background(Color.cream)
                                            }
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                                    .padding(.horizontal, 24)
                                    .offset(y: 60)
                                    .zIndex(2)
                                }
                            }
                            .zIndex(10)
                            
                            // "Your Basket"
                            VStack(alignment: .leading, spacing: 12) {
                                Text("YOUR BASKET (\(ingredients.count))")
                                    .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                                    .padding(.horizontal, 24)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                                    ForEach(ingredients, id: \.self) { item in
                                        HStack(spacing: 6) {
                                            Text(item).font(.subheadline).fontWeight(.medium).lineLimit(1)
                                            Button(action: {
                                                withAnimation(.spring()) { ingredients.removeAll(where: { $0 == item }) }
                                            }) {
                                                Image(systemName: "xmark").font(.caption2).fontWeight(.bold)
                                            }
                                        }
                                        .padding(.vertical, 8).padding(.horizontal, 12)
                                        .background(Color.terracotta.opacity(0.1))
                                        .foregroundColor(.forestGreen)
                                        .cornerRadius(20)
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.terracotta.opacity(0.3), lineWidth: 1))
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // Quick Add Staples
                            VStack(alignment: .leading, spacing: 12) {
                                Text("QUICK ADD STAPLES")
                                    .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                                    .padding(.horizontal, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        QuickAddCard(name: "Butter", icon: "cube.fill", action: { addIngredient("Butter") })
                                        QuickAddCard(name: "Sugar", icon: "square.fill", action: { addIngredient("Sugar") })
                                        QuickAddCard(name: "Vanilla", icon: "drop.fill", action: { addIngredient("Vanilla") })
                                        QuickAddCard(name: "Salt", icon: "circle.dotted", action: { addIngredient("Salt") })
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    
                    // Footer Button
                    VStack {
                        Divider()
                        Button(action: {
                            Task {
                                isLoading = true
                                await recipeManager.fetchPantryRecipes(ingredients: ingredients)
                                isLoading = false
                                showResults = true
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "basket")
                                    Text("Find Recipes")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ingredients.isEmpty ? Color.gray : Color.terracotta)
                            .cornerRadius(25)
                            .shadow(color: Color.terracotta.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(ingredients.isEmpty || isLoading)
                        .padding(24)
                        .background(Color.cream.ignoresSafeArea())
                    }
                }
                
                // Navigation to Results
                .navigationDestination(isPresented: $showResults) {
                    PantryResultsView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left").foregroundColor(.forestGreen)
                    }
                }
            }
        }
    }
    
    func addIngredient(_ item: String) {
        if !item.isEmpty && !ingredients.contains(item) {
            withAnimation(.spring()) {
                ingredients.append(item)
                ingredientText = ""
            }
        }
    }
}

// MARK: - Helper View: Quick Add Card
struct QuickAddCard: View {
    let name: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle().fill(Color.white).frame(width: 50, height: 50)
                    .overlay(Image(systemName: icon).foregroundColor(.forestGreen).font(.title3))
                    .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
                Text(name).font(.caption).fontWeight(.medium).foregroundColor(.forestGreen)
            }
            .frame(width: 70)
        }
    }
}

// MARK: - Beautiful Results View
struct PantryResultsView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            BakersTableBackground().ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.forestGreen)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Found Recipes")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.forestGreen)
                    Spacer()
                    Image(systemName: "arrow.left").opacity(0).padding(10)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Results List
                if recipeManager.pantryRecipes.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.terracotta)
                        Text("No matches found")
                            .font(.headline)
                            .foregroundColor(.forestGreen)
                        Text("Try adding more staple ingredients like flour, sugar, or eggs.")
                            .font(.caption)
                            .foregroundColor(.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(recipeManager.pantryRecipes) { recipe in
                                // Using RecipeListCard for consistency
                                RecipeListCard(recipe: recipe)
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    PantryInputView().environmentObject(RecipeManager())
}
