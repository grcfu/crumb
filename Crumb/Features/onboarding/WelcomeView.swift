//
//  WelcomeView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct WelcomeView: View {
    // FIXED: Renamed from 'showQuiz' to 'showSignUp' to match RootView
    @Binding var showSignUp: Bool
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color.cream, Color.forestGreen.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Icon Card
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .frame(width: 300, height: 300)
                    .overlay(
                        Image(systemName: "camera.macro")
                            .font(.system(size: 80))
                            .foregroundColor(.lightGray)
                    )
                    .rotationEffect(.degrees(-5))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                Spacer()
                
                // Bottom Section
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Let's Get Baking")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.forestGreen)
                        
                        Text("Your digital sourdough starter.\nBake, track, and connect.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.mediumGray)
                            .padding(.horizontal, 20)
                    }
                    
                    // FIXED: Button now toggles showSignUp
                    Button(action: {
                        showSignUp = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Get Started")
                        }
                        .font(.headline)
                        .foregroundColor(.forestGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.forestGreen.opacity(0.1))
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                }
                .padding(.top, 40)
                .background(Color.cream.opacity(0.9))
                .cornerRadius(40)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
