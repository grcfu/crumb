//
//  EditProfileView.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    // Form States (In a real app, these would load from Supabase initially)
    @State private var fullName = "Grace Fu"
    @State private var username = "gracebakes"
    @State private var bio = "Sourdough enthusiast & weekend patissier."
    
    // Photo Picker States
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background
                EditProfileBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 2. Custom Navbar
                    HStack {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.terracotta)
                        Spacer()
                        Text("Edit Profile")
                            .font(.headline)
                            .foregroundColor(.forestGreen)
                        Spacer()
                        Button("Done") {
                            // TODO: Save to Supabase here
                            dismiss()
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.forestGreen)
                    }
                    .padding()
                    .background(Color.cream.opacity(0.9)) // Slight blur effect behind nav
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            
                            // 3. Profile Photo Picker
                            profilePhotoSection
                            
                            // 4. Form Fields
                            VStack(spacing: 20) {
                                CustomTextField(title: "Full Name", text: $fullName, icon: "person.fill")
                                CustomTextField(title: "Username", text: $username, icon: "at")
                                CustomBioField(title: "Bio", text: $bio, icon: "text.quote")
                            }
                            .padding(.horizontal, 24)
                            
                            // 5. Aesthetic Footer
                            VStack(spacing: 8) {
                                Image(systemName: "laurel.leading")
                                    .font(.title)
                                    .foregroundColor(.terracotta.opacity(0.5))
                                Text("Level 5 Baker")
                                    .font(.caption)
                                    .foregroundColor(.forestGreen.opacity(0.6))
                                    .tracking(2)
                            }
                            .padding(.top, 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        // Logic to load image when picked
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
    
    // MARK: - Photo Section
    private var profilePhotoSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    // The Image
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        // Placeholder
                        ZStack {
                            Circle()
                                .fill(Color.white)
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.sageGreen)
                        }
                        .frame(width: 120, height: 120)
                    }
                    
                    // The "Stitched" Border
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                        .foregroundColor(.terracotta)
                        .frame(width: 130, height: 130)
                    
                    // The Camera Icon Badge
                    Circle()
                        .fill(Color.forestGreen)
                        .frame(width: 36, height: 36)
                        .overlay(Image(systemName: "camera.fill").foregroundColor(.white).font(.caption))
                        .background(Circle().stroke(Color.cream, lineWidth: 3)) // Border to separate from image
                        .offset(x: 40, y: 40)
                        .shadow(radius: 4)
                }
            }
            
            Text("Change Photo")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.terracotta)
        }
    }
}

// MARK: - CUSTOM COMPONENTS (Aesthetic Inputs)

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.terracotta)
                .tracking(1)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.forestGreen.opacity(0.6))
                    .frame(width: 20)
                
                TextField(title, text: $text)
                    .foregroundColor(.forestGreen)
                    .accentColor(.terracotta)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

struct CustomBioField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.terracotta)
                .tracking(1)
            
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .foregroundColor(.forestGreen.opacity(0.6))
                    .frame(width: 20)
                    .padding(.top, 6)
                
                TextEditor(text: $text)
                    .frame(height: 100)
                    .scrollContentBackground(.hidden) // Removes default gray background
                    .foregroundColor(.forestGreen)
                    .accentColor(.terracotta)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

// MARK: - BACKGROUND (Reused but slightly simpler)
struct EditProfileBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.cream
                
                // Dot Grid
                DotGrid(spacing: 30)
                    .fill(Color.terracotta.opacity(0.1))
                
                // Static Watermarks (Faded)
                ZStack {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 250))
                        .foregroundColor(.forestGreen.opacity(0.03))
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                        .rotationEffect(.degrees(15))
                    
                    Image(systemName: "signature")
                        .font(.system(size: 180))
                        .foregroundColor(.terracotta.opacity(0.04))
                        .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.8)
                        .rotationEffect(.degrees(-10))
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
}
