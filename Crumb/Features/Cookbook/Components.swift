//
//  Components.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

// MARK: - Recipe List Card (Horizontal Layout)
struct RecipeListCard: View {
    let recipe: RecipeModel
    
    // Helper to safely get total time
    var totalTime: Int {
        return (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0)
    }
    
    // Calculate Difficulty
    var difficulty: String {
        return totalTime > 60 ? "Expert" : (totalTime > 30 ? "Medium" : "Easy")
    }
    
    var difficultyColor: Color {
        return totalTime > 60 ? .terracotta : (totalTime > 30 ? .golden : .sageGreen)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Image
            if let urlString = recipe.imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(20)
                .clipped()
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(recipe.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.forestGreen)
                    .lineLimit(1)
                
                // Metadata Row
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text("\(totalTime) min") // Uses the safe helper
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.caption2)
                        Text(difficulty)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(difficultyColor)
                }
                
                Spacer()
                
                // Start Bake Button
                HStack {
                    Image(systemName: "play.fill")
                        .font(.caption)
                    Text("Start Bake")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.forestGreen)
                .cornerRadius(20)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Small Recipe Card (Vertical Layout)
struct SmallRecipeCard: View {
    let recipe: RecipeModel
    let color: Color
    
    // NEW: Pass the saved state and action from the parent
    var isSaved: Bool
    var onToggleSave: () -> Void
    
    private var difficulty: String {
        let time = recipe.prepTime ?? 0
        if time == 0 { return "Unknown" }
        if time <= 30 { return "Easy" }
        if time <= 90 { return "Medium" }
        return "Hard"
    }
    
    private var formattedTime: String {
        let minutes = recipe.prepTime ?? 0
        if minutes == 0 { return "-- min" }
        if minutes < 60 { return "\(minutes) min" }
        else {
            let hours = minutes / 60
            let rem = minutes % 60
            return rem == 0 ? "\(hours) hr" : "\(hours)h \(rem)m"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Image Logic
                if let urlString = recipe.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image): image.resizable().scaledToFill()
                        case .failure: Color.gray.opacity(0.3)
                        case .empty: Color.gray.opacity(0.1)
                        @unknown default: Color.gray
                        }
                    }
                    .frame(width: 160, height: 200)
                    .cornerRadius(16)
                    .clipped()
                } else {
                    Color.white.opacity(0.6)
                        .frame(width: 160, height: 200)
                        .cornerRadius(16)
                        .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray.opacity(0.3)))
                }
                
                // NEW: Working Heart Button
                Button(action: onToggleSave) {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .font(.caption)
                                .foregroundColor(isSaved ? .red : color)
                        )
                }
                .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.forestGreen)
                    .lineLimit(1)
                
                Text("\(formattedTime) • \(difficulty)")
                    .font(.caption)
                    .foregroundColor(.mediumGray)
            }
            .frame(width: 160, alignment: .leading)
        }
    }
}
