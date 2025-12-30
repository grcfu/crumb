//
//  SplashScreenView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isActive: Bool
    @State private var progress: CGFloat = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var subheadlineOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background color
            Color.cream.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // CENTERED BRANDING
                VStack(spacing: 4) { // Tighter spacing for a logo lockup feel
                    Text("crumb")
                        .font(.system(size: 80, weight: .heavy, design: .serif)) // Serif font for that bakery feel
                        .foregroundColor(.forestGreen)
                        .tracking(-3) // Tight tracking makes it look like a custom logo
                        .opacity(textOpacity)
                        .scaleEffect(textOpacity) // Subtle scale-in effect
                    
                    Text("The messy part, managed.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.terracotta) // Accent color for the tagline
                        .tracking(1.5) // Wide tracking for elegance
                        .opacity(subheadlineOpacity)
                        .padding(.top, 4)
                }
                .padding(.bottom, 60) // Visual center adjustment
                
                Spacer()
                
                // Minimalist Rising Bar at the Bottom
                VStack(spacing: 12) {
                    // Status Text
                    HStack {
                        Image(systemName: "oven.fill")
                            .font(.caption)
                            .foregroundColor(.forestGreen.opacity(0.6))
                        
                        Text("RISING...")
                            .font(.caption)
                            .fontWeight(.black)
                            .tracking(2)
                            .foregroundColor(.forestGreen.opacity(0.6))
                    }
                    .opacity(subheadlineOpacity) // Fade this in with the tagline
                    
                    // The Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Track
                            Capsule()
                                .fill(Color.forestGreen.opacity(0.1))
                                .frame(height: 6)
                            
                            // Progress
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [.terracotta, .terracotta.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geometry.size.width * progress, height: 6)
                                .shadow(color: .terracotta.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 60) // Make the bar narrower than the screen width
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // 1. Animate Main Logo ("crumb")
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                textOpacity = 1.0
            }
            
            // 2. Animate Tagline & Loading Text slightly later
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                subheadlineOpacity = 1.0
            }
            
            // 3. Animate Progress Bar smoothly
            withAnimation(.easeInOut(duration: 2.5).delay(0.1)) {
                progress = 1.0
            }
            
            // 4. Transition to Main App
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    SplashScreenView(isActive: .constant(true))
}
#endif
