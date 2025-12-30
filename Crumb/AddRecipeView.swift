//
//  AddRecipeView.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    @Environment(\.dismiss) var dismiss
    
    // Form Fields
    @State private var title = ""
    @State private var prepTime = ""
    @State private var cookTime = ""
    
    // Image Picking
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    // Loading State
    @State private var isUploading = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 1. PHOTO SECTION
                Section {
                    HStack {
                        Spacer()
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1)) // Changed to standard green if sageGreen isn't global
                                .frame(width: 150, height: 150)
                                .overlay(
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.title)
                                            .foregroundColor(.green)
                                        Text("Add Photo")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                )
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .overlay(
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Color.clear // Invisible clickable area covering the whole row
                        }
                    )
                }
                
                // 2. DETAILS SECTION
                Section(header: Text("Recipe Details")) {
                    TextField("Recipe Title (e.g., Sourdough)", text: $title)
                    
                    HStack {
                        Text("Prep Time (min)")
                        Spacer()
                        TextField("0", text: $prepTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Cook Time (min)")
                        Spacer()
                        TextField("0", text: $cookTime)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("New Bake")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveRecipe()
                        }
                        .disabled(title.isEmpty)
                    }
                }
            }
            // Logic to load image from gallery when picked
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
    
    func saveRecipe() {
        isUploading = true
        Task {
            // Convert Strings to Ints (default to 0 if empty)
            let prepInt = Int(prepTime) ?? 0
            let cookInt = Int(cookTime) ?? 0
            
            // Call Manager
            await recipeManager.createRecipe(
                title: title,
                prepTime: prepInt,
                cookTime: cookInt,
                uiImage: selectedImage
            )
            
            isUploading = false
            dismiss()
        }
    }
}
