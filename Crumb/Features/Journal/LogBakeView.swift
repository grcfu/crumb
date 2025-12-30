//
//  LogBakeView.swift
//  Crumb
//
//  Created by Grace Fu on 12/27/25.
//

import SwiftUI
import PhotosUI

struct LogBakeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeManager: RecipeManager
    
    // Form State
    @State private var recipeName = ""
    @State private var notes = ""
    @State private var rating = 0
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    // Animation for rating
    @State private var starScale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background Texture
                Color.cream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: - Header
                        VStack(spacing: 8) {
                            Text("New Entry")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(.forestGreen)
                            
                            Text("Document your latest creation.")
                                .font(.subheadline)
                                .foregroundColor(.mediumGray)
                        }
                        .padding(.top, 20)
                        
                        // MARK: - 1. Hero Photo Picker (Polaroid Style)
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 280)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(24)
                                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                                        .overlay(
                                            // Edit Badge
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .shadow(radius: 4)
                                                .padding(16),
                                            alignment: .topTrailing
                                        )
                                } else {
                                    // Empty State - "Dashed Card"
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.white)
                                        
                                        RoundedRectangle(cornerRadius: 24)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                                            .foregroundColor(.terracotta.opacity(0.4))
                                        
                                        VStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.terracotta.opacity(0.1))
                                                .frame(width: 70, height: 70)
                                                .overlay(
                                                    Image(systemName: "camera.fill")
                                                        .font(.title)
                                                        .foregroundColor(.terracotta)
                                                )
                                            
                                            Text("Add a Photo")
                                                .font(.headline)
                                                .foregroundColor(.terracotta)
                                        }
                                    }
                                    .frame(height: 250)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    withAnimation(.spring()) {
                                        selectedImage = uiImage
                                    }
                                }
                            }
                        }
                        
                        // MARK: - 2. Details Card
                        VStack(spacing: 24) {
                            
                            // Recipe Name Input
                            VStack(alignment: .leading, spacing: 10) {
                                Label("THE RECIPE", systemImage: "pencil.line")
                                    .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                                
                                TextField("", text: $recipeName, prompt: Text("e.g. Grandma's Sourdough").foregroundColor(.forestGreen.opacity(0.3))) // <--- FIX IS HERE
                                    .padding()
                                    .font(.system(size: 18, weight: .medium, design: .serif))
                                    .foregroundColor(.forestGreen)
                                    .background(Color.warmBeige.opacity(0.3))
                                    .cornerRadius(12)
                            }
                            
                            // Rating Input
                            VStack(spacing: 12) {
                                Text("HOW WAS IT?")
                                    .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                                
                                HStack(spacing: 16) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .font(.system(size: 32))
                                            .foregroundColor(star <= rating ? .golden : .lightGray.opacity(0.5))
                                            .scaleEffect(star == rating ? starScale : 1.0)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                                    rating = star
                                                    starScale = 1.3
                                                }
                                                // Reset bounce
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation { starScale = 1.0 }
                                                }
                                            }
                                    }
                                }
                            }
                            
                            // Notes Input
                            VStack(alignment: .leading, spacing: 10) {
                                Label("BAKER'S NOTES", systemImage: "note.text")
                                    .font(.caption).fontWeight(.bold).foregroundColor(.mediumGray)
                                
                                TextEditor(text: $notes)
                                    .scrollContentBackground(.hidden) // Removes default gray background
                                    .foregroundColor(.forestGreen) // Dark text for visibility
                                    .padding(8)
                                    .frame(height: 120)
                                    .background(Color.warmBeige.opacity(0.3))
                                    .cornerRadius(12)
                                    .overlay(
                                        Text(notes.isEmpty ? "What went well? What would you change?" : "")
                                            .foregroundColor(.mediumGray.opacity(0.5))
                                            .padding(.top, 16)
                                            .padding(.leading, 12)
                                            .allowsHitTesting(false), // Let clicks pass through to editor
                                        alignment: .topLeading
                                    )
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
                        .padding(.horizontal, 24)
                        
                        // MARK: - 3. Save Button
                        Button(action: saveBake) {
                            Text("Log to Journal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    recipeName.isEmpty ? Color.gray.opacity(0.3) : Color.forestGreen
                                )
                                .cornerRadius(20)
                                .shadow(color: recipeName.isEmpty ? .clear : .forestGreen.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(recipeName.isEmpty)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.mediumGray)
                }
            }
        }
    }
    
    func saveBake() {
        recipeManager.addBake(name: recipeName, image: selectedImage, rating: rating, notes: notes)
        dismiss()
    }
}
