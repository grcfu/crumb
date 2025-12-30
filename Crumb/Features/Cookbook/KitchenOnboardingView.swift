//
//  KitchenOnboardingView.swift
//  Crumb
//
//  Created by Grace Fu on 12/27/25.
//

import SwiftUI

struct KitchenOnboardingView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss // To close the sheet
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Background
                Color.cream.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // MARK: - Header
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.lightGray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // MARK: - Hero Content
                    VStack(spacing: 16) {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.forestGreen)
                            .shadow(color: .forestGreen.opacity(0.2), radius: 10, y: 5)
                        
                        Text("Hands-Free\nKitchen Mode")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.forestGreen)
                        
                        Text("Keep your screen clean! Just speak to Crumb to navigate your recipe.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.mediumGray)
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                    }
                    
                    // MARK: - Command Guide
                    VStack(spacing: 20) {
                        CommandRow(icon: "arrow.right.circle.fill", command: "Next", description: "Go to the next step")
                        CommandRow(icon: "arrow.left.circle.fill", command: "Back", description: "Go to previous step")
                        CommandRow(icon: "speaker.wave.2.circle.fill", command: "Read", description: "Read step out loud")
                        CommandRow(icon: "hand.raised.circle.fill", command: "Stop", description: "Stop speaking")
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // MARK: - Start Button
                    NavigationLink(destination: KitchenModeView(recipe: recipe).navigationBarHidden(true)) {
                        HStack {
                            Text("I'm Ready, Chef")
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.forestGreen)
                        .cornerRadius(30)
                        .shadow(color: .forestGreen.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// Helper Row Component
struct CommandRow: View {
    let icon: String
    let command: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.terracotta)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\"\(command)\"")
                    .font(.headline)
                    .foregroundColor(.forestGreen)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.lightGray)
            }
            Spacer()
        }
    }
}
