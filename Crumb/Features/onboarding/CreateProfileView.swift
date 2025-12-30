//
//  CreateProfileView.swift
//  Crumb
//
//  Created by Grace Fu on 12/26/25.
//

import SwiftUI
import PhotosUI
import Supabase

struct CreateProfileView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // CHANGED: We accept this binding to control the "Back" navigation
    @Binding var isQuizComplete: Bool
    
    @State private var fullName = ""
    @State private var username = ""
    @State private var bio = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                EditProfileBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // NEW: Custom Nav Bar with Back Button
                        HStack {
                            Button(action: {
                                withAnimation {
                                    isQuizComplete = false // <--- THIS SENDS USER BACK TO QUIZ
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.left")
                                    Text("Back")
                                }
                                .foregroundColor(.terracotta)
                                .fontWeight(.medium)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Header
                        VStack(spacing: 8) {
                            Text("One Last Step!")
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(.forestGreen)
                            
                            Text("Create your baker identity.")
                                .font(.subheadline)
                                .foregroundColor(.terracotta)
                        }
                        
                        // Photo Picker
                        profilePhotoSection
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            CustomTextField(title: "Full Name", text: $fullName, icon: "person.fill")
                            CustomTextField(title: "Username", text: $username, icon: "at")
                            CustomBioField(title: "Bio (Optional)", text: $bio, icon: "text.quote")
                        }
                        .padding(.horizontal, 24)
                        
                        // Big Action Button
                        Button(action: { finishSetup() }) {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text("Start Baking")
                                    .font(.headline).fontWeight(.bold).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding()
                                    .background(isValid() ? Color.forestGreen : Color.gray.opacity(0.5))
                                    .cornerRadius(16)
                                    .shadow(color: isValid() ? Color.forestGreen.opacity(0.3) : .clear, radius: 10, y: 5)
                            }
                        }
                        .disabled(!isValid() || isSaving)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
    
    func isValid() -> Bool { return !fullName.isEmpty && !username.isEmpty }
    
    // MARK: - Save Logic
    func finishSetup() {
        isSaving = true
        
        Task {
            // 1. Get current user ID
            guard let userId = AppManager.shared.client.auth.currentUser?.id else {
                print("🚨 No user logged in! Skipping save.")
                await MainActor.run {
                    isSaving = false
                    hasCompletedOnboarding = true // Let them in anyway
                }
                return
            }
            
            // 2. Upload Image (Optional)
            var avatarURL: String? = nil
            if let selectedImage, let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                let fileName = "\(userId)/avatar.jpg"
                do {
                    try await AppManager.shared.client.storage.from("images").upload(fileName, data: imageData, options: FileOptions(upsert: true))
                    let url = try AppManager.shared.client.storage.from("images").getPublicURL(path: fileName)
                    avatarURL = url.absoluteString
                } catch {
                    print("⚠️ Image upload failed (Check Storage Policies): \(error)")
                }
            }
            
            // 3. Update Profile in Database
            struct UpdateProfile: Encodable {
                let id: UUID // Include ID for upsert
                let full_name: String
                let username: String
                let bio: String
                let avatar_url: String?
            }
            
            let updateData = UpdateProfile(
                id: userId, // CRITICAL: Link data to the user ID
                full_name: fullName,
                username: username,
                bio: bio,
                avatar_url: avatarURL
            )
            
            do {
                // CHANGED: Use .upsert() instead of .update()
                // This creates the row if it doesn't exist, or updates it if it does.
                try await AppManager.shared.client
                    .from("profiles")
                    .upsert(updateData)
                    .execute()
                
                print("✅ Profile Setup Complete!")
                
            } catch {
                print("🚨 Database Error (Check Table/RLS Policies): \(error)")
                // We continue anyway so you aren't locked out of the app
            }
            
            // 4. TRANSITION TO MAIN APP (Happens regardless of success/fail now)
            await MainActor.run {
                isSaving = false
                hasCompletedOnboarding = true
            }
        }
    }
    
    // Reuse Photo Section
    private var profilePhotoSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack {
                    if let selectedImage {
                        Image(uiImage: selectedImage).resizable().scaledToFill()
                            .frame(width: 120, height: 120).clipShape(Circle())
                    } else {
                        ZStack {
                            Circle().fill(Color.white)
                            Image(systemName: "person.fill").font(.system(size: 60)).foregroundColor(.sageGreen)
                        }.frame(width: 120, height: 120)
                    }
                    Circle().strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 6])).foregroundColor(.terracotta).frame(width: 130, height: 130)
                    Circle().fill(Color.forestGreen).frame(width: 36, height: 36)
                        .overlay(Image(systemName: "camera.fill").foregroundColor(.white).font(.caption))
                        .offset(x: 40, y: 40).shadow(radius: 4)
                }
            }
            Text("Add Photo").font(.caption).fontWeight(.bold).foregroundColor(.terracotta)
        }
    }
}
