//
//  VictoryView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI
import PhotosUI // Needed for photo picker

struct VictoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeManager: RecipeManager // <--- CONNECTED TO DATA
    
    // Form State
    @State private var rating: Int = 4
    @State private var difficulty: Double = 0.5
    @State private var notes: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2).foregroundColor(.lightGray)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        Text("Fresh out\nof the oven!")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .multilineTextAlignment(.center).foregroundColor(.forestGreen)
                        Text("Great job! Time to log your bake.")
                            .foregroundColor(.mediumGray)
                    }
                    
                    // Photo Upload Card
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 320)
                                    .clipped()
                                    .cornerRadius(30)
                            } else {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.warmBeige.opacity(0.5))
                                    .frame(height: 320)
                                    .overlay(
                                        VStack(spacing: 12) {
                                            Image(systemName: "camera.fill").font(.system(size: 40)).foregroundColor(.forestGreen)
                                            Text("Snap the Crumb Shot").font(.headline).foregroundColor(.forestGreen)
                                            Text("TAP TO UPLOAD").font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                                        }
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
                    }
                    
                    // Rating
                    VStack(spacing: 12) {
                        HStack {
                            Text("How did it taste?").fontWeight(.bold).foregroundColor(.forestGreen)
                            Spacer()
                            Text("\(rating)/5 Crumbs").font(.caption).foregroundColor(.terracotta)
                        }
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .font(.title2).foregroundColor(.terracotta)
                                    .onTapGesture { rating = index }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Difficulty Slider
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Difficulty Level").fontWeight(.bold).foregroundColor(.forestGreen)
                        Slider(value: $difficulty).tint(.forestGreen)
                        HStack {
                            Text("EASY PEASY").font(.caption2).foregroundColor(.mediumGray)
                            Spacer()
                            Text("A REAL SWEAT").font(.caption2).foregroundColor(.mediumGray)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Baker's Notes").fontWeight(.bold).foregroundColor(.forestGreen)
                        
                        // FIX: Updated to use $notes and proper placeholder styling
                        TextField("", text: $notes, prompt: Text("Any tweaks for next time?").foregroundColor(.forestGreen.opacity(0.5)))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .foregroundColor(.forestGreen)
                    }
                    .padding(.horizontal, 24)
                    
                    // Save Button
                    Button(action: saveToJournal) {
                        HStack {
                            Text("Save to Journal")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.forestGreen).cornerRadius(25)
                    }
                    .padding(24)
                }
                .padding(.top, 20)
            }
        }
    }
    
    // THE UPDATED SAVE FUNCTION
    func saveToJournal() {
        print("Saving to journal...")
        
        // 1. Save data to the shared manager
        recipeManager.addBake(
            name: "My Latest Bake",
            image: selectedImage,
            rating: rating,
            notes: notes
        )
        
        // 2. Switch Tab to Journal
        TabManager.shared.selectedTab = .journal
        
        // 3. Tell ExploreView to close all sheets (Detail, Kitchen, etc.)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            TabManager.shared.shouldDismissSheets = true
        }
    }
}
