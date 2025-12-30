//
//  ChallengeDetailView.swift
//  Crumb
//
//  Created by Grace Fu on 12/25/25.
//

import SwiftUI

struct ChallengeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showSubmission = false
    
    // Bindings for the timer (received from CommunityView)
    @Binding var days: Int
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - 1. Hero Header (No Image)
                ZStack(alignment: .topLeading) {
                    
                    // Simple Gradient Background
                    LinearGradient(
                        colors: [Color.forestGreen, Color.sageGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 320)
                    
                    // Icon Pattern Overlay (Optional, adds texture)
                    GeometryReader { geo in
                        Image(systemName: "laurel.leading")
                            .font(.system(size: 200))
                            .foregroundColor(.white.opacity(0.1))
                            .position(x: geo.size.width * 0.8, y: geo.size.height * 0.6)
                            .rotationEffect(.degrees(15))
                    }
                    .frame(height: 320)
                    
                    // Back Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Material.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.top, 60)
                    .padding(.leading, 24)
                    
                    // Difficulty Badge
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                            Text("HARD")
                        }
                        .font(.caption).fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.terracotta)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 24)
                }
                
                // MARK: - 2. Content Card
                VStack(spacing: 32) {
                    
                    // Title & Stats
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("The Sourdough Starter")
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(.forestGreen)
                            
                            Text("Master the art of wild yeast. Create your own starter from scratch and bake the perfect loaf.")
                                .font(.body)
                                .foregroundColor(.mediumGray)
                                .lineSpacing(4)
                        }
                        
                        // Participants & XP
                        HStack {
                            HStack(spacing: -12) {
                                ForEach(0..<3) { i in
                                    Circle()
                                        .fill(Color.sageGreen.opacity(0.5))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Text(String("ABC".prefix(i+1).suffix(1)))
                                                .font(.caption).fontWeight(.bold).foregroundColor(.white)
                                        )
                                        .overlay(Circle().stroke(Color.cream, lineWidth: 3))
                                }
                            }
                            
                            Text("1,240 joined")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.mediumGray)
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.golden)
                                Text("500 XP")
                                    .fontWeight(.bold)
                                    .foregroundColor(.forestGreen)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.golden.opacity(0.15))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Timer Card (Connected to Live Data)
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.terracotta)
                            Text("TIME REMAINING")
                                .font(.caption).fontWeight(.bold)
                                .tracking(1)
                                .foregroundColor(.terracotta)
                            Spacer()
                        }
                        
                        HStack(spacing: 0) {
                            countdownItem(value: String(format: "%02d", days), label: "DAYS")
                            divider
                            countdownItem(value: String(format: "%02d", hours), label: "HRS")
                            divider
                            countdownItem(value: String(format: "%02d", minutes), label: "MINS")
                            divider
                            countdownItem(value: String(format: "%02d", seconds), label: "SECS")
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    
                    // Rules Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Requirements")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(.forestGreen)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ruleRow(icon: "leaf.fill", title: "No Commercial Yeast", subtitle: "Must use wild yeast only.")
                            ruleRow(icon: "camera.fill", title: "The Crumb Shot", subtitle: "Upload a clear photo of the interior texture.")
                            ruleRow(icon: "clock.fill", title: "Submit on Time", subtitle: "Late entries ineligible for badges.")
                        }
                    }
                    
                    // Join Button
                    Button(action: { showSubmission = true }) {
                        Text("Join Challenge")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.forestGreen)
                            .cornerRadius(25)
                            .shadow(color: .forestGreen.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(Color.cream)
                .cornerRadius(30)
                .offset(y: -40) // Card overlap effect
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.cream)
        .toolbar(.hidden)
        .sheet(isPresented: $showSubmission) {
            ChallengeSubmissionView()
        }
    }
    
    // MARK: - Helper Views
    
    private var divider: some View {
        Rectangle()
            .fill(Color.lightGray.opacity(0.3))
            .frame(width: 1, height: 40)
    }
    
    private func countdownItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.forestGreen)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.mediumGray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func ruleRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                
                Image(systemName: icon)
                    .foregroundColor(.terracotta)
                    .font(.subheadline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.forestGreen)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.mediumGray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#if DEBUG
#Preview {
    ChallengeDetailView(days: .constant(2), hours: .constant(14), minutes: .constant(30), seconds: .constant(0))
}
#endif
