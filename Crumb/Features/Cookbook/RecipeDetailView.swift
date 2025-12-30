//
//  RecipeDetailView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecipeModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showKitchenMode = false
    @State private var currentScale: Double = 1.0
    let scaleOptions: [Double] = [0.5, 1.0, 2.0, 3.0]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - HERO IMAGE SECTION
                    ZStack(alignment: .topLeading) {
                        GeometryReader { geo in
                            if let urlString = recipe.imageUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .clipped()
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.2))
                                }
                            } else {
                                Rectangle().fill(Color.forestGreen.opacity(0.3))
                            }
                        }
                        .frame(height: 350) // Fixed height for hero image
                        
                        // Gradient
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 350)
                        
                        // Back Button
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(radius: 4)
                        }
                        .padding(.top, 50)
                        .padding(.leading, 24)
                        
                        // Title & Info
                        VStack(alignment: .leading, spacing: 8) {
                            Spacer() // Pushes content to bottom
                            Text(recipe.title)
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            HStack {
                                Label("\(recipe.prepTime ?? 0)m prep", systemImage: "clock")
                                Text("•")
                                Label("\(recipe.servings ?? 4) servings", systemImage: "person.2")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(24)
                        .frame(height: 350) // Matches container height
                    }
                    
                    // MARK: - CONTENT SECTION
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Portion Scaler
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PORTION SIZE").font(.caption).fontWeight(.bold).foregroundColor(.lightGray)
                            
                            HStack(spacing: 0) {
                                ForEach(scaleOptions, id: \.self) { scale in
                                    Button(action: { withAnimation { currentScale = scale } }) {
                                        Text(scale == 0.5 ? "½x" : "\(Int(scale))x")
                                            .font(.subheadline).fontWeight(.bold)
                                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                                            .background(currentScale == scale ? Color.forestGreen : Color.clear)
                                            .foregroundColor(currentScale == scale ? .white : .forestGreen)
                                    }
                                }
                            }
                            .background(Color.forestGreen.opacity(0.1)).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.forestGreen, lineWidth: 1))
                        }
                        
                        Divider()
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ingredients").font(.title2).fontWeight(.bold).foregroundColor(.forestGreen)
                            
                            ForEach(recipe.ingredients) { ingredient in
                                HStack(alignment: .top) {
                                    Text(formatAmount(ingredient.amount * currentScale))
                                        .fontWeight(.bold).foregroundColor(.forestGreen)
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Text(ingredient.unit)
                                        .fontWeight(.medium).foregroundColor(.terracotta)
                                        .fixedSize(horizontal: true, vertical: false) // Prevents cutting off
                                    
                                    Text(ingredient.name.capitalized)
                                        .foregroundColor(.mediumGray)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 2)
                                Divider().opacity(0.3)
                            }
                        }
                        
                        // Summary
                        if let description = recipe.description {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Summary")
                                    .font(.title2).fontWeight(.bold).foregroundColor(.forestGreen)
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.mediumGray)
                                    .lineSpacing(6)
                            }
                        }
                        
                        // Start Bake Button
                        Button(action: { showKitchenMode = true }) {
                            HStack {
                                Image(systemName: "oven.fill")
                                Text("Start Kitchen Mode")
                            }
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.forestGreen).cornerRadius(25)
                            .shadow(color: Color.forestGreen.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(24)
                }
            }
            .background(Color.cream.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)
            .fullScreenCover(isPresented: $showKitchenMode) {
                KitchenOnboardingView(recipe: recipe)
            }
        }
    }
    
    func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
