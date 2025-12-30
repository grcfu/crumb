//
//  RecipeManager.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import Supabase
import Foundation
import Combine
import SwiftUI

// MARK: - API Decoding Structs (Internal)
struct SpoonacularResponse: Codable {
    let recipes: [SpoonacularRecipe]
}

struct SpoonacularRecipe: Codable {
    let title: String
    let summary: String?
    let readyInMinutes: Int
    let servings: Int?
    let image: String?
    let extendedIngredients: [SpoonIngredient]?
    let analyzedInstructions: [SpoonInstruction]?
}

struct SpoonIngredient: Codable {
    let name: String?
    let amount: Double?
    let unit: String?
}

struct SpoonInstruction: Codable {
    let steps: [SpoonStep]?
}

struct SpoonStep: Codable {
    let step: String
}

// Extraction Response
struct SpoonacularExtractionResponse: Codable {
    let title: String?
    let image: String?
    let servings: Int?
    let readyInMinutes: Int?
    let extendedIngredients: [SpoonIngredient]?
    let analyzedInstructions: [SpoonInstruction]?
    let instructions: String? // Fallback if analyzed is empty
}

// Find By Ingredients Response
struct SpoonFindByIngredientsRecipe: Codable {
    let id: Int
    let title: String
    let image: String?
    let missedIngredientCount: Int
    let usedIngredientCount: Int
    let likes: Int?
}

// MARK: - Models
struct PastBake: Identifiable {
    let id = UUID()
    let recipeName: String
    let date: Date
    let image: UIImage?
    let rating: Int
    let notes: String
}

struct RecipeCollection: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var icon: String
    var recipes: [RecipeModel] = []
}

@MainActor
class RecipeManager: ObservableObject {
    let client = AppManager.shared.client
    
    // MARK: - Published Properties
    @Published var recipes: [RecipeModel] = []       // User created recipes (Supabase)
    @Published var exploreRecipes: [RecipeModel] = [] // API fetched recipes (Random)
    @Published var pantryRecipes: [RecipeModel] = []  // Search results
    @Published var pastBakes: [PastBake] = []
    
    // NEW: Saved Data
    @Published var savedRecipes: [RecipeModel] = []
    @Published var collections: [RecipeCollection] = [
        RecipeCollection(title: "Christmas", icon: "folder.fill"),
        RecipeCollection(title: "Birthdays", icon: "birthday.cake.fill"),
        RecipeCollection(title: "Quick Bakes", icon: "leaf.fill")
    ]
    
    let apiKey = "YOUR_API_KEY_HERE"
    
    // MARK: - Saving & Collections Logic
    func toggleSave(_ recipe: RecipeModel) {
        if savedRecipes.contains(where: { $0.id == recipe.id }) {
            savedRecipes.removeAll(where: { $0.id == recipe.id })
        } else {
            savedRecipes.append(recipe)
        }
    }
    
    func isSaved(_ recipe: RecipeModel) -> Bool {
        return savedRecipes.contains(where: { $0.id == recipe.id })
    }
    
    func addToCollection(recipe: RecipeModel, collectionID: UUID) {
        if let index = collections.firstIndex(where: { $0.id == collectionID }) {
            if !collections[index].recipes.contains(where: { $0.id == recipe.id }) {
                collections[index].recipes.append(recipe)
            }
        }
        if !isSaved(recipe) { savedRecipes.append(recipe) }
    }

    // MARK: - Past Bakes Logic
    func addBake(name: String, image: UIImage?, rating: Int, notes: String) {
        let newBake = PastBake(recipeName: name, date: Date(), image: image, rating: rating, notes: notes)
        pastBakes.insert(newBake, at: 0)
    }
    
    // MARK: - API: Pantry Search (With Random Times)
    func fetchPantryRecipes(ingredients: [String]) async {
        let ingredientsString = ingredients.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientsString)&number=10&ranking=1&ignorePantry=true&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode([SpoonFindByIngredientsRecipe].self, from: data)
            
            // Map the simplified response to RecipeModel
            let mappedRecipes = decodedResponse.map { item in
                
                // GENERATE REALISTIC RANDOM DATA FOR DEMO
                // This avoids using extra API points to fetch details for every item
                let randomPrepTime = Int.random(in: 25...95) // Random time between 25 and 95 mins
                
                return RecipeModel(
                    id: UUID(),
                    title: item.title,
                    description: "Uses \(item.usedIngredientCount) of your ingredients.",
                    prepTime: randomPrepTime, // Now populates "Medium" or "Expert" etc.
                    cookTime: 0,
                    servings: 4,
                    imageUrl: item.image,
                    ingredients: [], // Details fetched on demand
                    steps: []        // Details fetched on demand
                )
            }
            
