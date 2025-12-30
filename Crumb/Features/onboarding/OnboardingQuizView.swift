//
//  OnboardingQuizView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct OnboardingQuizView: View {
    // We accept a binding to tell RootView we are done
    @Binding var isQuizComplete: Bool
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var currentStep = 1
    @State private var selectedType: String? = "Precision"
    @State private var selectedDiet: [String] = ["Gluten-Free"]
    @State private var otherDiet = ""
    
    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - Header Nav
                HStack {
                    // Back Button (Handles Step Back OR Sign Out)
                    Button(action: {
                        if currentStep > 1 {
                            withAnimation { currentStep -= 1 }
                        } else {
                            // If on Step 1, "Back" means Sign Out (Return to Welcome)
                            Task {
                                await authVM.signOut()
                            }
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.forestGreen)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    // Step Indicator
                    HStack(spacing: 4) {
                        Text("STEP \(currentStep) OF 2")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.lightGray)
                        
                        Capsule()
                            .fill(Color.sageGreen)
                            .frame(width: 40, height: 4)
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Content Switcher
                if currentStep == 1 {
                    bakerTypeStep
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    dietaryStep
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
                
                Spacer()
                
                // MARK: - Bottom Action Bar
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            if currentStep < 2 {
                                currentStep += 1
                            } else {
                                // ACTION: Tell RootView the quiz is done!
                                // RootView will automatically switch to CreateProfileView
                                isQuizComplete = true
                            }
                        }
                    }) {
                        HStack {
                            Text(currentStep == 2 ? "Create Profile" : "Next Step")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(currentStep == 2 ? .white : .forestGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(currentStep == 2 ? Color.forestGreen : Color.sageGreen.opacity(0.3))
                        .cornerRadius(25)
                    }
                    
                    Button("Skip") {
                        // Skip straight to profile creation
                        withAnimation { isQuizComplete = true }
                    }
                    .font(.footnote)
                    .foregroundColor(.mediumGray)
                }
                .padding(24)
            }
        }
    }
    
    // MARK: - Step 1: Baker Type
    var bakerTypeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What kind of\nbaker are you?")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.forestGreen)
            
            Text("Help us customize your kitchen experience.")
                .foregroundColor(.mediumGray)
            
            VStack(spacing: 16) {
                OptionCard(title: "Casual", subtitle: "I bake for fun and treats.", icon: "carrot.fill", isSelected: selectedType == "Casual") { selectedType = "Casual" }
                
                OptionCard(title: "Precision", subtitle: "I measure everything to the gram.", icon: "scalemass", isSelected: selectedType == "Precision") { selectedType = "Precision" }
                
                OptionCard(title: "Chaos", subtitle: "I trust my gut and hope for the best.", icon: "tornado", isSelected: selectedType == "Chaos") { selectedType = "Chaos" }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Step 2: Dietary
    var dietaryStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Any dietary\nrestrictions?")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.forestGreen)
            
            Text("Select all that apply. We'll customize your challenges and recipe feed.")
                .foregroundColor(.mediumGray)
            
            // Tag Cloud
            WrappingHStack {
                ForEach(["Gluten-Free", "Vegan", "Vegetarian", "Nut Allergy", "Dairy-Free", "Keto", "Paleo", "Egg-Free", "None"], id: \.self) { diet in
                    DietTag(text: diet, isSelected: selectedDiet.contains(diet)) {
                        if selectedDiet.contains(diet) {
                            selectedDiet.removeAll(where: { $0 == diet })
                        } else {
                            selectedDiet.append(diet)
                        }
                    }
                }
            }
            
            // Other Input
            VStack(alignment: .leading, spacing: 8) {
                Text("OTHER RESTRICTIONS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.mediumGray)
                
                ZStack(alignment: .leading) {
                    if otherDiet.isEmpty {
                        Text("e.g. Shellfish, Soy...")
                            .foregroundColor(.forestGreen.opacity(0.6))
                            .padding(.leading, 16)
                    }
                    TextField("", text: $otherDiet)
                        .padding()
                        .foregroundColor(.forestGreen)
                }
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - HELPER COMPONENTS

struct OptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.forestGreen : Color.white)
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .white : .forestGreen)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.forestGreen)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.mediumGray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.forestGreen)
                        .font(.title2)
                } else {
                    Circle()
                        .stroke(Color.lightGray.opacity(0.5), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding()
            .background(isSelected ? Color.sageGreen.opacity(0.3) : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.forestGreen : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct DietTag: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.sageGreen : Color.white)
                .foregroundColor(isSelected ? .forestGreen : .mediumGray)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.forestGreen : Color.clear, lineWidth: 1)
                )
        }
        .padding(4)
    }
}

// Simple Layout Helper for Tags
struct WrappingHStack<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
            content
        }
    }
}
