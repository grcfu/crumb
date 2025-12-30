//
//  RecipeModels.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import Foundation

// MARK: - 1. The Master Model
struct RecipeModel: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let prepTime: Int?      // API gives "ReadyInMinutes"
    let cookTime: Int?      // We default this to 0 for API
    let servings: Int?      // Used by DetailView scaling
    let imageUrl: String?
    
    // Both Database and API will map to these
    let ingredients: [Ingredient]
    let steps: [Step]       // KitchenMode needs this specifically
    
    // Helper: If something asks for "instructions" (string list), we generate it from steps
    var instructions: [String] {
        return steps.map { $0.instruction }
    }
}

// MARK: - 2. The Magic Fix (Typealias)
// This tells Xcode: "Whenever you see 'Recipe' in the old files, use 'RecipeModel' instead."
typealias Recipe = RecipeModel

// MARK: - 3. Sub-Models
struct Ingredient: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let name: String
    let amount: Double
    let unit: String
}

struct Step: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let orderIndex: Int
    let instruction: String
}