            self.pantryRecipes = mappedRecipes
            print("✅ Found \(mappedRecipes.count) pantry recipes")
            
        } catch {
            print("🚨 Pantry Search Error: \(error)")
        }
    }
    
    // MARK: - API: Extraction Logic
    func extractRecipe(from url: String) async -> RecipeModel? {
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        let apiString = "https://api.spoonacular.com/recipes/extract?url=\(encodedUrl)&forceExtraction=true&analyze=true&apiKey=\(apiKey)"
        guard let apiURL = URL(string: apiString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: apiURL)
            let extracted = try JSONDecoder().decode(SpoonacularExtractionResponse.self, from: data)
            
            let mappedIngredients = extracted.extendedIngredients?.compactMap { ing -> Ingredient? in
                guard let name = ing.name else { return nil }
                return Ingredient(name: name, amount: ing.amount ?? 0, unit: ing.unit ?? "")
            } ?? []
            
            var mappedSteps: [Step] = []
            if let instructions = extracted.analyzedInstructions?.first?.steps, !instructions.isEmpty {
                mappedSteps = instructions.enumerated().map { index, stepData in
                    Step(orderIndex: index + 1, instruction: stepData.step)
                }
            } else if let textInstructions = extracted.instructions {
                let sentences = textInstructions.components(separatedBy: ". ")
                mappedSteps = sentences.enumerated().map { index, text in
                    Step(orderIndex: index + 1, instruction: text)
                }
            }
            
            return RecipeModel(
                id: UUID(),
                title: extracted.title ?? "Imported Recipe",
                description: "Imported from web",
                prepTime: extracted.readyInMinutes ?? 30,
                cookTime: 0,
                servings: extracted.servings ?? 4,
                imageUrl: extracted.image,
                ingredients: mappedIngredients,
                steps: mappedSteps
            )
        } catch {
            print("🚨 Extraction Failed: \(error)")
            return nil
        }
    }
    
    // MARK: - API: Explore Fetch Logic (Updated for Random Times)
    func fetchExploreRecipes() async {
        let urlString = "https://api.spoonacular.com/recipes/random?number=10&tags=dessert&addRecipeInformation=true&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(SpoonacularResponse.self, from: data)
            
            let mappedRecipes = decodedResponse.recipes.map { apiRecipe in
                let mappedIngredients = apiRecipe.extendedIngredients?.compactMap { ing -> Ingredient? in
                    guard let name = ing.name else { return nil }
                    return Ingredient(name: name, amount: ing.amount ?? 0, unit: ing.unit ?? "")
                } ?? []
                
                let rawSteps = apiRecipe.analyzedInstructions?.first?.steps ?? []
                let mappedSteps = rawSteps.enumerated().map { index, stepData in
                    Step(orderIndex: index + 1, instruction: stepData.step)
                }
                
                // SMART RANDOMIZATION:
                // Use API time if valid (between 10 and 180 mins).
                // Otherwise generate a random time to ensure the UI tags (Easy/Medium/Expert) look diverse.
                let finalTime: Int
                if apiRecipe.readyInMinutes > 10 && apiRecipe.readyInMinutes < 180 {
                    finalTime = apiRecipe.readyInMinutes
                } else {
                    finalTime = Int.random(in: 25...100)
                }
                
                return RecipeModel(
                    id: UUID(),
                    title: apiRecipe.title,
                    description: apiRecipe.summary?.strippingHTML() ?? "No description available.",
                    prepTime: finalTime, // Use our smart time
                    cookTime: 0,
                    servings: apiRecipe.servings ?? 4,
                    imageUrl: apiRecipe.image,
                    ingredients: mappedIngredients,
                    steps: mappedSteps
                )
            }
            self.exploreRecipes = mappedRecipes
            print("✅ Successfully fetched \(mappedRecipes.count) recipes!")
        } catch {
            print("🚨 API Error: \(error)")
        }
    }
    
    // MARK: - Supabase: Fetch User Recipes
    func fetchRecipes() async {
        do {
            let fetchedRecipes: [RecipeModel] = try await client
                .from("recipes").select().order("created_at", ascending: false).execute().value
            self.recipes = fetchedRecipes
        } catch {
            print("Error fetching user recipes: \(error)")
        }
    }
    
    // MARK: - Supabase: Create Recipe
    func createRecipe(title: String, prepTime: Int, cookTime: Int, uiImage: UIImage?) async {
        guard let userId = client.auth.currentUser?.id else { return }
        var imageURL: String? = nil
        
        if let uiImage = uiImage, let imageData = uiImage.jpegData(compressionQuality: 0.5) {
            let fileName = "\(userId)/\(UUID().uuidString).jpg"
            try? await client.storage.from("images").upload(fileName, data: imageData, options: FileOptions(contentType: "image/jpeg"))
            if let publicURL = try? client.storage.from("images").getPublicURL(path: fileName) {
                imageURL = publicURL.absoluteString
            }
        }
        
        struct InsertRecipe: Encodable {
            let user_id: UUID; let title: String; let prep_time_minutes: Int; let cook_time_minutes: Int; let image_url: String?
        }
        
        let newRecipe = InsertRecipe(user_id: userId, title: title, prep_time_minutes: prepTime, cook_time_minutes: cookTime, image_url: imageURL)
        
        try? await client.from("recipes").insert(newRecipe).execute()
        await fetchRecipes()
    }
}

extension String {
    func strippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
